import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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
  String? _pickedImagePath;

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
    final hasAttachment = _pickedImagePath != null;
    IconData attachmentIcon = Icons.insert_drive_file_outlined;
    if (hasAttachment) {
      final ext = _pickedImagePath!.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(ext)) {
        attachmentIcon = Icons.image_outlined;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasAttachment ? null : _pickAttachment,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
          ),
          child: hasAttachment 
              ? Row(
                  children: [
                    Icon(attachmentIcon, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _pickedImagePath!.split('/').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded, color: AppColors.error),
                      onPressed: () => setState(() => _pickedImagePath = null),
                    )
                  ],
                )
              : Column(
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

  Widget _buildAttachmentOptionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromSource(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() => _pickedImagePath = image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() => _pickedImagePath = result.files.single.path);
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> _pickAttachment() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'إرفاق ملف أو صورة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'اختر طريقة إرفاق ملف الواجب لمشاركته مع الطلاب',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOptionCard(
                    context: context,
                    icon: Icons.camera_alt_rounded,
                    label: 'التقاط صورة',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickFromSource(ImageSource.camera);
                    },
                    isDark: isDark,
                  ),
                  _buildAttachmentOptionCard(
                    context: context,
                    icon: Icons.photo_library_rounded,
                    label: 'معرض الصور',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickFromSource(ImageSource.gallery);
                    },
                    isDark: isDark,
                  ),
                  _buildAttachmentOptionCard(
                    context: context,
                    icon: Icons.insert_drive_file_rounded,
                    label: 'ملف أو مستند',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickFile();
                    },
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _saveAssignment() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty || _dueDate == null || _selectedClass == null || _selectedSubject == null) {
      AppNotification.show(
        context,
        type: AppNotificationType.error,
        title: context.loc.assignmentSaveError,
      );
      return;
    }

    final classId = ref.read(classesProvider.notifier).nameToIdMap[_selectedClass];
    final subjectId = ref.read(subjectsProvider.notifier).nameToIdMap[_selectedSubject];

    if (classId == null || subjectId == null) {
      AppNotification.show(
        context,
        type: AppNotificationType.error,
        title: 'عذراً، لم يتم العثور على الصف أو المادة المحددة في النظام',
      );
      return;
    }

    // Show loading dialog/overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final newAssignment = Assignment(
        id: '',
        classId: classId,
        subjectName: subjectId, // Pass subjectId string to be used by addAssignment parameter mapping
        title: _titleController.text,
        content: _contentController.text,
        dateCreated: DateTime.now(),
        dueDate: _dueDate!,
      );

      await ref.read(assignmentsDataProvider.notifier).addAssignment(newAssignment, _pickedImagePath);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        AppNotification.show(
          context,
          type: AppNotificationType.success,
          title: context.loc.assignmentSaveSuccess,
        );
        context.pop();
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        AppNotification.show(
          context,
          type: AppNotificationType.error,
          title: 'فشل حفظ وإرسال الواجب. يرجى التحقق من الاتصال بالشبكة.',
        );
      }
    }
  }
}
