import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentRoute = GoRouterState.of(context).uri.toString();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final authState = ref.watch(authProvider);
    final isAssistant = authState.role == UserRole.assistant;

    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final subTextColor = isDark ? Colors.white70 : AppColors.textSecondaryLight;
    final drawerBg = isDark ? AppColors.surfaceAltDark : Colors.white;
    final primaryColor = AppColors.primary;

    final displayName = authState.userName.isNotEmpty
        ? authState.userName
        : (isAssistant ? 'أ. منى الحربي' : context.loc.teacherName);
    
    final roleLabel = isAssistant
        ? context.loc.prepAssistant
        : context.loc.teacherAccount;

    return Drawer(
      elevation: 10,
      backgroundColor: drawerBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Flat edge or rounded
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------------- HEADER ----------------
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 40 + 10,
            ),
            decoration: BoxDecoration(
              color: drawerBg,
              borderRadius: const BorderRadiusDirectional.only(
                bottomEnd: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? Colors.white24
                            : primaryColor.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : primaryColor.withValues(alpha: 0.2),
                      child: Icon(
                        isAssistant ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.person_solid,
                        size: 45,
                        color: isDark ? Colors.white : primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAssistant
                          ? Colors.orange.withValues(alpha: 0.15)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      roleLabel,
                      style: TextStyle(
                        color: isAssistant 
                            ? (isDark ? Colors.orange[300] : Colors.orange[800])
                            : subTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------------- MENU ----------------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              children: isAssistant
                  ? [
                      // Assistant Options
                      _DrawerItem(
                        title: context.loc.home,
                        icon: CupertinoIcons.home,
                        route: '/assistant/dashboard',
                        currentRoute: currentRoute,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () => _navigate(context, currentRoute, '/assistant/dashboard'),
                      ),
                      _DrawerItem(
                        title: context.loc.assistantClasses,
                        icon: CupertinoIcons.group,
                        route: '/assistant/classes',
                        currentRoute: currentRoute,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () => _navigate(context, currentRoute, '/assistant/classes'),
                      ),
                      _DrawerItem(
                        title: context.loc.assistantHistory,
                        icon: CupertinoIcons.calendar_today,
                        route: '/assistant/history',
                        currentRoute: currentRoute,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () => _navigate(context, currentRoute, '/assistant/history'),
                      ),
                      _DrawerItem(
                        title: context.loc.assistantReports,
                        icon: CupertinoIcons.doc_chart,
                        route: '/assistant/reports',
                        currentRoute: currentRoute,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () => _navigate(context, currentRoute, '/assistant/reports'),
                      ),
                      _DrawerItem(
                        title: context.loc.settings,
                        icon: Icons.settings_rounded,
                        route: '/settings',
                        currentRoute: currentRoute,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () => _navigate(context, currentRoute, '/settings'),
                      ),
                    ]
                  : [
                      // Teacher Options
                      _DrawerItem(
                        title: context.loc.home,
                        icon: CupertinoIcons.home,
                        route: '/dashboard',
                        currentRoute: currentRoute,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () => _navigate(context, currentRoute, '/dashboard'),
                      ),
                      _DrawerItem(
                        title: context.loc.assignments,
                        icon: Icons.assignment,
                        route: '/assignments',
                        currentRoute: currentRoute,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () => _navigate(context, currentRoute, '/assignments'),
                      ),
                      _DrawerItem(
                        title: context.loc.grades,
                        icon: Icons.grade,
                        route: '/grades',
                        currentRoute: currentRoute,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () => _navigate(context, currentRoute, '/grades'),
                      ),
                      _DrawerItem(
                        title: context.loc.attendanceRecord,
                        icon: Icons.how_to_reg,
                        route: '/attendance',
                        currentRoute: currentRoute,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () => _navigate(context, currentRoute, '/attendance'),
                      ),
                      _DrawerItem(
                        title: context.loc.notifications,
                        icon: CupertinoIcons.bell_fill,
                        route: '/notifications',
                        currentRoute: currentRoute,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () => _navigate(context, currentRoute, '/notifications'),
                      ),
                      _DrawerItem(
                        title: context.translateMock('البلاغات'),
                        icon: CupertinoIcons.doc_text_viewfinder,
                        route: '/reports',
                        currentRoute: currentRoute,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () => _navigate(context, currentRoute, '/reports'),
                      ),
                      _DrawerItem(
                        title: context.loc.settings,
                        icon: Icons.settings_rounded,
                        route: '/settings',
                        currentRoute: currentRoute,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () => _navigate(context, currentRoute, '/settings'),
                      ),
                    ],
            ),
          ),

          // ---------------- LOGOUT ----------------
          Padding(
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              top: false,
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(context.loc.logout),
                      content: Text(context.loc.logoutConfirmation),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(context.loc.cancel),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext); // Close dialog
                            Navigator.pop(context); // Close drawer
                            await ref.read(authProvider.notifier).logout();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                          child: Text(
                            context.loc.logout,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.redAccent[100] : Colors.red,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: (isDark ? Colors.redAccent[100]! : Colors.red)
                          .withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  backgroundColor: isDark
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.transparent,
                ),
                icon: const Icon(Icons.logout_rounded, size: 22),
                label: Text(
                  context.loc.logout,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(
    BuildContext context,
    String currentRoute,
    String targetRoute,
  ) {
    Navigator.pop(context);
    if (currentRoute != targetRoute) {
      context.go(targetRoute);
    }
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.currentRoute,
    required this.isDark,
    required this.primaryColor,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final String route;
  final String currentRoute;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = currentRoute == route && route != '/';

    final Color backgroundColor = isSelected
        ? (isDark
              ? Colors.white.withValues(alpha: 0.1)
              : primaryColor.withValues(alpha: 0.08))
        : Colors.transparent;

    final Color foregroundColor = isSelected
        ? (isDark ? Colors.amber : primaryColor)
        : (isDark ? Colors.white70 : AppColors.textSecondaryLight);

    final FontWeight fontWeight = isSelected
        ? FontWeight.w700
        : FontWeight.w500;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: backgroundColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          minLeadingWidth: 24,
          leading: Icon(
            icon,
            color: foregroundColor,
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: fontWeight,
              color: foregroundColor,
              fontSize: 14,
            ),
          ),
          trailing: isSelected
              ? Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: foregroundColor,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
