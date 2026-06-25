import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/notification_model.dart';

part 'notifications_provider.g.dart';

@riverpod
class Notifications extends _$Notifications {
  @override
  List<AppNotificationModel> build() {
    return [
      AppNotificationModel(
        id: 'n1',
        title: 'إشعار عام',
        message: 'غداً إجازة رسمية بمناسبة العيد الوطني.',
        date: DateTime.now().subtract(const Duration(hours: 1)),
        icon: CupertinoIcons.bell_fill,
        iconColor: Colors.blueAccent,
      ),
      AppNotificationModel(
        id: 'n2',
        title: 'طلب اجتماع طارئ',
        message: 'اجتماع طارئ لأعضاء هيئة التدريس في المكتبة المدرسية الساعة 12 ظهراً لمناقشة سير الاختبارات.',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        icon: CupertinoIcons.group_solid,
        iconColor: Colors.purpleAccent,
      ),
      AppNotificationModel(
        id: 'n3',
        title: 'تنبيه رصد الدرجات',
        message: 'يرجى استكمال رصد درجات الشهر الأول لجميع الطلاب قبل نهاية هذا الأسبوع.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        icon: CupertinoIcons.doc_checkmark_fill,
        iconColor: Colors.orangeAccent,
      ),
    ];
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

  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n
    ];
  }
}
