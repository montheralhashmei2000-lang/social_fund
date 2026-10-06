// lib/core/config.dart
// إعدادات الخادم، كلها قابلة للتجاوز بمتغيرات البيئة.

import 'dart:io';
import 'dart:math';

class ServerConfig {
  ServerConfig._();

  static String get host => Platform.environment['HOST'] ?? '0.0.0.0';

  static int get port => int.tryParse(Platform.environment['PORT'] ?? '') ?? 8000;

  /// مفتاح توقيع JWT. إلزامي في الإنتاج؛ إن لم يُضبط يُولَّد ويُحفظ محلياً
  /// مرة واحدة حتى لا تُبطل الجلسات عند كل إعادة تشغيل أثناء التطوير.
  static String get jwtSecret {
    final env = Platform.environment['JWT_SECRET'];
    if (env != null && env.isNotEmpty) return env;
    return _persistedSecret('jwt');
  }

  /// مفتاح تشفير الحقول الحساسة (AES-256-GCM).
  static String get encryptionKey {
    final env = Platform.environment['ENCRYPTION_KEY'];
    if (env != null && env.isNotEmpty) return env;
    return _persistedSecret('enc');
  }

  static const int accessTokenMinutes = 30;
  static const int refreshTokenDays = 30;

  static const int otpTtlSeconds = 180;
  static const int otpMaxAttempts = 5;
  static const int otpRequestMaxPerHour = 5;

  static const int loginMaxAttempts = 5;
  static const int loginWindowSeconds = 300;
  static const int loginLockoutSeconds = 900;

  static bool get isProduction =>
      Platform.environment['APP_ENV'] == 'production';

  static String? get mediaDir => Platform.environment['MEDIA_DIR'];

  static String? get adminBootstrapPassword =>
      Platform.environment['ADMIN_PASSWORD'];

  /// مجلد البيانات: قاعدة SQLite والنسخ الاحتياطية والمرفقات.
  static String get dataDir {
    final env = Platform.environment['DATA_DIR'];
    if (env != null && env.isNotEmpty) return env;
    if (Platform.isWindows) {
      return (Platform.environment['APPDATA'] ?? '.') + '/SocialFund';
    }
    if (Platform.isLinux) {
      return (Platform.environment['HOME'] ?? '.') + '/.local/share/social_fund';
    }
    return Directory.systemTemp.path + '/social_fund';
  }

  /// مفتاح تطوير دائم يُخزَّن مرة واحدة على القرص، حتى لا تُبطل الجلسات
  /// عند كل إعادة تشغيل. في الإنتاج يجب ضبطه عبر البيئة.
  static String _persistedSecret(String name) {
    try {
      final file = File('$dataDir/$name.secret');
      if (file.existsSync()) return file.readAsStringSync().trim();
      file.parent.createSync(recursive: true);
      final value = randomSecret();
      file.writeAsStringSync(value);
      return value;
    } catch (_) {
      return randomSecret();
    }
  }

  /// نص عشوائي 256 بت بصيغة hex.
  static String randomSecret() {
    final rand = Random.secure();
    return List<int>.generate(32, (_) => rand.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}