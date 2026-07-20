import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/attendance.dart';
import '../network/api_client.dart';
import '../utils/constants.dart';
import 'classes_provider.dart';

part 'attendance_provider.g.dart';

@riverpod
class DailyAttendance extends _$DailyAttendance {
  String? _loadedClassId;
  String? _loadedDate;
  List<AttendanceRecord> _cache = const [];

  @override
  List<AttendanceRecord> build(String date) {
    final selectedClass = ref.watch(selectedClassProvider);
    if (selectedClass.isEmpty) {
      _loadedClassId = null;
      _loadedDate = null;
      _cache = const [];
      return const [];
    }
    
    final classesNotifier = ref.read(classesProvider.notifier);
    final classId = classesNotifier.nameToIdMap[selectedClass];
    if (classId == null) {
      _loadedClassId = null;
      _loadedDate = null;
      _cache = const [];
      return const [];
    }
    
    if (_loadedClassId != classId || _loadedDate != date) {
      _loadedClassId = classId;
      _loadedDate = date;
      _cache = const [];
      Future.microtask(() => _fetch(classId, date));
    }
    
    return _cache;
  }

  Future<void> _fetch(String classId, String date) async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get(
        'teacher/classes/$classId/students',
        queryParameters: {'date': date},
      );
      if (!ref.mounted) return;
      if (response.data != null) {
        final List<dynamic> data = response.data;
        state = data.map((json) {
          final dbStatus = json['status']?.toString().toLowerCase();
          final status = dbStatus == 'present'
              ? AttendanceStatus.present
              : (dbStatus == 'absent' ? AttendanceStatus.absent : AttendanceStatus.pending);
          return AttendanceRecord(
            id: json['id']?.toString() ?? '',
            studentId: json['id']?.toString() ?? '',
            studentName: json['name'] ?? '',
            date: DateTime.tryParse(date) ?? DateTime.now(),
            status: status,
            studentPhotoUrl: AppConstants.normalizeUrl(json['photoUrl'] ?? json['photo_url']),
          );
        }).toList();
        _cache = state;
      }
    } catch (e) {
      debugPrint('Error fetching teacher class students: $e');
    }
  }

  Future<void> updateStatus(String studentId, AttendanceStatus newStatus) async {
    // Save previous state for rollback
    final previousState = state;

    // 1. Update state immediately (optimistic)
    state = [
      for (final record in state)
        if (record.studentId == studentId)
          record.copyWith(status: newStatus)
        else
          record
    ];
    _cache = state;

    // 2. Send to backend
    try {
      final dio = ref.read(apiClientProvider);
      final statusStr = newStatus.name; // present, absent
      await dio.put('teacher/students/$studentId/attendance', data: {
        'status': statusStr,
      });
    } catch (e) {
      // Rollback on failure
      if (ref.mounted) {
        state = previousState;
        _cache = state;
      }
      debugPrint('Error updating teacher student attendance: $e');
    }
  }

  Future<void> markAllPresent() async {
    // Save previous state for rollback
    final previousState = state;

    // Update local state
    state = [
      for (final record in state)
        record.copyWith(status: AttendanceStatus.present)
    ];
    _cache = state;
    
    // Send updates to backend in parallel instead of sequentially
    try {
      final dio = ref.read(apiClientProvider);
      await Future.wait(
        state.map((record) => dio.put(
          'teacher/students/${record.studentId}/attendance',
          data: {'status': 'present'},
        )),
      );
    } catch (e) {
      // Rollback on failure
      if (ref.mounted) {
        state = previousState;
        _cache = state;
      }
      debugPrint('Error marking all present: $e');
    }
  }
}

@riverpod
Future<Map<String, AttendanceStatus>> studentAttendanceHistory(Ref ref, String studentId) async {
  try {
    final dio = ref.read(apiClientProvider);
    final response = await dio.get('attendance/student/$studentId');
    if (response.data != null && response.data['success'] == true) {
      final List<dynamic> list = response.data['attendance'] ?? [];
      final Map<String, AttendanceStatus> history = {};
      for (final item in list) {
        final dateStr = item['record_date']?.toString();
        final dbStatus = item['status']?.toString().toLowerCase();
        if (dateStr != null && dbStatus != null) {
          history[dateStr] = dbStatus == 'present'
              ? AttendanceStatus.present
              : (dbStatus == 'absent' ? AttendanceStatus.absent : AttendanceStatus.pending);
        }
      }
      return history;
    }
  } catch (e) {
    debugPrint('Error fetching student attendance history: $e');
  }
  return const {};
}
