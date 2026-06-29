
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../network/api_client.dart';

part 'classes_provider.g.dart';

@Riverpod(keepAlive: true)
class Classes extends _$Classes {
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
      final response = await dio.get('teacher/classes');
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> list = response.data['classes'];
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
      print('Error fetching teacher classes: $e');
    }
  }
  
  Future<void> refresh() async {
    await _fetch();
  }
}

@Riverpod(keepAlive: true)
class SelectedClass extends _$SelectedClass {
  @override
  String build() {
    final cls = ref.watch(classesProvider);
    return cls.isNotEmpty ? cls.first : '';
  }

  void setClass(String newClass) {
    state = newClass;
  }
}
