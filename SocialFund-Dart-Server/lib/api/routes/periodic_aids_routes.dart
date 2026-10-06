import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import '../../db/database.dart';
import '../middleware.dart';

class PeriodicAidsRoutes {
  final AppDatabase db;
  PeriodicAidsRoutes(this.db);
  Router get router {
    final r = Router();
    r.get('/periodic-aids', (Request req) async {
      final list = await db.select(db.periodicAids).get();
      return jsonOk(list.map((p) => {
        'id': p.id, 'beneficiary_id': p.beneficiaryId, 'beneficiary_name': '',
        'monthly_amount': p.monthlyAmount, 'started_on': p.startedOn,
        'status': p.status, 'last_paid_period': p.lastPaidPeriod,
        'due_period': p.lastPaidPeriod, 'notes': p.notes, 'days_overdue': 0,
      }).toList());
    });
    r.get('/periodic-aids/due', (Request req) async {
      final list = await (db.select(db.periodicAids)
            ..where((t) => t.status.equals('active')))
          .get();
      return jsonOk(list.map((p) => {
        'id': p.id, 'beneficiary_id': p.beneficiaryId, 'beneficiary_name': '',
        'monthly_amount': p.monthlyAmount, 'started_on': p.startedOn,
        'status': p.status, 'days_overdue': 0,
      }).toList());
    });
    r.post('/periodic-aids', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final beneficiaryId = (b['beneficiary_id'] ?? '').toString();
      final amount = (b['monthly_amount'] as num?)?.toDouble() ?? 0;
      final startedOn = (b['started_on'] ?? '').toString();
      if (beneficiaryId.isEmpty || amount <= 0 || startedOn.isEmpty) {
        return jsonErr(400, 'beneficiary_id, monthly_amount, started_on required');
      }
      final id = const Uuid().v4();
      await db.into(db.periodicAids).insert(PeriodicAidsCompanion.insert(
        id: id, beneficiaryId: beneficiaryId,
        monthlyAmount: amount, startedOn: startedOn,
        notes: Value(b['notes'] as String?),
        createdAt: DateTime.now(),
      ));
      return jsonOk({'id': id});
    });
    r.post('/periodic-aids/<id>/pay', (Request req, String id) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final period = (b['period'] ?? DateTime.now().toIso8601String().substring(0, 7)).toString();
      await (db.update(db.periodicAids)..where((t) => t.id.equals(id))).write(
        PeriodicAidsCompanion(lastPaidPeriod: Value(period)),
      );
      return jsonOk({'ok': true});
    });
    return r;
  }
}
