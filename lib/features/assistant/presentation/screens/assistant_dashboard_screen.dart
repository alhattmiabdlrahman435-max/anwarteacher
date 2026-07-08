import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/widgets/adaptive_sliver_app_bar.dart';
import '../../providers/assistant_dashboard_provider.dart';
import '../../providers/assistant_classes_provider.dart';
import '../../providers/assistant_class_details_provider.dart';

class AssistantDashboardScreen extends ConsumerStatefulWidget {
  const AssistantDashboardScreen({super.key});

  @override
  ConsumerState<AssistantDashboardScreen> createState() => _AssistantDashboardScreenState();
}

class _AssistantDashboardScreenState extends ConsumerState<AssistantDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (mounted) {
        // 1. Refresh assistant classes
        await ref.read(assistantClassesProvider.notifier).refresh();
        // 2. Refresh each class details to update stats
        final classes = ref.read(assistantClassesProvider);
        if (mounted) {
          await Future.wait(
            classes.map(
              (cls) => ref.read(assistantClassDetailsProvider(cls.id).notifier).refresh(cls.id),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final authState = ref.watch(authProvider);
    final stats = ref.watch(assistantDashboardStatsProvider);
    
    final supervisorName = authState.userName.isNotEmpty 
        ? authState.userName 
        : context.loc.monaAlHarbi;

    return Scaffold(
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          // 1. Refresh assistant classes
          await ref.read(assistantClassesProvider.notifier).refresh();
          // 2. Refresh each class details to update stats
          final classes = ref.read(assistantClassesProvider);
          await Future.wait(
            classes.map(
              (cls) => ref.read(assistantClassDetailsProvider(cls.id).notifier).refresh(cls.id),
            ),
          );
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            AdaptiveSliverAppBar(
              title: context.loc.home,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _WelcomeHeader(supervisorName: supervisorName),
                    const SizedBox(height: AppSpacing.md),
  
                    // Statistics Header
                    Text(
                      context.loc.attendanceStats,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
  
                    // Stats cards row
                    _StatsSection(stats: stats),
                    const SizedBox(height: AppSpacing.lg),
  
                    // Quick Actions Title
                    Text(
                      context.loc.quickTasks,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
  
                    // Quick Actions Grid
                    const _QuickActionsGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends ConsumerWidget {
  final String supervisorName;

  const _WelcomeHeader({required this.supervisorName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final authState = ref.watch(authProvider);
    
    String greeting;
    if (hour < 12) {
      greeting = context.loc.goodMorning;
    } else if (hour < 17) {
      greeting = context.loc.goodAfternoon;
    } else {
      greeting = context.loc.goodEvening;
    }

    final gradient = LinearGradient(
      colors: [AppColors.lightBlue, AppColors.primary],
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightBlue.withValues(alpha: 0.3),
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
            child: authState.userAvatar != null && authState.userAvatar!.startsWith('http')
                ? CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(authState.userAvatar!),
                  )
                : authState.userAvatar != null && (authState.userAvatar!.contains('/') || authState.userAvatar!.contains('\\') || File(authState.userAvatar!).existsSync())
                    ? CircleAvatar(
                        radius: 32,
                        backgroundImage: FileImage(File(authState.userAvatar!)),
                      )
                : (authState.userAvatar != null && authState.userAvatar!.runes.length <= 4)
                    ? CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          authState.userAvatar!,
                          style: const TextStyle(fontSize: 26),
                        ),
                      )
                    : CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.verified_rounded,
                          size: 38,
                          color: Colors.white,
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  supervisorName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.loc.prepAssistantDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontSize: 12,
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

class _StatsSection extends StatelessWidget {
  final DashboardStats stats;

  const _StatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.groups_rounded,
            label: context.loc.totalStudents,
            value: '${stats.totalStudents}',
            color: AppColors.lightBlue,
            delay: 100,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_rounded,
            label: context.loc.presentToday,
            value: '${stats.presentToday}',
            color: AppColors.successGreen,
            delay: 200,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.cancel_rounded,
            label: context.loc.absentToday,
            value: '${stats.absentToday}',
            color: AppColors.dangerRed,
            delay: 300,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int delay;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark 
        ? color.withValues(alpha: 0.1) 
        : color.withValues(alpha: 0.06);
    final borderColor = isDark
        ? color.withValues(alpha: 0.2)
        : color.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.1) 
                  : color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
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

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _ActionCard(
          icon: PhosphorIconsFill.users,
          label: context.loc.assistantClasses,
          color: AppColors.lightBlue,
          onTap: () {
            context.go('/assistant/classes');
          },
        ),
        _ActionCard(
          icon: PhosphorIconsFill.qrCode,
          label: context.loc.scanQr,
          color: AppColors.accent,
          onTap: () {
            context.push('/assistant/qr_scan');
          },
        ),
        _ActionCard(
          icon: PhosphorIconsFill.clockCounterClockwise,
          label: context.loc.assistantHistory,
          color: AppColors.purple,
          onTap: () {
            context.go('/assistant/history');
          },
        ),
        _ActionCard(
          icon: PhosphorIconsFill.chartBar,
          label: context.loc.assistantReports,
          color: AppColors.pink,
          onTap: () {
            context.go('/assistant/reports');
          },
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? AppColors.cardDark.withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.5),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
