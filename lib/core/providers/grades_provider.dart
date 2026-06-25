import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/academic_grade.dart';

part 'grades_provider.g.dart';

@riverpod
class GradesData extends _$GradesData {
  @override
  ClassSubjectGrades build() {
    TermRecord createEmptyTerm(int termIndex) {
      return TermRecord(
        termIndex: termIndex,
        months: [
          const MonthRecord(monthIndex: 1),
          const MonthRecord(monthIndex: 2),
          const MonthRecord(monthIndex: 3),
        ],
        finalExam: 0,
      );
    }

    return ClassSubjectGrades(
      classId: 'class1',
      subjectName: 'الرياضيات',
      grades: [
        StudentSubjectGrade(
          studentId: 's1',
          studentName: 'أحمد محمد عبدالله',
          subjectId: 'math1',
          firstTerm: createEmptyTerm(1),
          secondTerm: createEmptyTerm(2),
        ),
        StudentSubjectGrade(
          studentId: 's2',
          studentName: 'سارة محمد عبدالله',
          subjectId: 'math1',
          firstTerm: createEmptyTerm(1),
          secondTerm: createEmptyTerm(2),
        ),
        StudentSubjectGrade(
          studentId: 's3',
          studentName: 'عمر محمد عبدالله',
          subjectId: 'math1',
          firstTerm: createEmptyTerm(1),
          secondTerm: createEmptyTerm(2),
        ),
      ],
    );
  }

  void updateStudentGrade(String studentId, StudentSubjectGrade newGrade) {
    state = state.copyWith(
      grades: [
        for (final g in state.grades)
          if (g.studentId == studentId) newGrade else g
      ],
    );
  }
}
