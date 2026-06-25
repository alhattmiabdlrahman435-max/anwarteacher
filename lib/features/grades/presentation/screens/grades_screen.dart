import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/academic_grade.dart';
import '../../../../core/providers/grades_provider.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/widgets/class_subject_selector.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/widgets/app_notification.dart';

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  int _selectedTermIndex = 1; // 1 or 2
  int _selectedView = 1; // 1, 2, 3 for months, 4 for final/summary
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final classGrades = ref.watch(gradesDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : AppColors.primary;

    final filteredGrades = classGrades.grades.where((g) {
      return g.studentName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          AppSliverHeader(
            title: context.loc.gradesRecord,
            automaticallyImplyLeading: true,
          ),
          const ClassSubjectSelector(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: _buildFilters(isDark, primaryColor),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            sliver: filteredGrades.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Icon(CupertinoIcons.search, size: 64, color: isDark ? Colors.white24 : Colors.black12),
                          const SizedBox(height: 16),
                          Text(
                            context.loc.noSearchResults,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final grade = filteredGrades[index];
                        return _buildStudentCard(grade, isDark, primaryColor);
                      },
                      childCount: filteredGrades.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  Widget _buildFilters(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Modern Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: ModernCard(
            isDark: isDark,
            padding: const EdgeInsets.all(0), // padding is handled inside TextField
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: context.loc.searchStudentHint,
                hintStyle: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondaryLight),
                prefixIcon: Icon(CupertinoIcons.search, color: isDark ? Colors.white54 : AppColors.textSecondaryLight),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        
        // Custom Modern Term Segmented Control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Container(
            height: 54,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceAltDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTermButton(1, context.loc.firstSemester, isDark, primaryColor)),
                Expanded(child: _buildTermButton(2, context.loc.secondSemester, isDark, primaryColor)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        
        // Modern Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            children: [
              _buildFilterChip(1, context.loc.month1, isDark, primaryColor),
              const SizedBox(width: AppSpacing.md),
              _buildFilterChip(2, context.loc.month2, isDark, primaryColor),
              const SizedBox(width: AppSpacing.md),
              _buildFilterChip(3, context.loc.month3, isDark, primaryColor),
              const SizedBox(width: AppSpacing.md),
              _buildFilterChip(4, context.loc.recordTotalFinal, isDark, primaryColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermButton(int index, String title, bool isDark, Color primaryColor) {
    final isSelected = _selectedTermIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTermIndex = index),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? AppColors.surfaceAltDark : Colors.white) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected 
                ? (isDark ? Colors.white : primaryColor)
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(int value, String label, bool isDark, Color primaryColor) {
    final isSelected = _selectedView == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedView = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? primaryColor 
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected 
                ? primaryColor 
                : (isDark ? Colors.white12 : AppColors.border),
          ),
          boxShadow: !isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : (isSelected && !isDark
                  ? [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected 
                ? (isDark ? AppColors.surfaceDark : Colors.white) 
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(StudentSubjectGrade grade, bool isDark, Color primaryColor) {
    final termRecord = _selectedTermIndex == 1 ? grade.firstTerm : grade.secondTerm;
    final bool isMonthView = _selectedView <= 3;
    final double currentTotal = isMonthView 
        ? termRecord.months[_selectedView - 1].total 
        : termRecord.termTotal;

    final theme = Theme.of(context);
    return ModernCard(
      isDark: isDark,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: EdgeInsets.zero,
      onTap: () {
        _showGradeEntrySheet(context, grade, termRecord, isMonthView, primaryColor);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      context.translateMock(grade.studentName).isNotEmpty
                          ? context.translateMock(grade.studentName).substring(0, 1)
                          : '?',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.translateMock(grade.studentName),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isMonthView
                            ? context.loc.monthGrades(Localizations.localeOf(context).languageCode == 'ar'
                                ? context.toArabicNumbers(_selectedView.toString())
                                : _selectedView.toString())
                            : context.loc.endTermGrades,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge
                _buildTotalBadge(currentTotal, isMonthView ? 100 : 50, isDark),
              ],
            ),
          ),
    );
  }

  void _showGradeEntrySheet(BuildContext context, StudentSubjectGrade grade, TermRecord termRecord, bool isMonthView, Color primaryColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GradeEntrySheet(
          grade: grade,
          termRecord: termRecord,
          isMonthView: isMonthView,
          selectedView: _selectedView,
          selectedTermIndex: _selectedTermIndex,
          isDark: isDark,
          primaryColor: primaryColor,
          onSave: (updatedGrade) {
            ref.read(gradesDataProvider.notifier).updateStudentGrade(grade.studentId, updatedGrade);
            Navigator.pop(context);
            AppNotification.show(
              context,
              type: AppNotificationType.success,
              title: context.loc.gradesSavedSuccessfully,
            );
          },
        );
      },
    );
  }

  Widget _buildTotalBadge(double total, double maxTotal, bool isDark) {
    Color color = AppColors.textSecondaryLight;
    Color bgColor = isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.surfaceLight;
    
    if (total > 0) {
      if (total >= maxTotal * 0.9) {
        color = AppColors.success;
        bgColor = AppColors.success.withValues(alpha: 0.15);
      } else if (total >= maxTotal * 0.7) {
        color = AppColors.primaryGradient;
        bgColor = AppColors.primaryGradient.withValues(alpha: 0.15);
      } else if (total >= maxTotal * 0.5) {
        color = AppColors.accent;
        bgColor = AppColors.accent.withValues(alpha: 0.15);
      } else {
        color = AppColors.error;
        bgColor = AppColors.error.withValues(alpha: 0.15);
      }
    }

    if (isDark && total > 0) {
      bgColor = color.withValues(alpha: 0.2);
    }

    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 56),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        total.toStringAsFixed(1),
        style: theme.textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class GradeEntrySheet extends StatefulWidget {
  final StudentSubjectGrade grade;
  final TermRecord termRecord;
  final bool isMonthView;
  final int selectedView;
  final int selectedTermIndex;
  final bool isDark;
  final Color primaryColor;
  final Function(StudentSubjectGrade) onSave;

  const GradeEntrySheet({
    super.key,
    required this.grade,
    required this.termRecord,
    required this.isMonthView,
    required this.selectedView,
    required this.selectedTermIndex,
    required this.isDark,
    required this.primaryColor,
    required this.onSave,
  });

  @override
  State<GradeEntrySheet> createState() => _GradeEntrySheetState();
}

class _GradeEntrySheetState extends State<GradeEntrySheet> {
  late MonthRecord _currentMonth;
  late TermRecord _currentTerm;

  @override
  void initState() {
    super.initState();
    _currentTerm = widget.termRecord;
    if (widget.isMonthView) {
      _currentMonth = _currentTerm.months[widget.selectedView - 1];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dialogBg = widget.isDark ? AppColors.surfaceAltDark : Colors.white;
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: dialogBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: widget.isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                const SizedBox(height: 24),
                
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: widget.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          context.translateMock(widget.grade.studentName).isNotEmpty
                              ? context.translateMock(widget.grade.studentName).substring(0, 1)
                              : '?',
                          style: TextStyle(
                            color: widget.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translateMock(widget.grade.studentName),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.isMonthView
                                ? context.loc.recordMonthGrades(Localizations.localeOf(context).languageCode == 'ar'
                                    ? context.toArabicNumbers(widget.selectedView.toString())
                                    : widget.selectedView.toString())
                                : context.loc.recordTotalFinal,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(CupertinoIcons.xmark_circle_fill, size: 28, color: widget.isDark ? Colors.white30 : Colors.grey.shade400),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Inputs
                if (widget.isMonthView)
                  _buildMonthInputs()
                else
                  _buildTermSummaryInputs(),

                const SizedBox(height: 32),

                // Save Button
                FilledButton(
                  onPressed: _saveAndClose,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(context.loc.saveGrades, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthInputs() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLabeledInput(context.loc.homeworkLabel('15'), _currentMonth.homework, 15, (v) => setState(() => _currentMonth = _currentMonth.copyWith(homework: v)))),
            const SizedBox(width: 16),
            Expanded(child: _buildLabeledInput(context.loc.attendanceLabel('15'), _currentMonth.attendance, 15, (v) => setState(() => _currentMonth = _currentMonth.copyWith(attendance: v)))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildLabeledInput(context.loc.behaviorLabel('10'), _currentMonth.behavior, 10, (v) => setState(() => _currentMonth = _currentMonth.copyWith(behavior: v)))),
            const SizedBox(width: 16),
            Expanded(child: _buildLabeledInput(context.loc.oralLabel('10'), _currentMonth.oral, 10, (v) => setState(() => _currentMonth = _currentMonth.copyWith(oral: v)))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildLabeledInput(context.loc.writtenLabel('50'), _currentMonth.written, 50, (v) => setState(() => _currentMonth = _currentMonth.copyWith(written: v)))),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: widget.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.primaryColor.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.loc.monthlyTotal, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: widget.primaryColor)),
              Text(
                _currentMonth.total.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: widget.primaryColor),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTermSummaryInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildReadOnlyBox(context.loc.averageLabel('20'), _currentTerm.monthsAverage),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildLabeledInput(context.loc.finalExamLabel('30'), _currentTerm.finalExam, 30, (v) => setState(() => _currentTerm = _currentTerm.copyWith(finalExam: v))),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: widget.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.primaryColor.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.loc.totalGrade, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: widget.primaryColor)),
              Text(
                _currentTerm.termTotal.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: widget.primaryColor),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildLabeledInput(String label, double value, double maxValue, Function(double) onChanged) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value == 0 ? '' : value.toString(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.isEmpty) return newValue;
              final val = double.tryParse(newValue.text);
              if (val == null) return oldValue;
              if (val > maxValue) return oldValue;
              return newValue;
            }),
          ],
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800, 
          ),
          onChanged: (val) {
            final doubleVal = double.tryParse(val) ?? 0;
            onChanged(doubleVal);
          },
        ),
      ],
    );
  }

  Widget _buildReadOnlyBox(String label, double value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.surfaceAltDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.isDark ? Colors.white12 : AppColors.border),
          ),
          child: Text(
            value.toStringAsFixed(1),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800, 
              color: widget.isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ],
    );
  }

  void _saveAndClose() {
    TermRecord updatedTerm = _currentTerm;
    
    if (widget.isMonthView) {
      final updatedMonths = List<MonthRecord>.from(_currentTerm.months);
      updatedMonths[widget.selectedView - 1] = _currentMonth;
      updatedTerm = updatedTerm.copyWith(months: updatedMonths);
    }

    var updatedGrade = widget.grade;
    if (widget.selectedTermIndex == 1) {
      updatedGrade = updatedGrade.copyWith(firstTerm: updatedTerm);
    } else {
      updatedGrade = updatedGrade.copyWith(secondTerm: updatedTerm);
    }
    
    widget.onSave(updatedGrade);
  }
}
