import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class AdaptiveSliverAppBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool automaticallyImplyLeading;

  const AdaptiveSliverAppBar({
    super.key,
    required this.title,
    this.trailing,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final primaryColor = isDark ? Colors.white : AppColors.primary;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceAltLight;

    return CupertinoSliverNavigationBar(
      largeTitle: Text(
        title,
        style: TextStyle(height: 1.0, color: textColor),
      ),
      backgroundColor: bgColor.withValues(alpha: 0.8),
      border: null, // No bottom border for a flat look
      leading: automaticallyImplyLeading && context.canPop()
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: primaryColor,
              ),
              onPressed: () => context.pop(),
            )
          : null,
      trailing: trailing,
    );
  }
}
