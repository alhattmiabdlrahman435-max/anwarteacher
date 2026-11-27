import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/academic_grade.dart';

class GradesLocalService {
  static const String _prefixCache = 'grades_cache_';
  static const String _prefixDelta = 'grades_delta_';
  static const String _prefixUnsynced = 'grades_unsynced_';
  static const String _prefixLastModified = 'grades_last_mod_';

  static SharedPreferences? _cachedPrefs;

  static Future<SharedPreferences> _getPrefs() async {
    return _cachedPrefs ??= await SharedPreferences.getInstance();
  }

  static String _scopeSegment(String? academicYearId, String? userId) {
    final y = (academicYearId != null && academicYearId.isNotEmpty) ? 'y${academicYearId}_' : '';
    final u = (userId != null && userId.isNotEmpty) ? 'u${userId}_' : '';
    return '$y$u';
  }

  static String _getCacheKey(String classId, String subjectId, {String? academicYearId, String? userId}) =>
      '$_prefixCache${_scopeSegment(academicYearId, userId)}${classId}_$subjectId';

  static String _getDeltaKey(String classId, String subjectId, {String? academicYearId, String? userId}) =>
      '$_prefixDelta${_scopeSegment(academicYearId, userId)}${classId}_$subjectId';

  static String _getUnsyncedKey(String classId, String subjectId, {String? academicYearId, String? userId}) =>
      '$_prefixUnsynced${_scopeSegment(academicYearId, userId)}${classId}_$subjectId';

  static String _getLastModifiedKey(String classId, String subjectId, {String? academicYearId, String? userId}) =>
      '$_prefixLastModified${_scopeSegment(academicYearId, userId)}${classId}_$subjectId';

  /// Load cached grades for a specific class and subject, overlaying any pending delta drafts.
  static Future<ClassSubjectGrades?> getCachedGrades(
      String classId, String subjectId, {String? academicYearId, String? userId}) async {
    try {
      final prefs = await _getPrefs();
      final key = _getCacheKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
      final jsonStr = prefs.getString(key);
      ClassSubjectGrades? base;
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final dynamic decoded = jsonDecode(jsonStr);
        if (decoded is Map<String, dynamic>) {
          base = ClassSubjectGrades.fromMap(decoded);
        }
      }

      // Overlay lightweight delta drafts if present
      final deltaKey = _getDeltaKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
      final deltaStr = prefs.getString(deltaKey);
      if (deltaStr != null && deltaStr.isNotEmpty) {
        final dynamic decodedDelta = jsonDecode(deltaStr);
        if (decodedDelta is Map<String, dynamic>) {
          final deltaStudentsRaw = decodedDelta['students'] as Map<String, dynamic>? ?? {};
          final deltaGrades = <String, StudentSubjectGrade>{
            for (final entry in deltaStudentsRaw.entries)
              entry.key: StudentSubjectGrade.fromMap(entry.value as Map<String, dynamic>),
          };
          final unsyncedIds = List<String>.from(
            (decodedDelta['unsyncedStudentIds'] as List? ?? []).map((e) => e.toString()),
          );
          final dirtyKeys = List<String>.from(
            (decodedDelta['dirtyPeriodKeys'] as List? ?? []).map((e) => e.toString()),
          );
          if (base != null) {
            final mergedList = base.grades
                .map((g) => deltaGrades[g.studentId] ?? g)
                .toList();
            base = base.copyWith(
              grades: mergedList,
              hasUnsyncedChanges: unsyncedIds.isNotEmpty || dirtyKeys.isNotEmpty,
              unsyncedStudentIds: unsyncedIds,
              dirtyPeriodKeys: dirtyKeys,
            );
          } else if (deltaGrades.isNotEmpty) {
            base = ClassSubjectGrades(
              classId: classId,
              subjectName: '',
              grades: deltaGrades.values.toList(),
              hasUnsyncedChanges: unsyncedIds.isNotEmpty || dirtyKeys.isNotEmpty,
              unsyncedStudentIds: unsyncedIds,
              dirtyPeriodKeys: dirtyKeys,
            );
          }
        }
      }

      return base;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GRADES_LOCAL: Error reading cached grades: $e');
      }
    }
    return null;
  }

  /// Save ONLY modified (unsynced) students as a compact delta draft instead of serializing the whole class.
  static Future<void> saveDraftDelta(
    String classId,
    String subjectId,
    ClassSubjectGrades current, {
    String? academicYearId,
    String? userId,
  }) async {
    try {
      final prefs = await _getPrefs();
      final unsyncedSet = current.unsyncedStudentIds.toSet();
      final deltaStudents = <String, dynamic>{};
      for (final g in current.grades) {
        if (unsyncedSet.contains(g.studentId)) {
          deltaStudents[g.studentId] = g.toMap();
        }
      }

      final deltaPayload = {
        'unsyncedStudentIds': current.unsyncedStudentIds,
        'dirtyPeriodKeys': current.dirtyPeriodKeys,
        'students': deltaStudents,
      };

      final deltaKey = _getDeltaKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
      await prefs.setString(deltaKey, jsonEncode(deltaPayload));

      final unsyncedKey = _getUnsyncedKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
      await prefs.setBool(unsyncedKey, unsyncedSet.isNotEmpty || current.dirtyPeriodKeys.isNotEmpty);

      final modKey = _getLastModifiedKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
      await prefs.setString(modKey, DateTime.now().toIso8601String());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GRADES_LOCAL: Error saving delta draft: $e');
      }
    }
  }

  /// Save grades locally to device storage (full base snapshot)
  static Future<void> saveGradesLocally(
    String classId,
    String subjectId,
    ClassSubjectGrades grades, {
    bool markAsUnsynced = true,
    String? academicYearId,
    String? userId,
  }) async {
    try {
      final prefs = await _getPrefs();
      final cacheKey = _getCacheKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
      final jsonStr = jsonEncode(grades.toMap());
      await prefs.setString(cacheKey, jsonStr);

      final unsyncedKey = _getUnsyncedKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
      await prefs.setBool(unsyncedKey, markAsUnsynced);

      if (!markAsUnsynced) {
        final deltaKey = _getDeltaKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
        await prefs.remove(deltaKey);
      }

      final modKey = _getLastModifiedKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
      await prefs.setString(modKey, DateTime.now().toIso8601String());

      if (kDebugMode) {
        debugPrint(
            'GRADES_LOCAL: Saved ${grades.grades.length} grades locally (unsynced: $markAsUnsynced)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GRADES_LOCAL: Error saving grades locally: $e');
      }
    }
  }

  /// Check if there are local modifications that have not been sent to admin
  static Future<bool> hasUnsyncedGrades(
      String classId, String subjectId, {String? academicYearId, String? userId}) async {
    try {
      final prefs = await _getPrefs();
      final key = _getUnsyncedKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
      return prefs.getBool(key) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Mark the local grades for this class and subject as synced with administration
  static Future<void> markAsSynced(
      String classId, String subjectId, ClassSubjectGrades currentGrades, {String? academicYearId, String? userId}) async {
    try {
      final prefs = await _getPrefs();
      final unsyncedKey = _getUnsyncedKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
      await prefs.setBool(unsyncedKey, false);

      final deltaKey = _getDeltaKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
      await prefs.remove(deltaKey);

      // Also save with markAsUnsynced = false
      await saveGradesLocally(classId, subjectId, currentGrades,
          markAsUnsynced: false, academicYearId: academicYearId, userId: userId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GRADES_LOCAL: Error marking grades as synced: $e');
      }
    }
  }

  /// Clear all cached grades (call on logout or academic year switch)
  static Future<void> clearAllCache() async {
    try {
      final prefs = await _getPrefs();
      final keys = prefs.getKeys().where((k) =>
          k.startsWith(_prefixCache) ||
          k.startsWith(_prefixDelta) ||
          k.startsWith(_prefixUnsynced) ||
          k.startsWith(_prefixLastModified)).toList();
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GRADES_LOCAL: Error clearing cache: $e');
      }
    }
  }
}
