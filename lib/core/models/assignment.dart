enum SubmissionStatus { submitted, notSubmitted, submittedLate }

class StudentSubmission {
  final String studentId;
  final String studentName;
  final SubmissionStatus status;
  final String? teacherNote;

  const StudentSubmission({
    required this.studentId,
    required this.studentName,
    required this.status,
    this.teacherNote,
  });

  StudentSubmission copyWith({
    SubmissionStatus? status,
    String? teacherNote,
  }) {
    return StudentSubmission(
      studentId: studentId,
      studentName: studentName,
      status: status ?? this.status,
      teacherNote: teacherNote ?? this.teacherNote,
    );
  }
}

class Assignment {
  final String id;
  final String classId;
  final String subjectName;
  final String title;
  final String content;
  final DateTime dateCreated;
  final DateTime dueDate;
  final List<String> attachments; // e.g. file paths or URLs
  final List<StudentSubmission> submissions;

  const Assignment({
    required this.id,
    required this.classId,
    required this.subjectName,
    required this.title,
    required this.content,
    required this.dateCreated,
    required this.dueDate,
    this.attachments = const [],
    this.submissions = const [],
  });

  Assignment copyWith({
    String? id,
    String? classId,
    String? subjectName,
    String? title,
    String? content,
    DateTime? dateCreated,
    DateTime? dueDate,
    List<String>? attachments,
    List<StudentSubmission>? submissions,
  }) {
    return Assignment(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      subjectName: subjectName ?? this.subjectName,
      title: title ?? this.title,
      content: content ?? this.content,
      dateCreated: dateCreated ?? this.dateCreated,
      dueDate: dueDate ?? this.dueDate,
      attachments: attachments ?? this.attachments,
      submissions: submissions ?? this.submissions,
    );
  }
}
