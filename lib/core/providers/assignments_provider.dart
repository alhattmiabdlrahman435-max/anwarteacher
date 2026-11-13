import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../models/assignment.dart';
import '../network/api_client.dart';
import '../services/image_compress_service.dart';
import 'auth_provider.dart';
import 'subjects_provider.dart';

part 'assignments_provider.g.dart';

/// خطأ مُرجع من الخادم عند تعديل الواجب ({success:false, message})
class AssignmentUpdateException implements Exception {
  final String message;
  const AssignmentUpdateException(this.message);

  @override
  String toString() => message;
}

@riverpod
class AssignmentsData extends _$AssignmentsData {
  List<Assignment> _cache = const [];
  String? _loadedUserId;

  @override
  List<Assignment> build() {
    final authState = ref.watch(authProvider);
    if (!authState.isLoggedIn) {
      _loadedUserId = null;
      _cache = const [];
      return const [];
    }
    if (_loadedUserId != authState.userId) {
      _loadedUserId = authState.userId;
      _cache = const [];
      Future.microtask(() => _fetch());
    }
    return _cache;
  }

  bool _isFetching = false;

  /// طُلب تحديث أثناء جلب جارٍ (مثل بعد حفظ تعديل) — نعيد الجلب فور انتهائه حتى لا تبقى بيانات قديمة
  bool _refetchRequested = false;

  Future<void> _fetch() async {
    if (_isFetching) {
      _refetchRequested = true;
      return;
    }
    _isFetching = true;
    try {
      final dio = ref.read(apiClientProvider);
      // كل واجبات المعلم السابقة (الخادم يُرجع 20 فقط افتراضياً)
      final response = await dio.get('assignments', queryParameters: {'per_page': 1000});
      if (!ref.mounted) return;
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['assignments'] ?? [];
        state = list.map((item) {
          final List<dynamic> subList = item['submissions'] ?? [];
          final submissions = subList.map((sub) {
            final studentName = sub['student']?['name_ar'] ?? sub['student']?['name'] ?? '';
            final studentPhotoUrl = sub['student']?['photo_url'] ?? sub['student']?['photoUrl'];
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
              studentPhotoUrl: studentPhotoUrl,
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
            // وقت الإرسال الفعلي بالتوقيت المحلي
            dateCreated: (DateTime.tryParse(item['created_at']?.toString() ?? '') ??
                    DateTime.tryParse(item['date_created']?.toString() ?? '') ??
                    DateTime.now())
                .toLocal(),
            dueDate: DateTime.tryParse(item['due_date']?.toString() ?? '') ?? DateTime.now(),
            attachments: (item['attachment_urls'] is List && (item['attachment_urls'] as List).isNotEmpty)
                ? (item['attachment_urls'] as List).map((u) => u.toString()).toList()
                : (item['attachment_url'] != null ? [item['attachment_url'].toString()] : const []),
            submissions: submissions,
            editedAt: DateTime.tryParse(item['edited_at']?.toString() ?? '')?.toLocal(),
          );
        }).toList();
        _cache = state;
      }
    } catch (e) {
      debugPrint('Error fetching assignments: $e');
    } finally {
      _isFetching = false;
      if (_refetchRequested && ref.mounted) {
        _refetchRequested = false;
        await _fetch();
      }
    }
  }

  Future<void> refresh() async {
    await _fetch();
  }

  Future<void> addAssignment(Assignment assignment, List<String> attachmentPaths) async {
    try {
      final dio = ref.read(apiClientProvider);

      // كل المرفقات (صور تُضغط قبل الرفع، وملفات تُرفع كما هي)
      final files = <MultipartFile>[];
      const imageExts = {'jpg', 'jpeg', 'png', 'webp'};
      for (int i = 0; i < attachmentPaths.length; i++) {
        final path = attachmentPaths[i];
        if (path.isEmpty) continue;
        final ext = path.split('.').last.toLowerCase();
        // الصور المضغوطة مسبقاً (من المعرض/الكاميرا) لا يُعاد ضغطها — أسرع وبدون فقد جودة إضافي
        if (imageExts.contains(ext) && await File(path).length() > ImageCompressService.alreadyCompressedBytes) {
          final result = await ImageCompressService.compress(
            File(path),
            maxWidth: ImageCompressService.homeworkMaxSide,
            maxHeight: ImageCompressService.homeworkMaxSide,
            quality: ImageCompressService.homeworkQuality,
          );
          files.add(await MultipartFile.fromFile(result.file.path, filename: 'image_${i + 1}.jpg'));
        } else {
          files.add(await MultipartFile.fromFile(path, filename: path.split(RegExp(r'[\\/]')).last));
        }
      }

      int? parsedSubjectId = int.tryParse(assignment.subjectName) ?? int.tryParse(assignment.id);
      if (parsedSubjectId == null) {
        final subjectsNotifier = ref.read(subjectsProvider.notifier);
        final mappedId = subjectsNotifier.nameToIdMap[assignment.subjectName];
        if (mappedId != null) {
          parsedSubjectId = int.tryParse(mappedId);
        }
      }

      final formData = FormData.fromMap({
        'class_id': int.tryParse(assignment.classId) ?? 0,
        'subject_id': parsedSubjectId ?? 0,
        'title': assignment.title,
        'content': assignment.content,
        'due_date': '${assignment.dueDate.year}-${assignment.dueDate.month.toString().padLeft(2, '0')}-${assignment.dueDate.day.toString().padLeft(2, '0')}',
        'attachments[]': files,
      });

      await dio.post('assignments', data: formData);
      if (!ref.mounted) return;
      // Refresh local list
      await _fetch();
    } catch (e) {
      debugPrint('Error adding assignment: $e');
      rethrow;
    }
  }

  /// تعديل واجب بعد إرساله (العنوان/النص/موعد التسليم/المرفقات).
  /// يُرسل كـ multipart مع `_method=PUT` ليتمكن الخادم من استقبال الملفات.
  Future<void> updateAssignment({
    required String id,
    required String title,
    required String content,
    required DateTime dueDate,
    required List<String> newAttachmentPaths,
    required List<String> removeAttachmentUrls,
  }) async {
    try {
      final dio = ref.read(apiClientProvider);

      // المرفقات الجديدة (صور تُضغط قبل الرفع، وملفات تُرفع كما هي)
      final files = <MultipartFile>[];
      const imageExts = {'jpg', 'jpeg', 'png', 'webp'};
      for (int i = 0; i < newAttachmentPaths.length; i++) {
        final path = newAttachmentPaths[i];
        if (path.isEmpty) continue;
        final ext = path.split('.').last.toLowerCase();
        // الصور المضغوطة مسبقاً (من المعرض/الكاميرا) لا يُعاد ضغطها — أسرع وبدون فقد جودة إضافي
        if (imageExts.contains(ext) && await File(path).length() > ImageCompressService.alreadyCompressedBytes) {
          final result = await ImageCompressService.compress(
            File(path),
            maxWidth: ImageCompressService.homeworkMaxSide,
            maxHeight: ImageCompressService.homeworkMaxSide,
            quality: ImageCompressService.homeworkQuality,
          );
          files.add(await MultipartFile.fromFile(result.file.path, filename: 'image_${i + 1}.jpg'));
        } else {
          files.add(await MultipartFile.fromFile(path, filename: path.split(RegExp(r'[\\/]')).last));
        }
      }

      final formData = FormData.fromMap({
        '_method': 'PUT',
        'title': title,
        'content': content,
        'due_date': '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
        if (files.isNotEmpty) 'attachments[]': files,
        if (removeAttachmentUrls.isNotEmpty) 'remove_attachment_urls[]': removeAttachmentUrls,
      });

      final response = await dio.post('assignments/$id', data: formData);
      final data = response.data;
      if (data is Map && data['success'] == false) {
        throw AssignmentUpdateException(data['message']?.toString() ?? 'فشل تعديل الواجب');
      }
      if (!ref.mounted) return;
      await _fetch();
    } catch (e) {
      debugPrint('Error updating assignment: $e');
      rethrow;
    }
  }

  Future<void> updateSubmission(String assignmentId, String studentId, SubmissionStatus newStatus, String? newNote) async {
    // Save previous state for rollback
    final previousState = state;

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
    _cache = state;

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
      // Rollback on failure
      if (ref.mounted) {
        state = previousState;
        _cache = state;
      }
      debugPrint('Error updating assignment submission: $e');
    }
  }
}
