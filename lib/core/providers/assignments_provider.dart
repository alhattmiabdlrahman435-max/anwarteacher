import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assignment.dart';

part 'assignments_provider.g.dart';

@riverpod
class AssignmentsData extends _$AssignmentsData {
  @override
  List<Assignment> build() {
    return [
      Assignment(
        id: '1',
        classId: 'class1',
        subjectName: 'الرياضيات',
        title: 'حل تمارين الكسور',
        content: 'الرجاء حل التمارين في صفحة 45 من كتاب الطالب.',
        dateCreated: DateTime.now().subtract(const Duration(days: 2)),
        dueDate: DateTime.now().add(const Duration(days: 1)),
        submissions: const [
          StudentSubmission(studentId: 's1', studentName: 'أحمد محمد عبدالله', status: SubmissionStatus.submitted),
          StudentSubmission(studentId: 's2', studentName: 'سارة محمد عبدالله', status: SubmissionStatus.notSubmitted),
        ],
      ),
    ];
  }

  void addAssignment(Assignment assignment) {
    state = [...state, assignment];
  }

  void updateSubmission(String assignmentId, String studentId, SubmissionStatus newStatus, String? newNote) {
    state = state.map((assignment) {
      if (assignment.id == assignmentId) {
        final updatedSubmissions = assignment.submissions.map((sub) {
          if (sub.studentId == studentId) {
            return sub.copyWith(status: newStatus, teacherNote: newNote);
          }
          return sub;
        }).toList();
        return assignment.copyWith(submissions: updatedSubmissions);
      }
      return assignment;
    }).toList();
  }
}
