import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../network/api_client.dart';
import 'classes_provider.dart';

part 'subjects_provider.g.dart';

@Riverpod(keepAlive: true)
class Subjects extends _$Subjects {
  Map<String, String> _nameToIdMap = {};
  
  Map<String, String> get nameToIdMap => _nameToIdMap;
  
  @override
  List<String> build() {
    final selectedClass = ref.watch(selectedClassProvider);
    if (selectedClass.isNotEmpty) {
      final classesNotifier = ref.read(classesProvider.notifier);
      final classId = classesNotifier.nameToIdMap[selectedClass];
      if (classId != null) {
        _fetchForClass(classId);
      }
    }
    return const [];
  }
  
  bool _isFetching = false;
  
  Future<void> _fetchForClass(String classId) async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('teacher/classes/$classId/subjects');
      if (!ref.mounted) return;
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['subjects'];
        final Map<String, String> newMap = {};
        final List<String> names = [];
        for (final item in list) {
          final String name = item['name_ar'] ?? item['name'] ?? '';
          final String id = item['id']?.toString() ?? '';
          if (name.isNotEmpty && id.isNotEmpty) {
            newMap[name] = id;
            names.add(name);
          }
        }
        _nameToIdMap = newMap;
        state = names;
      }
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh() async {
    final selectedClass = ref.read(selectedClassProvider);
    if (selectedClass.isNotEmpty) {
      final classesNotifier = ref.read(classesProvider.notifier);
      final classId = classesNotifier.nameToIdMap[selectedClass];
      if (classId != null) {
        await _fetchForClass(classId);
      }
    }
  }
}

@Riverpod(keepAlive: true)
class SelectedSubject extends _$SelectedSubject {
  @override
  String build() {
    final subjs = ref.watch(subjectsProvider);
    return subjs.isNotEmpty ? subjs.first : '';
  }

  void setSubject(String newSubject) {
    state = newSubject;
  }
}
