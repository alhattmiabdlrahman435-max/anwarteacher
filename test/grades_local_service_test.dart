import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anwarteacher/core/models/academic_grade.dart';
import 'package:anwarteacher/core/services/grades_local_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GradesLocalService & Model Tests', () {
    test('ClassSubjectGrades serialization to and from Map', () {
      final grades = ClassSubjectGrades(
        classId: 'c1',
        subjectName: 'الرياضيات',
        grades: [
          StudentSubjectGrade(
            studentId: '101',
            studentName: 'أحمد علي',
            subjectId: 's1',
            firstTerm: TermRecord(
              termIndex: 1,
              months: [
                const MonthRecord(
                  monthIndex: 1,
                  homework: 15,
                  attendance: 15,
                  behavior: 10,
                  oral: 10,
                  written: 50,
                  isSaved: false,
                ),
              ],
            ),
            secondTerm: const TermRecord(termIndex: 2, months: []),
          ),
        ],
      );

      final map = grades.toMap();
      final fromMap = ClassSubjectGrades.fromMap(map);

      expect(fromMap.classId, 'c1');
      expect(fromMap.subjectName, 'الرياضيات');
      expect(fromMap.grades.length, 1);
      expect(fromMap.grades.first.studentName, 'أحمد علي');
      expect(fromMap.grades.first.firstTerm.months.first.homework, 15);
      expect(fromMap.grades.first.firstTerm.months.first.total, 100);
    });

    test('Save and retrieve cached grades with unsynced flag', () async {
      final grades = ClassSubjectGrades(
        classId: 'class_5a',
        subjectName: 'العلوم',
        grades: [
          StudentSubjectGrade(
            studentId: '501',
            studentName: 'سارة محمد',
            subjectId: 'sub_sci',
            firstTerm: TermRecord(
              termIndex: 1,
              months: [
                const MonthRecord(
                  monthIndex: 1,
                  homework: 14,
                  attendance: 15,
                  written: 45,
                ),
              ],
            ),
            secondTerm: const TermRecord(termIndex: 2, months: []),
          ),
        ],
      );

      // Save locally with markAsUnsynced = true
      await GradesLocalService.saveGradesLocally('class_5a', 'sub_sci', grades, markAsUnsynced: true);

      // Check unsynced status
      final hasUnsynced = await GradesLocalService.hasUnsyncedGrades('class_5a', 'sub_sci');
      expect(hasUnsynced, true);

      // Retrieve cached grades
      final retrieved = await GradesLocalService.getCachedGrades('class_5a', 'sub_sci');
      expect(retrieved, isNotNull);
      expect(retrieved!.grades.length, 1);
      expect(retrieved.grades.first.studentId, '501');
      expect(retrieved.grades.first.firstTerm.months.first.homework, 14);

      // Mark as synced
      await GradesLocalService.markAsSynced('class_5a', 'sub_sci', grades);
      final hasUnsyncedAfter = await GradesLocalService.hasUnsyncedGrades('class_5a', 'sub_sci');
      expect(hasUnsyncedAfter, false);
    });
  });
}
