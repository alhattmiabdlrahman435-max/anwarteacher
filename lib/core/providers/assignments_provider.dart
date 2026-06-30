import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../models/assignment.dart';
import '../network/api_client.dart';

part 'assignments_provider.g.dart';

@riverpod
class AssignmentsData extends _$AssignmentsData {
  @override
  List<Assignment> build() {
    _fetch();
    return const [];
  }

  Future<void> _fetch() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('assignments');
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['assignments'] ?? [];
        state = list.map((item) {
          final List<dynamic> subList = item['submissions'] ?? [];
          final submissions = subList.map((sub) {
            final studentName = sub['student']?['name_ar'] ?? sub['student']?['name'] ?? '';
            final dbStatus = sub['status']?.toString() ?? 'pending';
            SubmissionStatus status = SubmissionStatus.notSubmitted;
            if (dbStatus == 'submitted') {
              status = SubmissionStatus.submitted;
            } else if (dbStatus == 'submitted_late') {
              status = SubmissionStatus.submittedLate;
            }
            return StudentSubmission(
              studentId: sub['student_id']?.toString() ?? '',
              studentName: studentName,
              status: status,
              teacherNote: sub['teacher_note'],
            );
          }).toList();

          return Assignment(
            id: item['id']?.toString() ?? '',
            classId: item['class_id']?.toString() ?? '',
            subjectName: item['subject']?['name_ar'] ?? item['subject']?['name'] ?? '',
            title: item['title'] ?? '',
            content: item['content'] ?? '',
            dateCreated: DateTime.tryParse(item['date_created']?.toString() ?? '') ?? DateTime.now(),
            dueDate: DateTime.tryParse(item['due_date']?.toString() ?? '') ?? DateTime.now(),
            attachments: item['attachment_url'] != null ? [item['attachment_url'].toString()] : const [],
            submissions: submissions,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching assignments: $e');
    }
  }

  Future<void> addAssignment(Assignment assignment, String? attachmentPath) async {
    try {
      final dio = ref.read(apiClientProvider);
      
      MultipartFile? file;
      if (attachmentPath != null && attachmentPath.isNotEmpty) {
        file = await MultipartFile.fromFile(
          attachmentPath,
          filename: attachmentPath.split('/').last,
        );
      }

      final formData = FormData.fromMap({
        'class_id': int.tryParse(assignment.classId) ?? 0,
        'subject_id': int.tryParse(assignment.subjectName) ?? 0,
        'title': assignment.title,
        'content': assignment.content,
        'due_date': '${assignment.dueDate.year}-${assignment.dueDate.month.toString().padLeft(2, '0')}-${assignment.dueDate.day.toString().padLeft(2, '0')}',
        'attachment': file,
      });

      await dio.post('assignments', data: formData);

      // Refresh local list
      await _fetch();
    } catch (e) {
      debugPrint('Error adding assignment: $e');
      rethrow;
    }
  }

  Future<void> updateSubmission(String assignmentId, String studentId, SubmissionStatus newStatus, String? newNote) async {
    // 1. Update local state immediately
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

    // 2. Put submission changes to backend
    try {
      final dio = ref.read(apiClientProvider);
      String statusStr = 'pending';
      if (newStatus == SubmissionStatus.submitted) {
        statusStr = 'submitted';
      } else if (newStatus == SubmissionStatus.submittedLate) {
        statusStr = 'submitted_late';
      }

      await dio.put('assignments/$assignmentId/submissions', data: {
        'submissions': [
          {
            'student_id': int.tryParse(studentId) ?? 0,
            'status': statusStr,
            'teacher_note': newNote ?? '',
          }
        ]
      });
    } catch (e) {
      debugPrint('Error updating assignment submission: $e');
    }
  }
}
