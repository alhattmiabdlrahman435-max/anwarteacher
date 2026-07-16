import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/notification_model.dart';
import '../network/api_client.dart';
import '../services/badge_service.dart';
import 'auth_provider.dart';

part 'notifications_provider.g.dart';

@riverpod
class Notifications extends _$Notifications {
  @override
  List<AppNotificationModel> build() {
    final authState = ref.watch(authProvider);
    if (!authState.isLoggedIn) return const [];
    _fetch();
    return const [];
  }

  bool _isFetching = false;

  Future<void> _fetch() async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('notifications');
      if (!ref.mounted) return;
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['notifications'] ?? [];
        final parsedList = list.map((item) {
          final String type = item['type']?.toString().toLowerCase() ?? 'general';
          
          IconData icon = CupertinoIcons.bell_fill;
          Color iconColor = Colors.blueAccent;
          
          if (type == 'attendance') {
            icon = CupertinoIcons.doc_checkmark_fill;
            iconColor = Colors.orangeAccent;
          } else if (type == 'broadcast' || type == 'meeting') {
            icon = CupertinoIcons.group_solid;
            iconColor = Colors.purpleAccent;
          }

          return AppNotificationModel(
            id: item['id']?.toString() ?? '',
            title: item['title'] ?? '',
            message: item['content'] ?? '',
            date: DateTime.tryParse(item['created_at']?.toString() ?? '') ?? DateTime.now(),
            icon: icon,
            iconColor: iconColor,
            isRead: item['is_read'] == 1 || item['is_read'] == true,
          );
        }).toList();

        // Only keep notifications created within the last 7 days
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        state = parsedList.where((n) => n.date.isAfter(sevenDaysAgo)).toList();

        final unreadCount = state.where((n) => !n.isRead).length;
        BadgeService.setBadge(unreadCount);
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh() async {
    await _fetch();
  }

  void addNotification({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    final newNotification = AppNotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      date: DateTime.now(),
      icon: icon,
      iconColor: iconColor,
    );
    state = [newNotification, ...state];
    final unreadCount = state.where((n) => !n.isRead).length;
    BadgeService.setBadge(unreadCount);
  }

  Future<void> markAsRead(String id) async {
    // Save previous state for rollback
    final previousState = state;

    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n
    ];

    final unreadCount = state.where((n) => !n.isRead).length;
    BadgeService.setBadge(unreadCount);

    try {
      final dio = ref.read(apiClientProvider);
      await dio.put('notifications/$id/read');
    } catch (e) {
      // Rollback on failure
      if (ref.mounted) {
        state = previousState;
        final rollbackUnread = previousState.where((n) => !n.isRead).length;
        BadgeService.setBadge(rollbackUnread);
      }
      debugPrint('Error marking notification as read in backend: $e');
    }
  }

  Future<void> markAllAsRead() async {
    // Save previous state for rollback
    final previousState = state;

    state = [
      for (final n in state)
        n.copyWith(isRead: true)
    ];

    BadgeService.clearBadge();

    try {
      final dio = ref.read(apiClientProvider);
      await dio.put('notifications/read-all');
    } catch (e) {
      // Rollback on failure
      if (ref.mounted) {
        state = previousState;
        final rollbackUnread = previousState.where((n) => !n.isRead).length;
        BadgeService.setBadge(rollbackUnread);
      }
      debugPrint('Error marking all notifications as read in backend: $e');
    }
  }
}
