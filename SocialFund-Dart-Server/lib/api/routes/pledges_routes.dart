import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import '../../db/database.dart';
import '../middleware.dart';

class PledgesRoutes {
  final AppDatabase db;
  PledgesRoutes(this.db);
  Router get router {
    final r = Router();
    r.get('/pledges', (Request req) async {
      final list = await db.select(db.pledges).get();
      return jsonOk(list.map((p) => {
        'id': p.id, 'donor_id': p.donorId, 'donor_name': '',
        'amount': p.amount, 'frequency': p.frequency,
        'frequency_label': p.frequency,
        'start_date': p.startDate, 'end_date': p.endDate,
        'status': p.status, 'last_fulfilled_on': p.lastFulfilledOn,
        'notes': p.notes, 'days_overdue': 0,
      }).toList());
    });
    r.get('/pledges/due', (Request req) async {
      final list = await (db.select(db.pledges)
            ..where((t) => t.status.equals('active')))
          .get();
      return jsonOk(list.map((p) => {
        'id': p.id, 'donor_id': p.donorId, 'donor_name': '',
        'amount': p.amount, 'frequency': p.frequency,
        'frequency_label': p.frequency,
        'start_date': p.startDate, 'end_date': p.endDate,
        'status': p.status, 'days_overdue': 0,
      }).toList());
    });
    r.post('/pledges', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final donorId = (b['donor_id'] ?? '').toString();
      final amount = (b['amount'] as num?)?.toDouble() ?? 0;
      final start = (b['start_date'] ?? '').toString();
      if (donorId.isEmpty || amount <= 0 || start.isEmpty) {
        return jsonErr(400, 'donor_id, amount, start_date required');
      }
      final id = const Uuid().v4();
      await db.into(db.pledges).insert(PledgesCompanion.insert(
        id: id, donorId: donorId, amount: amount, startDate: start,
        frequency: Value((b['frequency'] ?? 'monthly').toString()),
        endDate: Value(b['end_date'] as String?),
        notes: Value(b['notes'] as String?),
        createdAt: DateTime.now(),
      ));
      return jsonOk({'id': id});
    });
    r.post('/pledges/<id>/fulfill', (Request req, String id) async {
      await (db.update(db.pledges)..where((t) => t.id.equals(id))).write(
        PledgesCompanion(
          lastFulfilledOn: Value(DateTime.now().toIso8601String().substring(0, 10)),
        ),
      );
      return jsonOk({'ok': true});
    });
    return r;
  }
}
