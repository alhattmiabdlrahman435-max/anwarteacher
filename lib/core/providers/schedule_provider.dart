import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/teacher_schedule.dart';
import '../network/api_client.dart';

part 'schedule_provider.g.dart';

@Riverpod(keepAlive: true)
class TeacherScheduleState extends _$TeacherScheduleState {
  @override
  FutureOr<Map<String, List<TeacherPeriod>>> build() async {
    return _loadSchedule();
  }

  Future<Map<String, List<TeacherPeriod>>> _loadSchedule() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('teacher/schedule');

      if (response.data != null && response.data['success'] == true) {
        final Map<String, dynamic> apiData = response.data['schedule'] ?? {};
        final Map<String, List<TeacherPeriod>> result = {};

        apiData.forEach((day, list) {
          if (list is List) {
            result[day] = list.map((item) => TeacherPeriod.fromJson(item)).toList();
          }
        });

        return result;
      }
    } catch (e) {
      debugPrint('Error loading teacher schedule: $e');
    }
    return {};
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadSchedule());
  }
}
