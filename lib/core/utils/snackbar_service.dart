import 'package:flutter/material.dart';

/// Unified snackbar service for the application.
///
/// Provides two ways to show snackbars:
/// - Static methods via [scaffoldMessengerKey] (usable without a [BuildContext])
/// - Context-based methods for when a [BuildContext] is available
class SnackbarService {
  // ──────────────────────────────────────────────
  // Global key approach (context-free)
  // ──────────────────────────────────────────────

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message) {
    _show(
      message,
      backgroundColor: const Color(0xFF059669), // emerald-600
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void showError(String message) {
    _show(
      message,
      backgroundColor: const Color(0xFFDC2626), // red-600
      icon: Icons.error_outline_rounded,
    );
  }

  static void showInfo(String message) {
    _show(
      message,
      backgroundColor: const Color(0xFF2563EB), // blue-600
      icon: Icons.info_outline_rounded,
    );
  }

  static void showWarning(String message) {
    _show(
      message,
      backgroundColor: const Color(0xFFD97706), // amber-600
      icon: Icons.warning_amber_rounded,
    );
  }

  static void _show(
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      _buildSnackBar(message, backgroundColor: backgroundColor, icon: icon),
    );
  }

  // ──────────────────────────────────────────────
  // Context-based approach
  // ──────────────────────────────────────────────

  static void showSuccessContext(BuildContext context, String message) {
    _showWithContext(context, message,
        backgroundColor: const Color(0xFF059669),
        icon: Icons.check_circle_outline_rounded);
  }

  static void showErrorContext(BuildContext context, String message) {
    _showWithContext(context, message,
        backgroundColor: const Color(0xFFDC2626),
        icon: Icons.error_outline_rounded);
  }

  static void showInfoContext(BuildContext context, String message) {
    _showWithContext(context, message,
        backgroundColor: const Color(0xFF2563EB),
        icon: Icons.info_outline_rounded);
  }

  static void _showWithContext(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(message, backgroundColor: backgroundColor, icon: icon),
    );
  }

  // ──────────────────────────────────────────────
  // Shared builder
  // ──────────────────────────────────────────────

  static SnackBar _buildSnackBar(
    String message, {
    required Color backgroundColor,
    required IconData icon,
  }) {
    return SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      elevation: 6,
    );
  }
}
