enum AttendanceStatus { present, absent, late, excused, unknown }

class StudentEntity {
  final String id;
  final String name;
  final String? nameEn;
  final String parentName;
  final String? parentNameEn;
  final String parentPhone;
  final String? photoUrl;
  final String? parentPhotoUrl;
  final AttendanceStatus status;
  final bool isLocked;

  const StudentEntity({
    required this.id,
    required this.name,
    this.nameEn,
    required this.parentName,
    this.parentNameEn,
    required this.parentPhone,
    this.photoUrl,
    this.parentPhotoUrl,
    this.status = AttendanceStatus.unknown,
    this.isLocked = false,
  });

  factory StudentEntity.fromJson(Map<String, dynamic> json) {
    AttendanceStatus status = AttendanceStatus.unknown;
    final statusStr = json['status']?.toString().toLowerCase();
    if (statusStr == 'present') {
      status = AttendanceStatus.present;
    } else if (statusStr == 'absent') {
      status = AttendanceStatus.absent;
    } else if (statusStr == 'late') {
      status = AttendanceStatus.late;
    } else if (statusStr == 'excused') {
      status = AttendanceStatus.excused;
    }
    
    return StudentEntity(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      nameEn: json['nameEn'] ?? json['name'] ?? '',
      parentName: json['parentName'] ?? '',
      parentPhone: json['parentPhone'] ?? '',
      photoUrl: json['photoUrl'] ?? json['photo_url'],
      status: status,
      isLocked: json['isLocked'] ?? false,
    );
  }

  String getLocalizedName(String languageCode) {
    if (languageCode.toLowerCase() == 'en') {
      return (nameEn != null && nameEn!.trim().isNotEmpty) ? nameEn! : name;
    }
    return name;
  }

  String getLocalizedParentName(String languageCode) {
    if (languageCode.toLowerCase() == 'en') {
      return (parentNameEn != null && parentNameEn!.trim().isNotEmpty) ? parentNameEn! : parentName;
    }
    return parentName;
  }

  StudentEntity copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? parentName,
    String? parentNameEn,
    String? parentPhone,
    String? photoUrl,
    String? parentPhotoUrl,
    AttendanceStatus? status,
    bool? isLocked,
  }) {
    return StudentEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      parentName: parentName ?? this.parentName,
      parentNameEn: parentNameEn ?? this.parentNameEn,
      parentPhone: parentPhone ?? this.parentPhone,
      photoUrl: photoUrl ?? this.photoUrl,
      parentPhotoUrl: parentPhotoUrl ?? this.parentPhotoUrl,
      status: status ?? this.status,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

class ClassroomEntity {
  final String id;
  final String name;
  final String? nameEn;
  final String grade;
  final int studentCount;

  const ClassroomEntity({
    required this.id,
    required this.name,
    this.nameEn,
    required this.grade,
    required this.studentCount,
  });

  factory ClassroomEntity.fromJson(Map<String, dynamic> json) {
    return ClassroomEntity(
      id: json['id']?.toString() ?? '',
      name: json['name_ar'] ?? json['name'] ?? '',
      nameEn: json['name_en'] ?? json['name'] ?? '',
      grade: json['grade_level'] ?? '',
      studentCount: json['students_count'] ?? 0,
    );
  }

  String getLocalizedName(String languageCode) {
    if (languageCode.toLowerCase() == 'en') {
      return (nameEn != null && nameEn!.trim().isNotEmpty) ? nameEn! : name;
    }
    return name;
  }

  ClassroomEntity copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? grade,
    int? studentCount,
  }) {
    return ClassroomEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      grade: grade ?? this.grade,
      studentCount: studentCount ?? this.studentCount,
    );
  }
}

class ReportEntity {
  final DateTime date;
  final double attendancePercentage;

  const ReportEntity({required this.date, required this.attendancePercentage});

  factory ReportEntity.fromJson(Map<String, dynamic> json) {
    return ReportEntity(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      attendancePercentage: (json['attendancePercentage'] as num?)?.toDouble() ?? 100.0,
    );
  }
}

class StudentReportEntity {
  final String name;
  final String? nameEn;
  final String? civilId;
  final int presentCount;
  final int absentCount;
  final String? photoUrl;

  const StudentReportEntity({
    required this.name,
    this.nameEn,
    this.civilId,
    required this.presentCount,
    required this.absentCount,
    this.photoUrl,
  });

  factory StudentReportEntity.fromJson(Map<String, dynamic> json) {
    return StudentReportEntity(
      name: json['name'] ?? '',
      nameEn: json['nameEn'],
      civilId: json['civilId']?.toString(),
      presentCount: json['presentCount'] ?? 0,
      absentCount: json['absentCount'] ?? 0,
      photoUrl: json['photoUrl'],
    );
  }

  String getLocalizedName(String languageCode) {
    if (languageCode.toLowerCase() == 'en') {
      return (nameEn != null && nameEn!.trim().isNotEmpty) ? nameEn! : name;
    }
    return name;
  }
}

class AttendanceStatsEntity {
  final int totalStudents;
  final int presentToday;
  final int absentToday;
  final int unmarkedToday;
  final double averageAttendance;
  final List<ReportEntity> weeklyTrend;
  final List<StudentReportEntity> studentReports;

  const AttendanceStatsEntity({
    required this.totalStudents,
    required this.presentToday,
    required this.absentToday,
    required this.unmarkedToday,
    required this.averageAttendance,
    required this.weeklyTrend,
    required this.studentReports,
  });

  factory AttendanceStatsEntity.fromJson(Map<String, dynamic> json) {
    final List<dynamic> weeklyTrendJson = json['weeklyTrend'] ?? [];
    final List<dynamic> studentReportsJson = json['studentReports'] ?? [];
    return AttendanceStatsEntity(
      totalStudents: json['totalStudents'] ?? 0,
      presentToday: json['presentToday'] ?? 0,
      absentToday: json['absentToday'] ?? 0,
      unmarkedToday: json['unmarkedToday'] ?? 0,
      averageAttendance: (json['averageAttendance'] as num?)?.toDouble() ?? 100.0,
      weeklyTrend: weeklyTrendJson.map((w) => ReportEntity.fromJson(w)).toList(),
      studentReports: studentReportsJson.map((s) => StudentReportEntity.fromJson(s)).toList(),
    );
  }
}

class AttendanceHistoryRecord {
  final DateTime date;
  final List<StudentEntity> attendedStudents;
  final int totalStudents;
  final int presentCount;
  final int absentCount;

  const AttendanceHistoryRecord({
    required this.date,
    required this.attendedStudents,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
  });

  factory AttendanceHistoryRecord.fromJson(Map<String, dynamic> json) {
    final List<dynamic> studentsJson = json['attendedStudents'] ?? [];
    return AttendanceHistoryRecord(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      attendedStudents: studentsJson.map((s) => StudentEntity.fromJson(s)).toList(),
      totalStudents: json['totalStudents'] ?? 0,
      presentCount: json['presentCount'] ?? 0,
      absentCount: json['absentCount'] ?? 0,
    );
  }

  double get attendanceRate =>
      totalStudents > 0 ? (presentCount / totalStudents) * 100 : 0;
}

class AttendanceHistoryEntity {
  final String classId;
  final String className;
  final String? classNameEn;
  final List<AttendanceHistoryRecord> dailyRecords;

  const AttendanceHistoryEntity({
    required this.classId,
    required this.className,
    this.classNameEn,
    required this.dailyRecords,
  });

  factory AttendanceHistoryEntity.fromJson(Map<String, dynamic> json) {
    final List<dynamic> recordsJson = json['dailyRecords'] ?? [];
    return AttendanceHistoryEntity(
      classId: json['classId']?.toString() ?? '',
      className: json['className'] ?? '',
      classNameEn: json['classNameEn'] ?? json['className'] ?? '',
      dailyRecords: recordsJson.map((r) => AttendanceHistoryRecord.fromJson(r)).toList(),
    );
  }

  String getLocalizedClassName(String languageCode) {
    if (languageCode.toLowerCase() == 'en') {
      return (classNameEn != null && classNameEn!.trim().isNotEmpty) ? classNameEn! : className;
    }
    return className;
  }
}
