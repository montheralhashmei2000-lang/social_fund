import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// التخزين الآمن على الجهاز (Keystore المشفّر عبر EncryptedSharedPreferences).
///
/// هذا يحل ملاحظة الفحص 12: لم تعد بيانات الأعضاء تُخزَّن إطلاقاً على
/// الجهاز (نظام أونلاين فقط)، وما يُخزَّن هنا هو رموز الجلسة والإعدادات
/// الشخصية فقط، داخل تخزين مشفّر بدل AsyncStorage النصي.
class SecureStore {
  SecureStore._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _accessTokenKey = 'sf_access_token';
  static const String _refreshTokenKey = 'sf_refresh_token';
  static const String _biometricKey = 'sf_biometric_enabled';
  static const String _deviceIdKey = 'sf_device_id';
  static const String _darkModeKey = 'sf_dark_mode';

  static Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: _accessTokenKey, value: access);
    await _storage.write(key: _refreshTokenKey, value: refresh);
  }

  static Future<String?> accessToken() => _storage.read(key: _accessTokenKey);
  static Future<String?> refreshToken() => _storage.read(key: _refreshTokenKey);

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  static Future<void> setBiometricEnabled(bool value) =>
      _storage.write(key: _biometricKey, value: value ? '1' : '0');

  static Future<bool> biometricEnabled() async =>
      await _storage.read(key: _biometricKey) == '1';

  static Future<void> setDarkMode(bool value) =>
      _storage.write(key: _darkModeKey, value: value ? '1' : '0');

  static Future<bool> isDarkMode() async => await _storage.read(key: _darkModeKey) == '1';

  static const String _displayCurrencyKey = 'sf_display_currency';
  static const String _serversKey = 'sf_servers';
  static const String _activeServerKey = 'sf_active_server';

  /// عملة العرض المفضّلة لهذا الجهاز (null = افتراضية النظام).
  static Future<String?> displayCurrency() async {
    final v = await _storage.read(key: _displayCurrencyKey);
    return (v == null || v.isEmpty) ? null : v;
  }

  static Future<void> setDisplayCurrency(String? code) => code == null || code.isEmpty
      ? _storage.delete(key: _displayCurrencyKey)
      : _storage.write(key: _displayCurrencyKey, value: code);

  /// قائمة الخوادم المحفوظة (JSON) ومعرّف الخادم النشط.
  static Future<String?> serversJson() => _storage.read(key: _serversKey);
  static Future<void> saveServersJson(String json) =>
      _storage.write(key: _serversKey, value: json);
  static Future<String?> activeServerId() => _storage.read(key: _activeServerKey);
  static Future<void> setActiveServerId(String id) =>
      _storage.write(key: _activeServerKey, value: id);

  static Future<void> clearAll() => _storage.deleteAll();

  static Future<String> deviceId() async {
    var id = await _storage.read(key: _deviceIdKey);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await _storage.write(key: _deviceIdKey, value: id);
    }
    return id;
  }
}
