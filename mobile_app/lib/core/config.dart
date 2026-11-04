import 'package:flutter/foundation.dart';

/// إعدادات البيئات: التطوير / الإنتاج.
class AppConfig {
  AppConfig._();

  /// العنوان الافتراضي وقت البناء (يُستخدم إن لم يحفظ المستخدم أي خادم).
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// دالة ذكية لتحديد عنوان الخادم حسب المنصة:
  /// - في أندرويد (المحاكي): 10.0.2.2
  /// - في ويندوز/آيفون/ويب: 127.0.0.1 (لتجنب مشاكل IPv6 مع localhost)
  static String get defaultBaseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    
    if (kIsWeb) return 'http://127.0.0.1:8000';
    
    // إذا كان يعمل على أندرويد، استخدم عنوان المحاكي
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    
    // لأي منصة أخرى (ويندوز، ماك، لينكس)، استخدم 127.0.0.1
    return 'http://127.0.0.1:8000';
  }

  /// العنوان الفعّال حالياً.
  static String baseUrl = defaultBaseUrl;

  /// للتوافق مع الاستخدامات القديمة.
  static String get apiBaseUrl => baseUrl;

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static bool get isProduction => appEnv == 'production';

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