import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/widgets/app_notification.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock classes for the teacher
    final mockClasses = [
      {'name': 'الصف الخامس - أ', 'subject': 'الرياضيات والعلوم'},
      {'name': 'الصف السادس - ب', 'subject': 'الرياضيات'},
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          AppSliverHeader(title: context.loc.home),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _WelcomeHeader(),
                const SizedBox(height: AppSpacing.xl),

                _SummaryStats(classesCount: mockClasses.length, isDark: isDark),
                const SizedBox(height: AppSpacing.xl),

                _SectionTitle(title: context.loc.myClasses, isDark: isDark),
                const SizedBox(height: AppSpacing.lg),
                ...mockClasses.map(
                  (c) => _ClassQuickCard(
                    className: context.translateMock(c['name']!),
                    subject: context.translateMock(c['subject']!),
                    isDark: isDark,
                    onTap: () {
                      // Navigate to attendance by default when tapping a class
                      context.push('/attendance');
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                _SectionTitle(title: context.loc.quickAccess, isDark: isDark),
                const SizedBox(height: AppSpacing.lg),
                _QuickActions(isDark: isDark),
                const SizedBox(height: AppSpacing.xxxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeHeader extends ConsumerWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = context.loc.goodMorning;
    } else if (hour < 17) {
      greeting = context.loc.goodAfternoon;
    } else {
      greeting = context.loc.goodEvening;
    }

    final teacherName = context.loc.teacherName;

    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(
                teacherName.isNotEmpty ? teacherName.substring(0, 1) : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'GoogleSans',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    context.loc.welcomeParent(teacherName),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.loc.teacherAccount,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStats extends StatelessWidget {
  const _SummaryStats({required this.classesCount, required this.isDark});

  final int classesCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.school_rounded,
            value: classesCount.toString(),
            label: context.loc.myClasses,
            color: isDark ? Colors.white : AppColors.primary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _StatCard(
            icon: Icons.notifications_rounded,
            value: '3',
            label: context.loc.notifications,
            color: Colors.orange,
            isDark: isDark,
            onTap: () => context.push('/notifications'),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ModernCard(
      isDark: isDark,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ClassQuickCard extends StatelessWidget {
  const _ClassQuickCard({
    required this.className,
    required this.subject,
    required this.isDark,
    required this.onTap,
  });

  final String className;
  final String subject;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ModernCard(
      isDark: isDark,
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                className.isNotEmpty ? className.substring(0, 1) : '?',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    className,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subject,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
              size: 16,
            ),
          ],
        ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.assignment_turned_in_rounded,
                label: context.loc.assignments,
                color: Colors.teal,
                isDark: isDark,
                onTap: () => context.push('/assignments'),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.how_to_reg_rounded,
                label: context.loc.attendanceRecord,
                color: Colors.blue,
                isDark: isDark,
                onTap: () => context.push('/attendance'),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.star_rounded,
                label: context.loc.grades,
                color: AppColors.warning,
                isDark: isDark,
                onTap: () => context.push('/grades'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.notifications_rounded,
                label: context.loc.notifications,
                color: Colors.orange,
                isDark: isDark,
                badgeCount: 3,
                onTap: () => context.push('/notifications'),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.message_rounded,
                label: context.loc.messages,
                color: Colors.purple,
                isDark: isDark,
                badgeCount: 5,
                onTap: () {
                  AppNotification.show(
                    context,
                    type: AppNotificationType.info,
                    title: context.loc.comingSoon,
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.settings_rounded,
                label: context.loc.settings,
                color: Colors.grey,
                isDark: isDark,
                onTap: () => context.push('/settings'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.report_problem_rounded,
                label: context.translateMock('البلاغات'),
                color: Colors.redAccent,
                isDark: isDark,
                onTap: () => context.push('/reports'),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            const Expanded(child: SizedBox()),
            const SizedBox(width: AppSpacing.lg),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ModernCard(
      isDark: isDark,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : badgeCount.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.isDark});
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
