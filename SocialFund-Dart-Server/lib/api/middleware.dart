import 'dart:convert';
import 'dart:io' show HttpConnectionInfo;
import 'package:shelf/shelf.dart';
import '../core/auth.dart';
import '../db/database.dart';
import '../services/audit_service.dart';
import '../services/session_service.dart';
import 'authorization.dart';

const _cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
};

Middleware corsMiddleware() => (inner) => (req) async {
  if (req.method == 'OPTIONS') return Response.ok('', headers: _cors);
  final res = await inner(req);
  return res.change(headers: {...res.headers, ..._cors});
};

/// يسجّل كل عملية كتابة ناجحة (من فعل ماذا ومتى) في سجل العمليات.
/// الدخول والخروج يُسجَّلان في مساراتهما؛ ورموز الإشعارات لا تُسجَّل.
Middleware auditMiddleware(AppDatabase db) => (inner) => (req) async {
  var res = await inner(req);
  final m = req.method;
  final isWrite = m == 'POST' || m == 'PUT' || m == 'PATCH' || m == 'DELETE';
  final path = '/' + req.url.path;
  if (isWrite && res.statusCode < 400 &&
      !path.startsWith('/auth/') && !path.startsWith('/push/')) {
    var (action, resource, id, summary) = AuditService.describe(m, path);
    if (action == 'create' && id == null) {
      // معرّف السجل الجديد يأتي في جسم الرد (الجسم يُقرأ مرة واحدة ثم يُعاد تركيبه).
      final text = await res.readAsString();
      res = res.change(body: text);
      try {
        final j = jsonDecode(text);
        if (j is Map && j['id'] is String) {
          id = j['id'] as String;
          final short = id.length > 8 ? id.substring(0, 8) : id;
          summary = '$summary ($short)';
        }
      } catch (_) {}
    }
    final info = req.context['shelf.io.connection_info'];
    await AuditService.log(
      db,
      userId: req.context['userId'] as String?,
      action: action, resourceType: resource, resourceId: id, summary: summary,
      ip: info is HttpConnectionInfo ? info.remoteAddress.address : null,
    );
  }
  return res;
};

/// ترويسات أمان أساسية لكل رد (الواجهة تطبيق جوال، لكن المسارات قد تُفتح في متصفح).
Middleware securityHeadersMiddleware() => (inner) => (req) async {
  final res = await inner(req);
  return res.change(headers: {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'Referrer-Policy': 'no-referrer',
    'Cache-Control': 'no-store',
    ...res.headers,
  });
};

Middleware jsonErrorMiddleware() => (inner) => (req) async {
  try { return await inner(req); }
  catch (e, st) {
    print('ERR: ' + e.toString() + '\n' + st.toString());
    return Response.internalServerError(
      body: jsonEncode({'detail': 'Internal server error'}),
      headers: {'Content-Type': 'application/json', ..._cors},
    );
  }
};

Middleware loggingMiddleware() => (inner) => (req) async {
  final sw = Stopwatch()..start();
  final res = await inner(req);
  print(req.method + ' /' + req.url.path + ' -> ' + res.statusCode.toString() + ' (' + sw.elapsedMilliseconds.toString() + 'ms)');
  return res;
};

Middleware authMiddleware({bool required = true}) => (inner) => (req) async {
  final header = req.headers['authorization'] ?? '';
  final token = header.startsWith('Bearer ') ? header.substring(7) : null;
  if (token == null) {
    if (required) return jsonErr(401, 'Missing auth token');
    return inner(req);
  }
  final userId = TokenService.verifyAccess(token);
  if (userId == null) return jsonErr(401, 'Invalid token');
  final claims = TokenService.decodeAccess(token);
  return inner(req.change(context: {...req.context, 'userId': userId, 'role': claims?['role']}));
};

/// يطبّق المصادقة على كل المسارات ما عدا:
///   - OPTIONS (طلبات CORS preflight لا تحمل توكن)
///   - /health و /api/health
///   - /auth/*
Middleware authIfApiMiddleware(AppDatabase db) => (inner) => (req) async {
  // 1) دع OPTIONS يمر دائمًا (CORS preflight)
  if (req.method == 'OPTIONS') return inner(req);

  final path = '/' + req.url.path;
  if (path == '/health' || path == '/api/health') return inner(req);
  // مسارات الدخول فقط عامة. باقي /auth/* (me, change-password, logout-all)
  // تتطلب توكناً صالحاً وإلا لا يُعرف المستخدم (كان يتعطل تغيير كلمة المرور).
  const publicAuth = {'/auth/login', '/auth/refresh', '/auth/verify-otp', '/auth/logout'};
  if (publicAuth.contains(path)) return inner(req);

  final header = req.headers['authorization'] ?? '';
  final token = header.startsWith('Bearer ') ? header.substring(7) : null;
  if (token == null) return jsonErr(401, 'Missing auth token');
  final userId = TokenService.verifyAccess(token);
  if (userId == null) return jsonErr(401, 'Invalid or expired token');
  final claims = TokenService.decodeAccess(token);
  final sid = claims?['sid'] as String?;
  // الجلسة قائمة في القاعدة (الخروج/تغيير كلمة المرور/التعطيل تسري فوراً)،
  // والدور يُقرأ من القاعدة لا من التوكن (تغيير الدور يسري فوراً).
  if (sid == null || !await SessionService(db).isActive(sid, userId)) {
    return jsonErr(401, 'انتهت الجلسة، سجّل الدخول من جديد');
  }
  final user = await (db.select(db.users)..where((t) => t.id.equals(userId))).getSingleOrNull();
  if (user == null || !user.isActive) return jsonErr(401, 'الحساب معطّل');
  final role = user.role;
  // فرض الصلاحيات في الخادم؛ مسارات /auth/* المتبقية لأي مستخدم مسجَّل.
  if (!path.startsWith('/auth/') && !Authorization.allowed(role, req.method, path)) {
    return jsonErr(403, 'ليست لديك صلاحية لتنفيذ هذه العملية');
  }
  return inner(req.change(context: {
    ...req.context, 'userId': userId, 'role': role, 'sid': sid,
  }));
};

Response jsonOk(Object? data) => Response.ok(
  jsonEncode(data),
  headers: {'Content-Type': 'application/json; charset=utf-8', ..._cors},
);

Response jsonErr(int status, String message) => Response(
  status, body: jsonEncode({'detail': message}),
  headers: {'Content-Type': 'application/json; charset=utf-8', ..._cors},
);
