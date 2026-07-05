import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Requires flutterfire configure)
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

    // Enable foreground notifications presentation options for alerts and sound
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Local notifications configuration for foreground heads-up banner
    final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidNotificationChannel _channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin.initialize(
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

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM Foreground Message: ${message.notification?.title} - ${message.notification?.body}');
      
      final notification = message.notification;
      final android = message.notification?.android;
      final type = message.data['type'] ?? 'attendance';

      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
          ),
          payload: type,
        );
      }
    });

    // Handle background notification clicks
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM Notification clicked from background.');
      final type = message.data['type'] ?? 'attendance';
      if (type == 'weekly_schedule' || type == 'schedule') {
        rootNavigatorKey.currentContext?.push('/schedule');
      } else {
        rootNavigatorKey.currentContext?.push('/notifications');
      }
    });

    // Handle terminated state notification clicks
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
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

    // Retrieve FCM Token and print it
    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint('==================================================');
    debugPrint('FCM Token: $fcmToken');
    debugPrint('==================================================');
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  runApp(const ProviderScope(child: TeacherApp()));
}

class TeacherApp extends ConsumerStatefulWidget {
  const TeacherApp({super.key});

  @override
  ConsumerState<TeacherApp> createState() => _TeacherAppState();
}

class _TeacherAppState extends ConsumerState<TeacherApp> {
  @override
  void initState() {
    super.initState();
    _listenToFcmForDataRefresh();
  }

  void _listenToFcmForDataRefresh() {
    // When a foreground FCM message arrives, invalidate (refresh) the relevant
    // Riverpod provider immediately so the screen shows fresh data automatically.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final type = message.data['type'] ?? '';
      debugPrint('[TeacherApp] FCM data refresh triggered. type=$type');
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
    });

    // Also refresh when tapping from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final type = message.data['type'] ?? '';
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
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: easyLoadingBuilder(context, child),
            );
          },
        );
      },
    );
  }
}
