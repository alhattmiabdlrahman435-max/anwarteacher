import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary (Modern Vibrant Colors)
  static const Color primary = Color.fromARGB(255, 17, 50, 121); // Vibrant Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color uiPalettePrimary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFFF59E0B); // Amber/Orange
  static const Color primaryGradient = Color(0xFF60A5FA);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Surface Colors
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceAltLight = Colors.white;
  static const Color surfaceAltDark = Color(0xFF1E293B);
  static const Color neutralWarm = Color(0xFFF2E5C8);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Fallbacks / Settings integration
  static const Color backgroundDark = surfaceDark;
  static const Color secondary = accent;
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;

  // Compatibility Colors for Assistant Module
  static const Color lightBlue = Color(0xFF0EA5E9);
  static const Color successGreen = success;
  static const Color dangerRed = error;
  static const Color cardDark = surfaceAltDark;
  static const Color purple = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);
}
