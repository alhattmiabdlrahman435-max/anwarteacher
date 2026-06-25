import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class AppSliverHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const AppSliverHeader({
    super.key,
    required this.title,
    this.trailing,
    this.leading,
    this.automaticallyImplyLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;

    return CupertinoSliverNavigationBar(
      backgroundColor: bgColor.withValues(alpha: 0.8),
      border: null, // Removes bottom border
      largeTitle: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      leading: leading ??
          (automaticallyImplyLeading && context.canPop()
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => context.pop(),
                  child: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                )
              : Builder(
                  builder: (context) => CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(CupertinoIcons.bars, color: textColor, size: 34),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )),
      trailing: trailing,
    );
  }
}
