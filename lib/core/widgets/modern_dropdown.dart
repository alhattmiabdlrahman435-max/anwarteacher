import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ModernDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final ValueChanged<T?> onChanged;
  final IconData icon;
  final bool isDark;

  const ModernDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    required this.onChanged,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isDark ? Colors.white70 : AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DropdownButtonFormField<T>(
          isExpanded: true,
          initialValue: items.contains(value) ? value : null,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary.withValues(alpha: 0.6)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary.withValues(alpha: 0.6)),
          ),
          dropdownColor: isDark ? AppColors.surfaceAltDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabelBuilder(item),
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          hint: Text('اختر', style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white38 : Colors.grey.shade400)),
        ),
      ],
    );
  }
}
