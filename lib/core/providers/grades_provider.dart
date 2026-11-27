import 'dart:async';
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

enum GradesSubmitStatus { success, partial, offline, error }

class GradesSubmitResult {
  final GradesSubmitStatus status;
  final String? errorMessage;
  final int succeededCount;
  final int failedCount;
  final int skippedCount;
  final List<String> failedDetails;

  const GradesSubmitResult({
    required this.status,
    this.errorMessage,
    this.succeededCount = 0,
    this.failedCount = 0,
    this.skippedCount = 0,
    this.failedDetails = const [],
  });

  bool get isSuccess => status == GradesSubmitStatus.success;
  bool get isPartial => status == GradesSubmitStatus.partial;
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
    ref.onDispose(() {
      flushPendingSave();
    });

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
        final subjectType = (response.data['subjectType']?.toString() == 'descriptive') ? 'descriptive' : 'basic';
        final rawEstimates = (response.data['descriptivePolicy'] as Map?)?['estimates'] as List?;
        final estimates = rawEstimates != null && rawEstimates.isNotEmpty
            ? rawEstimates.map((e) => (e is Map ? e['label']?.toString() : e?.toString()) ?? '').where((s) => s.isNotEmpty).toList()
            : const ['ممتاز', 'جيد جداً', 'جيد', 'مقبول', 'ضعيف'];
        
        if (kDebugMode) {
          debugPrint('GRADES_FETCH: Successfully fetched ${remoteGrades.length} student grades from backend');
        }

        // If user already has local unsaved drafts, merge student info but preserve local draft grades
        if (isLocalDraft && state.grades.isNotEmpty) {
          final mergedGrades = _mergeRemoteWithLocal(remoteGrades, state.grades);
          state = ClassSubjectGrades(
            classId: classId,
            subjectName: ref.read(selectedSubjectProvider),
            subjectType: subjectType,
            descriptiveEstimates: estimates,
            grades: mergedGrades,
            hasUnsyncedChanges: true,
            unsyncedStudentIds: state.unsyncedStudentIds,
            isSubmitting: false,
          );
          _cache = state;
          await GradesLocalService.saveGradesLocally(classId, subjectId, state, markAsUnsynced: true);
        } else {
          state = ClassSubjectGrades(
            classId: classId,
            subjectName: ref.read(selectedSubjectProvider),
            subjectType: subjectType,
            descriptiveEstimates: estimates,
            grades: remoteGrades,
            hasUnsyncedChanges: false,
            unsyncedStudentIds: const [],
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

  Timer? _saveDebounceTimer;
  String? _pendingSaveClassId;
  String? _pendingSaveSubjectId;

  /// Immediately flush any pending debounced draft to local storage.
  Future<void> flushPendingSave() async {
    if (_saveDebounceTimer?.isActive ?? false) {
      _saveDebounceTimer?.cancel();
      final cId = _pendingSaveClassId ?? _cache.classId;
      final sId = _pendingSaveSubjectId ?? _loadedSubjectId ?? '';
      if (cId.isNotEmpty && sId.isNotEmpty) {
        await GradesLocalService.saveDraftDelta(cId, sId, _cache);
      }
    }
  }

  /// Update student grade in-memory and debounce compact delta storage write (Offline-First).
  /// Crucial: DOES NOT send HTTP request during typing/editing.
  Future<void> updateStudentGrade(
    String studentId,
    StudentSubjectGrade newGrade, {
    String? changedPeriodKey,
  }) async {
    final updatedGrades = [
      for (final g in state.grades)
        if (g.studentId == studentId) newGrade else g
    ];

    final updatedUnsyncedIds = <String>{
      ...state.unsyncedStudentIds,
      studentId,
    }.toList();

    final updatedDirtyKeys = <String>{...state.dirtyPeriodKeys};
    if (changedPeriodKey != null && changedPeriodKey.isNotEmpty) {
      updatedDirtyKeys.add(changedPeriodKey);
    } else {
      for (final t in [1, 2]) {
        final term = t == 1 ? newGrade.firstTerm : newGrade.secondTerm;
        for (int i = 0; i < term.months.length && i < 3; i++) {
          final m = term.months[i];
          if (m.total > 0 || m.isSaved) {
            updatedDirtyKeys.add('${studentId}_${t}_m${i + 1}');
          }
        }
        if ((term.finalExam != null && term.finalExam! > 0) || term.isFinalSaved) {
          updatedDirtyKeys.add('${studentId}_${t}_final');
        }
      }
    }

    final updatedVersions = Map<String, int>.from(state.studentEditVersions);
    updatedVersions[studentId] = (updatedVersions[studentId] ?? 0) + 1;

    state = state.copyWith(
      grades: updatedGrades,
      hasUnsyncedChanges: true,
      unsyncedStudentIds: updatedUnsyncedIds,
      dirtyPeriodKeys: updatedDirtyKeys.toList(),
      studentEditVersions: updatedVersions,
    );
    _cache = state;

    final classId = state.classId;
    final subjectId = newGrade.subjectId.isNotEmpty
        ? newGrade.subjectId
        : (_loadedSubjectId ?? '');

    if (classId.isNotEmpty && subjectId.isNotEmpty) {
      _pendingSaveClassId = classId;
      _pendingSaveSubjectId = subjectId;
      _saveDebounceTimer?.cancel();
      final snapshot = state;
      _saveDebounceTimer = Timer(const Duration(milliseconds: 350), () {
        GradesLocalService.saveDraftDelta(classId, subjectId, snapshot);
      });
    }
  }

  /// Send ONLY dirty/changed periods of selected students via a single bulk HTTP request.
  Future<GradesSubmitResult> sendGradesToAdministration({
    Set<String>? selectedStudentIds,
  }) async {
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

    // Flush any pending debounced local save before submitting
    await flushPendingSave();

    final targetGrades = selectedStudentIds == null
        ? state.grades
        : state.grades.where((g) => selectedStudentIds.contains(g.studentId)).toList();

    if (targetGrades.isEmpty) {
      return const GradesSubmitResult(
        status: GradesSubmitStatus.error,
        errorMessage: 'يرجى تحديد طالب واحد على الأقل للإرسال',
      );
    }

    // Snapshot edit versions and dirty keys at t=0 before network I/O
    final sentVersions = <String, int>{
      for (final g in targetGrades) g.studentId: (state.studentEditVersions[g.studentId] ?? 0),
    };
    final dirtySet = state.dirtyPeriodKeys.toSet();
    final List<Map<String, dynamic>> bulkItems = [];
    final Map<String, Set<String>> submittedKeysByStudent = {};
    int skippedCount = 0;

    for (final student in targetGrades) {
      final sId = student.studentId;
      final sIdInt = int.tryParse(sId) ?? 0;
      final subIdInt = int.tryParse(student.subjectId.isNotEmpty ? student.subjectId : subjectId) ?? 0;

      final studentItems = <Map<String, dynamic>>[];
      final studentKeys = <String>{};

      for (final tIdx in [1, 2]) {
        final term = tIdx == 1 ? student.firstTerm : student.secondTerm;
        if (state.subjectType != 'descriptive') {
          for (int i = 0; i < term.months.length && i < 3; i++) {
            final m = term.months[i];
            final mCode = 'm${i + 1}';
            final pKey = '${sId}_${tIdx}_$mCode';
            final isDirty = dirtySet.contains(pKey);
            // Send if explicitly dirty (even if 0!) OR fallback for legacy unsynced drafts without dirtyPeriodKeys
            final shouldSend = isDirty || (dirtySet.isEmpty && (m.total > 0 || m.homework > 0 || m.attendance > 0 || m.written > 0));
            if (shouldSend) {
              studentItems.add({
                'student_id': sIdInt,
                'subject_id': subIdInt,
                'term': tIdx.toString(),
                'month': mCode,
                'hw_grade': m.homework,
                'att_grade': m.attendance,
                'beh_grade': m.behavior,
                'oral_grade': m.oral,
                'wrt_grade': m.written,
              });
              studentKeys.add(pKey);
            }
          }
        }

        final fKey = '${sId}_${tIdx}_final';
        final isFinalDirty = dirtySet.contains(fKey);
        final hasDesc = term.descriptiveGrade != null && term.descriptiveGrade!.isNotEmpty;
        final shouldSendFinal = isFinalDirty || (dirtySet.isEmpty && (term.finalExam != null || hasDesc));
        if (shouldSendFinal) {
          studentItems.add({
            'student_id': sIdInt,
            'subject_id': subIdInt,
            'term': tIdx.toString(),
            'month': 'final',
            if (state.subjectType == 'descriptive')
              'descriptive_grade': term.descriptiveGrade
            else
              'final_exam': term.finalExam,
          });
          studentKeys.add(fKey);
        }
      }

      if (studentItems.isEmpty) {
        skippedCount++;
      } else {
        bulkItems.addAll(studentItems);
        submittedKeysByStudent[sId] = studentKeys;
      }
    }

    if (bulkItems.isEmpty) {
      return GradesSubmitResult(
        status: GradesSubmitStatus.error,
        skippedCount: skippedCount,
        errorMessage: 'لا توجد درجات معدّلة أو مدخلة للإرسال للطلاب المحددين',
      );
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.post(
        'grades/detailed/bulk',
        data: {'items': bulkItems},
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final data = response.data;
      if (data is! Map<String, dynamic> || data['results'] is! List) {
        state = state.copyWith(isSubmitting: false);
        return GradesSubmitResult(
          status: GradesSubmitStatus.error,
          failedCount: submittedKeysByStudent.length,
          skippedCount: skippedCount,
          errorMessage: (data is Map && data['message'] != null)
              ? data['message'].toString()
              : 'استجابة غير صالحة من الخادم (${response.statusCode})',
        );
      }

      // Group per-item server results by student_id
      final Map<String, List<Map<String, dynamic>>> resultsByStudent = {};
      for (final raw in (data['results'] as List)) {
        if (raw is Map) {
          final m = Map<String, dynamic>.from(raw);
          final sid = m['student_id']?.toString() ?? '';
          resultsByStudent.putIfAbsent(sid, () => []).add(m);
        }
      }

      final Set<String> succeededStudents = {};
      final Set<String> failedStudents = {};
      final List<String> failedDetails = [];
      final Set<String> confirmedSentKeys = {};

      for (final entry in submittedKeysByStudent.entries) {
        final sId = entry.key;
        final itemResults = resultsByStudent[sId] ?? const [];
        if (itemResults.isEmpty) {
          failedStudents.add(sId);
          failedDetails.add('الطالب $sId: لم يصل تأكيد من الخادم');
          continue;
        }

        final failedItems = itemResults.where((r) => r['success'] != true).toList();
        if (failedItems.isNotEmpty) {
          failedStudents.add(sId);
          final firstErr = failedItems.first['message']?.toString() ?? 'فشل الحفظ';
          failedDetails.add('الطالب $sId: $firstErr');
        } else {
          succeededStudents.add(sId);
          // Only clear dirty keys if the student was NOT edited again while in flight
          final currentVer = state.studentEditVersions[sId] ?? 0;
          if (currentVer == (sentVersions[sId] ?? 0)) {
            confirmedSentKeys.addAll(entry.value);
          }
        }
      }

      // Compute remaining unsynced state carefully (preserving concurrent edits & failed students)
      final remainingDirtyKeys = state.dirtyPeriodKeys
          .where((k) => !confirmedSentKeys.contains(k))
          .toList();

      final remainingUnsyncedIds = <String>{
        ...state.unsyncedStudentIds.where((id) {
          if (!succeededStudents.contains(id)) return true;
          // If edited during flight, keep in unsynced!
          return (state.studentEditVersions[id] ?? 0) != (sentVersions[id] ?? 0);
        }),
        ...failedStudents,
      }.toList();

      final syncedGrades = state.grades.map((g) {
        if (!succeededStudents.contains(g.studentId)) return g;
        if ((state.studentEditVersions[g.studentId] ?? 0) != (sentVersions[g.studentId] ?? 0)) {
          return g; // Preserve newer in-flight local edit untouched
        }
        final t1Months = g.firstTerm.months.map((m) => m.copyWith(isSaved: true)).toList();
        final t2Months = g.secondTerm.months.map((m) => m.copyWith(isSaved: true)).toList();
        return g.copyWith(
          firstTerm: g.firstTerm.copyWith(
            months: t1Months,
            isFinalSaved: g.firstTerm.finalExam != null,
          ),
          secondTerm: g.secondTerm.copyWith(
            months: t2Months,
            isFinalSaved: g.secondTerm.finalExam != null,
          ),
        );
      }).toList();

      final stillHasUnsynced = remainingUnsyncedIds.isNotEmpty || remainingDirtyKeys.isNotEmpty;
      state = state.copyWith(
        grades: syncedGrades,
        hasUnsyncedChanges: stillHasUnsynced,
        unsyncedStudentIds: remainingUnsyncedIds,
        dirtyPeriodKeys: remainingDirtyKeys,
        isSubmitting: false,
      );
      _cache = state;

      if (stillHasUnsynced) {
        await GradesLocalService.saveDraftDelta(classId, subjectId, state);
      } else {
        await GradesLocalService.markAsSynced(classId, subjectId, state);
      }

      if (failedStudents.isEmpty) {
        return GradesSubmitResult(
          status: GradesSubmitStatus.success,
          succeededCount: succeededStudents.length,
          failedCount: 0,
          skippedCount: skippedCount,
        );
      } else if (succeededStudents.isNotEmpty) {
        return GradesSubmitResult(
          status: GradesSubmitStatus.partial,
          succeededCount: succeededStudents.length,
          failedCount: failedStudents.length,
          skippedCount: skippedCount,
          failedDetails: failedDetails,
          errorMessage: 'نجح إرسال ${succeededStudents.length} وفشل ${failedStudents.length}',
        );
      } else {
        return GradesSubmitResult(
          status: GradesSubmitStatus.error,
          succeededCount: 0,
          failedCount: failedStudents.length,
          skippedCount: skippedCount,
          failedDetails: failedDetails,
          errorMessage: failedDetails.isNotEmpty ? failedDetails.first : 'فشل إرسال الدرجات',
        );
      }
    } on DioException catch (dioErr) {
      state = state.copyWith(isSubmitting: false);
      if (dioErr.type == DioExceptionType.connectionError ||
          dioErr.type == DioExceptionType.connectionTimeout) {
        return GradesSubmitResult(
          status: GradesSubmitStatus.offline,
          failedCount: submittedKeysByStudent.length,
          skippedCount: skippedCount,
        );
      }
      return GradesSubmitResult(
        status: GradesSubmitStatus.error,
        failedCount: submittedKeysByStudent.length,
        skippedCount: skippedCount,
        errorMessage: dioErr.message ?? 'فشل الاتصال بالخادم',
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      return GradesSubmitResult(
        status: GradesSubmitStatus.error,
        failedCount: submittedKeysByStudent.length,
        skippedCount: skippedCount,
        errorMessage: e.toString(),
      );
    }
  }
}
