import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assistant_models.dart';

part 'assistant_attendance_history_provider.g.dart';

@riverpod
class AssistantAttendanceHistory extends _$AssistantAttendanceHistory {
  @override
  List<AttendanceHistoryEntity> build() {
    final now = DateTime.now();
    
    final studentsC1 = [
      const StudentEntity(id: 's1', name: 'أحمد محمد عبدالله', nameEn: 'Ahmed Mohammed Abdullah', parentName: 'محمد عبدالله', parentPhone: '0512345678', status: AttendanceStatus.present),
      const StudentEntity(id: 's2', name: 'سارة محمد عبدالله', nameEn: 'Sarah Mohammed Abdullah', parentName: 'محمد عبدالله', parentPhone: '0523456789', status: AttendanceStatus.present),
      const StudentEntity(id: 's3', name: 'عمر محمد عبدالله', nameEn: 'Omar Mohammed Abdullah', parentName: 'محمد عبدالله', parentPhone: '0534567890', status: AttendanceStatus.absent),
      const StudentEntity(id: 's4', name: 'علي حسين', nameEn: 'Ali Hussein', parentName: 'حسين علي', parentPhone: '0545678901', status: AttendanceStatus.present),
      const StudentEntity(id: 's5', name: 'فاطمة الزهراء', nameEn: 'Fatima Al-Zahra', parentName: 'محمود أحمد', parentPhone: '0556789012', status: AttendanceStatus.present),
    ];

    final studentsC2 = [
      const StudentEntity(id: 's6', name: 'خالد وليد', nameEn: 'Khalid Waleed', parentName: 'وليد خالد', parentPhone: '0567890123', status: AttendanceStatus.present),
      const StudentEntity(id: 's7', name: 'ريما أحمد', nameEn: 'Rema Ahmed', parentName: 'أحمد ريما', parentPhone: '0578901234', status: AttendanceStatus.present),
      const StudentEntity(id: 's8', name: 'يوسف عمر', nameEn: 'Yousef Omar', parentName: 'عمر يوسف', parentPhone: '0589012345', status: AttendanceStatus.absent),
      const StudentEntity(id: 's9', name: 'ليان صالح', nameEn: 'Layan Saleh', parentName: 'صالح ليان', parentPhone: '0590123456', status: AttendanceStatus.present),
    ];

    return [
      AttendanceHistoryEntity(
        classId: 'c1',
        className: 'الصف الخامس - أ',
        classNameEn: 'Grade 5 - A',
        dailyRecords: [
          AttendanceHistoryRecord(
            date: now.subtract(const Duration(days: 1)),
            attendedStudents: studentsC1,
            totalStudents: 5,
            presentCount: 4,
            absentCount: 1,
          ),
          AttendanceHistoryRecord(
            date: now.subtract(const Duration(days: 2)),
            attendedStudents: studentsC1.map((s) => s.copyWith(status: AttendanceStatus.present)).toList(),
            totalStudents: 5,
            presentCount: 5,
            absentCount: 0,
          ),
          AttendanceHistoryRecord(
            date: now.subtract(const Duration(days: 3)),
            attendedStudents: studentsC1.map((s) => s.id == 's3' || s.id == 's4' ? s.copyWith(status: AttendanceStatus.absent) : s).toList(),
            totalStudents: 5,
            presentCount: 3,
            absentCount: 2,
          ),
        ],
      ),
      AttendanceHistoryEntity(
        classId: 'c2',
        className: 'الصف السادس - ب',
        classNameEn: 'Grade 6 - B',
        dailyRecords: [
          AttendanceHistoryRecord(
            date: now.subtract(const Duration(days: 1)),
            attendedStudents: studentsC2,
            totalStudents: 4,
            presentCount: 3,
            absentCount: 1,
          ),
          AttendanceHistoryRecord(
            date: now.subtract(const Duration(days: 2)),
            attendedStudents: studentsC2.map((s) => s.copyWith(status: AttendanceStatus.present)).toList(),
            totalStudents: 4,
            presentCount: 4,
            absentCount: 0,
          ),
        ],
      ),
    ];
  }
}
