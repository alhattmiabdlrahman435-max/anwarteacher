import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/exam_schedule.dart';
import '../network/api_client.dart';

part 'exams_provider.g.dart';

@riverpod
class Exams extends _$Exams {
  @override
  List<ExamSchedule> build() {
    _fetch();
    return const [];
  }

  Future<void> _fetch() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('exam-schedules');
      if (!ref.mounted) return;
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['exam_schedules'] ?? [];
        state = list.map((item) {
          final String title = item['title'] ?? '';
          
          // Map title/term/period to ExamTerm and ExamPeriod
          final termStr = item['term']?.toString() ?? '';
          ExamTerm term = ExamTerm.first;
          if (termStr == '2' || 
              termStr.toLowerCase() == 'second' || 
              termStr.toLowerCase() == 'term2' ||
              termStr.contains('الثاني') || 
              termStr.contains('الترم الثاني') || 
              termStr.contains('الفصل الثاني')) {
            term = ExamTerm.second;
          }

          ExamPeriod period = ExamPeriod.month1;
          if (title.contains('الثاني') && !title.contains('الترم')) {
            period = ExamPeriod.month2;
          } else if (title.contains('الثالث')) {
            period = ExamPeriod.month3;
          } else if (title.contains('نهاية') || title.contains('النهائي')) {
            period = ExamPeriod.finalExam;
          }

          final List<dynamic> subjectsJson = item['subjects'] ?? [];
          final subjects = subjectsJson.map((sub) {
            return ExamSubject(
              subjectName: sub['name_ar'] ?? sub['name'] ?? '',
              date: DateTime.tryParse(sub['exam_date']?.toString() ?? '') ?? DateTime.now(),
              note: sub['note'] ?? '',
            );
          }).toList();

          return ExamSchedule(
            id: item['id']?.toString() ?? '',
            studentId: item['class_id']?.toString() ?? '1',
            term: term,
            period: period,
            subjects: subjects,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching exam schedules: $e');
    }
  }

  List<ExamSchedule> getExamsForStudent(String studentId) {
    // Return all schedules to be flexible and avoid empty screens
    return state;
  }

  Future<void> refresh() async {
    await _fetch();
  }
}
