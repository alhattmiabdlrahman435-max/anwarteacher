import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/academic_grade.dart';
import '../../../../core/providers/grades_provider.dart';
import '../../../../core/providers/classes_provider.dart';
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

/// Formatter that strictly allows English ASCII digits (0-9) and at most one decimal point.
/// Rejects Arabic digits (٠-٩), Persian digits (۰-۹), Arabic commas (،, ٫),
/// European commas (,), letters, and values exceeding [maxValue].
/// Rejection keeps [oldValue] without automatic conversion or replacement.
class StrictEnglishGradeInputFormatter extends TextInputFormatter {
  final double maxValue;

  StrictEnglishGradeInputFormatter({required this.maxValue});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Strictly enforce English digits and single decimal dot
    final allowedRegex = RegExp(r'^[0-9]+(\.[0-9]*)?$');
    if (!allowedRegex.hasMatch(newValue.text)) {
      return oldValue; // Reject non-English, commas, spaces, or multiple dots
    }

    // Enforce maximum allowed value
    final textToCheck = newValue.text.endsWith('.')
        ? newValue.text.substring(0, newValue.text.length - 1)
        : newValue.text;
    if (textToCheck.isNotEmpty) {
      final parsed = double.tryParse(textToCheck);
      if (parsed == null || parsed > maxValue) {
        return oldValue; // Reject values exceeding max
      }
    }

    return newValue;
  }
}

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> with WidgetsBindingObserver {
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
  // Per-row total notifiers to isolate table cell updates without full-table rebuilds
  final Map<String, ValueNotifier<double>> _totalNotifiers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupScrollSynchronization();
    Future.microtask(() {
      if (mounted) {
        ref.read(gradesDataProvider.notifier).refresh();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ref.read(gradesDataProvider.notifier).flushPendingSave();
    }
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
    WidgetsBinding.instance.removeObserver(this);
    ref.read(gradesDataProvider.notifier).flushPendingSave();

    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    _namesVerticalController.dispose();
    _cellsVerticalController.dispose();

    for (final c in _cellControllers.values) {
      c.dispose();
    }
    _cellControllers.clear();
    for (final n in _totalNotifiers.values) {
      n.dispose();
    }
    _totalNotifiers.clear();
    super.dispose();
  }

  ValueNotifier<double> _getTotalNotifier(String key, double initialValue) {
    final existing = _totalNotifiers[key];
    if (existing != null) {
      if (existing.value != initialValue) {
        existing.value = initialValue;
      }
      return existing;
    }
    return _totalNotifiers[key] = ValueNotifier<double>(initialValue);
  }

  TextEditingController _getController(String key, double? value, {bool showZero = false}) {
    final String formatted;
    if (value == null) {
      formatted = '';
    } else if (value == 0) {
      formatted = showZero ? '0' : '';
    } else {
      formatted = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
    }
    if (!_cellControllers.containsKey(key)) {
      _cellControllers[key] = TextEditingController(text: formatted);
    } else {
      final currentText = _cellControllers[key]!.text;
      final currentDouble = currentText.trim().isEmpty ? null : double.tryParse(currentText);
      final normalizedVal = (value == 0 && !showZero) ? null : value;
      if (currentDouble != normalizedVal) {
        _cellControllers[key]!.text = formatted;
      }
    }
    return _cellControllers[key]!;
  }

  @override
  Widget build(BuildContext context) {
    // Watch structural metadata in Table View so typing in a single cell does not rebuild all rows.
    if (_isTableView) {
      ref.watch(gradesDataProvider.select(
        (s) => '${s.classId}|${s.subjectName}|${s.grades.length}|${s.hasUnsyncedChanges}|${s.isSubmitting}|${s.unsyncedStudentIds.length}',
      ));
    } else {
      ref.watch(gradesDataProvider);
    }
    final classGrades = ref.read(gradesDataProvider);
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
        
        // Modern Month & Summary Chips (hidden for descriptive subjects)
        if (ref.watch(gradesDataProvider).isDescriptive)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(CupertinoIcons.star_circle_fill, color: primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'مادة تقديرية — رصد التقدير الوصفي فقط',
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        else
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
  static bool _isMinisterialGrade(String gradeOrClassName) {
    final norm = gradeOrClassName
        .trim()
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ');
    if (norm.isEmpty) return false;
    return norm.contains('تاسع') ||
        norm.contains('ثالث ثانوي') ||
        norm.contains('الثالث الثانوي') ||
        norm.contains('الثالث ثانوي') ||
        norm.contains('ثالث الثانوي');
  }

  Widget _buildTableView(List<StudentSubjectGrade> grades, bool isDark, Color primaryColor) {
    final classGrades = ref.watch(gradesDataProvider);
    final selectedClass = ref.watch(selectedClassProvider);
    final bool isMinisterial = _isMinisterialGrade(selectedClass);
    final int finalExamMax = isMinisterial ? 80 : 30;
    final bool isMonthView = !classGrades.isDescriptive && _selectedView <= 3;
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
        : (classGrades.isDescriptive
            ? [
                _TableColumn('التقدير الوصفي', 'descriptiveGrade', 0),
              ]
            : [
                _TableColumn(context.loc.averageLabel('20'), 'average', 20, isReadOnly: true),
                _TableColumn(context.loc.finalExamLabel('$finalExamMax'), 'finalExam', finalExamMax.toDouble()),
                _TableColumn(context.loc.total, 'total', 0, isReadOnly: true),
              ]);

    final double cellWidth = (!isMonthView && classGrades.isDescriptive) ? 160.0 : 92.0;
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

    final bool isUnsynced = classGrades.hasUnsyncedChanges;

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
          // Table Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isUnsynced
                  ? (isDark ? Colors.amber.withValues(alpha: 0.15) : const Color(0xFFFEF3C7))
                  : (isDark ? AppColors.success.withValues(alpha: 0.15) : const Color(0xFFECFDF5)),
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isUnsynced ? CupertinoIcons.pencil_ellipsis_rectangle : CupertinoIcons.checkmark_seal_fill,
                  size: 16,
                  color: isUnsynced ? (isDark ? Colors.amber[300] : Colors.amber[800]) : AppColors.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isUnsynced
                        ? 'توجد درجات محفوظة كمسودة محلية — اضغط «إرسال الدرجات للإدارة» في الأسفل عند الرغبة في اعتمادها.'
                        : 'جميع الدرجات في هذا الكشف متزامنة ومعتمدة لدى الإدارة.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isUnsynced ? (isDark ? Colors.amber[200] : Colors.amber[900]) : (isDark ? Colors.green[200] : Colors.green[900]),
                    ),
                  ),
                ),
              ],
            ),
          ),
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

    if (column.key == 'descriptiveGrade') {
      final estimates = ref.read(gradesDataProvider).descriptiveEstimates;
      final currentDesc = (termRecord.descriptiveGrade != null &&
              estimates.contains(termRecord.descriptiveGrade))
          ? termRecord.descriptiveGrade
          : null;
      return Container(
        width: cellWidth,
        height: rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(right: BorderSide(color: borderColor)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: currentDesc != null
                  ? primaryColor.withValues(alpha: 0.5)
                  : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              isExpanded: true,
              value: currentDesc,
              hint: const Text('لم يُرصد', style: TextStyle(fontSize: 12)),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('لم يُرصد', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                ...estimates.map((est) => DropdownMenuItem<String?>(
                      value: est,
                      child: Text(est, overflow: TextOverflow.ellipsis),
                    )),
              ],
              onChanged: (val) {
                final updatedTerm = val == null
                    ? termRecord.copyWith(clearDescriptiveGrade: true, isFinalSaved: false)
                    : termRecord.copyWith(descriptiveGrade: val);
                final updatedGrade = _selectedTermIndex == 1
                    ? grade.copyWith(firstTerm: updatedTerm)
                    : grade.copyWith(secondTerm: updatedTerm);
                ref.read(gradesDataProvider.notifier).updateStudentGrade(
                      grade.studentId,
                      updatedGrade,
                      changedPeriodKey: '${grade.studentId}_${_selectedTermIndex}_final',
                    );
              },
            ),
          ),
        ),
      );
    }

    // Calculate value
    double? value = 0;
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
      final double readOnlyValue = value ?? 0.0;
      // Calculated Read-only cell (Total or Average) isolated via ValueNotifier
      final totalKey = '${grade.studentId}_${_selectedTermIndex}_$_selectedView';
      final notifier = isTotalColumn ? _getTotalNotifier(totalKey, readOnlyValue) : null;

      Widget buildReadOnlyContent(double displayVal) {
        Color textColor = isDark ? Colors.white70 : AppColors.textSecondaryLight;
        Color cellBg = bgColor;

        if (isTotalColumn && displayVal > 0) {
          final termMax = _isMinisterialGrade(ref.read(selectedClassProvider)) ? 100.0 : 50.0;
          final maxTotal = isMonthView ? 100.0 : termMax;
          if (displayVal >= maxTotal * 0.9) {
            textColor = AppColors.success;
            cellBg = AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08);
          } else if (displayVal >= maxTotal * 0.7) {
            textColor = AppColors.primaryGradient;
            cellBg = AppColors.primaryGradient.withValues(alpha: isDark ? 0.15 : 0.08);
          } else if (displayVal >= maxTotal * 0.5) {
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
            displayVal.toStringAsFixed(1),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: isTotalColumn ? FontWeight.w800 : FontWeight.w600,
              color: textColor,
              fontSize: 13,
            ),
          ),
        );
      }

      if (notifier != null) {
        return ValueListenableBuilder<double>(
          valueListenable: notifier,
          builder: (_, val, _) => buildReadOnlyContent(val),
        );
      }
      return buildReadOnlyContent(readOnlyValue);
    }

    // Editable cell with seamless numeric keyboard & auto text selection on tap
    final controllerKey = '${grade.studentId}_${_selectedTermIndex}_${_selectedView}_${column.key}';
    final bool isFinalExamField = !isMonthView && column.key == 'finalExam';
    final controller = _getController(controllerKey, value, showZero: isFinalExamField);

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
          StrictEnglishGradeInputFormatter(maxValue: column.maxValue),
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
          final trimmed = val.trim();
          final double? parsedVal = trimmed.isEmpty
              ? (isFinalExamField ? null : 0.0)
              : (double.tryParse(trimmed) ?? (isFinalExamField ? null : 0.0));
          _updateGradeCell(grade.studentId, column.key, parsedVal, isMonthView);
        },
      ),
    );
  }

  void _updateGradeCell(String studentId, String field, double? value, bool isMonthView) {
    // Always read the latest student record so isolated cell edits never overwrite sibling cells
    final currentGrades = ref.read(gradesDataProvider).grades;
    final grade = currentGrades.firstWhere(
      (g) => g.studentId == studentId,
      orElse: () => StudentSubjectGrade(
        studentId: studentId,
        studentName: '',
        subjectId: '',
        firstTerm: const TermRecord(termIndex: 1, months: []),
        secondTerm: const TermRecord(termIndex: 2, months: []),
      ),
    );
    TermRecord termRecord = _selectedTermIndex == 1 ? grade.firstTerm : grade.secondTerm;
    double newTotal = 0.0;

    if (isMonthView) {
      final monthVal = value ?? 0.0;
      final monthIdx = _selectedView - 1;
      final months = List<MonthRecord>.from(termRecord.months);
      while (months.length <= monthIdx) {
        months.add(MonthRecord(monthIndex: months.length + 1));
      }
      MonthRecord month = months[monthIdx];
      switch (field) {
        case 'homework': month = month.copyWith(homework: monthVal); break;
        case 'attendance': month = month.copyWith(attendance: monthVal); break;
        case 'behavior': month = month.copyWith(behavior: monthVal); break;
        case 'oral': month = month.copyWith(oral: monthVal); break;
        case 'written': month = month.copyWith(written: monthVal); break;
      }
      months[monthIdx] = month;
      newTotal = month.total;
      termRecord = termRecord.copyWith(months: months);
    } else {
      switch (field) {
        case 'finalExam':
          termRecord = value == null
              ? termRecord.copyWith(clearFinalExam: true, isFinalSaved: false)
              : termRecord.copyWith(finalExam: value);
          break;
      }
      newTotal = termRecord.termTotal;
    }

    var updatedGrade = grade;
    if (_selectedTermIndex == 1) {
      updatedGrade = updatedGrade.copyWith(firstTerm: termRecord);
    } else {
      updatedGrade = updatedGrade.copyWith(secondTerm: termRecord);
    }

    final totalKey = '${studentId}_${_selectedTermIndex}_$_selectedView';
    _totalNotifiers[totalKey]?.value = newTotal;

    final periodCode = isMonthView ? 'm$_selectedView' : 'final';
    final periodKey = '${studentId}_${_selectedTermIndex}_$periodCode';

    // Save locally immediately in memory + debounced compact delta (no network call on keystroke)
    ref.read(gradesDataProvider.notifier).updateStudentGrade(
          studentId,
          updatedGrade,
          changedPeriodKey: periodKey,
        );
  }

  Widget _buildStudentCard(StudentSubjectGrade grade, bool isDark, Color primaryColor) {
    final classGrades = ref.watch(gradesDataProvider);
    final termRecord = _selectedTermIndex == 1 ? grade.firstTerm : grade.secondTerm;
    final bool isMonthView = !classGrades.isDescriptive && _selectedView <= 3;
    final double currentTotal = isMonthView 
        ? ((_selectedView - 1 < termRecord.months.length) 
            ? termRecord.months[_selectedView - 1].total 
            : 0.0)
        : termRecord.termTotal;
    final bool isStudentUnsynced = classGrades.unsyncedStudentIds.contains(grade.studentId) ||
        (classGrades.hasUnsyncedChanges && classGrades.unsyncedStudentIds.isEmpty && currentTotal > 0);
    final bool hasDraft = isStudentUnsynced;
    final bool isSubmitted = !isStudentUnsynced &&
        (isMonthView
            ? currentTotal > 0
            : (classGrades.isDescriptive
                ? (termRecord.descriptiveGrade != null && termRecord.descriptiveGrade!.isNotEmpty)
                : (termRecord.isFinalSaved && termRecord.finalExam != null)));

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
                  Row(
                    children: [
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
                      const SizedBox(width: 8),
                      if (hasDraft)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.pencil, size: 10, color: isDark ? Colors.amber[300] : Colors.amber[800]),
                              const SizedBox(width: 3),
                              Text(
                                'مسودة محلية',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.amber[300] : Colors.amber[800],
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (isSubmitted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.checkmark_alt, size: 10, color: AppColors.success),
                              SizedBox(width: 3),
                              Text(
                                'معتمدة للإدارة',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            _buildTotalBadge(currentTotal, isMonthView ? 100 : (_isMinisterialGrade(ref.read(selectedClassProvider)) ? 100 : 50), isDark),
          ],
        ),
      ),
    );
  }

  void _showGradeEntrySheet(BuildContext context, StudentSubjectGrade grade, TermRecord termRecord, bool isMonthView, Color primaryColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final classGrades = ref.read(gradesDataProvider);
    final bool isMinisterial = _isMinisterialGrade(ref.read(selectedClassProvider));

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
          isDescriptive: classGrades.isDescriptive,
          isMinisterial: isMinisterial,
          descriptiveEstimates: classGrades.descriptiveEstimates,
          onSave: (updatedGrade) {
            final periodCode = isMonthView ? 'm$_selectedView' : 'final';
            final periodKey = '${grade.studentId}_${_selectedTermIndex}_$periodCode';
            ref.read(gradesDataProvider.notifier).updateStudentGrade(
                  grade.studentId,
                  updatedGrade,
                  changedPeriodKey: periodKey,
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
    final bool isUnsynced = classGrades.hasUnsyncedChanges;
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
    final classGrades = ref.read(gradesDataProvider);
    final allStudents = classGrades.grades;

    if (allStudents.isEmpty) {
      AppNotification.show(
        context,
        type: AppNotificationType.warning,
        title: 'لا توجد درجات لإرسالها',
      );
      return;
    }

    final unsyncedSet = classGrades.unsyncedStudentIds.toSet();
    final Set<String> selectedIds = unsyncedSet.isNotEmpty
        ? Set<String>.from(unsyncedSet)
        : allStudents.map((g) => g.studentId).toSet();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? AppColors.surfaceAltDark : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              context.loc.confirmSendGradesTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'اختر الطلاب المراد إرسال درجاتهم للإدارة (تبقى المسودات الأخرى محفوظة محلياً):',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setDialogState(() {
                            selectedIds
                              ..clear()
                              ..addAll(allStudents.map((g) => g.studentId));
                          });
                        },
                        child: const Text('تحديد الكل', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      if (unsyncedSet.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              selectedIds
                                ..clear()
                                ..addAll(unsyncedSet);
                            });
                          },
                          child: const Text('المسودات فقط', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      TextButton(
                        onPressed: () {
                          setDialogState(() => selectedIds.clear());
                        },
                        child: const Text('إلغاء التحديد', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: allStudents.length,
                      itemBuilder: (context, idx) {
                        final st = allStudents[idx];
                        final isSelected = selectedIds.contains(st.studentId);
                        final isDraft = unsyncedSet.contains(st.studentId);
                        return CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: isSelected,
                          onChanged: (checked) {
                            setDialogState(() {
                              if (checked == true) {
                                selectedIds.add(st.studentId);
                              } else {
                                selectedIds.remove(st.studentId);
                              }
                            });
                          },
                          title: Text(
                            context.translateMock(st.studentName),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: isDraft
                              ? const Text(
                                  'مسودة محلية غير مرسلة',
                                  style: TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
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
                onPressed: selectedIds.isEmpty ? null : () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? AppColors.uiPalettePrimary : AppColors.primary,
                ),
                child: Text('${context.loc.sendNow} (${selectedIds.length})'),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed != true || selectedIds.isEmpty || !mounted) return;

    final result = await ref
        .read(gradesDataProvider.notifier)
        .sendGradesToAdministration(selectedStudentIds: selectedIds);

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
        title: '${context.loc.gradesSentSuccessfully} (${result.succeededCount})',
      );
    } else if (result.isPartial) {
      final firstReason = result.failedDetails.isNotEmpty ? ' — ${result.failedDetails.first}' : '';
      AppNotification.show(
        context,
        type: AppNotificationType.warning,
        title: 'نجح إرسال ${result.succeededCount}، وفشل ${result.failedCount}$firstReason',
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
  final bool isDescriptive;
  final bool isMinisterial;
  final List<String> descriptiveEstimates;
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
    this.isDescriptive = false,
    this.isMinisterial = false,
    this.descriptiveEstimates = const ['ممتاز', 'جيد جداً', 'جيد', 'مقبول', 'ضعيف'],
    required this.onSave,
  });

  @override
  State<GradeEntrySheet> createState() => _GradeEntrySheetState();
}

class _GradeEntrySheetState extends State<GradeEntrySheet> {
  late MonthRecord _currentMonth;
  late TermRecord _currentTerm;
  bool _isSaved = false;
  bool _hasUserEdited = false;

  late final TextEditingController _hwController;
  late final TextEditingController _attController;
  late final TextEditingController _behController;
  late final TextEditingController _oralController;
  late final TextEditingController _wrtController;
  late final TextEditingController _finalExamController;

  static String _formatGrade(double val) {
    if (val == 0) return '';
    return val % 1 == 0 ? val.toInt().toString() : val.toString();
  }

  static String _formatNullableGrade(double? val) {
    if (val == null) return '';
    if (val == 0) return '0';
    return val % 1 == 0 ? val.toInt().toString() : val.toString();
  }

  @override
  void initState() {
    super.initState();
    _currentTerm = widget.termRecord;
    if (widget.isMonthView) {
      final monthIdx = widget.selectedView - 1;
      _currentMonth = (monthIdx < _currentTerm.months.length)
          ? _currentTerm.months[monthIdx]
          : const MonthRecord(monthIndex: 1);
    } else {
      _currentMonth = const MonthRecord(monthIndex: 1);
    }

    _hwController = TextEditingController(text: _formatGrade(widget.isMonthView ? _currentMonth.homework : 0));
    _attController = TextEditingController(text: _formatGrade(widget.isMonthView ? _currentMonth.attendance : 0));
    _behController = TextEditingController(text: _formatGrade(widget.isMonthView ? _currentMonth.behavior : 0));
    _oralController = TextEditingController(text: _formatGrade(widget.isMonthView ? _currentMonth.oral : 0));
    _wrtController = TextEditingController(text: _formatGrade(widget.isMonthView ? _currentMonth.written : 0));
    _finalExamController = TextEditingController(text: _formatNullableGrade(widget.isMonthView ? null : _currentTerm.finalExam));
  }

  @override
  void dispose() {
    _hwController.dispose();
    _attController.dispose();
    _behController.dispose();
    _oralController.dispose();
    _wrtController.dispose();
    _finalExamController.dispose();
    super.dispose();
  }

  void _autoSaveDraft() {
    if (!_hasUserEdited) return;
    TermRecord updatedTerm = _currentTerm;

    if (widget.isMonthView) {
      final updatedMonths = List<MonthRecord>.from(_currentTerm.months);
      final monthIdx = widget.selectedView - 1;
      while (updatedMonths.length <= monthIdx) {
        updatedMonths.add(MonthRecord(monthIndex: updatedMonths.length + 1));
      }
      updatedMonths[monthIdx] = _currentMonth.copyWith(isSaved: true);
      updatedTerm = updatedTerm.copyWith(months: updatedMonths);
    } else {
      updatedTerm = updatedTerm.copyWith(
        finalExam: _currentTerm.finalExam,
        clearFinalExam: _currentTerm.finalExam == null,
        isFinalSaved: _currentTerm.finalExam != null,
      );
    }

    var updatedGrade = widget.grade;
    if (widget.selectedTermIndex == 1) {
      updatedGrade = updatedGrade.copyWith(firstTerm: updatedTerm);
    } else {
      updatedGrade = updatedGrade.copyWith(secondTerm: updatedTerm);
    }

    widget.onSave(updatedGrade);
  }

  void _saveAndClose({bool shouldPop = true}) {
    if (!_hasUserEdited || _isSaved) {
      if (shouldPop && mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return;
    }
    _isSaved = true;
    _autoSaveDraft();
    if (shouldPop && mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dialogBg = widget.isDark ? AppColors.surfaceAltDark : Colors.white;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!_isSaved) {
          _saveAndClose(shouldPop: false);
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: widget.isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
        ),
        child: SafeArea(
          top: false,
          child: AnimatedPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. FIXED TOP HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: Column(
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
                      const SizedBox(height: 16),

                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          StudentAvatar(
                            photoUrl: widget.grade.studentPhotoUrl,
                            name: widget.grade.studentName,
                            size: 50,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.translateMock(widget.grade.studentName),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
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
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withValues(alpha: widget.isDark ? 0.2 : 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'مسودة محلية',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
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
                            onPressed: () => _saveAndClose(shouldPop: true),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: widget.isDark ? Colors.white12 : AppColors.border,
                ),

                // 2. SCROLLABLE MIDDLE (Input Fields)
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    child: widget.isMonthView
                        ? _buildMonthInputs()
                        : _buildTermSummaryInputs(),
                  ),
                ),

                // 3. FIXED BOTTOM BAR (Total + Save Button - ALWAYS VISIBLE ABOVE KEYBOARD)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: BoxDecoration(
                    color: widget.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    border: Border(
                      top: BorderSide(
                        color: widget.isDark ? Colors.white12 : AppColors.border,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Total Grade Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.chart_bar_alt_fill,
                                size: 18,
                                color: widget.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.isMonthView
                                    ? context.loc.monthlyTotal
                                    : context.loc.totalGrade,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: widget.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            (widget.isMonthView
                                    ? _currentMonth.total
                                    : _currentTerm.termTotal)
                                .toStringAsFixed(1),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: widget.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Fixed Save Button (Always above keyboard, never scrolls away)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: () => _saveAndClose(shouldPop: true),
                          icon: const Icon(CupertinoIcons.floppy_disk, size: 20),
                          label: Text(
                            context.loc.saveGrades,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: widget.isDark
                                ? AppColors.uiPalettePrimary
                                : AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
            Expanded(
              child: _buildLabeledInput(
                context.loc.homeworkLabel('15'),
                _hwController,
                15,
                (v) {
                  _currentMonth = _currentMonth.copyWith(homework: v);
                  _autoSaveDraft();
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildLabeledInput(
                context.loc.attendanceLabel('15'),
                _attController,
                15,
                (v) {
                  _currentMonth = _currentMonth.copyWith(attendance: v);
                  _autoSaveDraft();
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildLabeledInput(
                context.loc.behaviorLabel('10'),
                _behController,
                10,
                (v) {
                  _currentMonth = _currentMonth.copyWith(behavior: v);
                  _autoSaveDraft();
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildLabeledInput(
                context.loc.oralLabel('10'),
                _oralController,
                10,
                (v) {
                  _currentMonth = _currentMonth.copyWith(oral: v);
                  _autoSaveDraft();
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildLabeledInput(
                context.loc.writtenLabel('50'),
                _wrtController,
                50,
                (v) {
                  _currentMonth = _currentMonth.copyWith(written: v);
                  _autoSaveDraft();
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermSummaryInputs() {
    if (widget.isDescriptive) {
      final estimates = widget.descriptiveEstimates;
      final currentDesc = (_currentTerm.descriptiveGrade != null &&
              estimates.contains(_currentTerm.descriptiveGrade))
          ? _currentTerm.descriptiveGrade
          : null;
      return DropdownButtonFormField<String?>(
        initialValue: currentDesc,
        decoration: InputDecoration(
          labelText: 'التقدير الوصفي',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: [
          const DropdownMenuItem<String?>(value: null, child: Text('لم يُرصد')),
          ...estimates.map((e) => DropdownMenuItem<String?>(value: e, child: Text(e))),
        ],
        onChanged: (val) {
          _hasUserEdited = true;
          _currentTerm = val == null
              ? _currentTerm.copyWith(clearDescriptiveGrade: true, isFinalSaved: false)
              : _currentTerm.copyWith(descriptiveGrade: val);
          _autoSaveDraft();
          setState(() {});
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildReadOnlyBox(
                context.loc.averageLabel('20'),
                _currentTerm.monthsAverage,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildLabeledInput(
                context.loc.finalExamLabel('${widget.isMinisterial ? 80 : 30}'),
                _finalExamController,
                widget.isMinisterial ? 80 : 30,
                (_) {},
                onNullableChanged: (v) {
                  _hasUserEdited = true;
                  _currentTerm = v == null
                      ? _currentTerm.copyWith(clearFinalExam: true, isFinalSaved: false)
                      : _currentTerm.copyWith(finalExam: v);
                  _autoSaveDraft();
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabeledInput(
    String label,
    TextEditingController controller,
    double maxValue,
    Function(double) onChanged, {
    Function(double?)? onNullableChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: widget.isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            StrictEnglishGradeInputFormatter(maxValue: maxValue),
          ],
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          onTap: () {
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            );
          },
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isDark ? Colors.white24 : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isDark
                    ? AppColors.uiPalettePrimary
                    : widget.primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: widget.isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white,
          ),
          onChanged: (val) {
            _hasUserEdited = true;
            if (onNullableChanged != null) {
              final trimmed = val.trim();
              onNullableChanged(trimmed.isEmpty ? null : double.tryParse(trimmed));
            } else {
              final doubleVal = double.tryParse(val) ?? 0.0;
              onChanged(doubleVal);
            }
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
            color: widget.isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.surfaceAltDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isDark ? Colors.white12 : AppColors.border,
            ),
          ),
          child: Text(
            value.toStringAsFixed(1),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: widget.isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ],
    );
  }
}

class _TableColumn {
  final String label;
  final String key;
  final double maxValue;
  final bool isReadOnly;

  const _TableColumn(this.label, this.key, this.maxValue, {this.isReadOnly = false});
}
