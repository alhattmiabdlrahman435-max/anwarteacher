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
  List<AppNotificationModel> _cache = const [];
  String? _loadedUserId;

  @override
  List<AppNotificationModel> build() {
    final authState = ref.watch(authProvider);
    if (!authState.isLoggedIn) {
      _loadedUserId = null;
      _cache = const [];
      return const [];
    }
    if (_loadedUserId != authState.userId) {
      _loadedUserId = authState.userId;
      _cache = const [];
      Future.microtask(() => _fetch());
    }
    return _cache;
  }

  bool _isFetching = false;

  static const int _perPage = 20;
  int _currentPage = 0;
  int _lastPage = 1;

  /// هل توجد إشعارات أقدم لم تُحمَّل بعد
  bool get hasMore => _currentPage < _lastPage;

  /// يجلب صفحة من الإشعارات. الصفحة 1 تستبدل القائمة، والتالية تُضاف لنهايتها.
  Future<void> _fetch({int page = 1}) async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('notifications', queryParameters: {
        'page': page,
        'per_page': _perPage,
      });
      if (!ref.mounted) return;
      if (response.data != null && response.data['success'] == true) {
        _currentPage = (response.data['current_page'] as num?)?.toInt() ?? page;
        _lastPage = (response.data['last_page'] as num?)?.toInt() ?? _currentPage;
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

        // كل الإشعارات تبقى محفوظة (لا يُخفى القديم)؛ الأقدم يُحمَّل عند النزول
        if (page == 1) {
          state = parsedList;
        } else {
          final existing = state.map((n) => n.id).toSet();
          state = [...state, ...parsedList.where((n) => !existing.contains(n.id))];
        }
        _cache = state;

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

  /// تحميل الإشعارات الأقدم (الصفحة التالية)
  Future<void> loadMore() async {
    if (!hasMore) return;
    await _fetch(page: _currentPage + 1);
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
    _cache = state;
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
    _cache = state;

    final unreadCount = state.where((n) => !n.isRead).length;
    BadgeService.setBadge(unreadCount);

    try {
      final dio = ref.read(apiClientProvider);
      await dio.put('notifications/$id/read');
    } catch (e) {
      // Rollback on failure
      if (ref.mounted) {
        state = previousState;
        _cache = state;
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
    _cache = state;

    BadgeService.clearBadge();

    try {
      final dio = ref.read(apiClientProvider);
      await dio.put('notifications/read-all');
    } catch (e) {
      // Rollback on failure
      if (ref.mounted) {
        state = previousState;
        _cache = state;
        final rollbackUnread = previousState.where((n) => !n.isRead).length;
        BadgeService.setBadge(rollbackUnread);
      }
      debugPrint('Error marking all notifications as read in backend: $e');
    }
  }
}
