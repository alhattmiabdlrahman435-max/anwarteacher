import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/attendance.dart';

part 'attendance_provider.g.dart';

@riverpod
class DailyAttendance extends _$DailyAttendance {
  @override
  List<AttendanceRecord> build() {
    return [
      AttendanceRecord(id: '1', studentId: 's1', studentName: 'أحمد محمد عبدالله', date: DateTime.now(), status: AttendanceStatus.present),
      AttendanceRecord(id: '2', studentId: 's2', studentName: 'سارة محمد عبدالله', date: DateTime.now(), status: AttendanceStatus.present),
      AttendanceRecord(id: '3', studentId: 's3', studentName: 'عمر محمد عبدالله', date: DateTime.now(), status: AttendanceStatus.present),
      AttendanceRecord(id: '4', studentId: 's4', studentName: 'علي حسين', date: DateTime.now(), status: AttendanceStatus.present),
      AttendanceRecord(id: '5', studentId: 's5', studentName: 'فاطمة الزهراء', date: DateTime.now(), status: AttendanceStatus.present),
    ];
  }

  void updateStatus(String studentId, AttendanceStatus newStatus) {
    state = [
      for (final record in state)
        if (record.studentId == studentId)
          record.copyWith(status: newStatus)
        else
          record
    ];
  }

  void markAllPresent() {
    state = [
      for (final record in state)
        record.copyWith(status: AttendanceStatus.present)
    ];
  }
}
