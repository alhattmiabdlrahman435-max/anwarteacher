class MonthRecord {
  final int monthIndex; // 1, 2, or 3
  final double attendance; // مواظبة
  final double behavior; // سلوك
  final double oral; // شفوي
  final double homework; // واجبات
  final double written; // تحريري

  const MonthRecord({
    required this.monthIndex,
    this.attendance = 0,
    this.behavior = 0,
    this.oral = 0,
    this.homework = 0,
    this.written = 0,
  });

  double get total => attendance + behavior + oral + homework + written;

  MonthRecord copyWith({
    int? monthIndex,
    double? attendance,
    double? behavior,
    double? oral,
    double? homework,
    double? written,
  }) {
    return MonthRecord(
      monthIndex: monthIndex ?? this.monthIndex,
      attendance: attendance ?? this.attendance,
      behavior: behavior ?? this.behavior,
      oral: oral ?? this.oral,
      homework: homework ?? this.homework,
      written: written ?? this.written,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monthIndex': monthIndex,
      'attendance': attendance,
      'behavior': behavior,
      'oral': oral,
      'homework': homework,
      'written': written,
    };
  }

  factory MonthRecord.fromMap(Map<String, dynamic> map) {
    return MonthRecord(
      monthIndex: map['monthIndex']?.toInt() ?? 0,
      attendance: map['attendance']?.toDouble() ?? 0.0,
      behavior: map['behavior']?.toDouble() ?? 0.0,
      oral: map['oral']?.toDouble() ?? 0.0,
      homework: map['homework']?.toDouble() ?? 0.0,
      written: map['written']?.toDouble() ?? 0.0,
    );
  }
}

class TermRecord {
  final int termIndex; // 1 or 2
  final List<MonthRecord> months;
  final double finalExam;

  const TermRecord({
    required this.termIndex,
    required this.months,
    this.finalExam = 0,
  });

  double get monthsAverage {
    if (months.isEmpty) return 0;
    double sum = months.fold(0, (prev, month) => prev + month.total);
    return sum / 15;
  }

  double get termTotal => monthsAverage + finalExam;

  TermRecord copyWith({
    int? termIndex,
    List<MonthRecord>? months,
    double? finalExam,
  }) {
    return TermRecord(
      termIndex: termIndex ?? this.termIndex,
      months: months ?? this.months,
      finalExam: finalExam ?? this.finalExam,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'termIndex': termIndex,
      'months': months.map((x) => x.toMap()).toList(),
      'finalExam': finalExam,
    };
  }

  factory TermRecord.fromMap(Map<String, dynamic> map) {
    return TermRecord(
      termIndex: map['termIndex']?.toInt() ?? 0,
      months: List<MonthRecord>.from(map['months']?.map((x) => MonthRecord.fromMap(x)) ?? []),
      finalExam: map['finalExam']?.toDouble() ?? 0.0,
    );
  }
}

class StudentSubjectGrade {
  final String studentId;
  final String studentName;
  final String subjectId;
  final TermRecord firstTerm;
  final TermRecord secondTerm;

  const StudentSubjectGrade({
    required this.studentId,
    required this.studentName,
    required this.subjectId,
    required this.firstTerm,
    required this.secondTerm,
  });

  double get yearlyTotal => firstTerm.termTotal + secondTerm.termTotal;

  StudentSubjectGrade copyWith({
    String? studentId,
    String? studentName,
    String? subjectId,
    TermRecord? firstTerm,
    TermRecord? secondTerm,
  }) {
    return StudentSubjectGrade(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      subjectId: subjectId ?? this.subjectId,
      firstTerm: firstTerm ?? this.firstTerm,
      secondTerm: secondTerm ?? this.secondTerm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'subjectId': subjectId,
      'firstTerm': firstTerm.toMap(),
      'secondTerm': secondTerm.toMap(),
    };
  }

  factory StudentSubjectGrade.fromMap(Map<String, dynamic> map) {
    return StudentSubjectGrade(
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      subjectId: map['subjectId'] ?? '',
      firstTerm: TermRecord.fromMap(map['firstTerm']),
      secondTerm: TermRecord.fromMap(map['secondTerm']),
    );
  }
}

class ClassSubjectGrades {
  final String classId;
  final String subjectName;
  final List<StudentSubjectGrade> grades;

  const ClassSubjectGrades({
    required this.classId,
    required this.subjectName,
    required this.grades,
  });

  ClassSubjectGrades copyWith({
    String? classId,
    String? subjectName,
    List<StudentSubjectGrade>? grades,
  }) {
    return ClassSubjectGrades(
      classId: classId ?? this.classId,
      subjectName: subjectName ?? this.subjectName,
      grades: grades ?? this.grades,
    );
  }
}
