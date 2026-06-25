import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isDark;
  final int maxLines;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.maxLines = 1,
    this.textInputAction,
    this.keyboardType,
    this.validator,
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
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          validator: validator,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: maxLines == 1
                ? Icon(icon)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 80.0), // Align top for multiline
                    child: Icon(icon),
                  ),
          ),
        ),
      ],
    );
  }
}
