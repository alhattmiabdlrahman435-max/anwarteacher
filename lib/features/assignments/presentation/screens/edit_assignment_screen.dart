import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../../core/models/assignment.dart';
import '../../../../core/providers/assignments_provider.dart';
import '../../../../core/providers/classes_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/widgets/modern_text_field.dart';
import '../../../../core/widgets/school_date_picker.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/widgets/app_notification.dart';
import '../../../../core/services/image_compress_service.dart';
import '../../../../core/network/api_client.dart';

/// تعديل واجب بعد إرساله (في حال وقوع خطأ في كتابته).
/// الصف والمادة للعرض فقط — تغييرهما يغيّر مستلمي الواجب.
class EditAssignmentScreen extends ConsumerStatefulWidget {
  final String assignmentId;

  const EditAssignmentScreen({super.key, required this.assignmentId});

  @override
  ConsumerState<EditAssignmentScreen> createState() => _EditAssignmentScreenState();
}

class _EditAssignmentScreenState extends ConsumerState<EditAssignmentScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime? _dueDate;
  DateTime? _sentDate;
  bool _initialized = false;
  bool _saving = false;

  /// المرفقات الحالية كما وردت من الخادم (attachment_urls)
  List<String> _existing = [];

  /// المرفقات الحالية المعلَّمة للحذف (بنفس الرابط الوارد من الخادم)
  final Set<String> _removed = {};

  /// المرفقات الجديدة المختارة من الجهاز
  final List<String> _pickedPaths = [];
  static const int _maxAttachments = 10;

  int get _totalAttachments => _existing.where((u) => !_removed.contains(u)).length + _pickedPaths.length;

  String _t(String ar, String en) => context.loc.localeName == 'en' ? en : ar;

  @override
  void initState() {
    super.initState();
    _initFrom(_findAssignment(ref.read(assignmentsDataProvider)));
  }

  Assignment? _findAssignment(List<Assignment> list) =>
      list.where((a) => a.id == widget.assignmentId).firstOrNull;

  void _initFrom(Assignment? a) {
    if (a == null || _initialized) return;
    _initialized = true;
    _titleController.text = a.title;
    _contentController.text = a.content;
    _dueDate = a.dueDate;
    _sentDate = DateTime(a.dateCreated.year, a.dateCreated.month, a.dateCreated.day);
    _existing = a.attachments.where((u) => u.isNotEmpty).toList();
  }

  void _addPicked(Iterable<String> paths) {
    final room = _maxAttachments - _totalAttachments;
    final toAdd = paths.take(room < 0 ? 0 : room).toList();
    setState(() => _pickedPaths.addAll(toAdd));
    if (paths.length > room && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('الحد الأقصى 10 مرفقات للواجب الواحد.', 'Maximum 10 attachments per homework.'))),
      );
    }
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

    final assignments = ref.watch(assignmentsDataProvider);
    ref.watch(classesProvider);
    final assignment = _findAssignment(assignments);
    // في حال فُتحت الشاشة قبل اكتمال تحميل القائمة
    if (!_initialized && assignment != null) _initFrom(assignment);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
      body: CustomScrollView(
        slivers: [
          AppSliverHeader(
            title: _t('تعديل الواجب', 'Edit Homework'),
            automaticallyImplyLeading: true,
          ),
          if (assignment == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(_t('لم يتم العثور على الواجب', 'Homework not found'))),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                          Icons.edit_note_rounded,
                          size: 48,
                          color: isDark ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    Row(
                      children: [
                        Expanded(
                          child: _buildReadOnlyField(
                            label: context.loc.classLabel,
                            value: _className(assignment),
                            icon: Icons.school_rounded,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: _buildReadOnlyField(
                            label: context.loc.subjectLabel,
                            value: context.translateMock(assignment.subjectName),
                            icon: Icons.menu_book_rounded,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 8, left: 8),
                      child: Text(
                        _t('لا يمكن تغيير الصف أو المادة بعد إرسال الواجب.',
                            'Class and subject cannot be changed after sending.'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white38 : Colors.grey.shade500,
                        ),
                      ),
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

                    _buildAttachments(isDark),
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
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save_rounded, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(
                              _t('حفظ التعديلات', 'Save changes'),
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

  String _className(Assignment a) {
    for (final e in ref.read(classesProvider.notifier).nameToIdMap.entries) {
      if (e.value == a.classId) return context.translateMock(e.key);
    }
    return '-';
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isDark ? Colors.white70 : AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isDark ? Colors.white54 : Colors.grey.shade500),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              Icon(Icons.lock_outline_rounded, size: 16, color: isDark ? Colors.white38 : Colors.grey.shade400),
            ],
          ),
        ),
      ],
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
              final first = _sentDate ?? DateTime.now();
              var initial = _dueDate ?? first;
              if (initial.isBefore(first)) initial = first;
              final date = await showSchoolDatePicker(
                context: context,
                initialDate: initial,
                // لا يجوز أن يسبق موعد التسليم تاريخ إرسال الواجب
                firstDate: first,
                lastDate: first.add(const Duration(days: 365)),
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

  Widget _attachmentRow({
    required bool isDark,
    required Widget leading,
    required String name,
    required Widget trailing,
    bool faded = false,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: faded ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: faded ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: faded ? AppColors.error : (isDark ? Colors.white54 : Colors.grey.shade600),
                        ),
                      ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachments(bool isDark) {
    final theme = Theme.of(context);
    final canAddMore = _totalAttachments < _maxAttachments;
    final hasAny = _existing.isNotEmpty || _pickedPaths.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0, left: 8.0),
          child: Text(
            '${_t('المرفقات', 'Attachments')} ($_totalAttachments/$_maxAttachments)',
            style: theme.textTheme.titleSmall?.copyWith(
              color: isDark ? Colors.white70 : AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // المرفقات الحالية (من الخادم)
        for (final raw in _existing)
          Builder(builder: (context) {
            final url = AppConstants.normalizeUrl(raw) ?? raw;
            final removed = _removed.contains(raw);
            return _attachmentRow(
              isDark: isDark,
              faded: removed,
              subtitle: removed ? _t('سيُحذف عند الحفظ', 'Will be removed on save') : _t('مرفق حالي', 'Current attachment'),
              leading: _isImagePath(url)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.broken_image_outlined, color: AppColors.primary),
                        ),
                      ),
                    )
                  : const Icon(Icons.insert_drive_file_outlined, color: AppColors.primary, size: 32),
              name: _fileName(url),
              trailing: removed
                  ? IconButton(
                      tooltip: _t('تراجع', 'Undo'),
                      icon: const Icon(Icons.undo_rounded, color: AppColors.primary),
                      onPressed: () {
                        if (_totalAttachments >= _maxAttachments) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_t('الحد الأقصى 10 مرفقات للواجب الواحد.', 'Maximum 10 attachments per homework.'))),
                          );
                          return;
                        }
                        setState(() => _removed.remove(raw));
                      },
                    )
                  : IconButton(
                      tooltip: _t('حذف المرفق', 'Remove attachment'),
                      icon: const Icon(Icons.cancel_rounded, color: AppColors.error),
                      onPressed: () => setState(() => _removed.add(raw)),
                    ),
            );
          }),
        // المرفقات الجديدة
        for (int i = 0; i < _pickedPaths.length; i++)
          _attachmentRow(
            isDark: isDark,
            subtitle: _t('مرفق جديد', 'New attachment'),
            leading: _isImagePath(_pickedPaths[i])
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
            name: _pickedPaths[i].split(RegExp(r'[\\/]')).last,
            trailing: IconButton(
              icon: const Icon(Icons.cancel_rounded, color: AppColors.error),
              onPressed: () => setState(() => _pickedPaths.removeAt(i)),
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
                  vertical: hasAny ? 14 : 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                ),
                child: !hasAny
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
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark ? Colors.white70 : AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _t('يمكنك إرفاق حتى 10 صور أو ملفات في نفس الواجب',
                                'You can attach up to 10 images or files per homework'),
                            style: theme.textTheme.bodySmall?.copyWith(
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
                            '${_t('إضافة مرفق', 'Add attachment')} ($_totalAttachments/$_maxAttachments)',
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

  static bool _isImagePath(String path) {
    final p = Uri.tryParse(path)?.path ?? path;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif', 'bmp']
        .contains(p.split('.').last.toLowerCase());
  }

  static String _fileName(String url) {
    final path = Uri.tryParse(url)?.path ?? url;
    final name = path.split('/').where((s) => s.isNotEmpty).lastOrNull ?? url;
    try {
      return Uri.decodeComponent(name);
    } catch (_) {
      return name;
    }
  }

  Widget _buildAttachmentOptionCard({
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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      _showError(e.message);
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showError('${_t('فشل في اختيار الصورة', 'Failed to pick image')}: $e');
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
        // حد 10 ميجابايت للملف الواحد
        final size = await File(path).length();
        if (size > 10 * 1024 * 1024) {
          final mb = (size / 1_048_576).toStringAsFixed(1);
          _showError(_t(
            'حجم الملف ${f.name} ($mb MB) يتجاوز الحد المسموح (10 MB).',
            'File ${f.name} ($mb MB) exceeds the 10 MB limit.',
          ));
          continue;
        }
        accepted.add(path);
      }
      _addPicked(accepted);
    } catch (e) {
      debugPrint('Error picking file: $e');
      _showError('${_t('فشل في اختيار الملف', 'Failed to pick file')}: $e');
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
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                _t('إرفاق ملف أو صورة', 'Attach a file or image'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOptionCard(
                    icon: Icons.camera_alt_rounded,
                    label: _t('التقاط صورة', 'Camera'),
                    color: Colors.blue,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _pickFromSource(ImageSource.camera);
                    },
                    isDark: isDark,
                  ),
                  _buildAttachmentOptionCard(
                    icon: Icons.photo_library_rounded,
                    label: _t('معرض الصور', 'Gallery'),
                    color: Colors.purple,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _pickFromSource(ImageSource.gallery);
                    },
                    isDark: isDark,
                  ),
                  _buildAttachmentOptionCard(
                    icon: Icons.insert_drive_file_rounded,
                    label: _t('ملف أو مستند', 'File'),
                    color: Colors.orange,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
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

  Future<void> _save() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AppNotification.show(
        context,
        type: AppNotificationType.error,
        title: _t('يرجى كتابة عنوان الواجب', 'Please enter the homework title'),
      );
      return;
    }
    if (_dueDate == null) {
      AppNotification.show(
        context,
        type: AppNotificationType.error,
        title: _t('يرجى تحديد موعد التسليم', 'Please select the due date'),
      );
      return;
    }
    final due = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day);
    if (_sentDate != null && due.isBefore(_sentDate!)) {
      AppNotification.show(
        context,
        type: AppNotificationType.error,
        title: _t('لا يمكن أن يكون موعد التسليم قبل تاريخ إرسال الواجب',
            'The due date cannot be before the send date'),
      );
      return;
    }
    if (_totalAttachments > _maxAttachments) {
      AppNotification.show(
        context,
        type: AppNotificationType.error,
        title: _t('الحد الأقصى 10 مرفقات للواجب الواحد.', 'Maximum 10 attachments per homework.'),
      );
      return;
    }

    setState(() => _saving = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(assignmentsDataProvider.notifier).updateAssignment(
            id: widget.assignmentId,
            title: title,
            content: _contentController.text.trim(),
            dueDate: due,
            newAttachmentPaths: List.of(_pickedPaths),
            removeAttachmentUrls: _existing.where(_removed.contains).toList(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(); // إغلاق مؤشر التحميل
      AppNotification.show(
        context,
        type: AppNotificationType.success,
        title: _t('تم تعديل الواجب وإبلاغ أولياء الأمور', 'Homework updated and parents notified'),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // إغلاق مؤشر التحميل
      setState(() => _saving = false);
      final String errorMsg = (e is DioException)
          ? e.userFriendlyMessage
          : (e is AssignmentUpdateException)
              ? e.message
              : _t('فشل تعديل الواجب. يرجى المحاولة مرة أخرى.', 'Failed to update homework. Please try again.');
      AppNotification.show(
        context,
        type: AppNotificationType.error,
        title: errorMsg,
      );
    }
  }
}
