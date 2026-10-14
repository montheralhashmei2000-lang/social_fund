import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../db/database.dart';

/// سجل العمليات: من فعل ماذا ومتى. يُكتب لكل عملية كتابة ناجحة (عبر وسيط التدقيق)
/// ولأحداث الدخول. فشل التسجيل لا يُفشل الطلب الأصلي أبداً.
class AuditService {
  AuditService._();

  static Future<void> log(
    AppDatabase db, {
    String? userId,
    String? userName,
    required String action,
    required String resourceType,
    String? resourceId,
    String? summary,
    String? ip,
  }) async {
    try {
      var name = userName;
      if (name == null && userId != null) {
        final u = await (db.select(db.users)..where((t) => t.id.equals(userId))).getSingleOrNull();
        name = u?.fullName;
      }
      await db.into(db.auditLogs).insert(AuditLogsCompanion.insert(
            id: const Uuid().v4(),
            timestamp: DateTime.now(),
            action: action,
            resourceType: resourceType,
            userId: Value(userId),
            userName: Value(name),
            resourceId: Value(resourceId),
            summary: Value(summary),
            ipAddress: Value(ip),
          ));
    } catch (_) {/* التدقيق لا يعطّل العمل */}
  }

  static const _resourceAr = {
    'members': 'عضو', 'aids': 'طلب مساعدة', 'subscriptions': 'اشتراك', 'treasury': 'حركة خزينة',
    'vouchers': 'سند', 'events': 'موعد', 'users': 'مستخدم', 'accounts': 'حساب', 'journal': 'قيد يومية',
    'budgets': 'موازنة', 'donors': 'مانح', 'pledges': 'تعهد', 'campaigns': 'حملة', 'beneficiaries': 'مستفيد',
    'periodic-aids': 'مساعدة دورية', 'inkind': 'مساعدة عينية', 'fund-settings': 'بيانات الصندوق',
    'currencies': 'عملة', 'currencies-config': 'إعدادات العملات', 'app-settings': 'إعدادات النظام',
    'backup': 'نسخة احتياطية', 'messages': 'رسالة',
  };

  /// ملخص عربي مقروء لعملية كتابة من طريقها: "إنشاء سند" / "تعديل طلب مساعدة (a1b2c3d4)".
  static (String action, String resource, String? id, String summary) describe(String method, String path) {
    final segs = path.split('/').where((s) => s.isNotEmpty).toList();
    final res = segs.isEmpty ? 'system' : segs.first;
    // المقطع الثاني معرّف سجل فقط إن بدا كمعرّف (uuid)؛ وإلا فهو اسم إجراء (seed-defaults…)
    final second = segs.length > 1 ? segs[1] : null;
    final isId = second != null && RegExp(r'^[0-9a-fA-F-]{16,}$').hasMatch(second);
    final id = isId ? second : null;
    final tail = segs.length > 2 ? segs.last : (!isId && second != null ? second : '');
    String action;
    String verb;
    if (method == 'DELETE') {
      action = 'delete';
      verb = 'حذف';
    } else if (method == 'POST' && tail.isEmpty) {
      action = 'create';
      verb = 'إنشاء';
    } else if (tail == 'seed-defaults') {
      action = 'create';
      verb = 'تهيئة الافتراضي لـ';
    } else if (tail == 'reset') {
      action = 'delete';
      verb = 'تصفير';
    } else if (tail == 'create' && res == 'backup') {
      action = 'export';
      verb = 'إنشاء';
    } else if (tail == 'void') {
      action = 'update';
      verb = 'إلغاء';
    } else if (tail == 'status') {
      action = 'update';
      verb = 'تغيير حالة';
    } else if (tail == 'pay') {
      action = 'update';
      verb = 'صرف';
    } else {
      action = 'update';
      verb = 'تعديل';
    }
    final label = _resourceAr[res] ?? res;
    final short = id != null && id.length > 8 ? id.substring(0, 8) : id;
    return (action, res, id, '$verb $label${short != null ? ' ($short)' : ''}');
  }
}
