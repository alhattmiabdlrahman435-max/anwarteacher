import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assistant_models.dart';

part 'assistant_classes_provider.g.dart';

@riverpod
class AssistantClasses extends _$AssistantClasses {
  @override
  List<ClassroomEntity> build() {
    return const [
      ClassroomEntity(id: 'c1', name: 'الصف الخامس - أ', nameEn: 'Grade 5 - A', grade: '5', studentCount: 5),
      ClassroomEntity(id: 'c2', name: 'الصف السادس - ب', nameEn: 'Grade 6 - B', grade: '6', studentCount: 4),
      ClassroomEntity(id: 'c3', name: 'الصف الثالث - أ', nameEn: 'Grade 3 - A', grade: '3', studentCount: 3),
    ];
  }
}
