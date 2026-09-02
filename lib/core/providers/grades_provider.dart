import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../models/academic_grade.dart';
import '../network/api_client.dart';
import '../services/grades_local_service.dart';
import 'classes_provider.dart';
import 'subjects_provider.dart';
import 'connectivity_provider.dart';

part 'grades_provider.g.dart';

enum GradesSubmitStatus { success, offline, error }

class GradesSubmitResult {
  final GradesSubmitStatus status;
  final String? errorMessage;

  const GradesSubmitResult({required this.status, this.errorMessage});

  bool get isSuccess => status == GradesSubmitStatus.success;
  bool get isOffline => status == GradesSubmitStatus.offline;
  bool get isError => status == GradesSubmitStatus.error;
}

@riverpod
class GradesData extends _$GradesData {
  String? _loadedClassId;
  String? _loadedSubjectId;
  ClassSubjectGrades _cache = const ClassSubjectGrades(
    classId: '',
    subjectName: '',
    grades: [],
    hasUnsyncedChanges: false,
    isSubmitting: false,
  );

  @override
  ClassSubjectGrades build() {
    final selectedClass = ref.watch(selectedClassProvider);
    final selectedSubject = ref.watch(selectedSubjectProvider);

    if (selectedClass.isEmpty || selectedSubject.isEmpty) {
      _loadedClassId = null;
      _loadedSubjectId = null;
      _cache = const ClassSubjectGrades(
        classId: '',
        subjectName: '',
        grades: [],
        hasUnsyncedChanges: false,
        isSubmitting: false,
      );
      return _cache;
    }

    final classesNotifier = ref.read(classesProvider.notifier);
    final subjectsNotifier = ref.read(subjectsProvider.notifier);

    final classId = classesNotifier.nameToIdMap[selectedClass] ?? '';
    final subjectId = subjectsNotifier.nameToIdMap[selectedSubject] ?? '';

    if (classId.isEmpty || subjectId.isEmpty) {
      _loadedClassId = null;
      _loadedSubjectId = null;
      _cache = ClassSubjectGrades(
        classId: classId,
        subjectName: selectedSubject,
        grades: const [],
        hasUnsyncedChanges: false,
        isSubmitting: false,
      );
      return _cache;
    }

    if (_loadedClassId != classId || _loadedSubjectId != subjectId) {
      _loadedClassId = classId;
      _loadedSubjectId = subjectId;
      _cache = ClassSubjectGrades(
        classId: classId,
        subjectName: selectedSubject,
        grades: const [],
        hasUnsyncedChanges: false,
        isSubmitting: false,
      );
      // Check local cached grades first for instant offline access
      Future.microtask(() => _loadFromLocalThenFetch(classId, subjectId));
    }

    return _cache;
  }

  Future<void> _loadFromLocalThenFetch(String classId, String subjectId) async {
    // 1. Read local cache immediately
    final localGrades = await GradesLocalService.getCachedGrades(classId, subjectId);
    final isUnsynced = await GradesLocalService.hasUnsyncedGrades(classId, subjectId);
    
    if (ref.mounted) {
      if (localGrades != null && localGrades.grades.isNotEmpty) {
        state = localGrades.copyWith(hasUnsyncedChanges: isUnsynced);
        _cache = state;
      }
    }

    // 2. Fetch fresh data from backend in background if online and not unsynced
    await _fetch(classId, subjectId, isLocalDraft: isUnsynced);
  }

  Future<void> refresh() async {
    final selectedClass = ref.read(selectedClassProvider);
    final selectedSubject = ref.read(selectedSubjectProvider);
    final classesNotifier = ref.read(classesProvider.notifier);
    final subjectsNotifier = ref.read(subjectsProvider.notifier);

    final classId = classesNotifier.nameToIdMap[selectedClass] ?? '';
    final subjectId = subjectsNotifier.nameToIdMap[selectedSubject] ?? '';

    if (classId.isNotEmpty && subjectId.isNotEmpty) {
      final isUnsynced = await GradesLocalService.hasUnsyncedGrades(classId, subjectId);
      await _fetch(classId, subjectId, isLocalDraft: isUnsynced);
    }
  }

  bool _isFetching = false;

  Future<void> _fetch(String classId, String subjectId, {bool isLocalDraft = false}) async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      if (kDebugMode) {
        debugPrint('GRADES_FETCH: Fetching grades for classId: $classId, subjectId: $subjectId');
      }
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('grades/class/$classId/subject/$subjectId');
      
      if (!ref.mounted) return;
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['grades'] ?? [];
        final remoteGrades = list.map((x) => StudentSubjectGrade.fromMap(x)).toList();
        
        if (kDebugMode) {
          debugPrint('GRADES_FETCH: Successfully fetched ${remoteGrades.length} student grades from backend');
        }

        // If user already has local unsaved drafts, merge student info but preserve local draft grades
        if (isLocalDraft && state.grades.isNotEmpty) {
          final mergedGrades = _mergeRemoteWithLocal(remoteGrades, state.grades);
          state = ClassSubjectGrades(
            classId: classId,
            subjectName: ref.read(selectedSubjectProvider),
            grades: mergedGrades,
            hasUnsyncedChanges: true,
            isSubmitting: false,
          );
          _cache = state;
          await GradesLocalService.saveGradesLocally(classId, subjectId, state, markAsUnsynced: true);
        } else {
          state = ClassSubjectGrades(
            classId: classId,
            subjectName: ref.read(selectedSubjectProvider),
            grades: remoteGrades,
            hasUnsyncedChanges: false,
            isSubmitting: false,
          );
          _cache = state;
          // Save server data locally as synced cache
          await GradesLocalService.saveGradesLocally(classId, subjectId, state, markAsUnsynced: false);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GRADES_FETCH: Network fetch failed (offline or server error): $e');
      }
      // If network fails, local cached data remains in state cleanly
    } finally {
      _isFetching = false;
    }
  }

  List<StudentSubjectGrade> _mergeRemoteWithLocal(
    List<StudentSubjectGrade> remote,
    List<StudentSubjectGrade> local,
  ) {
    final Map<String, StudentSubjectGrade> localMap = {
      for (final g in local) g.studentId: g,
    };
    final List<StudentSubjectGrade> result = [];
    for (final r in remote) {
      final l = localMap[r.studentId];
      if (l != null) {
        // Keep local entered grades, but update student name/photo if remote has it
        result.add(l.copyWith(
          studentName: r.studentName.isNotEmpty ? r.studentName : l.studentName,
          studentPhotoUrl: r.studentPhotoUrl ?? l.studentPhotoUrl,
        ));
        localMap.remove(r.studentId);
      } else {
        result.add(r);
      }
    }
    // Add any local students not in remote
    result.addAll(localMap.values);
    return result;
  }

  /// Update student grade in-memory and save to local storage (Offline-First)
  /// Crucial: DOES NOT send HTTP request during typing/editing.
  Future<void> updateStudentGrade(String studentId, StudentSubjectGrade newGrade) async {
    final updatedGrades = [
      for (final g in state.grades)
        if (g.studentId == studentId) newGrade else g
    ];

    state = state.copyWith(
      grades: updatedGrades,
      hasUnsyncedChanges: true,
    );
    _cache = state;

    final classId = state.classId;
    final subjectId = newGrade.subjectId.isNotEmpty 
        ? newGrade.subjectId 
        : (_loadedSubjectId ?? '');

    if (classId.isNotEmpty && subjectId.isNotEmpty) {
      await GradesLocalService.saveGradesLocally(
        classId,
        subjectId,
        state,
        markAsUnsynced: true,
      );
    }
  }

  /// Send all grades for the current class & subject to Administration
  Future<GradesSubmitResult> sendGradesToAdministration() async {
    final connectivity = ref.read(connectivityProvider);
    if (connectivity == ConnectivityStatus.offline) {
      return const GradesSubmitResult(status: GradesSubmitStatus.offline);
    }

    final classId = state.classId;
    final subjectId = _loadedSubjectId ?? '';

    if (classId.isEmpty || subjectId.isEmpty || state.grades.isEmpty) {
      return const GradesSubmitResult(
        status: GradesSubmitStatus.error,
        errorMessage: 'لا توجد درجات لإرسالها',
      );
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final dio = ref.read(apiClientProvider);

      // Iterate through all students and push grades
      for (final student in state.grades) {
        final sId = student.studentId;
        final subId = student.subjectId.isNotEmpty ? student.subjectId : subjectId;

        // Push Term 1
        await _postTermGrades(dio, sId, subId, 1, student.firstTerm);

        // Push Term 2
        await _postTermGrades(dio, sId, subId, 2, student.secondTerm);
      }

      // Mark all months and finals as isSaved: true in state
      final syncedGrades = state.grades.map((g) {
        final t1Months = g.firstTerm.months.map((m) => m.copyWith(isSaved: true)).toList();
        final t2Months = g.secondTerm.months.map((m) => m.copyWith(isSaved: true)).toList();
        return g.copyWith(
          firstTerm: g.firstTerm.copyWith(months: t1Months, isFinalSaved: true),
          secondTerm: g.secondTerm.copyWith(months: t2Months, isFinalSaved: true),
        );
      }).toList();

      state = state.copyWith(
        grades: syncedGrades,
        hasUnsyncedChanges: false,
        isSubmitting: false,
      );
      _cache = state;

      // Update local storage to synced
      await GradesLocalService.markAsSynced(classId, subjectId, state);

      return const GradesSubmitResult(status: GradesSubmitStatus.success);
    } on DioException catch (dioErr) {
      state = state.copyWith(isSubmitting: false);
      if (dioErr.type == DioExceptionType.connectionError ||
          dioErr.type == DioExceptionType.connectionTimeout) {
        return const GradesSubmitResult(status: GradesSubmitStatus.offline);
      }
      return GradesSubmitResult(
        status: GradesSubmitStatus.error,
        errorMessage: dioErr.message ?? 'فشل الاتصال بالخادم',
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      return GradesSubmitResult(
        status: GradesSubmitStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _postTermGrades(
    Dio dio,
    String studentId,
    String subjectId,
    int termIndex,
    TermRecord term,
  ) async {
    final sIdInt = int.tryParse(studentId) ?? 0;
    final subIdInt = int.tryParse(subjectId) ?? 0;

    // Post months
    for (int i = 0; i < term.months.length && i < 3; i++) {
      final month = term.months[i];
      // Only post if has values
      if (month.total > 0 || month.homework > 0 || month.attendance > 0 || month.written > 0) {
        try {
          await dio.post('grades/detailed', data: {
            'student_id': sIdInt,
            'subject_id': subIdInt,
            'term': termIndex.toString(),
            'month': 'm${i + 1}',
            'hw_grade': month.homework,
            'att_grade': month.attendance,
            'beh_grade': month.behavior,
            'oral_grade': month.oral,
            'wrt_grade': month.written,
          });
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error posting month ${i + 1} for student $studentId: $e');
          }
        }
      }
    }

    // Post final exam
    if (term.finalExam > 0) {
      try {
        await dio.post('grades/detailed', data: {
          'student_id': sIdInt,
          'subject_id': subIdInt,
          'term': termIndex.toString(),
          'month': 'final',
          'final_exam': term.finalExam,
        });
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error posting final exam for student $studentId: $e');
        }
      }
    }
  }
}
