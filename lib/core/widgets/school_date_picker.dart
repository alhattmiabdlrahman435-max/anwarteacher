import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../extensions/localization_extension.dart';

String toArabicNumbers(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], arabic[i]);
  }
  return input;
}

DateTime adjustToSchoolDay(DateTime date) {
  if (date.weekday == DateTime.thursday) {
    return date.subtract(const Duration(days: 1));
  } else if (date.weekday == DateTime.friday) {
    return date.subtract(const Duration(days: 2));
  }
  return date;
}

Future<DateTime?> showSchoolDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return _SchoolDatePickerDialog(
        initialDate: adjustToSchoolDay(initialDate),
        firstDate: firstDate,
        lastDate: lastDate,
      );
    },
  );
}

class _SchoolDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const _SchoolDatePickerDialog({
    required this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<_SchoolDatePickerDialog> createState() => _SchoolDatePickerDialogState();
}

class _SchoolDatePickerDialogState extends State<_SchoolDatePickerDialog> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
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

  bool _isSelectable(DateTime date) {
    if (widget.firstDate != null && date.isBefore(DateTime(widget.firstDate!.year, widget.firstDate!.month, widget.firstDate!.day))) {
      return false;
    }
    if (widget.lastDate != null && date.isAfter(DateTime(widget.lastDate!.year, widget.lastDate!.month, widget.lastDate!.day, 23, 59, 59))) {
      return false;
    }
    return true;
  }

  String _formatHeaderDate(DateTime date) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    if (isEn) {
      final Map<int, String> weekdaysEnglish = {
        DateTime.saturday: 'Saturday',
        DateTime.sunday: 'Sunday',
        DateTime.monday: 'Monday',
        DateTime.tuesday: 'Tuesday',
        DateTime.wednesday: 'Wednesday',
      };
      final dayName = weekdaysEnglish[date.weekday] ?? '';
      final monthName = _getMonthName(date.month);
      return '$dayName, ${date.day} $monthName';
    } else {
      final Map<int, String> weekdaysArabic = {
        DateTime.saturday: 'السبت',
        DateTime.sunday: 'الأحد',
        DateTime.monday: 'الاثنين',
        DateTime.tuesday: 'الثلاثاء',
        DateTime.wednesday: 'الأربعاء',
      };
      final dayName = weekdaysArabic[date.weekday] ?? '';
      final monthName = _getMonthName(date.month);
      final dayStr = toArabicNumbers(date.day.toString());
      return '$dayName، $dayStr $monthName';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final year = _currentMonth.year;
    final month = _currentMonth.month;
    final grid = _buildGridDays(year, month);
    final gridItemCount = grid.isEmpty ? 0 : grid.keys.reduce((a, b) => a > b ? a : b) + 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: isDark ? AppColors.surfaceAltDark : Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 328),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: "اختيار التاريخ" and formatted date + edit icon
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 12, right: 24, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.loc.selectDate,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatHeaderDate(_selectedDate),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                      Icon(
                        Icons.edit_outlined,
                        color: isDark ? Colors.white70 : Colors.black54,
                        size: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Divider between header and body
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? Colors.white12 : Colors.black12,
            ),
            
            // Month Navigator Selector
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 24, top: 12, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Month dropdown on the right in RTL
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Localizations.localeOf(context).languageCode == 'ar'
                            ? toArabicNumbers('${_getMonthName(month)} $year')
                            : '${_getMonthName(month)} $year',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: isDark ? Colors.white70 : Colors.black54,
                        size: 20,
                      ),
                    ],
                  ),
                  // Chevron navigation buttons on the left in RTL
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(year, month - 1);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(year, month + 1);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Week Day Headers (Saturday to Wednesday)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: (Localizations.localeOf(context).languageCode == 'en'
                        ? ['S', 'S', 'M', 'T', 'W']
                        : ['س', 'ح', 'ن', 'ث', 'ر'])
                    .map((day) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Calendar Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: gridItemCount,
                itemBuilder: (context, index) {
                  final date = grid[index];
                  if (date == null) {
                    return const SizedBox.shrink();
                  }

                  final day = date.day;
                  final isSelectable = _isSelectable(date);
                  final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;
                  final isToday = date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;

                  Color cellBgColor = Colors.transparent;
                  Color cellTextColor = isDark ? Colors.white : AppColors.textPrimaryLight;
                  Border? cellBorder;

                  if (!isSelectable) {
                    cellTextColor = isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.4);
                  } else if (isSelected) {
                    cellBgColor = theme.colorScheme.primary;
                    cellTextColor = theme.colorScheme.onPrimary;
                  } else if (isToday) {
                    cellBorder = Border.all(color: theme.colorScheme.primary, width: 1.5);
                    cellTextColor = theme.colorScheme.primary;
                  }

                  return Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isSelectable
                            ? () {
                                setState(() {
                                  _selectedDate = date;
                                });
                              }
                            : null,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
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
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: cellTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Dialog Actions: plain text buttons matching native layout
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: Text(
                      context.loc.cancel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context, _selectedDate),
                    child: Text(
                      context.loc.ok,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
