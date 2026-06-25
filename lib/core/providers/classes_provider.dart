
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'classes_provider.g.dart';

@riverpod
List<String> classes(Ref ref) {
  return ['الصف الخامس - أ', 'الصف السادس - ب'];
}

@riverpod
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
