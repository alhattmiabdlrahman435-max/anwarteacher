import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/academic_grade.dart';
import '../../../../core/providers/grades_provider.dart';
import '../../../../core/providers/connectivity_provider.dart';
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
  bool _isTableView = true; // Default to table view as requested by user

  // Linked controllers for sticky table header and sticky student name column
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _bodyHorizontalController = ScrollController();
  final ScrollController _namesVerticalController = ScrollController();
  final ScrollController _cellsVerticalController = ScrollController();

  bool _isSyncingHorizontal = false;
  bool _isSyncingVertical = false;

  // Track controllers for table cells: key = "studentId_term_view_field"
  final Map<String, TextEditingController> _cellControllers = {};

  @override
  void initState() {
    super.initState();
    _setupScrollSynchronization();
    Future.microtask(() {
      if (mounted) {
        ref.read(gradesDataProvider.notifier).refresh();
      }
    });
  }

  void _setupScrollSynchronization() {
    // Horizontal sync between Header columns and Body cells
    _headerHorizontalController.addListener(() {
      if (!_isSyncingHorizontal && _bodyHorizontalController.hasClients) {
        _isSyncingHorizontal = true;
        if (_bodyHorizontalController.offset != _headerHorizontalController.offset) {
          _bodyHorizontalController.jumpTo(_headerHorizontalController.offset);
        }
        _isSyncingHorizontal = false;
      }
    });

    _bodyHorizontalController.addListener(() {
      if (!_isSyncingHorizontal && _headerHorizontalController.hasClients) {
        _isSyncingHorizontal = true;
        if (_headerHorizontalController.offset != _bodyHorizontalController.offset) {
          _headerHorizontalController.jumpTo(_bodyHorizontalController.offset);
        }
        _isSyncingHorizontal = false;
      }
    });

    // Vertical sync between Sticky Student Name column and Body cells rows
    _namesVerticalController.addListener(() {
      if (!_isSyncingVertical && _cellsVerticalController.hasClients) {
        _isSyncingVertical = true;
        if (_cellsVerticalController.offset != _namesVerticalController.offset) {
          _cellsVerticalController.jumpTo(_namesVerticalController.offset);
        }
        _isSyncingVertical = false;
      }
    });

    _cellsVerticalController.addListener(() {
      if (!_isSyncingVertical && _namesVerticalController.hasClients) {
        _isSyncingVertical = true;
        if (_namesVerticalController.offset != _cellsVerticalController.offset) {
          _namesVerticalController.jumpTo(_cellsVerticalController.offset);
        }
        _isSyncingVertical = false;
      }
    });
  }

  @override
  void dispose() {
    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    _namesVerticalController.dispose();
    _cellsVerticalController.dispose();

    for (final c in _cellControllers.values) {
      c.dispose();
    }
    _cellControllers.clear();
    super.dispose();
  }

  TextEditingController _getController(String key, double value) {
    final formatted = value == 0 ? '' : value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
    if (!_cellControllers.containsKey(key)) {
      _cellControllers[key] = TextEditingController(text: formatted);
    } else {
      // If controller text is different from current grade value and not currently focused, update it
      final currentText = _cellControllers[key]!.text;
      final currentDouble = double.tryParse(currentText) ?? 0.0;
      if (currentDouble != value && (currentText.isNotEmpty || value != 0)) {
        _cellControllers[key]!.text = formatted;
      }
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
      bottomNavigationBar: _buildBottomSubmitBar(isDark, primaryColor),
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
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: _buildFilters(isDark, primaryColor),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ModernCard(
            isDark: isDark,
            padding: EdgeInsets.zero,
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Custom Modern Term Segmented Control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            height: 48,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTermButton(1, context.loc.firstSemester, isDark, primaryColor)),
                Expanded(child: _buildTermButton(2, context.loc.secondSemester, isDark, primaryColor)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Modern Month & Summary Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              _buildFilterChip(1, context.loc.month1, isDark, primaryColor),
              const SizedBox(width: AppSpacing.sm),
              _buildFilterChip(2, context.loc.month2, isDark, primaryColor),
              const SizedBox(width: AppSpacing.sm),
              _buildFilterChip(3, context.loc.month3, isDark, primaryColor),
              const SizedBox(width: AppSpacing.sm),
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
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? AppColors.surfaceAltDark : Colors.white) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 6,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? activeColor 
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white),
          borderRadius: BorderRadius.circular(20),
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
                        blurRadius: 6,
                        offset: const Offset(0, 3),
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
            fontSize: 13,
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
          // Table View
          GestureDetector(
            onTap: () {
              if (!_isTableView) {
                setState(() => _isTableView = true);
              }
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
                size: 18,
                color: _isTableView
                    ? Colors.white
                    : (isDark ? Colors.white54 : AppColors.textSecondaryLight),
              ),
            ),
          ),
          const SizedBox(width: 2),
          // Card View
          GestureDetector(
            onTap: () {
              if (_isTableView) {
                setState(() => _isTableView = false);
              }
            },
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
                size: 18,
                color: !_isTableView
                    ? Colors.white
                    : (isDark ? Colors.white54 : AppColors.textSecondaryLight),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// STICKY HEADER TABLE VIEW:
  /// - Pinned Column Header at the top (never scrolls vertically)
  /// - Pinned Student Name Column on the side (never scrolls horizontally)
  /// - Synchronized horizontal scroll between Header and Body
  /// - Synchronized vertical scroll between Names and Cells
  Widget _buildTableView(List<StudentSubjectGrade> grades, bool isDark, Color primaryColor) {
    final bool isMonthView = _selectedView <= 3;
    final theme = Theme.of(context);

    // Define columns based on selected month or summary
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

    const double cellWidth = 92.0;
    const double nameColumnWidth = 145.0;
    const double rowHeight = 52.0;
    const double headerHeight = 52.0;

    final double totalColumnsWidth = columns.length * cellWidth;

    // Calculate height to fit rows comfortably
    final screenHeight = MediaQuery.of(context).size.height;
    final maxTableBodyHeight = (screenHeight * 0.55).clamp(260.0, 520.0);
    final double actualRowsHeight = grades.length * rowHeight;
    final double tableBodyHeight = actualRowsHeight.clamp(rowHeight, maxTableBodyHeight);

    final headerBg = isDark ? AppColors.surfaceAltDark : AppColors.primary;
    const headerTextColor = Colors.white;
    final rowBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final altRowBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ================= 1. FIXED / STICKY HEADER ROW =================
          Container(
            height: headerHeight,
            decoration: BoxDecoration(
              color: headerBg,
              border: Border(bottom: BorderSide(color: borderColor, width: 1.5)),
            ),
            child: Row(
              children: [
                // Fixed Student Name Header
                Container(
                  width: nameColumnWidth,
                  height: headerHeight,
                  decoration: BoxDecoration(
                    color: headerBg,
                    border: Border(
                      left: BorderSide(color: isDark ? Colors.white12 : Colors.white24, width: 1.5),
                    ),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    context.loc.studentNameColumn,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: headerTextColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Horizontally Scrollable Column Headers (linked with body)
                Expanded(
                  child: SingleChildScrollView(
                    controller: _headerHorizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: totalColumnsWidth,
                      child: Row(
                        children: columns.map((col) {
                          return Container(
                            width: cellWidth,
                            height: headerHeight,
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: isDark ? Colors.white12 : Colors.white24, width: 0.5),
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
                ),
              ],
            ),
          ),

          // ================= 2. VERTICALLY SCROLLABLE ROWS BODY =================
          SizedBox(
            height: tableBodyHeight,
            child: Row(
              children: [
                // Sticky Student Name Column (vertically scrollable, locked horizontally)
                SizedBox(
                  width: nameColumnWidth,
                  child: ListView.builder(
                    controller: _namesVerticalController,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: grades.length,
                    itemExtent: rowHeight,
                    itemBuilder: (context, index) {
                      final grade = grades[index];
                      final isAlt = index % 2 == 1;
                      final currentRowBg = isAlt ? altRowBg : rowBg;

                      return Container(
                        height: rowHeight,
                        decoration: BoxDecoration(
                          color: currentRowBg,
                          border: Border(
                            left: BorderSide(color: borderColor, width: 1.5),
                            bottom: BorderSide(color: borderColor, width: 0.5),
                          ),
                        ),
                        alignment: AlignmentDirectional.centerStart,
                        padding: const EdgeInsetsDirectional.only(start: 10, end: 6),
                        child: Text(
                          context.translateMock(grade.studentName),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),

                // Horizontally and Vertically scrollable data cells
                Expanded(
                  child: SingleChildScrollView(
                    controller: _bodyHorizontalController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: totalColumnsWidth,
                      child: ListView.builder(
                        controller: _cellsVerticalController,
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: grades.length,
                        itemExtent: rowHeight,
                        itemBuilder: (context, index) {
                          final grade = grades[index];
                          final termRecord = _selectedTermIndex == 1 ? grade.firstTerm : grade.secondTerm;
                          final isAlt = index % 2 == 1;
                          final currentRowBg = isAlt ? altRowBg : rowBg;

                          return SizedBox(
                            height: rowHeight,
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
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
    final MonthRecord month = isMonthView 
        ? ((_selectedView - 1 < termRecord.months.length) 
            ? termRecord.months[_selectedView - 1] 
            : const MonthRecord(monthIndex: 1)) 
        : (termRecord.months.isNotEmpty ? termRecord.months.first : const MonthRecord(monthIndex: 1));

    // Calculate value
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

    final bool isReadOnly = column.isReadOnly;
    final bool isTotalColumn = column.key == 'total';

    if (isReadOnly) {
      // Calculated Read-only cell (Total or Average)
      Color textColor = isDark ? Colors.white70 : AppColors.textSecondaryLight;
      Color cellBg = bgColor;

      if (isTotalColumn && value > 0) {
        final maxTotal = isMonthView ? 100.0 : 50.0;
        if (value >= maxTotal * 0.9) {
          textColor = AppColors.success;
          cellBg = AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08);
        } else if (value >= maxTotal * 0.7) {
          textColor = AppColors.primaryGradient;
          cellBg = AppColors.primaryGradient.withValues(alpha: isDark ? 0.15 : 0.08);
        } else if (value >= maxTotal * 0.5) {
          textColor = AppColors.accent;
          cellBg = AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.08);
        } else {
          textColor = AppColors.error;
          cellBg = AppColors.error.withValues(alpha: isDark ? 0.15 : 0.08);
        }
      }

      return Container(
        width: cellWidth,
        height: rowHeight,
        decoration: BoxDecoration(
          color: cellBg,
          border: Border(
            left: BorderSide(color: borderColor, width: 0.5),
            bottom: BorderSide(color: borderColor, width: 0.5),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          value.toStringAsFixed(1),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: isTotalColumn ? FontWeight.w800 : FontWeight.w600,
            color: textColor,
            fontSize: 13,
          ),
        ),
      );
    }

    // Editable cell with seamless numeric keyboard & auto text selection on tap
    final controllerKey = '${grade.studentId}_${_selectedTermIndex}_${_selectedView}_${column.key}';
    final controller = _getController(controllerKey, value);

    return Container(
      width: cellWidth,
      height: rowHeight,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(color: borderColor, width: 0.5),
          bottom: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        onTap: () {
          // Select all text on tap for single-tap replacement without deleting
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        },
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
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
            borderSide: BorderSide(color: isDark ? AppColors.uiPalettePrimary : primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        ),
        onChanged: (val) {
          final doubleVal = double.tryParse(val) ?? 0.0;
          _updateGradeCell(grade, column.key, doubleVal, isMonthView);
        },
      ),
    );
  }

  void _updateGradeCell(StudentSubjectGrade grade, String field, double value, bool isMonthView) {
    TermRecord termRecord = _selectedTermIndex == 1 ? grade.firstTerm : grade.secondTerm;

    if (isMonthView) {
      final monthIdx = _selectedView - 1;
      final months = List<MonthRecord>.from(termRecord.months);
      while (months.length <= monthIdx) {
        months.add(MonthRecord(monthIndex: months.length + 1));
      }
      MonthRecord month = months[monthIdx];
      switch (field) {
        case 'homework': month = month.copyWith(homework: value); break;
        case 'attendance': month = month.copyWith(attendance: value); break;
        case 'behavior': month = month.copyWith(behavior: value); break;
        case 'oral': month = month.copyWith(oral: value); break;
        case 'written': month = month.copyWith(written: value); break;
      }
      months[monthIdx] = month;
      termRecord = termRecord.copyWith(months: months);
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

    // Save locally immediately (Offline-First, no network call on keystroke)
    ref.read(gradesDataProvider.notifier).updateStudentGrade(grade.studentId, updatedGrade);
  }

  Widget _buildStudentCard(StudentSubjectGrade grade, bool isDark, Color primaryColor) {
    final termRecord = _selectedTermIndex == 1 ? grade.firstTerm : grade.secondTerm;
    final bool isMonthView = _selectedView <= 3;
    final double currentTotal = isMonthView 
        ? ((_selectedView - 1 < termRecord.months.length) 
            ? termRecord.months[_selectedView - 1].total 
            : 0.0)
        : termRecord.termTotal;

    final theme = Theme.of(context);
    return ModernCard(
      isDark: isDark,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.zero,
      onTap: () {
        _showGradeEntrySheet(context, grade, termRecord, isMonthView, primaryColor);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            StudentAvatar(
              photoUrl: grade.studentPhotoUrl,
              name: grade.studentName,
              size: 48,
            ),
            const SizedBox(width: 14),
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
              title: context.loc.gradesSavedLocally,
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
      constraints: const BoxConstraints(minWidth: 54),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
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

  /// STICKY BOTTOM SUBMIT BAR:
  /// Allows submitting all locally saved grades to the administration when desired.
  Widget _buildBottomSubmitBar(bool isDark, Color primaryColor) {
    final classGrades = ref.watch(gradesDataProvider);
    final isUnsynced = classGrades.hasUnsyncedChanges;
    final isSubmitting = classGrades.isSubmitting;
    final connectivity = ref.watch(connectivityProvider);
    final isOffline = connectivity == ConnectivityStatus.offline;

    final barBg = isDark ? AppColors.surfaceAltDark : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: barBg,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : AppColors.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Status Icon & Text
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOffline
                          ? Colors.grey
                          : (isUnsynced ? Colors.orange : AppColors.success),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isOffline
                          ? context.loc.offlineMode
                          : (isUnsynced
                              ? context.loc.unsyncedGradesNotice
                              : context.loc.allGradesSynced),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Submit Button
            FilledButton.icon(
              onPressed: isSubmitting ? null : _confirmAndSubmitGrades,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CupertinoActivityIndicator(color: Colors.white),
                    )
                  : const Icon(CupertinoIcons.cloud_upload_fill, size: 18),
              label: Text(
                isSubmitting ? context.loc.sendingGrades : context.loc.sendGradesToAdmin,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppColors.uiPalettePrimary : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAndSubmitGrades() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceAltDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.loc.confirmSendGradesTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          context.loc.confirmSendGradesMessage,
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              context.loc.cancel,
              style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? AppColors.uiPalettePrimary : AppColors.primary,
            ),
            child: Text(context.loc.sendNow),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await ref.read(gradesDataProvider.notifier).sendGradesToAdministration();

    if (!mounted) return;

    if (result.isOffline) {
      AppNotification.show(
        context,
        type: AppNotificationType.warning,
        title: context.loc.noInternetGradesSaved,
      );
    } else if (result.isSuccess) {
      AppNotification.show(
        context,
        type: AppNotificationType.success,
        title: context.loc.gradesSentSuccessfully,
      );
    } else {
      AppNotification.show(
        context,
        type: AppNotificationType.error,
        title: result.errorMessage ?? 'حدث خطأ أثناء إرسال الدرجات',
      );
    }
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
      final monthIdx = widget.selectedView - 1;
      _currentMonth = (monthIdx < _currentTerm.months.length)
          ? _currentTerm.months[monthIdx]
          : const MonthRecord(monthIndex: 1);
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
                      size: 54,
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
                const SizedBox(height: 28),

                // Inputs
                if (widget.isMonthView)
                  _buildMonthInputs()
                else
                  _buildTermSummaryInputs(),

                const SizedBox(height: 28),

                FilledButton(
                  onPressed: _saveAndClose,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      final monthIdx = widget.selectedView - 1;
      while (updatedMonths.length <= monthIdx) {
        updatedMonths.add(MonthRecord(monthIndex: updatedMonths.length + 1));
      }
      updatedMonths[monthIdx] = _currentMonth;
      updatedTerm = updatedTerm.copyWith(months: updatedMonths);
    } else {
      updatedTerm = updatedTerm.copyWith(finalExam: _currentTerm.finalExam);
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
