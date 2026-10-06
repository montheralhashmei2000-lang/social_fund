import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../db/repositories/members_repository.dart';
import '../middleware.dart';

class MembersRoutes {
  final AppDatabase db;
  MembersRoutes(this.db);

  Router get router {
    final r = Router();
    final repo = MembersRepository(db);

    r.get('/members', (Request req) async {
      final q = req.url.queryParameters;
      final list = await repo.list(
        search: q['search'], limit: int.tryParse(q['limit'] ?? '') ?? 200,
        offset: int.tryParse(q['offset'] ?? '') ?? 0,
      );
      return jsonOk(list.map(_toJson).toList());
    });

    r.get('/members/<id>', (Request req, String id) async {
      final m = await repo.byId(id);
      if (m == null) return jsonErr(404, 'Member not found');
      return jsonOk(_toJson(m));
    });

    r.post('/members', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final name = (b['name'] ?? '').toString().trim();
      final nid = (b['national_id'] ?? '').toString().trim();
      final phone = (b['phone'] ?? '').toString().trim();
      if (name.isEmpty || nid.isEmpty || phone.isEmpty) {
        return jsonErr(400, 'name, national_id, phone are required');
      }
      try {
        final m = await repo.create(
          name: name, nationalId: nid, phone: phone,
          email: b['email'] as String?, city: b['city'] as String?,
          joinDate: b['join_date'] as String?,
          monthlySubscription: (b['monthly_subscription'] as num?)?.toInt() ?? 0,
        );
        return jsonOk(_toJson(m));
      } on DuplicateNationalIdException catch (e) {
        return jsonErr(409, e.message);
      }
    });

    r.put('/members/<id>', (Request req, String id) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final nid = (b['national_id'] as String?)?.trim();
      try {
        final m = await repo.update(id,
          name: b['name'] as String?,
          nationalId: (nid == null || nid.isEmpty) ? null : nid,
          phone: b['phone'] as String?,
          email: b['email'] as String?, city: b['city'] as String?,
          joinDate: b['join_date'] as String?,
          status: b['status'] as String?,
          monthlySubscription: (b['monthly_subscription'] as num?)?.toInt(),
        );
        if (m == null) return jsonErr(404, 'Member not found');
        return jsonOk(_toJson(m));
      } on DuplicateNationalIdException catch (e) {
        return jsonErr(409, e.message);
      }
    });

    r.delete('/members/<id>', (Request req, String id) async {
      final ok = await repo.softDelete(id);
      if (!ok) return jsonErr(404, 'Member not found');
      return jsonOk({'ok': true});
    });

    return r;
  }

  static Map<String, dynamic> _toJson(Member m) => {
    'id': m.id, 'name': m.name, 'national_id': m.nationalId,
    'phone': m.phone, 'email': m.email, 'city': m.city,
    'join_date': m.joinDate, 'status': m.status,
    'monthly_subscription': m.monthlySubscription,
    'total_paid': m.totalPaid, 'balance_due': m.balanceDue,
    'created_at': m.createdAt.toIso8601String(),
  };
}
