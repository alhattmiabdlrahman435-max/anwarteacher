import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/adaptive_sliver_app_bar.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../models/assistant_models.dart';
import '../../providers/assistant_reports_provider.dart';

class AssistantReportsScreen extends ConsumerStatefulWidget {
  const AssistantReportsScreen({super.key});

  @override
  ConsumerState<AssistantReportsScreen> createState() => _AssistantReportsScreenState();
}

class _AssistantReportsScreenState extends ConsumerState<AssistantReportsScreen> {
  String _searchQuery = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final stats = ref.watch(assistantReportsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          AdaptiveSliverAppBar(
            title: context.loc.assistantReports,
          ),
          
          // Stats Grid Header
          _buildSummaryGrid(context, stats),
          
          // Search & List Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsFill.student,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.loc.cumulativeAttendanceStats,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildSearchBar(context),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          
          // Student List
          _buildStudentList(context, stats.studentReports),
          
          const SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.xl),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(BuildContext context, AttendanceStatsEntity stats) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
      ),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.25,
        children: [
          _SummaryCard(
            title: context.loc.totalTrackStudents,
            value: '${stats.totalStudents}',
            icon: PhosphorIconsFill.users,
            color: AppColors.primary,
            index: 0,
          ),
          _SummaryCard(
            title: context.loc.cumulativeAttendanceRate,
            value: '${stats.averageAttendance.toStringAsFixed(1)}%',
            icon: PhosphorIconsFill.chartLineUp,
            color: Colors.orange,
            index: 1,
          ),
          _SummaryCard(
            title: context.loc.dailyAttendance,
            value: '${stats.presentToday}',
            icon: PhosphorIconsFill.checkCircle,
            color: Colors.green,
            index: 2,
          ),
          _SummaryCard(
            title: context.loc.dailyAbsence,
            value: '${stats.absentToday}',
            icon: PhosphorIconsFill.xCircle,
            color: Colors.red,
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : theme.textTheme.bodyLarge?.color,
        ),
        decoration: InputDecoration(
          hintText: context.loc.searchStudentHint,
          hintStyle: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : theme.hintColor.withValues(alpha: 0.4),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            PhosphorIconsRegular.magnifyingGlass,
            color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildStudentList(BuildContext context, List<StudentReportEntity> students) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredStudents = students.where((s) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final matchesName = s.name.toLowerCase().contains(query);
      final matchesCivilId = s.civilId?.toLowerCase().contains(query) ?? false;
      return matchesName || matchesCivilId;
    }).toList();

    if (filteredStudents.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: Column(
              children: [
                Icon(
                  PhosphorIconsRegular.magnifyingGlass,
                  size: 48,
                  color: theme.disabledColor,
                ),
                const SizedBox(height: 8),
                Text(
                  context.loc.noMatchingResults,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final student = filteredStudents[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _StudentAttendanceModal.show(context, student),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      backgroundImage: student.photoUrl != null 
                        ? NetworkImage(student.photoUrl!) 
                        : null,
                      child: student.photoUrl == null 
                        ? Text(
                            student.name.isNotEmpty ? student.name[0] : '?',
                            style: TextStyle(
                              color: isDark ? Colors.white : theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (student.civilId != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              context.loc.civilIdLabel(student.civilId!),
                              style: TextStyle(
                                color: isDark ? Colors.white60 : AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _StatBadge(label: context.loc.presentLabel, value: '${student.presentCount}', color: AppColors.successGreen),
                              const SizedBox(width: AppSpacing.sm),
                              _StatBadge(label: context.loc.absentLabel, value: '${student.absentCount}', color: AppColors.dangerRed),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }, childCount: filteredStudents.length),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: $value",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final int index;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : color.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 26,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentAttendanceModal extends StatefulWidget {
  final StudentReportEntity student;

  const _StudentAttendanceModal({required this.student});

  static void show(BuildContext context, StudentReportEntity student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StudentAttendanceModal(student: student),
    );
  }

  @override
  State<_StudentAttendanceModal> createState() => _StudentAttendanceModalState();
}

class _StudentAttendanceModalState extends State<_StudentAttendanceModal> {
  DateTime _focusedDay = DateTime.now();
  
  bool _isPresent(DateTime day) {
    if (day.isAfter(DateTime.now())) return false;
    if (day.weekday == DateTime.thursday || day.weekday == DateTime.friday) return false;
    
    final hash = (day.day * 31 + day.month * 7 + widget.student.name.hashCode) % 10;
    return hash > 2; // ~70% attendance
  }

  bool _isAbsent(DateTime day) {
    if (day.isAfter(DateTime.now())) return false;
    if (day.weekday == DateTime.thursday || day.weekday == DateTime.friday) return false;
    return !_isPresent(day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header Student Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary,
                  backgroundImage: widget.student.photoUrl != null 
                    ? NetworkImage(widget.student.photoUrl!) 
                    : null,
                  child: widget.student.photoUrl == null 
                    ? const Icon(PhosphorIconsFill.user, color: Colors.white, size: 20)
                    : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.student.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Summary Rows
          Row(
            children: [
              Expanded(
                child: _ModalSummaryBox(
                  label: context.loc.attendanceDaysLabel,
                  value: '${widget.student.presentCount}',
                  color: const Color(0xFF10B981),
                  icon: PhosphorIconsFill.checkCircle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModalSummaryBox(
                  label: context.loc.absenceDaysLabel,
                  value: '${widget.student.absentCount}',
                  color: const Color(0xFFEF4444),
                  icon: PhosphorIconsFill.xCircle,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Calendar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                _buildCalendarHeader(),
                const SizedBox(height: 16),
                _buildCustomCalendar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final languageCode = Localizations.localeOf(context).languageCode;
    final monthName = intl.DateFormat.MMMM(languageCode).format(_focusedDay);
    final year = _focusedDay.year;

    return Row(
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
    );
  }

  Widget _buildCustomCalendar() {
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
    while (firstWorkingDay <= daysInMonth) {
      DateTime day = DateTime(_focusedDay.year, _focusedDay.month, firstWorkingDay);
      if (getColumnIndex(day.weekday) != -1) break;
      firstWorkingDay++;
    }
    
    int emptyCellsAtStart = 0;
    if (firstWorkingDay <= daysInMonth) {
      emptyCellsAtStart = getColumnIndex(DateTime(_focusedDay.year, _focusedDay.month, firstWorkingDay).weekday);
    }
    
    List<DateTime?> gridDays = List.generate(emptyCellsAtStart, (index) => null);
    for (int i = 1; i <= daysInMonth; i++) {
        DateTime day = DateTime(_focusedDay.year, _focusedDay.month, i);
        if (day.weekday != DateTime.thursday && day.weekday != DateTime.friday) {
          gridDays.add(day);
        }
    }
    
    while (gridDays.length % 5 != 0) {
      gridDays.add(null);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: Center(child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'سبت' : 'Sat', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold)))),
            Expanded(child: Center(child: Text(context.loc.sundayShort, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold)))),
            Expanded(child: Center(child: Text(context.loc.mondayShort, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold)))),
            Expanded(child: Center(child: Text(context.loc.tuesdayShort, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold)))),
            Expanded(child: Center(child: Text(context.loc.wednesdayShort, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold)))),
          ],
        ),
        const SizedBox(height: 12),
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
            
            if (_isPresent(day)) {
              return _buildCalendarDay(day, const Color(0xFF10B981));
            } else if (_isAbsent(day)) {
              return _buildCalendarDay(day, const Color(0xFFEF4444));
            }
            
            return Center(
              child: Text(
                '${day.day}',
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 15,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalendarDay(DateTime day, Color color) {
    return Center(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalSummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _ModalSummaryBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : const Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
