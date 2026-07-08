import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../models/report.dart';
import '../network/api_client.dart';

part 'reports_provider.g.dart';

@riverpod
class Reports extends _$Reports {
  @override
  List<Report> build() {
    fetch();
    return const [];
  }

  Future<void> fetch() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('reports');
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['reports'] ?? [];
        state = list.map((item) {
          final String statusStr = item['status']?.toString().toLowerCase() ?? 'pending';
          ReportStatus status = ReportStatus.pending;
          if (statusStr == 'approved') {
            status = ReportStatus.approved;
          } else if (statusStr == 'rejected') {
            status = ReportStatus.rejected;
          }

          final String typeStr = item['type']?.toString().toLowerCase() ?? 'academic';
          ReportType type = ReportType.academic;
          if (typeStr == 'behavioral') {
            type = ReportType.behavioral;
          } else if (typeStr == 'homework') {
            type = ReportType.homework;
          } else if (typeStr == 'psychological') {
            type = ReportType.psychological;
          }

          return Report(
            id: item['id']?.toString() ?? '',
            studentId: item['studentId']?.toString() ?? '',
            studentName: item['studentName'] ?? '',
            className: item['className'] ?? '',
            type: type,
            description: item['description'] ?? '',
            imageUrl: item['imageUrl'],
            studentPhotoUrl: item['studentPhotoUrl'],
            status: status,
            createdAt: DateTime.tryParse(item['createdAt']?.toString() ?? '') ?? DateTime.now(),
          );
        }).toList();
      }
    } catch (e) {
      print('Error fetching teacher student reports: $e');
    }
  }

  Future<void> addReport({
    required String studentId,
    required String studentName,
    required String className,
    required ReportType type,
    required String description,
    String? imageUrl, // Local picked image path
  }) async {
    try {
      final dio = ref.read(apiClientProvider);
      
      MultipartFile? file;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        file = await MultipartFile.fromFile(
          imageUrl,
          filename: imageUrl.split('/').last,
        );
      }

      final formData = FormData.fromMap({
        'student_id': int.tryParse(studentId) ?? 0,
        'type': type.name, // academic, behavioral, homework, psychological
        'description': description,
        if (file != null) 'image': file,
      });

      final response = await dio.post('reports', data: formData);
      if (response.data != null && response.data['success'] == true) {
        // Refresh reports list
        await fetch();
      }
    } catch (e) {
      print('Error submitting report to backend: $e');
      rethrow;
    }
  }
}
