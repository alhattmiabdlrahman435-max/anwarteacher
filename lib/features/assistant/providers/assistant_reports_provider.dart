import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assistant_models.dart';

part 'assistant_reports_provider.g.dart';

@riverpod
class AssistantReports extends _$AssistantReports {
  @override
  AttendanceStatsEntity build() {
    final now = DateTime.now();
    return AttendanceStatsEntity(
      totalStudents: 12,
      presentToday: 9,
      absentToday: 3,
      unmarkedToday: 0,
      averageAttendance: 85.5,
      weeklyTrend: [
        ReportEntity(date: now.subtract(const Duration(days: 4)), attendancePercentage: 90.0),
        ReportEntity(date: now.subtract(const Duration(days: 3)), attendancePercentage: 85.0),
        ReportEntity(date: now.subtract(const Duration(days: 2)), attendancePercentage: 80.0),
        ReportEntity(date: now.subtract(const Duration(days: 1)), attendancePercentage: 95.0),
        ReportEntity(date: now.subtract(const Duration(days: 0)), attendancePercentage: 85.5),
      ],
      studentReports: const [
        StudentReportEntity(name: 'أحمد محمد عبدالله', nameEn: 'Ahmed Mohammed Abdullah', civilId: '1023456789', presentCount: 14, absentCount: 2),
        StudentReportEntity(name: 'سارة محمد عبدالله', nameEn: 'Sarah Mohammed Abdullah', civilId: '1024567890', presentCount: 15, absentCount: 1),
        StudentReportEntity(name: 'عمر محمد عبدالله', nameEn: 'Omar Mohammed Abdullah', civilId: '1025678901', presentCount: 12, absentCount: 4),
        StudentReportEntity(name: 'علي حسين', nameEn: 'Ali Hussein', civilId: '1026789012', presentCount: 16, absentCount: 0),
        StudentReportEntity(name: 'فاطمة الزهراء', nameEn: 'Fatima Al-Zahra', civilId: '1027890123', presentCount: 13, absentCount: 3),
        StudentReportEntity(name: 'خالد وليد', nameEn: 'Khalid Waleed', civilId: '1028901234', presentCount: 14, absentCount: 2),
        StudentReportEntity(name: 'ريما أحمد', nameEn: 'Rema Ahmed', civilId: '1029012345', presentCount: 15, absentCount: 1),
        StudentReportEntity(name: 'يوسف عمر', nameEn: 'Yousef Omar', civilId: '1030123456', presentCount: 11, absentCount: 5),
        StudentReportEntity(name: 'ليان صالح', nameEn: 'Layan Saleh', civilId: '1031234567', presentCount: 15, absentCount: 1),
        StudentReportEntity(name: 'نور الدين', nameEn: 'Nour El-Din', civilId: '1032345678', presentCount: 14, absentCount: 2),
        StudentReportEntity(name: 'جود عبد العزيز', nameEn: 'Joud Abdulaziz', civilId: '1033456789', presentCount: 13, absentCount: 3),
        StudentReportEntity(name: 'حمزة مصطفى', nameEn: 'Hamza Mostafa', civilId: '1034567890', presentCount: 16, absentCount: 0),
      ],
    );
  }

  void loadReports() {
    // Updates local state if needed (no-op since data is static mock)
  }
}
