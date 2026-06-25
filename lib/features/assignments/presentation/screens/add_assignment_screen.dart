import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/assignment.dart';
import '../../../../core/providers/assignments_provider.dart';
import '../../../../core/providers/classes_provider.dart';
import '../../../../core/providers/subjects_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/widgets/modern_text_field.dart';
import '../../../../core/widgets/modern_dropdown.dart';
import '../../../../core/widgets/school_date_picker.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/widgets/app_notification.dart';

class AddAssignmentScreen extends ConsumerStatefulWidget {
  const AddAssignmentScreen({super.key});

  @override
  ConsumerState<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends ConsumerState<AddAssignmentScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime? _dueDate;
  String? _selectedClass;
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentClass = ref.read(selectedClassProvider);
      final currentSubject = ref.read(selectedSubjectProvider);
      if (currentClass.isNotEmpty) setState(() => _selectedClass = currentClass);
      if (currentSubject.isNotEmpty) setState(() => _selectedSubject = currentSubject);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final classes = ref.watch(classesProvider);
    final subjects = ref.watch(subjectsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          AppSliverHeader(
            title: context.loc.addNewAssignment,
            automaticallyImplyLeading: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form header / icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assignment_add,
                        size: 48,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  Row(
                    children: [
                      Expanded(
                        child: ModernDropdown<String>(
                          label: context.loc.classLabel,
                          value: _selectedClass,
                          items: classes,
                          onChanged: (val) => setState(() => _selectedClass = val),
                          icon: Icons.school_rounded,
                          isDark: isDark,
                          itemLabelBuilder: (item) => context.translateMock(item),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: ModernDropdown<String>(
                          label: context.loc.subjectLabel,
                          value: _selectedSubject,
                          items: subjects,
                          onChanged: (val) => setState(() => _selectedSubject = val),
                          icon: Icons.menu_book_rounded,
                          isDark: isDark,
                          itemLabelBuilder: (item) => context.translateMock(item),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  ModernTextField(
                    controller: _titleController,
                    label: context.loc.assignmentTitleLabel,
                    hint: context.loc.assignmentTitleHint,
                    icon: Icons.title_rounded,
                    isDark: isDark,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  ModernTextField(
                    controller: _contentController,
                    label: context.loc.assignmentDescLabel,
                    hint: context.loc.assignmentDescHint,
                    icon: Icons.notes_rounded,
                    maxLines: 5,
                    isDark: isDark,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  _buildDateSelector(isDark),
                  const SizedBox(height: AppSpacing.xl),

                  _buildAttachmentButton(isDark),
                  const SizedBox(height: AppSpacing.xxl),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: AppColors.brandGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _saveAssignment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            context.loc.saveAndSendAssignment,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(bool isDark) {
    final theme = Theme.of(context);
    final hasDate = _dueDate != null;
    final selectedColor = isDark ? Colors.white : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
          child: Text(
            context.loc.dueDateLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isDark ? Colors.white70 : AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Material(
          color: isDark ? AppColors.surfaceAltDark : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: hasDate ? selectedColor : (isDark ? Colors.white12 : Colors.grey.shade200),
              width: hasDate ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final date = await showSchoolDatePicker(
                context: context,
                initialDate: _dueDate ?? adjustToSchoolDay(DateTime.now().add(const Duration(days: 1))),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _dueDate = date);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: hasDate ? selectedColor.withValues(alpha: 0.1) : (isDark ? Colors.white10 : Colors.grey.shade100),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: hasDate ? selectedColor : (isDark ? Colors.white54 : Colors.grey.shade500),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasDate ? context.loc.dueDay : context.loc.selectDueDate,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white54 : Colors.grey.shade600,
                          ),
                        ),
                        if (hasDate) ...[
                          const SizedBox(height: 4),
                          Text(
                            "${_dueDate!.year}/${_dueDate!.month.toString().padLeft(2, '0')}/${_dueDate!.day.toString().padLeft(2, '0')}",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  Icon(
                    Icons.edit_calendar_rounded,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppNotification.show(
            context,
            type: AppNotificationType.info,
            title: context.loc.assignmentSelectFiles,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Icon(Icons.cloud_upload_rounded, color: isDark ? Colors.white : AppColors.primary, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                context.loc.attachFilesOrImages,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white70 : AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.loc.fileFormatHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAssignment() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty || _dueDate == null || _selectedClass == null || _selectedSubject == null) {
      AppNotification.show(
        context,
        type: AppNotificationType.error,
        title: context.loc.assignmentSaveError,
      );
      return;
    }

    final newAssignment = Assignment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      classId: _selectedClass!,
      subjectName: _selectedSubject!,
      title: _titleController.text,
      content: _contentController.text,
      dateCreated: DateTime.now(),
      dueDate: _dueDate!,
    );

    ref.read(assignmentsDataProvider.notifier).addAssignment(newAssignment);

    AppNotification.show(
      context,
      type: AppNotificationType.success,
      title: context.loc.assignmentSaveSuccess,
    );
    context.pop();
  }
}
