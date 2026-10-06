// lib/core/auth.dart
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart' as c;
import 'config.dart';

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  AuthTokens({required this.accessToken, required this.refreshToken, required this.expiresIn});
}

class TokenService {
  static const _accessTtl = Duration(minutes: 30);
  static const _refreshTtl = Duration(days: 30);
  static final Random _rng = Random.secure();

  static String _b64(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  static List<int> _sign(String data) {
    final mac = c.Hmac(c.sha256, utf8.encode(ServerConfig.jwtSecret));
    return mac.convert(utf8.encode(data)).bytes;
  }

  static String _encodeSegment(Map<String, dynamic> obj) =>
      _b64(utf8.encode(jsonEncode(obj)));

  /// معرّف جلسة عشوائي آمن (يُستخدم كـ sid في الوصول وjti في التجديد).
  static String newSessionId() => _b64(List<int>.generate(24, (_) => _rng.nextInt(256)));

  static AuthTokens issue({
    required String userId,
    required String role,
    required String sessionId,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final header = _encodeSegment({'alg': 'HS256', 'typ': 'JWT'});
    final payload = _encodeSegment({
      'sub': userId,
      'role': role,
      'type': 'access',
      'sid': sessionId,
      'iat': now,
      'exp': now + _accessTtl.inSeconds,
    });
    final signing = '$header.$payload';
    final sig = _b64(_sign(signing));
    final access = '$signing.$sig';

    // توكن التجديد: JWT موقَّع بمعرّف عشوائي آمن (jti) وانتهاء صلاحية.
    // سابقاً كان `hash.base64(userId)` دون أي تحقق ← يمكن تزويره لأي مستخدم.
    final refreshHeader = _encodeSegment({'alg': 'HS256', 'typ': 'JWT'});
    final refreshPayload = _encodeSegment({
      'sub': userId,
      'type': 'refresh',
      'jti': sessionId,
      'iat': now,
      'exp': now + _refreshTtl.inSeconds,
    });
    final refreshSigning = '$refreshHeader.$refreshPayload';
    final refresh = '$refreshSigning.${_b64(_sign(refreshSigning))}';

    return AuthTokens(
      accessToken: access,
      refreshToken: refresh,
      expiresIn: _accessTtl.inSeconds,
    );
  }

  static Map<String, dynamic>? _decodePayload(String payloadB64) {
    try {
      final padded = payloadB64 + '=' * ((4 - payloadB64.length % 4) % 4);
      return jsonDecode(utf8.decode(base64Url.decode(padded))) as Map<String, dynamic>;
    } catch (_) { return null; }
  }

  static String? verifyAccess(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final signing = '${parts[0]}.${parts[1]}';
      final expected = _b64(_sign(signing));
      if (!_constantTimeEquals(expected, parts[2])) return null;
      final payload = _decodePayload(parts[1]);
      if (payload == null) return null;
      if (payload['type'] != 'access') return null;
      final exp = payload['exp'] as int?;
      if (exp == null) return null;
      if (DateTime.now().millisecondsSinceEpoch ~/ 1000 > exp) return null;
      return payload['sub'] as String?;
    } catch (_) { return null; }
  }

  /// يتحقق من توقيع توكن التجديد وصلاحيته ويعيد حمولته (sub, jti…)، أو null.
  static Map<String, dynamic>? refreshClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final expected = _b64(_sign('${parts[0]}.${parts[1]}'));
      if (!_constantTimeEquals(expected, parts[2])) return null;
      final payload = _decodePayload(parts[1]);
      if (payload == null || payload['type'] != 'refresh') return null;
      final exp = payload['exp'] as int?;
      if (exp == null || DateTime.now().millisecondsSinceEpoch ~/ 1000 > exp) return null;
      return payload;
    } catch (_) { return null; }
  }

  /// معرّف المستخدم من توكن تجديد صالح التوقيع، أو null.
  static String? verifyRefresh(String token) => refreshClaims(token)?['sub'] as String?;

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  static Map<String, dynamic>? decodeAccess(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      return _decodePayload(parts[1]);
    } catch (_) { return null; }
  }

  static String hashRefresh(String raw) => _b64(_sign(raw));
}
