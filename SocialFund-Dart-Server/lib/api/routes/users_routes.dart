import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../db/repositories/users_full_repository.dart';
import '../middleware.dart';

class UsersRoutes {
  final AppDatabase db;
  UsersRoutes(this.db);

  Router get router {
    final r = Router();
    final repo = UsersFullRepository(db);

    r.get('/users', (Request req) async {
      final list = await repo.list();
      return jsonOk(list.map(_toJson).toList());
    });

    r.get('/users/colleagues', (Request req) async {
      final uid = req.context['userId'] as String? ?? '';
      final list = await repo.colleagues(uid);
      return jsonOk(list.map(_toColleague).toList());
    });

    r.post('/users', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final username = (b['username'] ?? '').toString().trim();
      final password = (b['password'] ?? '').toString();
      final fullName = (b['full_name'] ?? '').toString().trim();
      final role = (b['role'] ?? 'viewer').toString();
      if (username.isEmpty || password.isEmpty || fullName.isEmpty) {
        return jsonErr(400, 'username, password, full_name required');
      }
      if (password.length < 8) return jsonErr(400, 'كلمة المرور 8 أحرف على الأقل');
      if (!const {'admin', 'accountant', 'reviewer', 'viewer'}.contains(role)) {
        return jsonErr(400, 'دور غير صالح');
      }
      try {
        final u = await repo.create(
          username: username, password: password, fullName: fullName,
          role: role, phone: b['phone'] as String?,
        );
        return jsonOk(_toJson(u));
      } catch (e) {
        return jsonErr(400, 'تعذر إنشاء المستخدم: ${e.toString().contains('UNIQUE') ? "اسم المستخدم موجود" : e}');
      }
    });

    r.put('/users/<id>', (Request req, String id) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final newRole = b['role'] as String?;
      if (newRole != null && !const {'admin', 'accountant', 'reviewer', 'viewer'}.contains(newRole)) {
        return jsonErr(400, 'دور غير صالح');
      }
      // منع المدير من قفل النظام بتعطيل حسابه أو خفض دوره بنفسه.
      if (id == req.context['userId'] &&
          (b['is_active'] == false || (newRole != null && newRole != 'admin'))) {
        return jsonErr(400, 'لا يمكنك تعطيل حسابك أو خفض صلاحياتك بنفسك');
      }
      final u = await repo.update(id,
        fullName: b['full_name'] as String?,
        role: b['role'] as String?,
        phone: b['phone'] as String?,
        isActive: b['is_active'] as bool?,
      );
      if (u == null) return jsonErr(404, 'User not found');
      return jsonOk(_toJson(u));
    });

    r.delete('/users/<id>', (Request req, String id) async {
      if (id == req.context['userId']) return jsonErr(400, 'لا يمكن حذف حسابك الحالي');
      final ok = await repo.softDelete(id);
      if (!ok) return jsonErr(404, 'User not found');
      return jsonOk({'ok': true});
    });

    return r;
  }

  static Map<String, dynamic> _toJson(User u) => {
    'id': u.id, 'username': u.username, 'full_name': u.fullName,
    'role': u.role, 'is_active': u.isActive, 'phone': u.phone,
  };

  static Map<String, dynamic> _toColleague(User u) => {
    'id': u.id, 'username': u.username, 'full_name': u.fullName,
    'role': u.role,
    'avatar_initial': u.fullName.isNotEmpty ? u.fullName[0] : '?',
  };
}
