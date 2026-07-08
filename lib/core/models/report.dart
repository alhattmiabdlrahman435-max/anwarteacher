import 'package:flutter/material.dart';

enum ReportStatus {
  pending,
  approved,
  rejected;

  String get nameAr {
    switch (this) {
      case ReportStatus.pending:
        return 'قيد الانتظار';
      case ReportStatus.approved:
        return 'مقبول';
      case ReportStatus.rejected:
        return 'مرفوض';
    }
  }

  String get nameEn {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.approved:
        return 'Approved';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }
}

enum ReportType {
  academic,
  behavioral,
  homework,
  psychological;

  String get nameAr {
    switch (this) {
      case ReportType.academic:
        return 'أكاديمي';
      case ReportType.behavioral:
        return 'سلوكي';
      case ReportType.homework:
        return 'واجبات';
      case ReportType.psychological:
        return 'نفسي';
    }
  }

  String get nameEn {
    switch (this) {
      case ReportType.academic:
        return 'Academic';
      case ReportType.behavioral:
        return 'Behavioral';
      case ReportType.homework:
        return 'Homework';
      case ReportType.psychological:
        return 'Psychological';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportType.academic:
        return Icons.school_rounded;
      case ReportType.behavioral:
        return Icons.sentiment_dissatisfied_rounded;
      case ReportType.homework:
        return Icons.assignment_rounded;
      case ReportType.psychological:
        return Icons.psychology_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ReportType.academic:
        return const Color(0xFF3B82F6);
      case ReportType.behavioral:
        return const Color(0xFFF59E0B);
      case ReportType.homework:
        return const Color(0xFF10B981);
      case ReportType.psychological:
        return const Color(0xFFEC4899);
    }
  }
}

class Report {
  final String id;
  final String studentId;
  final String studentName;
  final String className;
  final ReportType type;
  final String description;
  final String? imageUrl;
  final String? studentPhotoUrl;
  final ReportStatus status;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.type,
    required this.description,
    this.imageUrl,
    this.studentPhotoUrl,
    required this.status,
    required this.createdAt,
  });

  Report copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? className,
    ReportType? type,
    String? description,
    String? imageUrl,
    String? studentPhotoUrl,
    ReportStatus? status,
    DateTime? createdAt,
  }) {
    return Report(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      className: className ?? this.className,
      type: type ?? this.type,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      studentPhotoUrl: studentPhotoUrl ?? this.studentPhotoUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
