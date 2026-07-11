import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/connectivity_provider.dart';
import '../providers/server_error_provider.dart';
import '../theme/app_colors.dart';

class ConnectivityOverlay extends ConsumerWidget {
  final Widget child;

  const ConnectivityOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityStatus = ref.watch(connectivityProvider);
    final hasServerError = ref.watch(serverErrorProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        child,
        if (connectivityStatus == ConnectivityStatus.offline)
          _buildErrorScreen(
            context: context,
            isDark: isDark,
            title: 'لا يوجد اتصال بالإنترنت',
            message: 'يرجى التحقق من اتصالك بشبكة الواي فاي أو بيانات الهاتف والمحاولة مرة أخرى.',
            icon: PhosphorIcons.wifiSlash(PhosphorIconsStyle.duotone),
            iconColor: AppColors.error,
            onRetry: () {
              // Trigger state refresh
              ref.invalidate(connectivityProvider);
            },
          )
        else if (hasServerError)
          _buildErrorScreen(
            context: context,
            isDark: isDark,
            title: 'مشكلة في خادم المدرسة',
            message: 'نواجه حالياً صعوبة في الاتصال بالسيرفر. يرجى المحاولة لاحقاً أو التواصل مع الإدارة.',
            icon: PhosphorIcons.cloudWarning(PhosphorIconsStyle.duotone),
            iconColor: AppColors.warning,
            onRetry: () {
              // Reset error state manually to let the app try again
              ref.read(serverErrorProvider.notifier).setHasError(false);
            },
            showClose: true,
          ),
      ],
    );
  }

  Widget _buildErrorScreen({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onRetry,
    bool showClose = false,
  }) {
    return Positioned.fill(
      child: Container(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.98)
            : AppColors.surfaceLight.withValues(alpha: 0.98),
        child: SafeArea(
          child: Stack(
            children: [
              if (showClose)
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      PhosphorIcons.x(),
                      color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                    ),
                    onPressed: () {
                      onRetry(); // This sets hasServerError to false
                    },
                  ),
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Icon container
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 72,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          fontFamily: 'GoogleSans',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Description message
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontFamily: 'GoogleSans',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Premium retry button
                      ElevatedButton.icon(
                        onPressed: onRetry,
                        icon: Icon(
                          PhosphorIcons.arrowsClockwise(),
                          size: 20,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'تحديث الاتصال',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'GoogleSans',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
