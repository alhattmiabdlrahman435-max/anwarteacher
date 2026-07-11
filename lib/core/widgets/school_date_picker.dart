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
  bool _isTextInputMode = false;
  late final TextEditingController _textController;
  String? _inputError;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _textController = TextEditingController(
      text: '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}'
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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

  void _validateInput(String value) {
    final cleanVal = value.replaceAll('٠', '0').replaceAll('١', '1').replaceAll('٢', '2').replaceAll('٣', '3').replaceAll('٤', '4').replaceAll('٥', '5').replaceAll('٦', '6').replaceAll('٧', '7').replaceAll('٨', '8').replaceAll('٩', '9');
    final parts = cleanVal.split('/');
    if (parts.length != 3) {
      setState(() {
        _inputError = 'صيغة غير صحيحة (يجب أن تكون: YYYY/MM/DD)';
      });
      return;
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);

    if (year == null || month == null || day == null || month < 1 || month > 12) {
      setState(() {
        _inputError = 'التاريخ غير صالح';
      });
      return;
    }

    final daysInMonth = _getDaysInMonth(year, month);
    if (day < 1 || day > daysInMonth) {
      setState(() {
        _inputError = 'اليوم المحدد غير صالح لهذا الشهر';
      });
      return;
    }

    final date = DateTime(year, month, day);

    // Check weekend (Thursday/Friday)
    if (date.weekday == DateTime.thursday || date.weekday == DateTime.friday) {
      setState(() {
        _inputError = 'لا يمكن اختيار أيام الإجازة (الخميس والجمعة)';
      });
      return;
    }

    // Check range
    if (widget.firstDate != null && date.isBefore(DateTime(widget.firstDate!.year, widget.firstDate!.month, widget.firstDate!.day))) {
      setState(() {
        _inputError = 'التاريخ قبل الحد الأدنى المسموح به';
      });
      return;
    }
    if (widget.lastDate != null && date.isAfter(DateTime(widget.lastDate!.year, widget.lastDate!.month, widget.lastDate!.day, 23, 59, 59))) {
      setState(() {
        _inputError = 'التاريخ بعد الحد الأقصى المسموح به';
      });
      return;
    }

    setState(() {
      _selectedDate = date;
      _currentMonth = DateTime(year, month);
      _inputError = null;
    });
  }

  Future<void> _showMonthYearPicker() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    int selectedYear = _currentMonth.year;
    int selectedMonth = _currentMonth.month;

    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.surfaceAltDark : Colors.white,
              title: const Text('اختر الشهر والسنة', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            final isAr = Localizations.localeOf(context).languageCode == 'ar';
                            setDialogState(() {
                              if (isAr) {
                                selectedYear++;
                              } else {
                                selectedYear--;
                              }
                            });
                          },
                        ),
                        Text(
                          selectedYear.toString(),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            final isAr = Localizations.localeOf(context).languageCode == 'ar';
                            setDialogState(() {
                              if (isAr) {
                                selectedYear--;
                              } else {
                                selectedYear++;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  SizedBox(
                    width: 280,
                    height: 200,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final monthNum = index + 1;
                        final isSelected = monthNum == selectedMonth;
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pop(DateTime(selectedYear, monthNum));
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? theme.colorScheme.primary : (isDark ? Colors.white24 : Colors.grey.shade300),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getMonthName(monthNum),
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _currentMonth = result;
      });
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _formatHeaderDate(_selectedDate),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isTextInputMode ? Icons.calendar_today_outlined : Icons.edit_outlined),
                        color: isDark ? Colors.white70 : Colors.black54,
                        onPressed: () {
                          setState(() {
                            _isTextInputMode = !_isTextInputMode;
                            if (!_isTextInputMode) {
                              _textController.text = '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}';
                              _inputError = null;
                            }
                          });
                        },
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

            if (_isTextInputMode) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _textController,
                      keyboardType: TextInputType.datetime,
                      onChanged: _validateInput,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        labelText: 'التاريخ (السنة/الشهر/اليوم)',
                        hintText: 'YYYY/MM/DD',
                        errorText: _inputError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.edit_calendar_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'تنبيه: لا يمكن اختيار يومي الخميس والجمعة لأنهما يمثلان عطلة نهاية الأسبوع المدرسية.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Month Navigator Selector
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 24, top: 12, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Month dropdown on the right in RTL (interactive)
                    InkWell(
                      onTap: _showMonthYearPicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
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
                      ),
                    ),
                    // Chevron navigation buttons on the left in RTL
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded),
                            onPressed: () {
                              final isAr = Localizations.localeOf(context).languageCode == 'ar';
                              setState(() {
                                if (isAr) {
                                  _currentMonth = DateTime(year, month + 1);
                                } else {
                                  _currentMonth = DateTime(year, month - 1);
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded),
                            onPressed: () {
                              final isAr = Localizations.localeOf(context).languageCode == 'ar';
                              setState(() {
                                if (isAr) {
                                  _currentMonth = DateTime(year, month - 1);
                                } else {
                                  _currentMonth = DateTime(year, month + 1);
                                }
                              });
                            },
                          ),
                        ],
                      ),
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
            ],
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
                    onPressed: _inputError != null 
                        ? null 
                        : () => Navigator.pop(context, _selectedDate),
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
