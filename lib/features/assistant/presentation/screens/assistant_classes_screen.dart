import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/extensions/localization_extension.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/adaptive_sliver_app_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../models/assistant_models.dart';
import '../../providers/assistant_classes_provider.dart';

class AssistantClassesScreen extends ConsumerWidget {
  const AssistantClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classrooms = ref.watch(assistantClassesProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate network delay
          await Future.delayed(const Duration(seconds: 1));
          // Once the provider is async, we would do: ref.invalidate(assistantClassesProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            AdaptiveSliverAppBar(
              title: context.loc.assistantClasses,
            ),
            if (classrooms.isEmpty)
              SliverFillRemaining(
                child: EmptyStateWidget(
                  message: 'No classes available.', // Can be localized later
                  onRetry: () {},
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final classroom = classrooms[index];
                      return _ClassCard(classroom: classroom);
                    },
                    childCount: classrooms.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final ClassroomEntity classroom;

  const _ClassCard({required this.classroom});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.1),
        ),
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
        contentPadding: const EdgeInsets.all(AppSpacing.lg),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            PhosphorIconsFill.chalkboardTeacher,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          classroom.getLocalizedName(languageCode),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            context.loc.studentsCount(classroom.studentCount),
            style: TextStyle(
              color: isDark ? Colors.white60 : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        onTap: () {
          context.push('/assistant/classes/${classroom.id}');
        },
      ),
    );
  }
}
