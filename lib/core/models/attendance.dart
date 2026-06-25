enum AttendanceStatus { present, absent }

class AttendanceRecord {
  final String id;
  final String studentId;
  final String studentName;
  final DateTime date;
  final AttendanceStatus status;
  final String? note;

  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.status,
    this.note,
  });

  AttendanceRecord copyWith({
    String? id,
    String? studentId,
    String? studentName,
    DateTime? date,
    AttendanceStatus? status,
    String? note,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      date: date ?? this.date,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }
}
