import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/report.dart';
import 'notifications_provider.dart';

part 'reports_provider.g.dart';

@riverpod
class Reports extends _$Reports {
  @override
  List<Report> build() {
    return [
      Report(
        id: 'r1',
        studentId: 's1',
        studentName: 'أحمد محمد عبدالله',
        className: 'الصف الخامس - أ',
        type: ReportType.academic,
        description: 'تراجع ملحوظ في مستوى الطالب في مادة الرياضيات خلال الأسبوعين الماضيين، ويحتاج إلى متابعة وتعزيز من المنزل.',
        status: ReportStatus.approved,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Report(
        id: 'r2',
        studentId: 's2',
        studentName: 'سارة محمد عبدالله',
        className: 'الصف الخامس - أ',
        type: ReportType.behavioral,
        description: 'تكرار الحديث الجانبي أثناء الشرح وعدم الانتباه للمعلمة بشكل متكرر خلال الأسبوع الماضي.',
        status: ReportStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Report(
        id: 'r3',
        studentId: 's1',
        studentName: 'أحمد محمد عبدالله',
        className: 'الصف الخامس - أ',
        type: ReportType.homework,
        description: 'لم يسلم الطالب واجبات الرياضيات للأسبوع الثالث على التوالي.',
        status: ReportStatus.rejected,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  void addReport({
    required String studentId,
    required String studentName,
    required String className,
    required ReportType type,
    required String description,
    String? imageUrl,
  }) {
    final newReport = Report(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      studentName: studentName,
      className: className,
      type: type,
      description: description,
      imageUrl: imageUrl,
      status: ReportStatus.pending,
      createdAt: DateTime.now(),
    );
    state = [newReport, ...state];
  }

  void updateReportStatus(String id, ReportStatus newStatus) {
    state = [
      for (final report in state)
        if (report.id == id) _handleStatusChange(report, newStatus) else report
    ];
  }

  Report _handleStatusChange(Report report, ReportStatus newStatus) {
    final updatedReport = report.copyWith(status: newStatus);

    if (newStatus == ReportStatus.approved) {
      // Trigger a notification to the parent
      ref.read(notificationsProvider.notifier).addNotification(
        title: 'تم إرسال بلاغ لولي الأمر',
        message: 'تمت الموافقة من الإدارة وإرسال البلاغ لولي أمر الطالب ${report.studentName} (${report.type.nameAr}).',
        icon: Icons.check_circle_rounded,
        iconColor: Colors.green,
      );
    } else if (newStatus == ReportStatus.rejected) {
      // Trigger notification that report was rejected by admin
      ref.read(notificationsProvider.notifier).addNotification(
        title: 'تم رفض بلاغ من الإدارة',
        message: 'رفضت الإدارة إرسال البلاغ الخاص بالطالب ${report.studentName}.',
        icon: Icons.cancel_rounded,
        iconColor: Colors.red,
      );
    }

    return updatedReport;
  }
}
