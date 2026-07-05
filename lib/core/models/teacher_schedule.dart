class TeacherPeriod {
  final String subjectName;
  final String className;
  final String startTime;
  final String endTime;

  const TeacherPeriod({
    required this.subjectName,
    required this.className,
    required this.startTime,
    required this.endTime,
  });

  factory TeacherPeriod.fromJson(Map<String, dynamic> json) {
    return TeacherPeriod(
      subjectName: json['subject_name']?.toString() ?? '',
      className: json['class_name']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
    );
  }
}
