import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/attendance.dart';
import '../../../../core/providers/attendance_provider.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/widgets/class_subject_selector.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/widgets/school_date_picker.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/widgets/student_avatar.dart';

enum AttendanceFilter { all, present, absent }

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  AttendanceFilter _selectedFilter = AttendanceFilter.all;
  late DateTime _selectedDate;
  String _searchQuery = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedDate = adjustToSchoolDay(DateTime.now());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getColumnIndex(DateTime date) {
    switch (date.weekday) {
      case DateTime.saturday: return 0;
      case DateTime.sunday: return 1;
      case DateTime.monday: return 2;
      case DateTime.tuesday: return 3;
      case DateTime.wednesday: return 4;
      default: return -1;
    }
  }

  Map<int, DateTime> _buildGridDays(int year, int month) {
    final Map<int, DateTime> grid = {};
    final daysInMonth = _getDaysInMonth(year, month);
    final firstDayOfMonth = DateTime(year, month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysSinceSaturday = (firstWeekday + 1) % 7;
    final firstSaturday = firstDayOfMonth.subtract(Duration(days: daysSinceSaturday));
    final firstSaturdayUtc = DateTime.utc(firstSaturday.year, firstSaturday.month, firstSaturday.day);
    
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final colIndex = _getColumnIndex(date);
      if (colIndex != -1) {
        final dateUtc = DateTime.utc(year, month, day);
        final differenceInDays = dateUtc.difference(firstSaturdayUtc).inDays;
        final weekIndex = differenceInDays ~/ 7;
        final gridIndex = weekIndex * 5 + colIndex;
        grid[gridIndex] = date;
      }
    }
    return grid;
  }


  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final comparisonDate = DateTime(date.year, date.month, date.day);
    
    if (comparisonDate == today) {
      return context.loc.today;
    } else if (comparisonDate == today.subtract(const Duration(days: 1))) {
      return context.loc.yesterday;
    } else {
      return DateFormat('yyyy/MM/dd').format(date);
    }
  }

  int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }

  String _getMonthName(int month) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    if (isEn) {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return months[month - 1];
    } else {
      const months = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return months[month - 1];
    }
  }

  bool _isFuture(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isAfter(today);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showSchoolDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showStudentCalendar(BuildContext context, AttendanceRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final dialogBg = theme.dialogTheme.backgroundColor ?? (isDark ? AppColors.surfaceAltDark : Colors.white);
        
        DateTime calendarDate = adjustToSchoolDay(DateTime.now());
        
        return Consumer(
          builder: (context, ref, child) {
            final historyAsync = ref.watch(studentAttendanceHistoryProvider(record.studentId));
            
            return StatefulBuilder(
              builder: (context, setSheetState) {
            final year = calendarDate.year;
            final month = calendarDate.month;
            final grid = _buildGridDays(year, month);
            final gridItemCount = grid.isEmpty ? 0 : grid.keys.reduce((a, b) => a > b ? a : b) + 1;
            
            return Container(
              padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xxxl, left: 16, right: 16),
              decoration: BoxDecoration(
                color: dialogBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
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
                  const SizedBox(height: AppSpacing.lg),
                  // Student Header info
                  Row(
                    children: [
                      StudentAvatar(
                        photoUrl: record.studentPhotoUrl,
                        name: record.studentName,
                        size: 48,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translateMock(record.studentName),
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            context.loc.studentAttendanceRecord(record.studentId),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  // Month Navigator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: () {
                          setSheetState(() {
                            calendarDate = adjustToSchoolDay(DateTime(year, month - 1));
                          });
                        },
                      ),
                      Text(
                        Localizations.localeOf(context).languageCode == 'ar'
                            ? toArabicNumbers('${_getMonthName(month)} $year')
                            : '${_getMonthName(month)} $year',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: () {
                          setSheetState(() {
                            calendarDate = adjustToSchoolDay(DateTime(year, month + 1));
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Calendar Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(context.loc.present, AppColors.success),
                      const SizedBox(width: 24),
                      _buildLegendItem(context.loc.absent, AppColors.error),
                      const SizedBox(width: 24),
                      _buildLegendItem(context.loc.noRecord, Colors.grey),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Week Days Header
                  Row(
                    children: [
                      context.loc.saturday,
                      context.loc.sunday,
                      context.loc.monday,
                      context.loc.tuesday,
                      context.loc.wednesday,
                    ].map((day) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Grid of Days
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: gridItemCount,
                    itemBuilder: (context, index) {
                      final date = grid[index];
                      if (date == null) {
                        return const SizedBox.shrink();
                      }
                      
                      final day = date.day;
                      final isFutureDate = _isFuture(date);
                      final isTodayDate = _isToday(date);
                      
                      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                      final status = historyAsync.value?[dateStr];
                      
                      Color cellBgColor = Colors.transparent;
                      Color cellTextColor = isDark ? Colors.white : AppColors.textPrimaryLight;
                      Border? cellBorder;
                      
                      if (isFutureDate) {
                        cellTextColor = isDark ? Colors.white.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.5);
                      } else {
                        if (status == AttendanceStatus.present) {
                          cellBgColor = AppColors.success.withValues(alpha: isDark ? 0.3 : 0.15);
                          cellTextColor = isDark ? const Color(0xFF34D399) : AppColors.success;
                        } else if (status == AttendanceStatus.absent) {
                          cellBgColor = AppColors.error.withValues(alpha: isDark ? 0.3 : 0.15);
                          cellTextColor = isDark ? const Color(0xFFFCA5A5) : AppColors.error;
                        } else {
                          cellBgColor = Colors.grey.withValues(alpha: isDark ? 0.15 : 0.08);
                          cellTextColor = isDark ? Colors.white30 : Colors.grey;
                        }
                      }
                      
                      if (isTodayDate) {
                        cellBorder = Border.all(color: AppColors.uiPalettePrimary, width: 2);
                      }
                      
                      return Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: cellBgColor,
                            shape: BoxShape.circle,
                            border: cellBorder,
                          ),
                          child: Text(
                            Localizations.localeOf(context).languageCode == 'ar'
                                ? toArabicNumbers(day.toString())
                                : day.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: cellTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  },
);
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final baseList = ref.watch(dailyAttendanceProvider(dateString));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // 1. Generate records for the selected date
    final dailyList = baseList.map((record) {
      return record.copyWith(
        date: _selectedDate,
      );
    }).toList();

    // 2. Compute stats for this date (independent of name search)
    int total = dailyList.length;
    int present = dailyList.where((r) => r.status == AttendanceStatus.present).length;
    int absent = dailyList.where((r) => r.status == AttendanceStatus.absent).length;

    // 3. Apply status filter & search query
    final filteredList = dailyList.where((record) {
      final matchesStatus = _selectedFilter == AttendanceFilter.all ||
          (_selectedFilter == AttendanceFilter.present && record.status == AttendanceStatus.present) ||
          (_selectedFilter == AttendanceFilter.absent && record.status == AttendanceStatus.absent);

      final matchesSearch = _searchQuery.isEmpty ||
          record.studentName.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesStatus && matchesSearch;
    }).toList();

    return Scaffold(
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          AppSliverHeader(
            title: context.loc.attendanceRecord,
            automaticallyImplyLeading: true,
          ),
          const ClassSubjectSelector(showSubject: false),
          // Search & Date Query Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceAltDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.border,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimaryLight),
                        decoration: InputDecoration(
                          hintText: context.loc.searchStudentHint,
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Date Picker Button
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceAltDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.uiPalettePrimary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _formatDate(_selectedDate),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildStatsBar(context, total, present, absent, isDark),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 24, top: 8),
            sliver: filteredList.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: AppSpacing.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedFilter == AttendanceFilter.present
                                ? Icons.check_circle_outline_rounded
                                : _selectedFilter == AttendanceFilter.absent
                                    ? Icons.cancel_outlined
                                    : Icons.people_outline_rounded,
                            size: 64,
                            color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.5) : AppColors.textSecondaryLight.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? '${context.loc.noSearchResults} "$_searchQuery"'
                                : _selectedFilter == AttendanceFilter.present
                                    ? context.loc.noStudentsPresent
                                    : _selectedFilter == AttendanceFilter.absent
                                        ? context.loc.noStudentsAbsent
                                        : context.loc.noStudentsInSection,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final record = filteredList[index];
                        return _buildStudentCard(context, record, isDark);
                      },
                      childCount: filteredList.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context, int total, int present, int absent, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                label: context.loc.all,
                value: total.toString(),
                color: AppColors.uiPalettePrimary,
                icon: Icons.people_alt_rounded,
                isSelected: _selectedFilter == AttendanceFilter.all,
                onTap: () {
                  setState(() {
                    _selectedFilter = AttendanceFilter.all;
                  });
                },
                context: context,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatItem(
                label: context.loc.present,
                value: present.toString(),
                color: AppColors.success,
                icon: Icons.check_circle_rounded,
                isSelected: _selectedFilter == AttendanceFilter.present,
                onTap: () {
                  setState(() {
                    _selectedFilter = AttendanceFilter.present;
                  });
                },
                context: context,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatItem(
                label: context.loc.absent,
                value: absent.toString(),
                color: AppColors.error,
                icon: Icons.cancel_rounded,
                isSelected: _selectedFilter == AttendanceFilter.absent,
                onTap: () {
                  setState(() {
                    _selectedFilter = AttendanceFilter.absent;
                  });
                },
                context: context,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ModernCard(
      isDark: isDark,
      onTap: onTap,
      borderColor: isSelected ? color : null,
      borderWidth: isSelected ? 2.0 : 1.0,
      backgroundColor: isSelected ? color.withValues(alpha: isDark ? 0.15 : 0.08) : null,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textPrimaryLight)),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          )),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, AttendanceRecord record, bool isDark) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(record.status);

    return ModernCard(
      isDark: isDark,
      onTap: () => _showStudentCalendar(context, record),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 1.5),
            ),
            child: StudentAvatar(
              photoUrl: record.studentPhotoUrl,
              name: record.studentName,
              size: 46,
              backgroundColor: statusColor.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translateMock(record.studentName),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  context.loc.studentWithId(record.studentId),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          if (record.status != AttendanceStatus.pending)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getStatusIcon(record.status), color: statusColor, size: 18),
                  if (_getStatusText(record.status).isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      _getStatusText(record.status),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present: return Icons.check_circle_rounded;
      case AttendanceStatus.absent: return Icons.cancel_rounded;
      case AttendanceStatus.pending: return Icons.radio_button_unchecked_rounded;
    }
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present: return AppColors.success;
      case AttendanceStatus.absent: return AppColors.error;
      case AttendanceStatus.pending: return Colors.grey;
    }
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present: return context.loc.present;
      case AttendanceStatus.absent: return context.loc.absent;
      case AttendanceStatus.pending: return '';
    }
  }
}
