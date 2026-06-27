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

  String getLocalizedClassName(String languageCode) {
    if (languageCode.toLowerCase() == 'en') {
      return (classNameEn != null && classNameEn!.trim().isNotEmpty) ? classNameEn! : className;
    }
    return className;
  }
}
