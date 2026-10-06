import 'package:flutter/foundation.dart';

/// إعدادات البيئات: التطوير / الإنتاج.
///
/// بناء الإنتاج يجب أن يمرر عنوان خادم آمن عبر dart-define:
/// flutter build apk --release \
///   --dart-define=API_BASE_URL=https://api.example.com \
///   --dart-define=APP_ENV=production
///
/// هذا يحل ملاحظة الفحص 15 (العنوان الثابت 10.0.2.2 الخاص بالمحاكي).
class AppConfig {
  AppConfig._();

  /// العنوان الافتراضي وقت البناء (يُستخدم إن لم يحفظ المستخدم أي خادم).
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// العنوان الفعّال حالياً: يُستبدل وقت التشغيل عند اختيار خادم من «الخوادم».
  static String baseUrl = defaultBaseUrl;

  /// للتوافق مع الاستخدامات القديمة.
  static String get apiBaseUrl => baseUrl;

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static bool get isProduction => appEnv == 'production';

  /// في الإنتاج يجب أن يكون العنوان https - أي عنوان http يُسجَّل كتحذير خطير.
  static bool get isSecureBaseUrl {
    final uri = Uri.tryParse(baseUrl);
    return uri != null && uri.scheme == 'https';
  }

  static void assertSafeConfiguration() {
    if (isProduction && !isSecureBaseUrl && kDebugMode) {
      debugPrint(
        'تحذير أمني: APP_ENV=production مع API_BASE_URL غير آمن (غير HTTPS). '
        'مرّر --dart-define=API_BASE_URL=https://... عند بناء نسخة الإنتاج.',
      );
    }
  }

  static const String appVersion = '9.0.0';
  static const String appName = 'الصندوق الاجتماعي التنموي';
}
