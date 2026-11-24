import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/academic_grade.dart';

class GradesLocalService {
  static const String _prefixCache = 'grades_cache_';
  static const String _prefixUnsynced = 'grades_unsynced_';
  static const String _prefixLastModified = 'grades_last_mod_';

  static String _scopeSegment(String? academicYearId, String? userId) {
    final y = (academicYearId != null && academicYearId.isNotEmpty) ? 'y${academicYearId}_' : '';
    final u = (userId != null && userId.isNotEmpty) ? 'u${userId}_' : '';
    return '$y$u';
  }

  static String _getCacheKey(String classId, String subjectId, {String? academicYearId, String? userId}) =>
      '$_prefixCache${_scopeSegment(academicYearId, userId)}${classId}_$subjectId';

  static String _getUnsyncedKey(String classId, String subjectId, {String? academicYearId, String? userId}) =>
      '$_prefixUnsynced${_scopeSegment(academicYearId, userId)}${classId}_$subjectId';

  static String _getLastModifiedKey(String classId, String subjectId, {String? academicYearId, String? userId}) =>
      '$_prefixLastModified${_scopeSegment(academicYearId, userId)}${classId}_$subjectId';

  /// Load cached grades for a specific class and subject (scoped by academicYearId & userId when provided)
  static Future<ClassSubjectGrades?> getCachedGrades(
      String classId, String subjectId, {String? academicYearId, String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getCacheKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
      final jsonStr = prefs.getString(key);
      if (jsonStr == null || jsonStr.isEmpty) return null;

      final dynamic decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        return ClassSubjectGrades.fromMap(decoded);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GRADES_LOCAL: Error reading cached grades: $e');
      }
    }
    return null;
  }

  /// Save grades locally to device storage
  static Future<void> saveGradesLocally(
    String classId,
    String subjectId,
    ClassSubjectGrades grades, {
    bool markAsUnsynced = true,
    String? academicYearId,
    String? userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
      final jsonStr = jsonEncode(grades.toMap());
      await prefs.setString(cacheKey, jsonStr);

      if (markAsUnsynced) {
        final unsyncedKey = _getUnsyncedKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
        await prefs.setBool(unsyncedKey, true);
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
      final prefs = await SharedPreferences.getInstance();
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
      final prefs = await SharedPreferences.getInstance();
      final unsyncedKey = _getUnsyncedKey(classId, subjectId, academicYearId: academicYearId, userId: userId);
      await prefs.setBool(unsyncedKey, false);

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
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) =>
          k.startsWith(_prefixCache) ||
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
