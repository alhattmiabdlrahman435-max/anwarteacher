import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/assistant_models.dart';
import 'assistant_classes_provider.dart';
import 'assistant_class_details_provider.dart';

part 'assistant_dashboard_provider.g.dart';

class DashboardStats {
  final int totalStudents;
  final int presentToday;
  final int absentToday;
  final int unmarkedToday;

  const DashboardStats({
    required this.totalStudents,
    required this.presentToday,
    required this.absentToday,
    required this.unmarkedToday,
  });
}

@riverpod
DashboardStats assistantDashboardStats(Ref ref) {
  final classes = ref.watch(assistantClassesProvider);
  
  int total = 0;
  int present = 0;
  int absent = 0;
  int unmarked = 0;

  for (final cls in classes) {
    final students = ref.watch(assistantClassDetailsProvider(cls.id));
    total += students.length;
    for (final s in students) {
      if (s.status == AttendanceStatus.present) {
        present++;
      } else if (s.status == AttendanceStatus.absent) {
        absent++;
      } else {
        unmarked++;
      }
    }
  }

  return DashboardStats(
    totalStudents: total,
    presentToday: present,
    absentToday: absent,
    unmarkedToday: unmarked,
  );
}
