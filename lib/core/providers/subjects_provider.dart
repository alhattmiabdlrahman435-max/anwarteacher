import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subjects_provider.g.dart';

@riverpod
List<String> subjects(Ref ref) {
  return ['القرآن الكريم', 'الرياضيات', 'العلوم', 'لغتي'];
}

@riverpod
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
