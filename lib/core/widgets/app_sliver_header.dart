import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'start_aligned_collapsing_title.dart';

class AppSliverHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool automaticallyImplyLeading;

  const AppSliverHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final primaryColor = isDark ? Colors.white : AppColors.primary;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    final titleStyle = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontWeight: FontWeight.bold,
      color: textColor,
    );

    final titleWidget = Text(
      title,
      style: titleStyle,
    );

    return CupertinoSliverNavigationBar(
      largeTitle: titleWidget,
      middle: StartAlignedCollapsingTitle(
        title: title,
        style: titleStyle,
      ),
      backgroundColor: bgColor.withValues(alpha: 0.9),
      border: null,
      leading: leading ?? (automaticallyImplyLeading
          ? (context.canPop()
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
                  onPressed: () => context.pop(),
                )
              : Builder(
                  builder: (context) {
                    final scaffold = Scaffold.maybeOf(context);
                    if (scaffold != null && scaffold.hasDrawer) {
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(
                          CupertinoIcons.bars,
                          color: textColor,
                          size: 28,
                        ),
                        onPressed: () => scaffold.openDrawer(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ))
          : null),
      trailing: trailing,
    );
  }
}
