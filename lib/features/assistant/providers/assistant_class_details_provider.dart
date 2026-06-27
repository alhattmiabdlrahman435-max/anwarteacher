import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assistant_models.dart';

part 'assistant_class_details_provider.g.dart';

@riverpod
class AssistantClassDetails extends _$AssistantClassDetails {
  @override
  List<StudentEntity> build(String classId) {
    if (classId == 'c1') {
      return [
        const StudentEntity(id: 's1', name: 'أحمد محمد عبدالله', nameEn: 'Ahmed Mohammed Abdullah', parentName: 'محمد عبدالله', parentPhone: '0512345678', status: AttendanceStatus.unknown),
        const StudentEntity(id: 's2', name: 'سارة محمد عبدالله', nameEn: 'Sarah Mohammed Abdullah', parentName: 'محمد عبدالله', parentPhone: '0523456789', status: AttendanceStatus.unknown),
        const StudentEntity(id: 's3', name: 'عمر محمد عبدالله', nameEn: 'Omar Mohammed Abdullah', parentName: 'محمد عبدالله', parentPhone: '0534567890', status: AttendanceStatus.unknown),
        const StudentEntity(id: 's4', name: 'علي حسين', nameEn: 'Ali Hussein', parentName: 'حسين علي', parentPhone: '0545678901', status: AttendanceStatus.unknown),
        const StudentEntity(id: 's5', name: 'فاطمة الزهراء', nameEn: 'Fatima Al-Zahra', parentName: 'محمود أحمد', parentPhone: '0556789012', status: AttendanceStatus.unknown),
      ];
    } else if (classId == 'c2') {
      return [
        const StudentEntity(id: 's6', name: 'خالد وليد', nameEn: 'Khalid Waleed', parentName: 'وليد خالد', parentPhone: '0567890123', status: AttendanceStatus.unknown),
        const StudentEntity(id: 's7', name: 'ريما أحمد', nameEn: 'Rema Ahmed', parentName: 'أحمد ريما', parentPhone: '0578901234', status: AttendanceStatus.unknown),
        const StudentEntity(id: 's8', name: 'يوسف عمر', nameEn: 'Yousef Omar', parentName: 'عمر يوسف', parentPhone: '0589012345', status: AttendanceStatus.unknown),
        const StudentEntity(id: 's9', name: 'ليان صالح', nameEn: 'Layan Saleh', parentName: 'صالح ليان', parentPhone: '0590123456', status: AttendanceStatus.unknown),
      ];
    } else {
      return [
        const StudentEntity(id: 's10', name: 'نور الدين', nameEn: 'Nour El-Din', parentName: 'علاء الدين', parentPhone: '0591234567', status: AttendanceStatus.unknown),
        const StudentEntity(id: 's11', name: 'جود عبد العزيز', nameEn: 'Joud Abdulaziz', parentName: 'عبد العزيز جود', parentPhone: '0592345678', status: AttendanceStatus.unknown),
        const StudentEntity(id: 's12', name: 'حمزة مصطفى', nameEn: 'Hamza Mostafa', parentName: 'مصطفى حمزة', parentPhone: '0593456789', status: AttendanceStatus.unknown),
      ];
    }
  }

  void markAttendance(String studentId, AttendanceStatus status) {
    state = [
      for (final student in state)
        if (student.id == studentId)
          student.copyWith(status: status)
        else
          student
    ];
  }

  Future<bool> submitDailyReport() async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = [
      for (final student in state)
        student.copyWith(isLocked: true)
    ];
    return true;
  }
}
