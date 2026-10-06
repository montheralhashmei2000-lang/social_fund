import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'api_client.dart';
import 'config.dart';
import 'secure_store.dart';

/// خادم محفوظ (محلي أو سحابي). التطبيق يعمل مع خادم واحد نشط في كل لحظة،
/// والتبديل بينها لا يحتاج إعادة بناء التطبيق.
class ServerProfile {
  final String id;
  final String name;
  final String url;

  const ServerProfile({required this.id, required this.name, required this.url});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'url': url};

  factory ServerProfile.fromJson(Map<String, dynamic> j) => ServerProfile(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        url: (j['url'] ?? '').toString(),
      );
}

class ServerProfiles {
  ServerProfiles._();

  static List<ServerProfile> all = [];
  static String? activeId;

  static ServerProfile? get active {
    for (final s in all) {
      if (s.id == activeId) return s;
    }
    return null;
  }

  /// هل المضيف شبكة محلية خاصة (يُسمح معها بـ http دون تشفير)؟
  static bool isPrivateHost(String host) {
    final h = host.toLowerCase();
    if (h == 'localhost' || h.endsWith('.local')) return true;
    final p = h.split('.');
    if (p.length != 4) return false;
    final n = p.map(int.tryParse).toList();
    if (n.any((x) => x == null || x < 0 || x > 255)) return false;
    final a = n[0]!, b = n[1]!;
    return a == 10 || a == 127 || (a == 192 && b == 168) || (a == 172 && b >= 16 && b <= 31);
  }

  /// يعيد العنوان منظّفاً، أو يرمي [FormatException] برسالة عربية.
  /// http مقبول للشبكة المحلية فقط؛ أي عنوان على الإنترنت يجب أن يكون https.
  static String normalize(String input) {
    var u = input.trim();
    if (u.isEmpty) throw const FormatException('أدخل عنوان الخادم');
    if (!u.contains('://')) u = 'https://$u';
    final uri = Uri.tryParse(u);
    if (uri == null || uri.host.isEmpty || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      throw const FormatException('عنوان غير صالح');
    }
    if (uri.scheme == 'http' && !isPrivateHost(uri.host)) {
      throw const FormatException(
          'اتصال http غير مشفر مسموح للشبكة المحلية فقط. استخدم https للخوادم على الإنترنت.');
    }
    return u.replaceAll(RegExp(r'/+$'), '');
  }

  static Future<void> load() async {
    try {
      final raw = await SecureStore.serversJson();
      if (raw != null && raw.isNotEmpty) {
        all = (jsonDecode(raw) as List)
            .map((e) => ServerProfile.fromJson(Map<String, dynamic>.from(e as Map)))
            .where((s) => s.id.isNotEmpty && s.url.isNotEmpty)
            .toList();
      }
    } catch (_) {
      all = [];
    }
    activeId = await SecureStore.activeServerId();
    if (all.isEmpty) {
      // أول تشغيل: الخادم المضمَّن وقت البناء يصبح الخادم الأول.
      final first = ServerProfile(
          id: const Uuid().v4(), name: 'الخادم الافتراضي', url: AppConfig.defaultBaseUrl);
      all = [first];
      activeId = first.id;
      await _persist();
    }
    if (active == null) activeId = all.first.id;
    AppConfig.baseUrl = active!.url;
    ApiClient.instance.useBaseUrl(active!.url);
  }

  static Future<void> _persist() async {
    await SecureStore.saveServersJson(jsonEncode(all.map((s) => s.toJson()).toList()));
    if (activeId != null) await SecureStore.setActiveServerId(activeId!);
  }

  static Future<ServerProfile> add(String name, String url) async {
    final clean = normalize(url);
    final s = ServerProfile(
        id: const Uuid().v4(), name: name.trim().isEmpty ? clean : name.trim(), url: clean);
    all = [...all, s];
    await _persist();
    return s;
  }

  static Future<void> remove(String id) async {
    if (all.length <= 1) return; // يبقى خادم واحد على الأقل
    final wasActive = activeId == id;
    all = all.where((s) => s.id != id).toList();
    if (wasActive) {
      await select(all.first.id);
    } else {
      await _persist();
    }
  }

  /// اختيار خادم نشط. الرموز مرتبطة بخادم بعينه، لذا تُمسح عند التبديل.
  static Future<void> select(String id) async {
    final s = all.firstWhere((x) => x.id == id);
    final changed = activeId != id;
    activeId = id;
    await _persist();
    AppConfig.baseUrl = s.url;
    ApiClient.instance.useBaseUrl(s.url);
    if (changed) await ApiClient.instance.clearTokens();
  }
}
