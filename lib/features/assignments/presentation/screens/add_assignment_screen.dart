import 'dart:io';
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
import '../../../../core/services/image_compress_service.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

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
  /// مرفقات الواجب (صور/ملفات) — حتى 10
  final List<String> _pickedPaths = [];
  static const int _maxAttachments = 10;

  void _addPicked(Iterable<String> paths) {
    final room = _maxAttachments - _pickedPaths.length;
    final toAdd = paths.take(room).toList();
    setState(() => _pickedPaths.addAll(toAdd));
    if (paths.length > room && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الحد الأقصى 10 مرفقات للواجب الواحد.')),
      );
    }
  }

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
                          onChanged: (val) {
                            setState(() {
                              _selectedClass = val;
                              _selectedSubject = null;
                            });
                            if (val != null) {
                              ref.read(selectedClassProvider.notifier).setClass(val);
                            }
                          },
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
    final canAddMore = _pickedPaths.length < _maxAttachments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < _pickedPaths.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  _isImagePath(_pickedPaths[i])
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_pickedPaths[i]),
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.insert_drive_file_outlined, color: AppColors.primary, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _pickedPaths[i].split(RegExp(r'[\\/]')).last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_rounded, color: AppColors.error),
                    onPressed: () => setState(() => _pickedPaths.removeAt(i)),
                  ),
                ],
              ),
            ),
          ),
        if (canAddMore)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickAttachment,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: _pickedPaths.isEmpty ? 24 : 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                ),
                child: _pickedPaths.isEmpty
                    ? Column(
                        children: [
                          Icon(
                            Icons.cloud_upload_rounded,
                            color: isDark ? Colors.white : AppColors.primary,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.loc.attachFilesOrImages,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isDark ? Colors.white70 : AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'يمكنك إرفاق حتى 10 صور أو ملفات في نفس الواجب',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                                ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'إضافة مرفق آخر (${_pickedPaths.length}/$_maxAttachments)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
      ],
    );
  }

  bool _isImagePath(String path) =>
      ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(path.split('.').last.toLowerCase());

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
      if (source == ImageSource.gallery) {
        // اختيار أكثر من صورة دفعة واحدة من المعرض
        final picked = await ImagePicker().pickMultiImage();
        if (picked.isEmpty) return;
        final paths = <String>[];
        for (final x in picked) {
          final result = await ImageCompressService.compress(
            File(x.path),
            maxWidth: ImageCompressService.homeworkMaxSide,
            maxHeight: ImageCompressService.homeworkMaxSide,
            quality: ImageCompressService.homeworkQuality,
          );
          paths.add(result.file.path);
        }
        _addPicked(paths);
        return;
      }
      final result = await ImageCompressService.pickAndCompress(
        source: source,
        maxWidth: ImageCompressService.homeworkMaxSide,
        maxHeight: ImageCompressService.homeworkMaxSide,
        quality: ImageCompressService.homeworkQuality,
      );
      if (result != null) {
        _addPicked([result.file.path]);
      }
    } on ImageValidationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في اختيار الصورة: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );
      if (result == null) return;
      final accepted = <String>[];
      for (final f in result.files) {
        final path = f.path;
        if (path == null) continue;
        // Enforce 10 MB limit for non-image attachments
        final size = await File(path).length();
        if (size > 10 * 1024 * 1024) {
          final mb = (size / 1_048_576).toStringAsFixed(1);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('حجم الملف ${f.name} ($mb MB) يتجاوز الحد المسموح (10 MB).'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
          continue;
        }
        accepted.add(path);
      }
      _addPicked(accepted);
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في اختيار الملف: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
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

      await ref.read(assignmentsDataProvider.notifier).addAssignment(newAssignment, _pickedPaths);

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
        final String errorMsg = (e is DioException)
            ? e.userFriendlyMessage
            : 'فشل حفظ وإرسال الواجب. يرجى المحاولة مرة أخرى.';
        AppNotification.show(
          context,
          type: AppNotificationType.error,
          title: errorMsg,
        );
      }
    }
  }
}
