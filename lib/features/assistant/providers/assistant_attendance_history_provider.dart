import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assistant_models.dart';
import '../../../core/network/api_client.dart';

part 'assistant_attendance_history_provider.g.dart';

@riverpod
class AssistantAttendanceHistory extends _$AssistantAttendanceHistory {
  @override
  List<AttendanceHistoryEntity> build() {
    _fetch();
    return const [];
  }

  Future<void> _fetch() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('supervisor/attendance-history');
      if (response.data != null) {
        final List<dynamic> data = response.data;
        state = data.map((json) => AttendanceHistoryEntity.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching supervisor attendance history: $e');
    }
  }

  Future<void> refresh() async {
    await _fetch();
  }
}
