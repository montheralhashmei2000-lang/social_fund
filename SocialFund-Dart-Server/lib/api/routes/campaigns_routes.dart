import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../db/repositories/campaigns_repository.dart';
import '../middleware.dart';

class CampaignsRoutes {
  final AppDatabase db;
  CampaignsRoutes(this.db);
  Router get router {
    final r = Router();
    final repo = CampaignsRepository(db);
    r.get('/campaigns', (Request req) async {
      final list = await repo.list();
      return jsonOk(list.map((c) => {
        'id': c.id, 'name': c.name, 'description': c.description,
        'status': c.status, 'start_date': c.startDate, 'end_date': c.endDate,
        'goal_amount': c.goalAmount, 'raised': 0, 'spent': 0, 'net': 0, 'percent': 0,
      }).toList());
    });
    r.post('/campaigns', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final name = (b['name'] ?? '').toString();
      final goal = (b['goal_amount'] as num?)?.toDouble() ?? 0;
      final start = (b['start_date'] ?? '').toString();
      if (name.isEmpty || goal <= 0 || start.isEmpty) return jsonErr(400, 'name, goal_amount, start_date required');
      final c = await repo.create(name: name, goalAmount: goal, startDate: start,
        description: b['description'] as String?, endDate: b['end_date'] as String?);
      return jsonOk({'id': c.id, 'name': c.name});
    });
    r.post('/campaigns/<id>/close', (Request req, String id) async => jsonOk({'ok': true}));
    return r;
  }
}
