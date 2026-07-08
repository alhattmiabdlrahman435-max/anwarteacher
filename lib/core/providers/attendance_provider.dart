import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/attendance.dart';
import '../network/api_client.dart';
import '../utils/constants.dart';
import 'classes_provider.dart';

part 'attendance_provider.g.dart';

@riverpod
class DailyAttendance extends _$DailyAttendance {
  @override
  List<AttendanceRecord> build(String date) {
    final selectedClass = ref.watch(selectedClassProvider);
    if (selectedClass.isEmpty) return const [];
    
    final classesNotifier = ref.read(classesProvider.notifier);
    final classId = classesNotifier.nameToIdMap[selectedClass];
    if (classId == null) return const [];
    
    _fetch(classId, date);
    return const [];
  }

  Future<void> _fetch(String classId, String date) async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get(
        'teacher/classes/$classId/students',
        queryParameters: {'date': date},
      );
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
      }
    } catch (e) {
      debugPrint('Error fetching teacher class students: $e');
    }
  }
  Future<void> updateStatus(String studentId, AttendanceStatus newStatus) async {
    // 1. Update state immediately
    state = [
      for (final record in state)
        if (record.studentId == studentId)
          record.copyWith(status: newStatus)
        else
          record
    ];

    // 2. Put attendance update to backend
    try {
      final dio = ref.read(apiClientProvider);
      final statusStr = newStatus.name; // present, absent
      await dio.put('teacher/students/$studentId/attendance', data: {
        'status': statusStr,
      });
    } catch (e) {
      debugPrint('Error updating teacher student attendance: $e');
    }
  }

  Future<void> markAllPresent() async {
    // Update local state
    state = [
      for (final record in state)
        record.copyWith(status: AttendanceStatus.present)
    ];
    
    // Send updates to backend for each student in the list
    final dio = ref.read(apiClientProvider);
    for (final record in state) {
      try {
        await dio.put('teacher/students/${record.studentId}/attendance', data: {
          'status': 'present',
        });
      } catch (e) {
        debugPrint('Error marking student ${record.studentId} present: $e');
      }
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
    print('Error fetching student attendance history: $e');
  }
  return const {};
}
