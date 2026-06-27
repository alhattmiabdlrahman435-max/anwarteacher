import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../providers/classes_provider.dart';
import '../providers/subjects_provider.dart';
import '../extensions/localization_extension.dart';

class ClassSubjectSelector extends ConsumerWidget {
  final bool showSubject;

  const ClassSubjectSelector({
    super.key,
    this.showSubject = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : AppColors.primary;
    final bgColor = isDark ? AppColors.surfaceAltDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;

    final classes = ref.watch(classesProvider);
    final selectedClass = ref.watch(selectedClassProvider);
    
    final subjects = ref.watch(subjectsProvider);
    final selectedSubject = ref.watch(selectedSubjectProvider);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Row(
          children: [
            // Class Selector
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : AppColors.border,
                  ),
                  boxShadow: isDark ? [] : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedClass.isNotEmpty ? selectedClass : null,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor, size: 20),
                    dropdownColor: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                    ),
                    items: classes.map((className) {
                      return DropdownMenuItem(
                        value: className,
                        child: Text(
                          context.translateMock(className),
                          style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        ref.read(selectedClassProvider.notifier).setClass(newValue);
                      }
                    },
                  ),
                ),
              ),
            ),
            if (showSubject) const SizedBox(width: 12),
            // Subject Selector
            if (showSubject)
              Expanded(
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : AppColors.border,
                  ),
                  boxShadow: isDark ? [] : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedSubject.isNotEmpty ? selectedSubject : null,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor, size: 20),
                    dropdownColor: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13,
                    ),
                    items: subjects.map((subjectName) {
                      return DropdownMenuItem(
                        value: subjectName,
                        child: Text(
                          context.translateMock(subjectName),
                          style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        ref.read(selectedSubjectProvider.notifier).setSubject(newValue);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
