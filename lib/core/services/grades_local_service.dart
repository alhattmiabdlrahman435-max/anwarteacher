import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/academic_grade.dart';

class GradesLocalService {
  static const String _prefixCache = 'grades_cache_';
  static const String _prefixUnsynced = 'grades_unsynced_';
  static const String _prefixLastModified = 'grades_last_mod_';

  static String _getCacheKey(String classId, String subjectId) =>
      '$_prefixCache${classId}_$subjectId';

  static String _getUnsyncedKey(String classId, String subjectId) =>
      '$_prefixUnsynced${classId}_$subjectId';

  static String _getLastModifiedKey(String classId, String subjectId) =>
      '$_prefixLastModified${classId}_$subjectId';

  /// Load cached grades for a specific class and subject
  static Future<ClassSubjectGrades?> getCachedGrades(
      String classId, String subjectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getCacheKey(classId, subjectId);
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
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(classId, subjectId);
      final jsonStr = jsonEncode(grades.toMap());
      await prefs.setString(cacheKey, jsonStr);

      if (markAsUnsynced) {
        final unsyncedKey = _getUnsyncedKey(classId, subjectId);
        await prefs.setBool(unsyncedKey, true);
      }

      final modKey = _getLastModifiedKey(classId, subjectId);
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
      String classId, String subjectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUnsyncedKey(classId, subjectId);
      return prefs.getBool(key) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Mark the local grades for this class and subject as synced with administration
  static Future<void> markAsSynced(
      String classId, String subjectId, ClassSubjectGrades currentGrades) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unsyncedKey = _getUnsyncedKey(classId, subjectId);
      await prefs.setBool(unsyncedKey, false);

      // Also save with markAsUnsynced = false
      await saveGradesLocally(classId, subjectId, currentGrades,
          markAsUnsynced: false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GRADES_LOCAL: Error marking grades as synced: $e');
      }
    }
  }
}
