import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/notification_model.dart';
import '../network/api_client.dart';
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

  Future<void> _fetch() async {
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
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
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
  }

  Future<void> markAsRead(String id) async {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n
    ];

    try {
      final dio = ref.read(apiClientProvider);
      await dio.put('notifications/$id/read');
    } catch (e) {
      debugPrint('Error marking notification as read in backend: $e');
    }
  }

  Future<void> markAllAsRead() async {
    state = [
      for (final n in state)
        n.copyWith(isRead: true)
    ];

    try {
      final dio = ref.read(apiClientProvider);
      await dio.put('notifications/read-all');
    } catch (e) {
      debugPrint('Error marking all notifications as read in backend: $e');
    }
  }
}
