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
import '../../../../core/widgets/student_avatar.dart';

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  int _selectedTermIndex = 1; // 1 or 2
  int _selectedView = 1; // 1, 2, 3 for months, 4 for final/summary
  String _searchQuery = '';
  bool _isTableView = false;
  final ScrollController _tableVerticalController = ScrollController();
  final ScrollController _tableHorizontalController = ScrollController();
  // Track controllers for table cells: key = "studentId_field"
  final Map<String, TextEditingController> _cellControllers = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(gradesDataProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _tableVerticalController.dispose();
    _tableHorizontalController.dispose();
    for (final c in _cellControllers.values) {
      c.dispose();
    }
    _cellControllers.clear();
    super.dispose();
  }

  TextEditingController _getController(String key, double value) {
    if (!_cellControllers.containsKey(key)) {
      _cellControllers[key] = TextEditingController(
        text: value == 0 ? '' : value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1),
      );
    }
    return _cellControllers[key]!;
  }

  @override
  Widget build(BuildContext context) {
    final classGrades = ref.watch(gradesDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : AppColors.primary;

    final filteredGrades = classGrades.grades.where((g) {
      final query = _searchQuery.trim().toLowerCase();
      return g.studentName.toLowerCase().contains(query) ||
          g.studentId.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => ref.read(gradesDataProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            AppSliverHeader(
            title: context.loc.gradesRecord,
            automaticallyImplyLeading: true,
            trailing: _buildHeaderViewToggle(isDark, primaryColor),
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
                : _isTableView
                    ? SliverToBoxAdapter(
                        child: _buildTableView(filteredGrades, isDark, primaryColor),
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
              color: isDark ? Colors.black26 : AppColors.surfaceLight,
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
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
    final activeColor = isDark ? AppColors.uiPalettePrimary : primaryColor;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedView = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? activeColor 
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected 
                ? activeColor 
                : (isDark ? Colors.white24 : AppColors.border),
          ),
          boxShadow: !isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : (isSelected
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: isDark ? 0.4 : 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : (isDark ? Colors.white70 : AppColors.textSecondaryLight),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderViewToggle(bool isDark, Color primaryColor) {
    final activeColor = isDark ? AppColors.uiPalettePrimary : primaryColor;
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card View
          GestureDetector(
            onTap: () => setState(() => _isTableView = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: !_isTableView ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                CupertinoIcons.square_list,
                size: 20,
                color: !_isTableView
                    ? Colors.white
                    : (isDark ? Colors.white54 : AppColors.textSecondaryLight),
              ),
            ),
          ),
          const SizedBox(width: 2),
          // Table View
          GestureDetector(
            onTap: () {
              for (final c in _cellControllers.values) {
                c.dispose();
              }
              _cellControllers.clear();
              setState(() => _isTableView = true);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _isTableView ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                CupertinoIcons.table,
                size: 20,
                color: _isTableView
                    ? Colors.white
                    : (isDark ? Colors.white54 : AppColors.textSecondaryLight),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(List<StudentSubjectGrade> grades, bool isDark, Color primaryColor) {
    final bool isMonthView = _selectedView <= 3;
    final theme = Theme.of(context);

    // Define columns based on view
    final List<_TableColumn> columns = isMonthView
        ? [
            _TableColumn(context.loc.homeworkLabel('15'), 'homework', 15),
            _TableColumn(context.loc.attendanceLabel('15'), 'attendance', 15),
            _TableColumn(context.loc.behaviorLabel('10'), 'behavior', 10),
            _TableColumn(context.loc.oralLabel('10'), 'oral', 10),
            _TableColumn(context.loc.writtenLabel('50'), 'written', 50),
            _TableColumn(context.loc.total, 'total', 0, isReadOnly: true),
          ]
        : [
            _TableColumn(context.loc.averageLabel('20'), 'average', 20, isReadOnly: true),
            _TableColumn(context.loc.finalExamLabel('30'), 'finalExam', 30),
            _TableColumn(context.loc.total, 'total', 0, isReadOnly: true),
          ];

    final double cellWidth = 90;
    final double nameColumnWidth = 160;
    final double rowHeight = 52;
    final double headerHeight = 56;

    final headerBg = isDark ? AppColors.surfaceAltDark : AppColors.primary;
    final headerTextColor = Colors.white;
    final rowBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final altRowBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Row
          SizedBox(
            height: headerHeight,
            child: Row(
              children: [
                // Sticky name header
                Container(
                  width: nameColumnWidth,
                  height: headerHeight,
                  decoration: BoxDecoration(
                    color: headerBg,
                    border: Border(
                      left: BorderSide.none,
                      right: BorderSide(color: isDark ? Colors.white12 : Colors.white24, width: 2),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    context.loc.studentNameColumn,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: headerTextColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                // Scrollable column headers
                Expanded(
                  child: SingleChildScrollView(
                    controller: _tableHorizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: columns.map((col) {
                        return Container(
                          width: cellWidth,
                          height: headerHeight,
                          decoration: BoxDecoration(
                            color: headerBg,
                            border: Border(
                              right: BorderSide(color: isDark ? Colors.white12 : Colors.white24, width: 0.5),
                            ),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            col.label,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: headerTextColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Data Rows
          ListView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: grades.length,
              itemBuilder: (context, index) {
                final grade = grades[index];
                final termRecord = _selectedTermIndex == 1 ? grade.firstTerm : grade.secondTerm;
                final isAlt = index % 2 == 1;
                final currentRowBg = isAlt ? altRowBg : rowBg;

                return SizedBox(
                  height: rowHeight,
                  child: Row(
                    children: [
                      // Sticky name cell
                      Container(
                        width: nameColumnWidth,
                        height: rowHeight,
                        decoration: BoxDecoration(
                          color: currentRowBg,
                          border: Border(
                            right: BorderSide(color: borderColor, width: 2),
                            bottom: BorderSide(color: borderColor, width: 0.5),
                          ),
                        ),
                        alignment: AlignmentDirectional.centerStart,
                        padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
                        child: Text(
                          context.translateMock(grade.studentName),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Scrollable cells
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            // Sync horizontal scroll across rows
                            if (notification is ScrollUpdateNotification) {
                              _tableHorizontalController.jumpTo(
                                notification.metrics.pixels,
                              );
                            }
                            return false;
                          },
                          child: SingleChildScrollView(
                            controller: ScrollController(
                              initialScrollOffset: _tableHorizontalController.hasClients
                                  ? _tableHorizontalController.offset
                                  : 0,
                            ),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: columns.map((col) {
                                return _buildTableCell(
                                  grade: grade,
                                  termRecord: termRecord,
                                  column: col,
                                  isMonthView: isMonthView,
                                  cellWidth: cellWidth,
                                  rowHeight: rowHeight,
                                  bgColor: currentRowBg,
                                  borderColor: borderColor,
                                  isDark: isDark,
                                  primaryColor: primaryColor,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTableCell({
    required StudentSubjectGrade grade,
    required TermRecord termRecord,
    required _TableColumn column,
    required bool isMonthView,
    required double cellWidth,
    required double rowHeight,
    required Color bgColor,
    required Color borderColor,
    required bool isDark,
    required Color primaryColor,
  }) {
    final theme = Theme.of(context);
    final MonthRecord month = isMonthView ? termRecord.months[_selectedView - 1] : termRecord.months.first;
    final bool isSaved = isMonthView ? month.isSaved : termRecord.isFinalSaved;

    // Get value
    double value = 0;
    if (isMonthView) {
      switch (column.key) {
        case 'homework': value = month.homework; break;
        case 'attendance': value = month.attendance; break;
        case 'behavior': value = month.behavior; break;
        case 'oral': value = month.oral; break;
        case 'written': value = month.written; break;
        case 'total': value = month.total; break;
      }
    } else {
      switch (column.key) {
        case 'average': value = termRecord.monthsAverage; break;
        case 'finalExam': value = termRecord.finalExam; break;
        case 'total': value = termRecord.termTotal; break;
      }
    }

    final bool isReadOnly = column.isReadOnly || isSaved;
    final bool isTotalColumn = column.key == 'total';

    if (isReadOnly) {
      // Read-only cell (total, average, or saved)
      Color textColor = isDark ? Colors.white70 : AppColors.textSecondaryLight;
      Color cellBg = bgColor;

      if (isTotalColumn && value > 0) {
        final maxTotal = isMonthView ? 100.0 : 50.0;
        if (value >= maxTotal * 0.9) {
          textColor = AppColors.success;
          cellBg = AppColors.success.withValues(alpha: isDark ? 0.12 : 0.06);
        } else if (value >= maxTotal * 0.7) {
          textColor = AppColors.primaryGradient;
          cellBg = AppColors.primaryGradient.withValues(alpha: isDark ? 0.12 : 0.06);
        } else if (value >= maxTotal * 0.5) {
          textColor = AppColors.accent;
          cellBg = AppColors.accent.withValues(alpha: isDark ? 0.12 : 0.06);
        } else {
          textColor = AppColors.error;
          cellBg = AppColors.error.withValues(alpha: isDark ? 0.12 : 0.06);
        }
      }

      return Container(
        width: cellWidth,
        height: rowHeight,
        decoration: BoxDecoration(
          color: cellBg,
          border: Border(
            right: BorderSide(color: borderColor, width: 0.5),
            bottom: BorderSide(color: borderColor, width: 0.5),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          value.toStringAsFixed(1),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: isTotalColumn ? FontWeight.w800 : FontWeight.w600,
            color: textColor,
          ),
        ),
      );
    }

    // Editable cell
    final controllerKey = '${grade.studentId}_${_selectedTermIndex}_${_selectedView}_${column.key}';
    final controller = _getController(controllerKey, value);

    return Container(
      width: cellWidth,
      height: rowHeight,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(color: borderColor, width: 0.5),
          bottom: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        inputFormatters: [
          TextInputFormatter.withFunction((oldValue, newValue) {
            if (newValue.text.isEmpty) return newValue;
            final val = double.tryParse(newValue.text);
            if (val == null) return oldValue;
            if (val > column.maxValue) return oldValue;
            return newValue;
          }),
        ],
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: isDark ? AppColors.uiPalettePrimary : primaryColor, width: 2),
          ),
          filled: true,
          fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        ),
        onChanged: (val) {
          final doubleVal = double.tryParse(val) ?? 0;
          _updateGradeCell(grade, column.key, doubleVal, isMonthView);
        },
      ),
    );
  }

  void _updateGradeCell(StudentSubjectGrade grade, String field, double value, bool isMonthView) {
    TermRecord termRecord = _selectedTermIndex == 1 ? grade.firstTerm : grade.secondTerm;

    if (isMonthView) {
      final monthIdx = _selectedView - 1;
      MonthRecord month = termRecord.months[monthIdx];
      switch (field) {
        case 'homework': month = month.copyWith(homework: value); break;
        case 'attendance': month = month.copyWith(attendance: value); break;
        case 'behavior': month = month.copyWith(behavior: value); break;
        case 'oral': month = month.copyWith(oral: value); break;
        case 'written': month = month.copyWith(written: value); break;
      }
      final updatedMonths = List<MonthRecord>.from(termRecord.months);
      updatedMonths[monthIdx] = month;
      termRecord = termRecord.copyWith(months: updatedMonths);
    } else {
      switch (field) {
        case 'finalExam': termRecord = termRecord.copyWith(finalExam: value); break;
      }
    }

    var updatedGrade = grade;
    if (_selectedTermIndex == 1) {
      updatedGrade = updatedGrade.copyWith(firstTerm: termRecord);
    } else {
      updatedGrade = updatedGrade.copyWith(secondTerm: termRecord);
    }

    ref.read(gradesDataProvider.notifier).updateStudentGrade(grade.studentId, updatedGrade);
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
                StudentAvatar(
                  photoUrl: grade.studentPhotoUrl,
                  name: grade.studentName,
                  size: 50,
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
                    StudentAvatar(
                      photoUrl: widget.grade.studentPhotoUrl,
                      name: widget.grade.studentName,
                      size: 56,
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

                if ((widget.isMonthView && !_currentMonth.isSaved) || (!widget.isMonthView && !_currentTerm.isFinalSaved))
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
    bool isReadOnly = _currentMonth.isSaved;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLabeledInput(context.loc.homeworkLabel('15'), _currentMonth.homework, 15, isReadOnly, (v) => setState(() => _currentMonth = _currentMonth.copyWith(homework: v)))),
            const SizedBox(width: 16),
            Expanded(child: _buildLabeledInput(context.loc.attendanceLabel('15'), _currentMonth.attendance, 15, isReadOnly, (v) => setState(() => _currentMonth = _currentMonth.copyWith(attendance: v)))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildLabeledInput(context.loc.behaviorLabel('10'), _currentMonth.behavior, 10, isReadOnly, (v) => setState(() => _currentMonth = _currentMonth.copyWith(behavior: v)))),
            const SizedBox(width: 16),
            Expanded(child: _buildLabeledInput(context.loc.oralLabel('10'), _currentMonth.oral, 10, isReadOnly, (v) => setState(() => _currentMonth = _currentMonth.copyWith(oral: v)))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildLabeledInput(context.loc.writtenLabel('50'), _currentMonth.written, 50, isReadOnly, (v) => setState(() => _currentMonth = _currentMonth.copyWith(written: v)))),
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
              Flexible(
                child: Text(
                  context.loc.monthlyTotal,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: widget.primaryColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
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
    bool isReadOnly = _currentTerm.isFinalSaved;
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
              child: _buildLabeledInput(context.loc.finalExamLabel('30'), _currentTerm.finalExam, 30, isReadOnly, (v) => setState(() => _currentTerm = _currentTerm.copyWith(finalExam: v))),
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
              Flexible(
                child: Text(
                  context.loc.totalGrade,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: widget.primaryColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
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

  Widget _buildLabeledInput(String label, double value, double maxValue, bool isReadOnly, Function(double) onChanged) {
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
          readOnly: isReadOnly,
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
      updatedMonths[widget.selectedView - 1] = _currentMonth.copyWith(isSaved: true);
      updatedTerm = updatedTerm.copyWith(months: updatedMonths);
    } else {
      updatedTerm = updatedTerm.copyWith(isFinalSaved: true);
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

class _TableColumn {
  final String label;
  final String key;
  final double maxValue;
  final bool isReadOnly;

  const _TableColumn(this.label, this.key, this.maxValue, {this.isReadOnly = false});
}
