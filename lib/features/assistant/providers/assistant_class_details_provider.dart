import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assistant_models.dart';
import '../../../core/network/api_client.dart';

part 'assistant_class_details_provider.g.dart';

@riverpod
class AssistantClassDetails extends _$AssistantClassDetails {
  @override
  List<StudentEntity> build(String classId) {
    _fetch(classId);
    return const [];
  }

  Future<void> _fetch(String classId) async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('supervisor/classes/$classId/students');
      if (response.data != null) {
        final List<dynamic> data = response.data;
        state = data.map((json) => StudentEntity.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
    }
  }

  Future<void> refresh(String classId) async {
    await _fetch(classId);
  }

  Future<void> markAttendance(String studentId, AttendanceStatus status) async {
    // 1. Update local state immediately for instant feedback
    state = [
      for (final student in state)
        if (student.id == studentId)
          student.copyWith(status: status)
        else
          student
    ];

    // 2. Send request to backend
    try {
      final dio = ref.read(apiClientProvider);
      final statusStr = status.name; // present, absent, late, excused
      await dio.put('supervisor/students/$studentId/attendance', data: {
        'status': statusStr,
      });
    } catch (e) {
      debugPrint('Error marking attendance: $e');
    }
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
