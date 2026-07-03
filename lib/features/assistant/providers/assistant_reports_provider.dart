import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assistant_models.dart';
import '../../../core/network/api_client.dart';

part 'assistant_reports_provider.g.dart';

@riverpod
class AssistantReports extends _$AssistantReports {
  @override
  AttendanceStatsEntity build() {
    _fetch();
    return const AttendanceStatsEntity(
      totalStudents: 0,
      presentToday: 0,
      absentToday: 0,
      unmarkedToday: 0,
      averageAttendance: 100.0,
      weeklyTrend: [],
      studentReports: [],
    );
  }

  Future<void> _fetch() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('supervisor/reports');
      if (response.data != null) {
        state = AttendanceStatsEntity.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching supervisor reports: $e');
    }
  }

  Future<void> loadReports() async {
    await _fetch();
  }
}
