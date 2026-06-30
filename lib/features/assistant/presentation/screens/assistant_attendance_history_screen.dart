import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/adaptive_sliver_app_bar.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../models/assistant_models.dart';
import '../../providers/assistant_attendance_history_provider.dart';

class AssistantAttendanceHistoryScreen extends ConsumerStatefulWidget {
  const AssistantAttendanceHistoryScreen({super.key});

  @override
  ConsumerState<AssistantAttendanceHistoryScreen> createState() => _AssistantAttendanceHistoryScreenState();
}

class _AssistantAttendanceHistoryScreenState extends ConsumerState<AssistantAttendanceHistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  AttendanceHistoryEntity? selectedClass;
  AttendanceHistoryRecord? selectedRecord;
  AttendanceStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(assistantAttendanceHistoryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (selectedClass != null) {
          setState(() {
            if (selectedRecord != null) {
              selectedRecord = null;
            } else {
              selectedClass = null;
            }
          });
        } else {
          context.go('/assistant/dashboard');
        }
      },
      child: Scaffold(
        drawer: const AppDrawer(),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF8FAFC),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            AdaptiveSliverAppBar(
              title: selectedClass != null 
                  ? '${selectedClass!.className} (${intl.DateFormat('yyyy/M/d').format(_selectedDay ?? _focusedDay)})'
                  : context.loc.attendanceRecord,
              automaticallyImplyLeading: true,
              leading: selectedClass != null 
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedClass = null;
                        });
                      },
                    )
                  : null,
            ),
            if (selectedClass != null)
              ..._buildClassHistoryContent(selectedClass!)
            else
              _buildClassesSliverList(history),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesSliverList(List<AttendanceHistoryEntity> history) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final classModel = history[index];
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : AppColors.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(PhosphorIconsFill.chalkboardTeacher, color: isDark ? Colors.white : AppColors.primary),
                ),
                title: Text(
                  classModel.className,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  context.loc.recordDaysCount(classModel.dailyRecords.length),
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded, 
                  size: 16, 
                  color: Color(0xFF94A3B8),
                ),
                onTap: () => setState(() => selectedClass = classModel),
              ),
            );
          },
          childCount: history.length,
        ),
      ),
    );
  }

  List<Widget> _buildClassHistoryContent(AttendanceHistoryEntity classModel) {
    final records = classModel.dailyRecords;
    final currentRecord = records.any((r) => isSameDay(r.date, _selectedDay))
        ? records.firstWhere((r) => isSameDay(r.date, _selectedDay))
        : null;

    int totalPresent = 0;
    int totalAbsent = 0;
    for (var r in records) {
      if (r.date.month == _focusedDay.month && r.date.year == _focusedDay.year) {
        totalPresent += r.presentCount;
        totalAbsent += r.absentCount;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      SliverToBoxAdapter(
        child: Column(
          children: [
            // Top Summary Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: _HeaderSummaryCard(
                      label: context.loc.attendanceThisMonth,
                      value: totalPresent.toString(),
                      color: AppColors.successGreen,
                      icon: PhosphorIconsFill.checkCircle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _HeaderSummaryCard(
                      label: context.loc.absenceThisMonth,
                      value: totalAbsent.toString(),
                      color: AppColors.dangerRed,
                      icon: PhosphorIconsFill.xCircle,
                    ),
                  ),
                ],
              ),
            ),

            // Calendar Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    _buildCalendarHeader(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _buildCustomCalendar(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Daily Status Card
            if (currentRecord != null)
              _DailyDetailCard(
                record: currentRecord,
                onFilterSelected: (status) => setState(() => _filterStatus = status),
                currentFilter: _filterStatus,
                onClearFilter: () => setState(() => _filterStatus = null),
              )
            else
              _EmptyRecordCard(date: _selectedDay ?? DateTime.now()),
          ],
        ),
      ),
      if (currentRecord != null)
        _buildStudentsSliverList(currentRecord.attendedStudents)
    ];
  }

  Widget _buildCalendarHeader() {
    final languageCode = Localizations.localeOf(context).languageCode;
    final monthName = intl.DateFormat.MMMM(languageCode).format(_focusedDay);
    final year = _focusedDay.year;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1)),
          ),
          Text(
            '$monthName $year',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCalendar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    
    int getColumnIndex(int weekday) {
      if (weekday == DateTime.saturday) return 0;
      if (weekday == DateTime.sunday) return 1;
      if (weekday == DateTime.monday) return 2;
      if (weekday == DateTime.tuesday) return 3;
      if (weekday == DateTime.wednesday) return 4;
      return -1;
    }
    
    int firstWorkingDay = 1;
    while (firstWorkingDay <= daysInMonth && getColumnIndex(DateTime(_focusedDay.year, _focusedDay.month, firstWorkingDay).weekday) == -1) {
      firstWorkingDay++;
    }
    
    int emptyCellsAtStart = firstWorkingDay <= daysInMonth 
        ? getColumnIndex(DateTime(_focusedDay.year, _focusedDay.month, firstWorkingDay).weekday) 
        : 0;
    
    List<DateTime?> gridDays = List.generate(emptyCellsAtStart, (index) => null, growable: true);
    for (int i = 1; i <= daysInMonth; i++) {
      DateTime day = DateTime(_focusedDay.year, _focusedDay.month, i);
      if (day.weekday != DateTime.thursday && day.weekday != DateTime.friday) {
        gridDays.add(day);
      }
    }
    
    final dayNames = [
        context.loc.saturday,
        context.loc.sunday,
        context.loc.monday,
        context.loc.tuesday,
        context.loc.wednesday
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayNames
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: gridDays.length,
          itemBuilder: (context, index) {
            final day = gridDays[index];
            if (day == null) return const SizedBox();
            
            final isSelected = isSameDay(day, _selectedDay);
            final isToday = isSameDay(day, DateTime.now());
            
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedDay = day;
                  _focusedDay = day;
                });
              },
              borderRadius: BorderRadius.circular(100),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFFECFDF5) 
                      : (isToday ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF10B981)
                          : (isToday
                              ? Colors.blue
                              : (isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF475569))),
                      fontWeight: (isSelected || isToday) ? FontWeight.bold : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStudentsSliverList(List<StudentEntity> students) {
    final filteredStudents = _filterStatus == null 
        ? students 
        : students.where((s) => s.status == _filterStatus).toList();

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final student = filteredStudents[index];
            return _StudentHistoryCard(student: student);
          },
          childCount: filteredStudents.length,
        ),
      ),
    );
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _HeaderSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _HeaderSummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyDetailCard extends StatelessWidget {
  final AttendanceHistoryRecord record;
  final Function(AttendanceStatus) onFilterSelected;
  final VoidCallback onClearFilter;
  final AttendanceStatus? currentFilter;

  const _DailyDetailCard({
    required this.record, 
    required this.onFilterSelected,
    required this.onClearFilter,
    this.currentFilter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = record.totalStudents > 0 ? record.totalStudents : 1;
    final rate = (record.presentCount / total * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: onClearFilter,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '$rate%',
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              intl.DateFormat('yyyy/M/d').format(record.date),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(PhosphorIconsFill.calendar, size: 20, color: Color(0xFF475569)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: record.presentCount / total,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onFilterSelected(AttendanceStatus.absent),
                      child: _StatusBox(
                        label: context.loc.absentPlural,
                        value: record.absentCount.toString(),
                        color: const Color(0xFFEF4444),
                        bgColor: isDark ? const Color(0xFFEF4444).withValues(alpha: 0.15) : const Color(0xFFFFF1F2),
                        isSelected: currentFilter == AttendanceStatus.absent,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onFilterSelected(AttendanceStatus.present),
                      child: _StatusBox(
                        label: context.loc.presentPlural,
                        value: record.presentCount.toString(),
                        color: const Color(0xFF10B981),
                        bgColor: isDark ? const Color(0xFF10B981).withValues(alpha: 0.15) : const Color(0xFFECFDF5),
                        isSelected: currentFilter == AttendanceStatus.present,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bgColor;
  final bool isSelected;

  const _StatusBox({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayColor = isDark 
        ? (color == const Color(0xFF10B981) ? const Color(0xFF34D399) : const Color(0xFFFCA5A5))
        : color;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: displayColor, width: 2) : null,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: displayColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: displayColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecordCard extends StatelessWidget {
  final DateTime date;

  const _EmptyRecordCard({required this.date});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
        ),
        child: Column(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 40),
            const SizedBox(height: 12),
            Text(
              context.loc.noAttendanceRecordForToday(intl.DateFormat('yyyy/M/d').format(date)),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}


/// Returns true only if [url] is a real network URL.
bool _isNetworkUrl(String? url) =>
    url != null && url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'));

/// Returns the emoji if available, otherwise the first letter of [name].
String _avatarLabel(String? photoUrl, String name) {
  if (photoUrl != null && photoUrl.isNotEmpty && !_isNetworkUrl(photoUrl)) {
    return photoUrl; // it's an emoji
  }
  return name.isNotEmpty ? name[0] : '?';
}

class _StudentHistoryCard extends StatelessWidget {
  final StudentEntity student;

  const _StudentHistoryCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final isPresent = student.status == AttendanceStatus.present;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _StudentDetailsModal.show(context, student),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: (isDark ? Colors.white : AppColors.primary).withValues(alpha: 0.1),
                  backgroundImage: _isNetworkUrl(student.photoUrl) ? NetworkImage(student.photoUrl!) : null,
                  child: !_isNetworkUrl(student.photoUrl)
                      ? Text(
                          _avatarLabel(student.photoUrl, student.name),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: student.photoUrl != null && student.photoUrl!.isNotEmpty ? 18 : 14,
                            color: isDark ? Colors.white : AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        student.parentName,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPresent ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPresent ? context.loc.presentLabel : context.loc.absentLabel,
                    style: TextStyle(
                      color: isPresent ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentDetailsModal extends StatelessWidget {
  final StudentEntity student;

  const _StudentDetailsModal({required this.student});

  static void show(BuildContext context, StudentEntity student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StudentDetailsModal(student: student),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            backgroundImage: _isNetworkUrl(student.photoUrl)
                ? NetworkImage(student.photoUrl!)
                : null,
            child: !_isNetworkUrl(student.photoUrl)
                ? Text(
                    _avatarLabel(student.photoUrl, student.name),
                    style: const TextStyle(fontSize: 40),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            student.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildInfoRow(
            context,
            icon: PhosphorIconsDuotone.user,
            label: context.loc.parentOrGuardian,
            value: student.parentName,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            context,
            icon: PhosphorIconsDuotone.phone,
            label: context.loc.parentPhone,
            value: student.parentPhone,
            onTap: () => _launchCaller(student.parentPhone),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: onTap != null ? Border.all(color: primaryColor.withValues(alpha: 0.15)) : null,
        ),
        child: Row(
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: Icon(
                icon,
                color: onTap != null ? primaryColor : (isDark ? Colors.white70 : Colors.black45),
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
             if (onTap != null)
              Icon(
                PhosphorIconsRegular.arrowSquareOut,
                size: 16,
                color: (isDark ? Colors.white : AppColors.primary).withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }

  void _launchCaller(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// Returns true only if [url] is a real network URL (starts with http/https).
  bool _isNetworkUrl(String? url) =>
      url != null && url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'));

  /// Returns the emoji if available, otherwise the first letter of [name].
  String _avatarLabel(String? photoUrl, String name) {
    if (photoUrl != null && photoUrl.isNotEmpty && !_isNetworkUrl(photoUrl)) {
      return photoUrl; // it's an emoji
    }
    return name.isNotEmpty ? name[0] : '?';
  }
}

