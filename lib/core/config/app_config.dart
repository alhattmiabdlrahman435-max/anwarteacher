class AppConfig {
  // false تعني الاتصال بالاستضافة الحية مباشرة (الافتراضي)
  // للتشغيل المحلي: flutter run --dart-define=LOCAL=true
  static const bool isLocal = bool.fromEnvironment('LOCAL', defaultValue: false);

  // عنوان جهاز السيرفر المحلي (اختياري). عبر كابل USB مع adb reverse:
  // --dart-define=LOCAL_HOST=127.0.0.1
  static const String localHost = String.fromEnvironment('LOCAL_HOST', defaultValue: '');

  // 1. الرابط الأساسي للـ API والاستضافة
  static const String baseUrl = 'https://msaratwasel.tech';

  // 2. إعدادات Reverb / Pusher
  static String get reverbHost =>
      isLocal ? (localHost.isNotEmpty ? localHost : '127.0.0.1') : 'msaratwasel.tech';
  static int get reverbPort => isLocal ? 8080 : 8090;
  static String get reverbAppKey => isLocal ? 'anwar-alola-key-2024' : 'bbwhoob4xfhkw0pihbff';
  static bool get isEncrypted => !isLocal; // ws:// للمحلي و wss:// للاستضافة

  // مهلة الاتصال بالملي ثانية
  static const int activityTimeout = 30000;
}
