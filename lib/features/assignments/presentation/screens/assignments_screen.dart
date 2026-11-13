import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/assignment.dart';
import '../../../../core/providers/assignments_provider.dart';
import '../../../../core/widgets/app_sliver_header.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/extensions/localization_extension.dart';

class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  /// التبويب المختار: 0 = واجبات اليوم، 1 = الواجبات السابقة (null = تلقائي)
  int? _tab;

  /// البحث بتاريخ الإرسال (null = كل التواريخ)
  DateTime? _date;

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      helpText: 'اختر تاريخ إرسال الواجب',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      // الانتقال للتبويب المناسب لهذا التاريخ
      _tab = _sameDay(picked, now) ? 0 : 1;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(assignmentsDataProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allAssignments = ref.watch(assignmentsDataProvider);
    final q = _query.trim().toLowerCase();
    final assignments = allAssignments.where((a) {
      if (_date != null && !_sameDay(a.dateCreated, _date!)) return false;
      if (q.isEmpty) return true;
      return a.title.toLowerCase().contains(q) ||
          a.subjectName.toLowerCase().contains(q) ||
          context.translateMock(a.title).toLowerCase().contains(q) ||
          context.translateMock(a.subjectName).toLowerCase().contains(q) ||
          // كتابة التاريخ في حقل البحث (مثل 2026-10-05) تعمل أيضاً
          _formatDate(a.dateCreated).contains(q);
    }).toList();
    final isEn = context.loc.localeName == 'en';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // تقسيم الواجبات حسب يوم الإرسال
    final now = DateTime.now();
    bool isToday(DateTime d) => d.year == now.year && d.month == now.month && d.day == now.day;
    final todayList = assignments.where((a) => isToday(a.dateCreated)).toList();
    final previousList = assignments.where((a) => !isToday(a.dateCreated)).toList();
    // افتراضياً: واجبات اليوم، وإن لم توجد فالسابقة
    final tab = _tab ?? (todayList.isEmpty && previousList.isNotEmpty ? 1 : 0);
    final shown = tab == 0 ? todayList : previousList;

    return Scaffold(
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(assignmentsDataProvider.notifier).refresh();
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            AppSliverHeader(
              title: context.loc.assignments,
              automaticallyImplyLeading: true,
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
                onPressed: () {
                  context.push('/add_assignment');
                },
              ),
            ),
            if (allAssignments.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                    children: [
                  Expanded(
                    child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: isEn ? 'Search homework by title or subject...' : 'ابحث في الواجبات بالعنوان أو المادة...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            ),
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceAltDark : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.border),
                      ),
                    ),
                  ),
                  ),
                  const SizedBox(width: 8),
                  // البحث بتاريخ الإرسال
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: IconButton.filledTonal(
                      onPressed: _pickDate,
                      tooltip: isEn ? 'Search by date' : 'البحث بالتاريخ',
                      icon: const Icon(Icons.calendar_month_rounded),
                    ),
                  ),
                    ],
                  ),
                  if (_date != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: InputChip(
                        avatar: const Icon(Icons.event_rounded, size: 18),
                        label: Text('${isEn ? 'Sent on' : 'المرسلة بتاريخ'}: ${_formatDate(_date!)}'),
                        onDeleted: () => setState(() => _date = null),
                        deleteButtonTooltipMessage: isEn ? 'All dates' : 'كل التواريخ',
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            if (allAssignments.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _buildTabs(
                    isDark: isDark,
                    tab: tab,
                    labels: [
                      '${isEn ? "Today's homework" : 'واجبات اليوم'} (${todayList.length})',
                      '${isEn ? 'Previous homework' : 'الواجبات السابقة'} (${previousList.length})',
                    ],
                  ),
                ),
              ),
            if (shown.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    allAssignments.isEmpty
                        ? context.loc.noCurrentAssignments
                        : (q.isNotEmpty || _date != null)
                            ? (isEn ? 'No matching homework' : 'لا توجد واجبات مطابقة')
                            : tab == 0
                                ? (isEn ? 'No homework sent today' : 'لم تُرسل واجبات اليوم')
                                : (isEn ? 'No previous homework' : 'لا توجد واجبات سابقة'),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAssignmentCard(context, shown[index], isDark),
                    childCount: shown.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// تبويبا "واجبات اليوم" و"الواجبات السابقة" (بنفس شكل تبويبات تطبيق ولي الأمر)
  Widget _buildTabs({required bool isDark, required int tab, required List<String> labels}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: tab == i ? (isDark ? Colors.white : AppColors.primary) : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: tab == i
                          ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, Assignment assignment, bool isDark) {
    final isEn = context.loc.localeName == 'en';
    // "سلّم متأخراً" يُحسب ضمن التسليمات كما في لوحة التحكم
    int submitted = assignment.submissions
        .where((s) => s.status == SubmissionStatus.submitted || s.status == SubmissionStatus.submittedLate)
        .length;
    int total = assignment.submissions.length;
    final theme = Theme.of(context);

    return ModernCard(
      isDark: isDark,
      onTap: () => context.push('/assignment_details/${assignment.id}'),
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  context.translateMock(assignment.title),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primary,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.blue.withValues(alpha: 0.1) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  context.translateMock(assignment.subjectName),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF60A5FA),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // تعديل الواجب بعد إرساله
              SizedBox(
                width: 36,
                height: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  tooltip: isEn ? 'Edit homework' : 'تعديل الواجب',
                  onPressed: () => context.push('/edit_assignment/${assignment.id}'),
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: isDark ? Colors.white70 : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.translateMock(assignment.content), 
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.send_rounded, size: 16, color: isDark ? Colors.white54 : AppColors.textSecondaryLight),
              const SizedBox(width: 6),
              Text(
                '${isEn ? 'Sent' : 'أُرسل'}: ${_formatDate(assignment.dateCreated)}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (assignment.editedAt != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isEn ? 'Edited' : 'معدَّل',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    context.loc.submissionsCount(submitted.toString(), total.toString()),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                ],
              ),
              Row(
                children: [
                  Text(
                    context.loc.dueWithDate(_formatDate(assignment.dueDate)),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600, 
                      color: AppColors.accent,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.access_time_filled, size: 18, color: AppColors.accent),
                ],
              ),
            ],
          ),
          if (assignment.attachments.isNotEmpty) ...[
            const Divider(height: 32),
            Row(
              children: [
                const Icon(Icons.attachment, size: 18, color: AppColors.textSecondaryLight),
                const SizedBox(width: 8),
                Text(
                  context.loc.attachmentsCount(assignment.attachments.length.toString()),
                  style: theme.textTheme.labelMedium,
                ),
              ],
            )
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              // عرض الواجب بكل محتوياته (النص والصور) للمراجعة
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/assignment_details/${assignment.id}'),
                    icon: const Icon(Icons.visibility_rounded, size: 20),
                    label: Text(
                      isEn ? 'View homework' : 'عرض الواجب',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/assignment_submissions/${assignment.id}'),
                    icon: const Icon(Icons.fact_check_outlined, size: 20),
                    label: Text(
                      context.loc.submissionsTracking,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : AppColors.primary,
                      side: BorderSide(color: isDark ? Colors.white54 : AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
