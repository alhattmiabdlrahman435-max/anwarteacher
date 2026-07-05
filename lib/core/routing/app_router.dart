import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/grades/presentation/screens/grades_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/assignments/presentation/screens/assignments_screen.dart';
import '../../features/assignments/presentation/screens/add_assignment_screen.dart';
import '../../features/assignments/presentation/screens/submissions_tracking_screen.dart';
import '../../features/schedule/presentation/screens/schedule_screen.dart';

import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/reports/presentation/screens/reports_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/contact_us_screen.dart';
import '../../features/settings/presentation/screens/about_app_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';

// Assistant Screens
import '../../features/assistant/presentation/screens/assistant_dashboard_screen.dart';
import '../../features/assistant/presentation/screens/assistant_classes_screen.dart';
import '../../features/assistant/presentation/screens/assistant_class_details_screen.dart';
import '../../features/assistant/presentation/screens/assistant_qr_scanner_screen.dart';
import '../../features/assistant/presentation/screens/assistant_attendance_history_screen.dart';
import '../../features/assistant/presentation/screens/assistant_reports_screen.dart';
import '../../features/error/presentation/screens/not_found_screen.dart';

part 'app_router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class RouterTransitionNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterTransitionNotifier(this._ref) {
    _ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}

@riverpod
GoRouter appRouter(Ref ref) {
  final notifier = RouterTransitionNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: notifier,
    errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isLoggedIn;
      final location = state.uri.toString();

      // If not logged in and not on splash/login, go to login
      if (!isLoggedIn && location != '/' && location != '/login') {
        return '/login';
      }

      // If logged in and on splash/login, redirect to correct dashboard
      if (isLoggedIn && (location == '/' || location == '/login')) {
        return authState.role == UserRole.teacher
            ? '/dashboard'
            : '/assistant/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/grades',
        builder: (context, state) => const GradesScreen(),
      ),
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/assignments',
        builder: (context, state) => const AssignmentsScreen(),
      ),
      GoRoute(
        path: '/add_assignment',
        builder: (context, state) => const AddAssignmentScreen(),
      ),
      GoRoute(
        path: '/assignment_submissions/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SubmissionsTrackingScreen(assignmentId: id);
        },
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsListScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings/contact_us',
        builder: (context, state) => const ContactUsScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        builder: (context, state) => const AboutAppScreen(),
      ),
      GoRoute(
        path: '/settings/privacy_policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      // Assistant Flow Routes
      GoRoute(
        path: '/assistant/dashboard',
        builder: (context, state) => const AssistantDashboardScreen(),
      ),
      GoRoute(
        path: '/assistant/classes',
        builder: (context, state) => const AssistantClassesScreen(),
      ),
      GoRoute(
        path: '/assistant/classes/:classId',
        builder: (context, state) {
          final classId = state.pathParameters['classId']!;
          return AssistantClassDetailsScreen(classId: classId);
        },
      ),
      GoRoute(
        path: '/assistant/qr_scan',
        builder: (context, state) => const AssistantQrScannerScreen(),
      ),
      GoRoute(
        path: '/assistant/history',
        builder: (context, state) => const AssistantAttendanceHistoryScreen(),
      ),
      GoRoute(
        path: '/assistant/reports',
        builder: (context, state) => const AssistantReportsScreen(),
      ),
    ],
  );
}
