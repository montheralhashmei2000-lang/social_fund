import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../core/auth.dart';
import '../../core/password.dart';
import '../../db/database.dart';
import '../../db/repositories/users_repository.dart';
import '../../services/session_service.dart';
import '../middleware.dart';

/// حدّ محاولات الدخول الفاشلة لكل اسم مستخدم (في الذاكرة): 5 محاولات / 15 دقيقة.
class _LoginThrottle {
  static const _max = 5;
  static const _window = Duration(minutes: 15);
  static final Map<String, List<DateTime>> _fails = {};

  static bool blocked(String key) {
    final list = _fails[key];
    if (list == null) return false;
    final cutoff = DateTime.now().subtract(_window);
    list.removeWhere((t) => t.isBefore(cutoff));
    if (list.isEmpty) _fails.remove(key);
    return list.length >= _max;
  }

  static const _maxKeys = 5000;

  static void fail(String key) {
    if (_fails.length >= _maxKeys && !_fails.containsKey(key)) {
      // سقف للذاكرة: أسماء مستخدمين عشوائية كثيرة لا تُضخّم الخريطة بلا حد.
      final cutoff = DateTime.now().subtract(_window);
      _fails.removeWhere((_, l) => l.every((t) => t.isBefore(cutoff)));
      if (_fails.length >= _maxKeys) _fails.remove(_fails.keys.first);
    }
    _fails.putIfAbsent(key, () => []).add(DateTime.now());
  }
  static void clear(String key) => _fails.remove(key);
}

String? _dummyHash;

class AuthRoutes {
  final AppDatabase db;
  AuthRoutes(this.db);

  Router get router {
    final r = Router();

    r.post('/auth/login', (Request req) async {
      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final username = (body['username'] ?? '').toString().trim();
      final password = (body['password'] ?? '').toString();
      if (username.isEmpty || password.isEmpty) return jsonErr(400, 'Missing credentials');
      final key = username.toLowerCase();
      if (_LoginThrottle.blocked(key)) {
        return jsonErr(429, 'محاولات دخول كثيرة. حاول بعد قليل.');
      }
      final repo = UsersRepository(db);
      final user = await repo.byUsername(username);
      if (user == null || !user.isActive) {
        // نفس زمن التحقق الفعلي حتى لا يُكشف وجود اسم المستخدم من سرعة الرد.
        _dummyHash ??= await hashPassword('timing-equalizer');
        await verifyPassword(password, _dummyHash!);
        _LoginThrottle.fail(key);
        return jsonErr(401, 'Invalid credentials');
      }
      final ok = await verifyPassword(password, user.passwordHash);
      if (!ok) {
        _LoginThrottle.fail(key);
        return jsonErr(401, 'Invalid credentials');
      }
      _LoginThrottle.clear(key);
      final t = await SessionService(db).start(user, deviceId: body['device_id'] as String?);
      return jsonOk({
        'access_token': t.accessToken,
        'refresh_token': t.refreshToken,
        'token_type': 'bearer',
        'expires_in': t.expiresIn,
        'user': _userJson(user),
      });
    });

    r.post('/auth/refresh', (Request req) async {
      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final refresh = (body['refresh_token'] ?? '').toString();
      if (refresh.isEmpty) return jsonErr(400, 'refresh_token required');
      final rotated = await SessionService(db).rotate(refresh);
      if (rotated == null) return jsonErr(401, 'Invalid refresh token');
      final t = rotated.tokens;
      return jsonOk({
        'access_token': t.accessToken,
        'refresh_token': t.refreshToken,
        'token_type': 'bearer',
        'expires_in': t.expiresIn,
      });
    });

    // خروج: يُبطل جلسة توكن التجديد المُرسَل (عام: التوكن قد يكون انتهى).
    r.post('/auth/logout', (Request req) async {
      try {
        final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
        final refresh = (body['refresh_token'] ?? '').toString();
        if (refresh.isNotEmpty) await SessionService(db).revoke(refresh);
      } catch (_) {/* الخروج لا يفشل */}
      return jsonOk({'ok': true});
    });

    // إنهاء كل جلسات المستخدم على كل الأجهزة (بما فيها الحالية).
    r.post('/auth/logout-all', (Request req) async {
      final userId = req.context['userId'] as String?;
      if (userId == null) return jsonErr(401, 'Unauthorized');
      await SessionService(db).revokeAll(userId);
      return jsonOk({'ok': true});
    });

    // ============ /auth/me ============
    r.get('/auth/me', (Request req) async {
      final header = req.headers['authorization'] ?? '';
      final token = header.startsWith('Bearer ') ? header.substring(7) : null;
      if (token == null || token.isEmpty) return jsonErr(401, 'Unauthorized');
      final userId = TokenService.verifyAccess(token);
      if (userId == null) return jsonErr(401, 'Unauthorized');
      final repo = UsersRepository(db);
      final user = await repo.byId(userId);
      if (user == null || !user.isActive) return jsonErr(404, 'User not found');
      return jsonOk(_userJson(user));
    });

    r.post('/auth/change-password', (Request req) async {
      final userId = req.context['userId'] as String?;
      if (userId == null) return jsonErr(401, 'Unauthorized');
      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final oldPw = (body['old_password'] ?? '').toString();
      final newPw = (body['new_password'] ?? '').toString();
      if (oldPw.isEmpty || newPw.length < 8) {
        return jsonErr(400, 'old_password و new_password (8 أحرف على الأقل) مطلوبان');
      }
      final repo = UsersRepository(db);
      final user = await repo.byId(userId);
      if (user == null) return jsonErr(404, 'User not found');
      final ok = await verifyPassword(oldPw, user.passwordHash);
      if (!ok) return jsonErr(400, 'كلمة المرور الحالية غير صحيحة');
      final newHash = await hashPassword(newPw);
      await (db.update(db.users)..where((t) => t.id.equals(userId)))
          .write(UsersCompanion(passwordHash: Value(newHash), updatedAt: Value(DateTime.now())));
      // تغيير كلمة المرور يُنهي بقية الجلسات (جهاز مسروق/مخترق) ويُبقي الحالية.
      await SessionService(db).revokeAll(userId, exceptSid: req.context['sid'] as String?);
      return jsonOk({'ok': true});
    });

    // verify-otp: معطل حالياً - نعيد خطأ واضح
    r.post('/auth/verify-otp', (Request req) async {
      return jsonErr(400, 'OTP غير مفعل. استخدم كلمة المرور فقط.');
    });

    return r;
  }

  static Map<String, dynamic> _userJson(User u) => {
    'id': u.id,
    'username': u.username,
    'full_name': u.fullName,
    'role': u.role,
    'avatar_initial': u.fullName.isNotEmpty ? u.fullName[0] : '?',
    'phone': u.phone,
    'otp_enabled': false,
  };
}
