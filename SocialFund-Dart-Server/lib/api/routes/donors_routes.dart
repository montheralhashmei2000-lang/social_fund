import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../db/repositories/donors_repository.dart';
import '../middleware.dart';

class DonorsRoutes {
  final AppDatabase db;
  DonorsRoutes(this.db);
  Router get router {
    final r = Router();
    final repo = DonorsRepository(db);
    r.get('/donors', (Request req) async {
      final list = await repo.list();
      final receipts = await (db.select(db.vouchers)
            ..where((t) => t.donorId.isNotNull() & t.deleted.equals(false) & t.status.equals('معتمد')))
          .get();
      final totals = <String, int>{};
      for (final v in receipts) {
        totals[v.donorId!] = (totals[v.donorId!] ?? 0) + v.amount;
      }
      return jsonOk(list.map((d) => {
        'id': d.id, 'name': d.name,
        'donor_type': d.donorType, 'donor_type_label': d.donorType,
        'tier': d.tier, 'tier_label': d.tier,
        'phone': d.phone, 'email': d.email, 'notes': d.notes,
        'is_active': d.isActive, 'total_donated': totals[d.id] ?? 0,
      }).toList());
    });
    r.post('/donors', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final name = (b['name'] ?? '').toString();
      if (name.isEmpty) return jsonErr(400, 'name required');
      final d = await repo.create(name: name,
        donorType: (b['donor_type'] ?? 'individual').toString(),
        tier: (b['tier'] ?? 'silver').toString(),
        phone: b['phone'] as String?, email: b['email'] as String?,
        notes: b['notes'] as String?);
      return jsonOk({'id': d.id, 'name': d.name});
    });
    return r;
  }
}
