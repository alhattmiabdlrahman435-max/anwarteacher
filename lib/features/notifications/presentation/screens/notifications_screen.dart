import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/providers/notifications_provider.dart';
import '../../../../main.dart'; // Import to access global flutterLocalNotificationsPlugin

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Clear all active local notification alerts and badges on entry
    Future.microtask(() {
      try {
        flutterLocalNotificationsPlugin.cancelAll();
      } catch (e) {
        debugPrint('Error canceling notifications: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(notificationsProvider.notifier).refresh();
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            AppSliverHeader(
              title: context.loc.notifications,
              trailing: notifications.any((n) => !n.isRead)
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(
                        Icons.done_all_rounded,
                        color: isDark ? Colors.white : AppColors.primary,
                        size: 24,
                      ),
                      onPressed: () {
                        ref.read(notificationsProvider.notifier).markAllAsRead();
                        try {
                          flutterLocalNotificationsPlugin.cancelAll();
                        } catch (_) {}
                      },
                    )
                  : null,
            ),
            if (notifications.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text('لا توجد إشعارات حالياً', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final n = notifications[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildNotificationCard(
                          context,
                          title: n.title,
                          message: n.message,
                          time: _formatDate(n.date),
                          icon: n.icon,
                          iconColor: n.iconColor,
                          isDark: isDark,
                          isRead: n.isRead,
                          onTap: () {
                            ref.read(notificationsProvider.notifier).markAsRead(n.id);
                          },
                        ),
                      );
                    },
                    childCount: notifications.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required bool isRead,
    required VoidCallback onTap,
  }) {
    return ModernCard(
      isDark: isDark,
      onTap: onTap,
      borderColor: isRead ? null : iconColor.withValues(alpha: 0.5),
      borderWidth: isRead ? 1.0 : 2.0,
      backgroundColor: isRead ? null : iconColor.withValues(alpha: isDark ? 0.08 : 0.04),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              if (!isRead)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isRead ? FontWeight.bold : FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
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
