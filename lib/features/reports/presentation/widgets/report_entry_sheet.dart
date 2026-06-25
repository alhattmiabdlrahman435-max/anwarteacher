import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/report.dart';
import '../../../../core/providers/reports_provider.dart';
import '../../../../core/providers/children_provider.dart';
import '../../../../core/providers/classes_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/modern_text_field.dart';
import '../../../../core/widgets/app_notification.dart';

class ReportEntrySheet extends ConsumerStatefulWidget {
  const ReportEntrySheet({super.key});

  @override
  ConsumerState<ReportEntrySheet> createState() => _ReportEntrySheetState();
}

class _ReportEntrySheetState extends ConsumerState<ReportEntrySheet> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Step 1 – class & student selection
  String? _selectedClass;
  Student? _selectedStudent;

  // Step 2 – report details
  ReportType? _selectedType;
  String? _attachedImagePath;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    // Pre-select the currently active class
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentClass = ref.read(selectedClassProvider);
      if (currentClass.isNotEmpty && mounted) {
        setState(() => _selectedClass = currentClass);
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // ─── helpers ──────────────────────────────────────────────────────────────

  List<Student> _studentsForClass(List<Student> all, String? cls) {
    if (cls == null || cls.isEmpty) return all;
    final filtered = all.where((s) {
      if (cls.contains('خامس') && s.grade.contains('خامس')) return true;
      if (cls.contains('سادس') && s.grade.contains('سادس')) return true;
      return false;
    }).toList();
    return filtered.isNotEmpty ? filtered : all;
  }

  void _simulatePickImage() async {
    setState(() => _isUploadingImage = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _attachedImagePath = 'mock_report_image.png';
        _isUploadingImage = false;
      });
    }
  }

  void _submitReport() {
    if (_selectedStudent == null) {
      AppNotification.show(
        context,
        type: AppNotificationType.warning,
        title: 'يرجى اختيار الطالب أولاً',
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      AppNotification.show(
        context,
        type: AppNotificationType.warning,
        title: 'يرجى تحديد نوع البلاغ',
      );
      return;
    }

    ref.read(reportsProvider.notifier).addReport(
          studentId: _selectedStudent!.id,
          studentName: _selectedStudent!.name,
          className: _selectedClass?.isNotEmpty == true
              ? _selectedClass!
              : _selectedStudent!.grade,
          type: _selectedType!,
          description: _descriptionController.text.trim(),
          imageUrl: _attachedImagePath,
        );

    AppNotification.show(
      context,
      type: AppNotificationType.success,
      title: 'تم إرسال البلاغ بنجاح',
      message: 'بانتظار مراجعة واعتماد الإدارة',
    );

    Navigator.pop(context);
  }

  // ─── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final classes = ref.watch(classesProvider);
    final allStudents = ref.watch(childrenProvider);
    final studentsForClass = _studentsForClass(allStudents, _selectedClass);
    final dialogBg = isDark ? AppColors.surfaceAltDark : Colors.white;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: dialogBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white24
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Sheet title ──
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.flag_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'بلاغ جديد',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontFamily: 'GoogleSans',
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'اختر الطالب وأدخل تفاصيل البلاغ',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                fontFamily: 'GoogleSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          size: 28,
                          color:
                              isDark ? Colors.white30 : Colors.grey.shade400,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Class selector ──
                  _buildSectionLabel(
                      'الفصل الدراسي', Icons.class_rounded, isDark),
                  const SizedBox(height: 10),
                  _buildClassSelector(classes, isDark),
                  const SizedBox(height: 20),

                  // ── Student selector ──
                  _buildSectionLabel(
                      'الطالب', CupertinoIcons.person_fill, isDark),
                  const SizedBox(height: 10),
                  _buildStudentSelector(studentsForClass, isDark, theme),
                  const SizedBox(height: 20),

                  // ── Report type ──
                  _buildSectionLabel(
                      'نوع البلاغ', Icons.category_rounded, isDark),
                  const SizedBox(height: 10),
                  _buildTypeSelector(isDark),
                  const SizedBox(height: 20),

                  // ── Details ──
                  _buildSectionLabel(
                      'تفاصيل البلاغ', Icons.notes_rounded, isDark),
                  const SizedBox(height: 10),
                  _buildDetailsField(isDark),
                  const SizedBox(height: 20),

                  // ── Image attachment ──
                  _buildSectionLabel(
                      'إرفاق صورة إثبات', Icons.photo_camera_rounded, isDark),
                  const SizedBox(height: 10),
                  _buildImageSection(isDark),
                  const SizedBox(height: 28),

                  // ── Submit ──
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── sub-widgets ──────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.5,
            color: isDark
                ? Colors.white70
                : AppColors.textSecondaryLight,
            fontFamily: 'GoogleSans',
          ),
        ),
      ],
    );
  }

  Widget _buildClassSelector(List<String> classes, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedClass,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'اختر الفصل',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey[400],
                fontFamily: 'GoogleSans',
                fontSize: 14,
              ),
            ),
          ),
          isExpanded: true,
          dropdownColor:
              isDark ? AppColors.surfaceAltDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            Icons.expand_more_rounded,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
            fontFamily: 'GoogleSans',
            fontSize: 14,
          ),
          items: classes
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(c),
                    ),
                  ))
              .toList(),
          onChanged: (val) => setState(() {
            _selectedClass = val;
            _selectedStudent = null; // reset student on class change
          }),
        ),
      ),
    );
  }

  Widget _buildStudentSelector(
      List<Student> students, bool isDark, ThemeData theme) {
    if (_selectedClass == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.info_circle,
                size: 16,
                color: isDark ? Colors.white30 : Colors.grey[400]),
            const SizedBox(width: 8),
            Text(
              'اختر الفصل أولاً لعرض الطلاب',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : Colors.grey[400],
                fontFamily: 'GoogleSans',
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _selectedStudent != null
              ? AppColors.primary.withValues(alpha: 0.4)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE2E8F0)),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Student>(
          value: _selectedStudent,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'اختر الطالب',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey[400],
                fontFamily: 'GoogleSans',
                fontSize: 14,
              ),
            ),
          ),
          isExpanded: true,
          dropdownColor:
              isDark ? AppColors.surfaceAltDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Icon(
            Icons.expand_more_rounded,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
            fontFamily: 'GoogleSans',
            fontSize: 14,
          ),
          items: students
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                s.name.isNotEmpty
                                    ? s.name.substring(0, 1)
                                    : '?',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: 'GoogleSans',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (val) => setState(() => _selectedStudent = val),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: ReportType.values.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? type.color
                  : (isDark ? AppColors.surfaceAltDark : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? type.color
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2E8F0)),
                width: isSelected ? 0 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: type.color.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type.icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? Colors.white60
                          : AppColors.textSecondaryLight),
                ),
                const SizedBox(width: 8),
                Text(
                  type.nameAr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? Colors.white70
                            : AppColors.textPrimaryLight),
                    fontFamily: 'GoogleSans',
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailsField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.02)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: ModernTextField(
        controller: _descriptionController,
        label: 'اكتب تفاصيل البلاغ...',
        hint: 'صف الموقف بالتفصيل لمساعدة الإدارة في اتخاذ القرار المناسب',
        icon: Icons.edit_note_rounded,
        maxLines: 4,
        isDark: isDark,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'يرجى كتابة تفاصيل البلاغ';
          }
          if (value.trim().length < 10) {
            return 'يرجى كتابة وصف أكثر تفصيلاً';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImageSection(bool isDark) {
    if (_isUploadingImage) {
      return Container(
        height: 76,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.02)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(height: 6),
              Text(
                'جارٍ رفع الصورة...',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontFamily: 'GoogleSans'),
              ),
            ],
          ),
        ),
      );
    }

    if (_attachedImagePath != null) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Colors.green.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.green, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تم إرفاق الصورة بنجاح',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 13,
                        fontFamily: 'GoogleSans'),
                  ),
                  Text(
                    'اضغط على حذف لإلغاء الإرفاق',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontFamily: 'GoogleSans'),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () =>
                  setState(() => _attachedImagePath = null),
              child: const Text('حذف',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontFamily: 'GoogleSans')),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _simulatePickImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.02)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 24,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'إرفاق صورة إثبات',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary,
                  fontFamily: 'GoogleSans'),
            ),
            const SizedBox(height: 2),
            Text(
              'اختياري — اضغط هنا لإرفاق صورة توضيحية',
              style: TextStyle(
                  fontSize: 10.5,
                  color: isDark ? Colors.white38 : Colors.grey[500],
                  fontFamily: 'GoogleSans'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppColors.brandGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded, size: 18),
            SizedBox(width: 8),
            Text(
              'إرسال البلاغ للإدارة',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'GoogleSans'),
            ),
          ],
        ),
      ),
    );
  }
}
