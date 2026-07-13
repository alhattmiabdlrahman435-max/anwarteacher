import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/teacher_schedule.dart';
import '../../../../core/providers/schedule_provider.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/extensions/localization_extension.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  int _selectedDayIndex = 0;
  bool _isGridView = false;

  final List<String> _daysKeys = [
    'saturday',
    'sunday',
    'monday',
    'tuesday',
    'wednesday'
  ];

  @override
  void initState() {
    super.initState();
    _determineInitialDay();
    Future.microtask(() {
      if (mounted) {
        ref.read(teacherScheduleStateProvider.notifier).refresh();
      }
    });
  }

  void _determineInitialDay() {
    final now = DateTime.now();
    final weekday = now.weekday;

    switch (weekday) {
      case DateTime.saturday:
        _selectedDayIndex = 0;
        break;
      case DateTime.sunday:
        _selectedDayIndex = 1;
        break;
      case DateTime.monday:
        _selectedDayIndex = 2;
        break;
      case DateTime.tuesday:
        _selectedDayIndex = 3;
        break;
      case DateTime.wednesday:
        _selectedDayIndex = 4;
        break;
      default:
        _selectedDayIndex = 0;
        break;
    }
  }

  String _getDayTranslation(BuildContext context, String dayKey) {
    switch (dayKey) {
      case 'saturday':
        return context.loc.saturday;
      case 'sunday':
        return context.loc.sunday;
      case 'monday':
        return context.loc.monday;
      case 'tuesday':
        return context.loc.tuesday;
      case 'wednesday':
        return context.loc.wednesday;
      default:
        return '';
    }
  }

  Color _getPeriodColor(int periodNumber) {
    final colors = [
      const Color(0xFF0D9488), // Teal
      const Color(0xFFEA580C), // Orange
      const Color(0xFFD97706), // Amber
      const Color(0xFF2563EB), // Blue
      const Color(0xFFDC2626), // Red
      const Color(0xFF7C3AED), // Purple
      const Color(0xFF16A34A), // Green
    ];
    return colors[(periodNumber - 1) % colors.length];
  }

  bool _isToday(String dayKey) {
    final now = DateTime.now();
    final weekday = now.weekday;
    String todayKey = '';
    switch (weekday) {
      case DateTime.saturday:
        todayKey = 'saturday';
        break;
      case DateTime.sunday:
        todayKey = 'sunday';
        break;
      case DateTime.monday:
        todayKey = 'monday';
        break;
      case DateTime.tuesday:
        todayKey = 'tuesday';
        break;
      case DateTime.wednesday:
        todayKey = 'wednesday';
        break;
    }
    return dayKey == todayKey;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final primaryColor = isDark ? Colors.white : const Color(0xFF062A5A);

    final scheduleAsync = ref.watch(teacherScheduleStateProvider);

    return Scaffold(
      backgroundColor: bgColor,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => ref.read(teacherScheduleStateProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            AppSliverHeader(
              title: context.translateMock('الجدول الدراسي الأسبوعي'),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
                child: Icon(
                  _isGridView ? CupertinoIcons.list_bullet : CupertinoIcons.grid,
                  color: isDark ? Colors.white : const Color(0xFF062A5A),
                ),
              ),
            ),
            sliverScheduleBody(
              scheduleAsync: scheduleAsync,
              isDark: isDark,
              bgColor: bgColor,
              cardBgColor: cardBgColor,
              textColor: textColor,
              subTextColor: subTextColor,
              primaryColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget sliverScheduleBody({
    required AsyncValue<Map<String, List<TeacherPeriod>>> scheduleAsync,
    required bool isDark,
    required Color bgColor,
    required Color cardBgColor,
    required Color textColor,
    required Color subTextColor,
    required Color primaryColor,
  }) {
    return scheduleAsync.when(
      loading: () => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'حدث خطأ أثناء تحميل الجدول',
            style: TextStyle(color: subTextColor),
          ),
        ),
      ),
      data: (schedule) {
        if (!_isGridView) {
          final currentDayKey = _daysKeys[_selectedDayIndex];
          final List<TeacherPeriod> periods = schedule[currentDayKey] ?? [];

          // Show only periods that have an actual subject assigned
          final List<MapEntry<int, TeacherPeriod>> activePeriods = [];
          for (int i = 0; i < periods.length; i++) {
            if (periods[i].subjectName.isNotEmpty) {
              activePeriods.add(MapEntry(i + 1, periods[i]));
            }
          }

          return SliverMainAxisGroup(
            slivers: [
              // Day Tabs
              SliverToBoxAdapter(
                child: Container(
                  height: 54,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _daysKeys.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final dayKey = _daysKeys[index];
                      final isSelected = index == _selectedDayIndex;
                      final isTodayDay = _isToday(dayKey);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDayIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                : (isTodayDay
                                    ? primaryColor.withValues(alpha: 0.15)
                                    : cardBgColor),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isTodayDay
                                      ? primaryColor.withValues(alpha: 0.3)
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.grey.withValues(alpha: 0.1))),
                            ),
                            boxShadow: [
                              if (isSelected && !isDark)
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _getDayTranslation(context, dayKey),
                              style: TextStyle(
                                fontFamily: 'GoogleSans',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isSelected
                                    ? (isDark && primaryColor == Colors.white
                                        ? const Color(0xFF0F172A)
                                        : Colors.white)
                                    : (isTodayDay ? primaryColor : subTextColor),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              if (activePeriods.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'لا توجد حصص مجدولة لك في هذا اليوم',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 16,
                          color: subTextColor,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = activePeriods[index];
                        final periodNumber = entry.key;
                        final period = entry.value;
                        final color = _getPeriodColor(periodNumber);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.transparent,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.25)
                                    : const Color(0xFF062A5A).withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Period Number circle
                              Container(
                                width: 44,
                                height: 44,
                                margin: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    periodNumber.toString(),
                                    style: TextStyle(
                                      fontFamily: 'GoogleSans',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Subject & Class details
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        context.translateMock(period.subjectName),
                                        style: TextStyle(
                                          fontFamily: 'GoogleSans',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Responsive wrap to prevent horizontal layout overflow
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 6,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                CupertinoIcons.group,
                                                size: 14,
                                                color: subTextColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                period.className,
                                                style: TextStyle(
                                                  fontFamily: 'GoogleSans',
                                                  fontSize: 12,
                                                  color: subTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                CupertinoIcons.clock,
                                                size: 14,
                                                color: subTextColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${period.startTime} - ${period.endTime}',
                                                style: TextStyle(
                                                  fontFamily: 'GoogleSans',
                                                  fontSize: 12,
                                                  color: subTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: activePeriods.length,
                    ),
                  ),
                ),
            ],
          );
        } else {
          // Grid View Table
          return SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: DataTable(
                      dataRowMinHeight: 110,
                      dataRowMaxHeight: 110,
                      columnSpacing: 12,
                      headingRowColor: WidgetStateProperty.all(
                        isDark ? const Color(0xFF0F172A) : const Color(0xFF062A5A).withValues(alpha: 0.05),
                      ),
                      dataRowColor: WidgetStateProperty.all(cardBgColor),
                      headingTextStyle: TextStyle(
                        fontFamily: 'GoogleSans',
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontSize: 14,
                      ),
                      dataTextStyle: TextStyle(
                        fontFamily: 'GoogleSans',
                        color: textColor,
                        fontSize: 13,
                      ),
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        verticalInside: BorderSide(
                          color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      columns: [
                        const DataColumn(label: Text('اليوم')),
                        ...List.generate(7, (i) => DataColumn(
                          label: Center(
                            child: Text('الحصة ${i + 1}'),
                          ),
                        )),
                      ],
                      rows: _daysKeys.map((dayKey) {
                        final List<TeacherPeriod> periods = schedule[dayKey] ?? [];

                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                _getDayTranslation(context, dayKey),
                                style: const TextStyle(
                                  fontFamily: 'GoogleSans',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...List.generate(7, (periodIdx) {
                              if (periodIdx >= periods.length) {
                                return const DataCell(Center(child: Text('-')));
                              }
                              final period = periods[periodIdx];
                              if (period.subjectName.isEmpty) {
                                return const DataCell(Center(child: Text('-')));
                              }

                              return DataCell(
                                SizedBox(
                                  width: 90,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        context.translateMock(period.subjectName),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'GoogleSans',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        context.translateMock(period.className),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'GoogleSans',
                                          fontSize: 10,
                                          color: subTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${period.startTime}-${period.endTime}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'GoogleSans',
                                          fontSize: 9,
                                          color: subTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
