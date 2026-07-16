import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../models/academic_grade.dart';
import '../network/api_client.dart';
import 'classes_provider.dart';
import 'subjects_provider.dart';

part 'grades_provider.g.dart';

@riverpod
class GradesData extends _$GradesData {
  @override
  ClassSubjectGrades build() {
    final selectedClass = ref.watch(selectedClassProvider);
    final selectedSubject = ref.watch(selectedSubjectProvider);

    debugPrint('GRADES_BUILD: selectedClass: "$selectedClass", selectedSubject: "$selectedSubject"');

    if (selectedClass.isEmpty || selectedSubject.isEmpty) {
      debugPrint('GRADES_BUILD: Empty class or subject, returning empty grades list.');
      return const ClassSubjectGrades(
        classId: '',
        subjectName: '',
        grades: [],
      );
    }

    final classesNotifier = ref.read(classesProvider.notifier);
    final subjectsNotifier = ref.read(subjectsProvider.notifier);

    final classId = classesNotifier.nameToIdMap[selectedClass] ?? '';
    final subjectId = subjectsNotifier.nameToIdMap[selectedSubject] ?? '';

    debugPrint('GRADES_BUILD: Resolved classId: "$classId", subjectId: "$subjectId"');

    if (classId.isNotEmpty && subjectId.isNotEmpty) {
      _fetch(classId, subjectId);
    } else {
      debugPrint('GRADES_BUILD: Warning: Resolved classId or subjectId is empty!');
    }

    return ClassSubjectGrades(
      classId: classId,
      subjectName: selectedSubject,
      grades: const [],
    );
  }

  Future<void> refresh() async {
    final selectedClass = ref.read(selectedClassProvider);
    final selectedSubject = ref.read(selectedSubjectProvider);
    final classesNotifier = ref.read(classesProvider.notifier);
    final subjectsNotifier = ref.read(subjectsProvider.notifier);

    final classId = classesNotifier.nameToIdMap[selectedClass] ?? '';
    final subjectId = subjectsNotifier.nameToIdMap[selectedSubject] ?? '';

    if (classId.isNotEmpty && subjectId.isNotEmpty) {
      await _fetch(classId, subjectId);
    }
  }

  bool _isFetching = false;

  Future<void> _fetch(String classId, String subjectId) async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      debugPrint('GRADES_FETCH: Fetching grades for classId: $classId, subjectId: $subjectId');
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('grades/class/$classId/subject/$subjectId');
      debugPrint('GRADES_FETCH: Response status: ${response.statusCode}, Data: ${response.data}');
      if (!ref.mounted) return;
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['grades'] ?? [];
        final grades = list.map((x) => StudentSubjectGrade.fromMap(x)).toList();
        debugPrint('GRADES_FETCH: Successfully parsed ${grades.length} student grades');
        
        state = ClassSubjectGrades(
          classId: classId,
          subjectName: ref.read(selectedSubjectProvider),
          grades: grades,
        );
      } else {
        debugPrint('GRADES_FETCH: API returned success: false or null data');
      }
    } catch (e) {
      debugPrint('GRADES_FETCH: Error fetching class subject grades: $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<void> updateStudentGrade(String studentId, StudentSubjectGrade newGrade) async {
    final oldGrade = state.grades.firstWhere(
      (g) => g.studentId == studentId,
      orElse: () => newGrade,
    );

    // Save previous state for rollback
    final previousState = state;

    // 1. Update local state immediately for fast response
    state = state.copyWith(
      grades: [
        for (final g in state.grades)
          if (g.studentId == studentId) newGrade else g
      ],
    );

    // 2. Detect changes and call POST grades/detailed
    try {
      final dio = ref.read(apiClientProvider);

      // Compare Term 1
      await _saveTermChanges(dio, studentId, newGrade.subjectId, 1, oldGrade.firstTerm, newGrade.firstTerm);

      // Compare Term 2
      await _saveTermChanges(dio, studentId, newGrade.subjectId, 2, oldGrade.secondTerm, newGrade.secondTerm);

    } catch (e) {
      // Rollback on failure
      if (ref.mounted) {
        state = previousState;
      }
      debugPrint('Error saving student grade to backend: $e');
    }
  }

  Future<void> _saveTermChanges(
    Dio dio,
    String studentId,
    String subjectId,
    int termIndex,
    TermRecord oldTerm,
    TermRecord newTerm,
  ) async {
    // Compare final exams
    if (oldTerm.finalExam != newTerm.finalExam) {
      await dio.post('grades/detailed', data: {
        'student_id': int.tryParse(studentId) ?? 0,
        'subject_id': int.tryParse(subjectId) ?? 0,
        'term': termIndex.toString(),
        'month': 'final',
        'final_exam': newTerm.finalExam,
      });
    }

    // Compare months
    for (int i = 0; i < 3; i++) {
      final oldMonth = oldTerm.months[i];
      final newMonth = newTerm.months[i];

      if (oldMonth.homework != newMonth.homework ||
          oldMonth.attendance != newMonth.attendance ||
          oldMonth.behavior != newMonth.behavior ||
          oldMonth.oral != newMonth.oral ||
          oldMonth.written != newMonth.written) {
          
        await dio.post('grades/detailed', data: {
          'student_id': int.tryParse(studentId) ?? 0,
          'subject_id': int.tryParse(subjectId) ?? 0,
          'term': termIndex.toString(),
          'month': 'm${i + 1}',
          'hw_grade': newMonth.homework,
          'att_grade': newMonth.attendance,
          'beh_grade': newMonth.behavior,
          'oral_grade': newMonth.oral,
          'wrt_grade': newMonth.written,
        });
      }
    }
  }
}
