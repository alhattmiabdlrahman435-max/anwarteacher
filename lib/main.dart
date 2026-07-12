import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'l10n/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/notifications_provider.dart';
import 'core/providers/attendance_provider.dart';
import 'core/providers/assignments_provider.dart';
import 'core/providers/grades_provider.dart';
import 'core/providers/exams_provider.dart';
import 'core/providers/schedule_provider.dart';
import 'core/providers/reports_provider.dart';
import 'core/providers/classes_provider.dart';
import 'core/providers/subjects_provider.dart';
import 'core/widgets/connectivity_overlay.dart';
import 'core/network/pusher_service.dart';
import 'firebase_options.dart';

// Global plugin instance for notifications (used in both main() and TeacherApp).
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel highImportanceChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Request permission for push notifications
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Enable foreground notifications presentation options
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notifications initialization
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('FCM Local Notification clicked: ${response.payload}');
        final payload = response.payload;
        if (payload == 'weekly_schedule' || payload == 'schedule') {
          rootNavigatorKey.currentContext?.push('/schedule');
        } else {
          rootNavigatorKey.currentContext?.push('/notifications');
        }
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highImportanceChannel);

    // Request runtime notification permission on Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Listen to foreground FCM messages to show a local notification banner.
    // NOTE: Data-refresh is handled in TeacherApp to avoid duplicate listeners.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM Foreground Message: ${message.notification?.title}');

      final notification = message.notification;
      final type = message.data['type'] ?? 'attendance';

      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              highImportanceChannel.id,
              highImportanceChannel.name,
              channelDescription: highImportanceChannel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: type,
        );
      }
    });

    // Handle background notification click navigation
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM Notification clicked from background.');
      final type = message.data['type'] ?? 'attendance';
      if (type == 'weekly_schedule' || type == 'schedule') {
        rootNavigatorKey.currentContext?.push('/schedule');
      } else {
        rootNavigatorKey.currentContext?.push('/notifications');
      }
    });

    // Handle terminated state notification click
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('FCM Notification clicked from terminated state.');
      Future.delayed(const Duration(milliseconds: 1500), () {
        final type = initialMessage.data['type'] ?? 'attendance';
        if (type == 'weekly_schedule' || type == 'schedule') {
          rootNavigatorKey.currentContext?.push('/schedule');
        } else {
          rootNavigatorKey.currentContext?.push('/notifications');
        }
      });
    }

    // Log FCM token only in debug mode (security: never expose in production logs)
    if (kDebugMode) {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('==================================================');
      debugPrint('FCM Token: $fcmToken');
      debugPrint('==================================================');
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize Pusher Client connection to Reverb
  PusherService().init();
  PusherService().connect();

  runApp(const ProviderScope(child: TeacherApp()));
}

class TeacherApp extends ConsumerStatefulWidget {
  const TeacherApp({super.key});

  @override
  ConsumerState<TeacherApp> createState() => _TeacherAppState();
}

class _TeacherAppState extends ConsumerState<TeacherApp> with WidgetsBindingObserver {
  // Store subscriptions to cancel them properly and prevent memory leaks.
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenToFcmForDataRefresh();
    // Fetch initial data immediately on launch
    Future.microtask(() => _refreshAllData());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAllData();
    }
  }

  void _refreshAllData() {
    try {
      debugPrint('[TeacherApp] Refreshing all data in background...');
      ref.read(notificationsProvider.notifier).refresh();
      ref.read(assignmentsDataProvider.notifier).refresh();
      ref.read(gradesDataProvider.notifier).refresh();
      ref.read(examsProvider.notifier).refresh();
      ref.read(teacherScheduleStateProvider.notifier).refresh();
      ref.read(reportsProvider.notifier).refresh();
      ref.read(classesProvider.notifier).refresh();
      ref.read(subjectsProvider.notifier).refresh();
    } catch (e) {
      debugPrint('[TeacherApp] Error during background refresh: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _onMessageSub?.cancel();
    _onMessageOpenedAppSub?.cancel();
    super.dispose();
  }

  /// Invalidates the relevant Riverpod provider based on the FCM message type.
  void _invalidateProviderForType(String type) {
    switch (type) {
      case 'attendance':
      case 'absence':
      case 'absence_request':
        ref.invalidate(dailyAttendanceProvider);
        break;
      case 'assignment':
      case 'assignments':
        ref.invalidate(assignmentsDataProvider);
        break;
      case 'grade':
      case 'grades':
        ref.invalidate(gradesDataProvider);
        break;
      case 'exam_schedule':
      case 'exams':
        ref.invalidate(examsProvider);
        break;
      case 'weekly_schedule':
      case 'schedule':
        ref.invalidate(teacherScheduleStateProvider);
        break;
      default:
        ref.invalidate(notificationsProvider);
        break;
    }
  }

  void _listenToFcmForDataRefresh() {
    // Invalidate relevant providers when a foreground FCM message arrives.
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final type = message.data['type'] ?? '';
      debugPrint('[TeacherApp] FCM data refresh triggered. type=$type');
      _invalidateProviderForType(type);
    });

    // Also refresh when tapping from background.
    _onMessageOpenedAppSub =
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final type = message.data['type'] ?? '';
      _invalidateProviderForType(type);
    });
  }
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
          ],
          locale: settings.locale,
          builder: (context, child) {
            final easyLoadingBuilder = EasyLoading.init();
            return ConnectivityOverlay(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: easyLoadingBuilder(context, child),
              ),
            );
          },
        );
      },
    );
  }
}
