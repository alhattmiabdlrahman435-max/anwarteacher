import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/report.dart';
import '../../../../core/providers/reports_provider.dart';
import '../../../../core/providers/classes_provider.dart';
import '../../../../core/providers/children_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/modern_text_field.dart';
import '../../../../core/widgets/app_notification.dart';

class ReportCreateSheet extends ConsumerStatefulWidget {
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onSuccess;

  const ReportCreateSheet({
    super.key,
    required this.isDark,
    required this.primaryColor,
    required this.onSuccess,
  });

  @override
  ConsumerState<ReportCreateSheet> createState() => _ReportCreateSheetState();
}

class _ReportCreateSheetState extends ConsumerState<ReportCreateSheet> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedClass;
  Student? _selectedStudent;
  ReportType? _selectedType;
  String? _attachedImagePath;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final classes = ref.read(classesProvider);
      final currentSelectedClass = ref.read(selectedClassProvider);
      setState(() {
        _selectedClass = currentSelectedClass.isNotEmpty 
            ? currentSelectedClass 
            : (classes.isNotEmpty ? classes.first : null);
      });
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  List<Student> _getFilteredStudents(List<Student> allStudents) {
    if (_selectedClass == null) return allStudents;

    final filtered = allStudents.where((s) {
      final cls = _selectedClass!;
      final grade = s.grade;
      if (cls.contains('خامس') && grade.contains('خامس')) return true;
      if (cls.contains('سادس') && grade.contains('سادس')) return true;
      return false;
    }).toList();

    return filtered.isNotEmpty ? filtered : allStudents;
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
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClass == null) {
      AppNotification.show(
        context,
        type: AppNotificationType.warning,
        title: 'يرجى اختيار الفصل الدراسي',
      );
      return;
    }

    if (_selectedStudent == null) {
      AppNotification.show(
        context,
        type: AppNotificationType.warning,
        title: 'يرجى اختيار الطالب',
      );
      return;
    }

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
          className: _selectedClass!,
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

    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dialogBg = widget.isDark ? AppColors.surfaceAltDark : Colors.white;
    final textColor = widget.isDark ? Colors.white : AppColors.textPrimaryLight;

    final classes = ref.watch(classesProvider);
    final allStudents = ref.watch(childrenProvider);
    final filteredStudents = _getFilteredStudents(allStudents);

    // If selected student is not in the newly filtered list, reset it
    if (_selectedStudent != null && !filteredStudents.any((s) => s.id == _selectedStudent!.id)) {
      _selectedStudent = null;
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: dialogBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: widget.isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
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
                        color: widget.isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.assignment_late_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'بلاغ جديد',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إرسال بلاغ جديد لإدارة المدرسة',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: widget.isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                fontFamily: AppTypography.fontFamily,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          size: 28,
                          color: widget.isDark ? Colors.white30 : Colors.grey.shade400,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Labeled section for Student Info
                  _buildSectionLabel('معلومات الطالب', Icons.person_pin_rounded, widget.isDark),
                  const SizedBox(height: 10),
                  _buildClassDropdown(classes, widget.isDark, textColor),
                  const SizedBox(height: 10),
                  _buildStudentDropdown(filteredStudents, widget.isDark, textColor),
                  const SizedBox(height: 20),

                  // Labeled section for type selector
                  _buildSectionLabel('نوع البلاغ', Icons.category_rounded, widget.isDark),
                  const SizedBox(height: 10),
                  _buildTypeSelector(widget.isDark),
                  const SizedBox(height: 20),

                  // Labeled section for details text field
                  _buildSectionLabel('تفاصيل البلاغ', Icons.notes_rounded, widget.isDark),
                  const SizedBox(height: 10),
                  _buildDetailsField(widget.isDark),
                  const SizedBox(height: 20),

                  // Labeled section for image attachment
                  _buildSectionLabel('إرفاق صورة إثبات', Icons.photo_camera_rounded, widget.isDark),
                  const SizedBox(height: 10),
                  _buildImageSection(widget.isDark),
                  const SizedBox(height: 28),

                  // Submit Button
                  _buildSubmitButton(widget.isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
            color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
            fontFamily: AppTypography.fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildClassDropdown(List<String> classes, bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceAltDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedClass,
          hint: Text('اختر الفصل الدراسي...', style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondaryLight, fontFamily: AppTypography.fontFamily, fontSize: 13)),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: widget.primaryColor, size: 20),
          dropdownColor: isDark ? AppColors.surfaceAltDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontFamily: AppTypography.fontFamily,
            fontSize: 13.5,
          ),
          items: classes.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(c),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedClass = newValue;
                _selectedStudent = null;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildStudentDropdown(List<Student> students, bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceAltDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Student>(
          isExpanded: true,
          value: _selectedStudent,
          hint: Text('اختر الطالب...', style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondaryLight, fontFamily: AppTypography.fontFamily, fontSize: 13)),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: widget.primaryColor, size: 20),
          dropdownColor: isDark ? AppColors.surfaceAltDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontFamily: AppTypography.fontFamily,
            fontSize: 13.5,
          ),
          items: students.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Text(s.name),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedStudent = newValue;
            });
          },
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
                      : (isDark ? Colors.white60 : AppColors.textSecondaryLight),
                ),
                const SizedBox(width: 8),
                Text(
                  type.nameAr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                    fontFamily: AppTypography.fontFamily,
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
        color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
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
          color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
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
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_attachedImagePath != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_rounded, color: Colors.green, size: 20),
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
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                  Text(
                    'اضغط على حذف لإلغاء الإرفاق',
                    style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: AppTypography.fontFamily),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _attachedImagePath = null),
              child: const Text('حذف', style: TextStyle(color: Colors.red, fontSize: 13, fontFamily: AppTypography.fontFamily)),
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
          color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8FAFC),
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
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'اختياري — اضغط هنا لإرفاق صورة توضيحية',
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? Colors.white38 : Colors.grey[500],
                fontFamily: AppTypography.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
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
            borderRadius: BorderRadius.circular(16),
          ),
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
                fontFamily: AppTypography.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
