import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assistant_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/auth_provider.dart';

part 'assistant_classes_provider.g.dart';

@riverpod
class AssistantClasses extends _$AssistantClasses {
  @override
  List<ClassroomEntity> build() {
    final authState = ref.watch(authProvider);
    if (!authState.isLoggedIn) return const [];
    _fetch();
    return const [];
  }

  bool _isFetching = false;

  Future<void> _fetch() async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('supervisor/classes');
      if (!ref.mounted) return;
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> data = response.data['classes'];
        state = data.map((json) => ClassroomEntity.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching classes: $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh() async {
    await _fetch();
  }
}
