import 'package:drift/drift.dart';
import '../core/auth.dart';
import '../db/database.dart';

/// جلسات الدخول المخزَّنة في قاعدة البيانات (جدول refresh_sessions).
///
/// - كل دخول ينشئ جلسة بمعرّف عشوائي (sid)؛ يوضع في توكن الوصول (sid) وتوكن
///   التجديد (jti).
/// - كل طلب يتحقق أن الجلسة قائمة وغير مُبطلة، فيسري الخروج وتغيير كلمة المرور
///   وتعطيل المستخدم فوراً (لا انتظار لانتهاء توكن الوصول).
/// - التجديد يدوّر التوكن: القديم يُبطل. إعادة استخدام توكن مُبطل (سرقة محتملة)
///   تُبطل كل جلسات المستخدم.
class SessionService {
  final AppDatabase db;
  SessionService(this.db);

  static const _refreshTtl = Duration(days: 30);

  Future<AuthTokens> start(User user, {String? ip, String? deviceId}) async {
    final sid = TokenService.newSessionId();
    final now = DateTime.now();
    await db.into(db.refreshSessions).insert(RefreshSessionsCompanion.insert(
      id: sid,
      userId: user.id,
      tokenHash: TokenService.hashRefresh(sid),
      deviceId: Value(deviceId),
      ipAddress: Value(ip),
      expiresAt: now.add(_refreshTtl),
      createdAt: now,
    ));
    // تنظيف الجلسات المنتهية/المُبطلة القديمة لهذا المستخدم (يبقي الجدول صغيراً)
    await (db.delete(db.refreshSessions)
          ..where((t) =>
              t.userId.equals(user.id) &
              (t.expiresAt.isSmallerThanValue(now) |
                  (t.revoked.equals(true) &
                      t.createdAt.isSmallerThanValue(now.subtract(const Duration(days: 7)))))))
        .go();
    return TokenService.issue(userId: user.id, role: user.role, sessionId: sid);
  }

  /// يدوّر توكن التجديد. null = غير صالح (مزوَّر/منتهٍ/مُبطل/مستخدم معطّل).
  Future<({AuthTokens tokens, User user})?> rotate(String refreshToken,
      {String? ip}) async {
    final claims = TokenService.refreshClaims(refreshToken);
    if (claims == null) return null;
    final userId = claims['sub'] as String?;
    final sid = claims['jti'] as String?;
    if (userId == null || sid == null) return null;

    final session = await (db.select(db.refreshSessions)..where((t) => t.id.equals(sid)))
        .getSingleOrNull();
    if (session == null || session.userId != userId) return null;
    if (session.revoked) {
      // توكن سبق تدويره ثم استُخدم ثانية: قد يكون مسروقاً → إنهاء كل الجلسات.
      await revokeAll(userId);
      return null;
    }
    if (session.expiresAt.isBefore(DateTime.now())) return null;

    final user = await (db.select(db.users)..where((t) => t.id.equals(userId))).getSingleOrNull();
    if (user == null || !user.isActive) return null;

    await (db.update(db.refreshSessions)..where((t) => t.id.equals(sid)))
        .write(const RefreshSessionsCompanion(revoked: Value(true)));
    final tokens = await start(user, ip: ip, deviceId: session.deviceId);
    return (tokens: tokens, user: user);
  }

  /// خروج: يُبطل جلسة هذا التوكن فقط.
  Future<void> revoke(String refreshToken) async {
    final sid = TokenService.refreshClaims(refreshToken)?['jti'] as String?;
    if (sid == null) return;
    await (db.update(db.refreshSessions)..where((t) => t.id.equals(sid)))
        .write(const RefreshSessionsCompanion(revoked: Value(true)));
  }

  /// يُبطل كل جلسات المستخدم، مع استثناء جلسة واحدة اختيارياً (الحالية).
  Future<void> revokeAll(String userId, {String? exceptSid}) async {
    final q = db.update(db.refreshSessions)
      ..where((t) => t.userId.equals(userId) &
          (exceptSid == null ? const Constant(true) : t.id.equals(exceptSid).not()));
    await q.write(const RefreshSessionsCompanion(revoked: Value(true)));
  }

  /// هل الجلسة قائمة؟ (تُستدعى في كل طلب)
  Future<bool> isActive(String sid, String userId) async {
    final s = await (db.select(db.refreshSessions)..where((t) => t.id.equals(sid)))
        .getSingleOrNull();
    return s != null &&
        s.userId == userId &&
        !s.revoked &&
        s.expiresAt.isAfter(DateTime.now());
  }
}
