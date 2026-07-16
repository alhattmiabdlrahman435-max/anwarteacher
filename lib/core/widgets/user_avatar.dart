import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A unified avatar widget that handles all image source types:
/// - HTTP/HTTPS URLs → CachedNetworkImage
/// - Local file paths → FileImage (without blocking existsSync)
/// - Emoji characters → Text
/// - Fallback → initials or icon
///
/// This eliminates duplicated avatar logic across Dashboard, Drawer, and Profile screens,
/// and avoids the blocking File.existsSync() call in build methods.
class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String fallbackName;
  final double radius;
  final bool isAssistant;
  final Color? borderColor;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.fallbackName = '',
    this.radius = 30,
    this.isAssistant = false,
    this.borderColor,
  });

  /// Checks if the path looks like a local file path without performing I/O.
  /// This avoids the blocking File.existsSync() call in build().
  static bool _isLocalFilePath(String path) {
    // A local file path starts with '/' (Unix) or contains ':' (Windows drive letter)
    // and does NOT start with 'http'
    if (path.startsWith('http://') || path.startsWith('https://')) return false;
    return path.startsWith('/') || path.contains(':\\');
  }

  /// Checks if the string is a short emoji/character avatar (≤ 4 runes).
  static bool _isEmoji(String value) {
    return value.runes.length <= 4 && value.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : (borderColor ?? AppColors.primary).withValues(alpha: 0.2);

    // Case 1: HTTP/HTTPS URL
    if (avatarUrl != null && avatarUrl!.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(avatarUrl!),
      );
    }

    // Case 2: Local file path (pattern-based check, no I/O)
    if (avatarUrl != null && _isLocalFilePath(avatarUrl!)) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(avatarUrl!)),
      );
    }

    // Case 3: Emoji avatar
    if (avatarUrl != null && _isEmoji(avatarUrl!)) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: Text(
          avatarUrl!,
          style: TextStyle(fontSize: radius * 0.85),
        ),
      );
    }

    // Case 4: Fallback — initials or icon
    if (fallbackName.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: Text(
          fallbackName.substring(0, 1),
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primary,
            fontSize: radius * 0.9,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    // Case 5: No data at all — show icon
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Icon(
        isAssistant
            ? CupertinoIcons.checkmark_seal_fill
            : CupertinoIcons.person_solid,
        size: radius * 1.1,
        color: isDark ? Colors.white : AppColors.primary,
      ),
    );
  }
}
