import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../middleware.dart';

class BudgetsRoutes {
  final AppDatabase db;
  BudgetsRoutes(this.db);
  Router get router {
    final r = Router();
    r.get('/budgets/<period>/report', (Request req, String period) async => jsonOk({'rows': []}));
    r.post('/budgets', (Request req) async => jsonOk({'ok': true}));
    return r;
  }
}
