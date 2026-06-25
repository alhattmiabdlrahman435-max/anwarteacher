import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/assignment.dart';
import '../../../../core/providers/assignments_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/widgets/modern_text_field.dart';
import '../../../../core/extensions/localization_extension.dart';

class SubmissionsTrackingScreen extends ConsumerStatefulWidget {
  final String assignmentId;

  const SubmissionsTrackingScreen({super.key, required this.assignmentId});

  @override
  ConsumerState<SubmissionsTrackingScreen> createState() => _SubmissionsTrackingScreenState();
}

class _SubmissionsTrackingScreenState extends ConsumerState<SubmissionsTrackingScreen> {
  // To avoid constant rebuilding of text fields while typing, we keep track of notes locally 
  // and update the provider when focus is lost or submitting.
  final Map<String, TextEditingController> _noteControllers = {};

  @override
  void dispose() {
    for (var controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getControllerFor(String studentId, String? initialNote) {
    if (!_noteControllers.containsKey(studentId)) {
      _noteControllers[studentId] = TextEditingController(text: initialNote ?? '');
    }
    return _noteControllers[studentId]!;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assignments = ref.watch(assignmentsDataProvider);
    final assignment = assignments.firstWhere(
      (a) => a.id == widget.assignmentId,
      orElse: () => throw Exception('Assignment not found'),
    );

    int submittedCount = assignment.submissions.where((s) => s.status == SubmissionStatus.submitted).length;
    int lateCount = assignment.submissions.where((s) => s.status == SubmissionStatus.submittedLate).length;
    int notSubmittedCount = assignment.submissions.where((s) => s.status == SubmissionStatus.notSubmitted).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.submissionsTracking),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ModernCard(
                isDark: isDark,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translateMock(assignment.title),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isDark ? Colors.white : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.blue.withValues(alpha: 0.1) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        context.translateMock(assignment.subjectName),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF60A5FA),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatColumn(context.loc.submissionStatusSubmitted, submittedCount, AppColors.success),
                        _buildStatColumn(context.loc.submissionStatusLate, lateCount, AppColors.accent),
                        _buildStatColumn(context.loc.submissionStatusNotSubmitted, notSubmittedCount, AppColors.error),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final submission = assignment.submissions[index];
                  return _buildStudentCard(context, assignment.id, submission, isDark);
                },
                childCount: assignment.submissions.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(BuildContext context, String assignmentId, StudentSubmission submission, bool isDark) {
    return ModernCard(
      isDark: isDark,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  context.translateMock(submission.studentName).isNotEmpty
                      ? context.translateMock(submission.studentName).substring(0, 1)
                      : '?',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  context.translateMock(submission.studentName),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceAltDark : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildStatusOption(
                  assignmentId,
                  submission,
                  SubmissionStatus.submitted,
                  context.loc.submissionStatusSubmitted,
                  AppColors.success,
                  isDark,
                ),
                _buildStatusOption(
                  assignmentId,
                  submission,
                  SubmissionStatus.submittedLate,
                  context.loc.submissionStatusLate,
                  AppColors.accent,
                  isDark,
                ),
                _buildStatusOption(
                  assignmentId,
                  submission,
                  SubmissionStatus.notSubmitted,
                  context.loc.submissionStatusNotSubmitted,
                  AppColors.error,
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                ref.read(assignmentsDataProvider.notifier).updateSubmission(
                  assignmentId,
                  submission.studentId,
                  submission.status,
                  _getControllerFor(submission.studentId, submission.teacherNote).text,
                );
              }
            },
            child: ModernTextField(
              controller: _getControllerFor(submission.studentId, submission.teacherNote),
              label: context.loc.teacherFeedback,
              hint: context.loc.addNoteHint,
              icon: Icons.edit_note_rounded,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
    String assignmentId,
    StudentSubmission submission,
    SubmissionStatus status,
    String label,
    Color activeColor,
    bool isDark,
  ) {
    final isSelected = submission.status == status;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(assignmentsDataProvider.notifier).updateSubmission(
            assignmentId,
            submission.studentId,
            status,
            submission.teacherNote,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? activeColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? activeColor
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
