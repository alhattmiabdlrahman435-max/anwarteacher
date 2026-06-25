class GradeEntry {
  final String studentId;
  final String studentName;
  final double? oral;      // 0-20
  final double? written;   // 0-40
  final double? activity;  // 0-10
  final double? finalExam; // 0-30

  const GradeEntry({
    required this.studentId,
    required this.studentName,
    this.oral,
    this.written,
    this.activity,
    this.finalExam,
  });

  double get total {
    return (oral ?? 0) + (written ?? 0) + (activity ?? 0) + (finalExam ?? 0);
  }

  GradeEntry copyWith({
    double? oral,
    double? written,
    double? activity,
    double? finalExam,
  }) {
    return GradeEntry(
      studentId: studentId,
      studentName: studentName,
      oral: oral ?? this.oral,
      written: written ?? this.written,
      activity: activity ?? this.activity,
      finalExam: finalExam ?? this.finalExam,
    );
  }
}

class SubjectGrades {
  final String classId;
  final String subjectName;
  final List<GradeEntry> grades;

  const SubjectGrades({
    required this.classId,
    required this.subjectName,
    required this.grades,
  });
}
