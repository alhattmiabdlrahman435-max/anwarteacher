import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assistant_models.dart';
import '../../../core/network/api_client.dart';

part 'assistant_classes_provider.g.dart';

@riverpod
class AssistantClasses extends _$AssistantClasses {
  @override
  List<ClassroomEntity> build() {
    _fetch();
    return const [];
  }

  Future<void> _fetch() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('supervisor/classes');
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> data = response.data['classes'];
        state = data.map((json) => ClassroomEntity.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching classes: $e');
    }
  }

  Future<void> refresh() async {
    await _fetch();
  }
}
