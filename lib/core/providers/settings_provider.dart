import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

enum AppFontSize {
  small,
  medium,
  large;

  double get scaleFactor {
    switch (this) {
      case AppFontSize.small:
        return 0.85;
      case AppFontSize.medium:
        return 1.0;
      case AppFontSize.large:
        return 1.15;
    }
  }

  String getLabel(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    switch (this) {
      case AppFontSize.small:
        return isArabic ? 'صغير' : 'Small';
      case AppFontSize.medium:
        return isArabic ? 'متوسط' : 'Medium';
      case AppFontSize.large:
        return isArabic ? 'كبير' : 'Large';
    }
  }
}

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;
  final AppFontSize fontSize;
  final bool notificationsEnabled;

  const AppSettings({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('ar'),
    this.fontSize = AppFontSize.medium,
    this.notificationsEnabled = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode, 
    Locale? locale, 
    AppFontSize? fontSize,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      fontSize: fontSize ?? this.fontSize,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  AppSettings build() {
    _loadSettings();
    return const AppSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    final languageCode = prefs.getString('languageCode') ?? 'ar';
    final fontSizeName = prefs.getString('fontSize') ?? 'medium';
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

    final fontSize = AppFontSize.values.firstWhere(
      (e) => e.name == fontSizeName,
      orElse: () => AppFontSize.medium,
    );

    state = state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(languageCode),
      fontSize: fontSize,
      notificationsEnabled: notificationsEnabled,
    );
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    state = state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }

  Future<void> toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final newLang = state.locale.languageCode == 'ar' ? 'en' : 'ar';
    await prefs.setString('languageCode', newLang);
    state = state.copyWith(locale: Locale(newLang));
  }

  Future<void> setFontSize(AppFontSize size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontSize', size.name);
    state = state.copyWith(fontSize: size);
  }

  Future<void> toggleNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
    
    if (!enabled) {
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (e) {
        debugPrint('Failed to delete FCM token: $e');
      }
    } else {
      try {
        // Just request a new token so it re-registers with FCM
        await FirebaseMessaging.instance.getToken();
      } catch (e) {
        debugPrint('Failed to get FCM token: $e');
      }
    }
    
    state = state.copyWith(notificationsEnabled: enabled);
  }
}
