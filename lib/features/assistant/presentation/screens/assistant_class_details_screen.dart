import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_sliver_app_bar.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/widgets/student_avatar.dart';
import '../../models/assistant_models.dart';
import '../../providers/assistant_classes_provider.dart';
import '../../providers/assistant_class_details_provider.dart';

class AssistantClassDetailsScreen extends ConsumerWidget {
  final String classId;

  const AssistantClassDetailsScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final classrooms = ref.watch(assistantClassesProvider);
    final classroom = classrooms.firstWhere(
      (c) => c.id == classId,
      orElse: () => ClassroomEntity(id: classId, name: context.loc.details, grade: '', studentCount: 0),
    );

    final students = ref.watch(assistantClassDetailsProvider(classId));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          AdaptiveSliverAppBar(
            title: classroom.name,
            automaticallyImplyLeading: true,
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                PhosphorIconsRegular.qrCode,
                color: isDark ? Colors.white : AppColors.primary,
                size: 28,
              ),
              onPressed: () {
                context.push('/assistant/qr_scan');
              },
            ),
          ),
          students.isEmpty
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final student = students[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _StudentCard(
                            student: student,
                            classId: classId,
                            className: classroom.name,
                          ),
                        );
                      },
                      childCount: students.length,
                    ),
                  ),
                ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, ref, students),
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, List<StudentEntity> students) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.5),
        ),
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () => _showConfirmationDialog(context, ref, students),
          icon: const Icon(PhosphorIconsRegular.paperPlaneRight),
          label: Text(
            context.loc.finishAndSendReport,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, WidgetRef ref, List<StudentEntity> students) {
    final totalCount = students.length;
    final presentCount = students.where((s) => s.status == AttendanceStatus.present).length;
    final absentCount = students.where((s) => s.status == AttendanceStatus.absent).length;
    final unmarkedCount = students.where((s) => s.status == AttendanceStatus.unknown).length;

    showDialog(
      context: context,
      builder: (dialogContext) => _ConfirmationDialog(
        totalCount: totalCount,
        presentCount: presentCount,
        absentCount: absentCount,
        unmarkedCount: unmarkedCount,
        onConfirm: () async {
          final success = await ref.read(assistantClassDetailsProvider(classId).notifier).submitDailyReport();
          if (context.mounted) {
            Navigator.of(dialogContext).pop();
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.loc.reportSentSuccess),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.loc.reportSentFail),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class _StudentCard extends ConsumerWidget {
  final StudentEntity student;
  final String classId;
  final String className;

  const _StudentCard({
    required this.student,
    required this.classId,
    required this.className,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showStudentDetails(context, student),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getStatusColor(student.status).withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: StudentAvatar(
                        photoUrl: student.photoUrl,
                        name: student.name,
                        size: 56,
                        backgroundColor: _getStatusColor(student.status).withValues(alpha: 0.1),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                PhosphorIconsRegular.user,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                student.parentName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        PhosphorIconsRegular.list,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildAttendanceButtons(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceButtons(BuildContext context, WidgetRef ref) {
    final bool isLocked = student.isLocked && student.status != AttendanceStatus.unknown;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Opacity(
        opacity: isLocked ? 0.6 : 1.0,
        child: Row(
          children: [
            Expanded(
              child: _AttendanceButton(
                label: context.loc.presentLabel,
                icon: PhosphorIconsFill.checkCircle,
                color: AppColors.successGreen,
                isSelected: student.status == AttendanceStatus.present,
                onTap: isLocked ? null : () {
                  ref.read(assistantClassDetailsProvider(classId).notifier).markAttendance(
                    student.id,
                    AttendanceStatus.present,
                  );
                },
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _AttendanceButton(
                label: context.loc.absentLabel,
                icon: PhosphorIconsFill.xCircle,
                color: AppColors.dangerRed,
                isSelected: student.status == AttendanceStatus.absent,
                onTap: isLocked ? null : () {
                  ref.read(assistantClassDetailsProvider(classId).notifier).markAttendance(
                    student.id,
                    AttendanceStatus.absent,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppColors.successGreen;
      case AttendanceStatus.absent:
        return AppColors.dangerRed;
      default:
        return Colors.grey.withValues(alpha: 0.5);
    }
  }

  void _showStudentDetails(BuildContext context, StudentEntity student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StudentDetailsModal(student: student, className: className),
    );
  }
}

class _AttendanceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _AttendanceButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentDetailsModal extends StatelessWidget {
  final StudentEntity student;
  final String className;

  const _StudentDetailsModal({required this.student, required this.className});

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
          StudentAvatar(
            photoUrl: student.photoUrl,
            name: student.name,
            size: 100,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            student.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            className,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
                color: primaryColor.withValues(alpha: 0.5),
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
}

class _ConfirmationDialog extends StatelessWidget {
  final int totalCount;
  final int presentCount;
  final int absentCount;
  final int unmarkedCount;
  final VoidCallback onConfirm;

  const _ConfirmationDialog({
    required this.totalCount,
    required this.presentCount,
    required this.absentCount,
    required this.unmarkedCount,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : AppColors.primary).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsFill.clipboardText,
                size: 48,
                color: isDark ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.loc.attendanceSummary,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.loc.confirmSendReport,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(context, context.loc.totalStudents, totalCount.toString(), Colors.blue),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(context, context.loc.presentPlural, presentCount.toString(), AppColors.successGreen),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(context, context.loc.absentPlural, absentCount.toString(), AppColors.dangerRed),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(context, context.loc.unmarked, unmarkedCount.toString(), Colors.grey),
                ),
              ],
            ),
            
            if (unmarkedCount > 0) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.loc.unmarkedWarning(unmarkedCount),
                        style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.loc.cancel),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onConfirm,
                    child: Text(context.loc.sendAndConfirm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
