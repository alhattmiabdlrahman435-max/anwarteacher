import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../network/api_client.dart';

part 'subjects_provider.g.dart';

@Riverpod(keepAlive: true)
class Subjects extends _$Subjects {
  Map<String, String> _nameToIdMap = {};
  
  Map<String, String> get nameToIdMap => _nameToIdMap;
  
  @override
  List<String> build() {
    _fetch();
    return const [];
  }
  
  Future<void> _fetch() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('subjects');
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
      print('Error fetching subjects: $e');
    }
  }

  Future<void> refresh() async {
    await _fetch();
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
