import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/models/assignment.dart';
import '../../../../core/providers/assignments_provider.dart';
import '../../../../core/providers/classes_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/extensions/localization_extension.dart';

/// عرض تفاصيل واجب سابق كاملة (النص + المرفقات) للمراجعة.
class AssignmentDetailsScreen extends ConsumerWidget {
  final String assignmentId;

  const AssignmentDetailsScreen({super.key, required this.assignmentId});

  static const _imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic', 'heif'];

  static bool _isImage(String url) {
    final path = Uri.tryParse(url)?.path ?? url;
    final dot = path.lastIndexOf('.');
    if (dot == -1) return false;
    return _imageExtensions.contains(path.substring(dot + 1).toLowerCase());
  }

  static String _fileName(String url) {
    final path = Uri.tryParse(url)?.path ?? url;
    final name = path.split('/').where((s) => s.isNotEmpty).lastOrNull ?? url;
    return Uri.decodeComponent(name);
  }

  String _t(BuildContext context, String ar, String en) =>
      context.loc.localeName == 'en' ? en : ar;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(BuildContext context, DateTime date) {
    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final period = date.hour < 12 ? _t(context, 'ص', 'AM') : _t(context, 'م', 'PM');
    return '${_formatDate(date)} ${hour12.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final assignments = ref.watch(assignmentsDataProvider);
    ref.watch(classesProvider);
    final assignment = assignments.where((a) => a.id == assignmentId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(context, 'تفاصيل الواجب', 'Homework Details')),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: assignment == null
          ? Center(child: Text(_t(context, 'لم يتم العثور على الواجب', 'Homework not found')))
          : _buildBody(context, ref, assignment, isDark, theme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    Assignment assignment,
    bool isDark,
    ThemeData theme,
  ) {
    final urls = assignment.attachments
        .map((u) => AppConstants.normalizeUrl(u) ?? u)
        .where((u) => u.isNotEmpty)
        .toList();
    final images = urls.where(_isImage).toList();
    final files = urls.where((u) => !_isImage(u)).toList();

    final idToName = {
      for (final e in ref.read(classesProvider.notifier).nameToIdMap.entries) e.value: e.key,
    };
    final className = idToName[assignment.classId];

    final secondaryColor = isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      physics: const BouncingScrollPhysics(),
      children: [
        ModernCard(
          isDark: isDark,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _chip(
                    context.translateMock(assignment.subjectName),
                    isDark ? Colors.blue.withValues(alpha: 0.1) : const Color(0xFFEFF6FF),
                    const Color(0xFF60A5FA),
                    theme,
                  ),
                  if (className != null && className.isNotEmpty)
                    _chip(
                      context.translateMock(className),
                      isDark ? Colors.green.withValues(alpha: 0.1) : const Color(0xFFECFDF5),
                      AppColors.success,
                      theme,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SelectableText(
                context.translateMock(assignment.title),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
              ),
              const Divider(height: 32),
              _infoRow(
                Icons.send_rounded,
                _t(context, 'تاريخ الإرسال', 'Sent on'),
                _formatDateTime(context, assignment.dateCreated),
                AppColors.primaryGradient,
                theme,
                isDark,
                badge: assignment.editedAt != null ? _editedBadge(context, theme) : null,
              ),
              const SizedBox(height: AppSpacing.md),
              _infoRow(
                Icons.access_time_filled,
                context.loc.dueDateLabel,
                _formatDate(assignment.dueDate),
                AppColors.accent,
                theme,
                isDark,
              ),
            ],
          ),
        ),
        ModernCard(
          isDark: isDark,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(_t(context, 'نص الواجب', 'Homework content'), Icons.notes_rounded, theme, isDark),
              const SizedBox(height: AppSpacing.md),
              SelectableText(
                assignment.content.trim().isEmpty
                    ? _t(context, 'لا يوجد نص', 'No text')
                    : context.translateMock(assignment.content),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: assignment.content.trim().isEmpty
                      ? secondaryColor
                      : (isDark ? Colors.white : AppColors.textPrimaryLight),
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
        if (urls.isNotEmpty)
          ModernCard(
            isDark: isDark,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(
                  context.loc.attachmentsCount(urls.length.toString()),
                  Icons.attachment,
                  theme,
                  isDark,
                ),
                if (images.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: images.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _ImageViewerPage(images: images, initialIndex: index),
                            ),
                          );
                        },
                        child: Hero(
                          tag: '${images[index]}#$index',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              child: Image.network(
                                images[index],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) => progress == null
                                    ? child
                                    : const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                errorBuilder: (context, error, stack) => Icon(
                                  Icons.broken_image_outlined,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
                if (files.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  ...files.map((url) => _fileRow(context, url, theme, isDark)),
                ],
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/edit_assignment/${assignment.id}'),
            icon: const Icon(Icons.edit_rounded),
            label: Text(
              _t(context, 'تعديل الواجب', 'Edit homework'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white : AppColors.primary,
              side: BorderSide(color: isDark ? Colors.white54 : AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/assignment_submissions/${assignment.id}'),
            icon: const Icon(Icons.fact_check_outlined),
            label: Text(
              _t(context, 'متابعة تسليم الطلاب', 'Track student submissions'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _chip(String text, Color bg, Color fg, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(color: fg, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon, ThemeData theme, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.white70 : AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.primary,
          ),
        ),
      ],
    );
  }

  /// شارة "معدَّل" تظهر عند تعديل الواجب بعد إرساله
  Widget _editedBadge(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _t(context, 'معدَّل', 'Edited'),
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color, ThemeData theme, bool isDark, {Widget? badge}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: theme.textTheme.labelMedium?.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontSize: 13,
          ),
        ),
        Flexible(
          fit: badge == null ? FlexFit.tight : FlexFit.loose,
          child: Text(
            value,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.start,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 13,
            ),
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: AppSpacing.sm),
          badge,
        ],
      ],
    );
  }

  Widget _fileRow(BuildContext context, String url, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        leading: const Icon(Icons.insert_drive_file_outlined, color: AppColors.primaryGradient),
        title: Text(
          _fileName(url),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        trailing: IconButton(
          tooltip: _t(context, 'نسخ الرابط', 'Copy link'),
          icon: const Icon(Icons.copy_rounded, size: 20),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: url));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_t(context, 'تم نسخ الرابط', 'Link copied'))),
              );
            }
          },
        ),
        onTap: () async {
          final uri = Uri.tryParse(url);
          final ok = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!ok && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_t(context, 'تعذر فتح الملف', 'Could not open file'))),
            );
          }
        },
      ),
    );
  }
}

/// عارض الصور بملء الشاشة مع التكبير والتنقل بين الصور.
class _ImageViewerPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImageViewerPage({required this.images, required this.initialIndex});

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);
  late int _current = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          '${_current + 1} / ${widget.images.length}',
          textDirection: TextDirection.ltr,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (context, index) {
          final url = widget.images[index];
          return InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(
              child: Hero(
                tag: '$url#$index',
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const Center(child: CircularProgressIndicator(color: Colors.white)),
                  errorBuilder: (context, error, stack) =>
                      const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 64),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
