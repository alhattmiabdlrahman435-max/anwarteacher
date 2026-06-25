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

class AssignmentsScreen extends ConsumerWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref.watch(assignmentsDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(),
      body: CustomScrollView(
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
          if (assignments.isEmpty)
            SliverFillRemaining(
              child: Center(child: Text(context.loc.noCurrentAssignments)),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final assignment = assignments[index];
                    return _buildAssignmentCard(context, assignment, isDark);
                  },
                  childCount: assignments.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, Assignment assignment, bool isDark) {
    int submitted = assignment.submissions.where((s) => s.status == SubmissionStatus.submitted).length;
    int total = assignment.submissions.length;
    final theme = Theme.of(context);

    return ModernCard(
      isDark: isDark,
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
          const SizedBox(height: AppSpacing.xl),
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
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                context.push('/assignment_submissions/${assignment.id}');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : AppColors.primary,
                side: BorderSide(color: isDark ? Colors.white54 : AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.loc.trackSubmissionsAndFeedback,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
