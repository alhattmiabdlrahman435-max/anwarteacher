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

  bool _isFetching = false;

  Future<void> _fetch(String classId) async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('supervisor/classes/$classId/students');
      if (!ref.mounted) return;
      if (response.data != null) {
        final List<dynamic> data = response.data;
        state = data.map((json) => StudentEntity.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh(String classId) async {
    await _fetch(classId);
  }

  Future<void> markAttendance(String studentId, AttendanceStatus status) async {
    // Save previous state for rollback
    final previousState = state;

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
      // Rollback on failure
      if (ref.mounted) {
        state = previousState;
      }
      debugPrint('Error marking attendance: $e');
    }
  }

  Future<bool> submitDailyReport() async {
    // Save previous state for rollback
    final previousState = state;

    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.post('supervisor/daily-report', data: {
        'students': state.map((s) => {
          'id': s.id,
          'status': s.status.name,
        }).toList(),
      });

      if (!ref.mounted) return false;

      if (response.data != null && response.data['success'] == true) {
        state = [
          for (final student in state)
            student.copyWith(isLocked: true)
        ];
        return true;
      }
      return false;
    } catch (e) {
      // Rollback on failure
      if (ref.mounted) {
        state = previousState;
      }
      debugPrint('Error submitting daily report: $e');
      return false;
    }
  }
}
