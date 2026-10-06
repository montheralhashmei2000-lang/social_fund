import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../middleware.dart';

class FinancialReportsRoutes {
  final AppDatabase db;
  FinancialReportsRoutes(this.db);
  Router get router {
    final r = Router();
    r.get('/financial-reports/<key>', (Request req, String key) async => jsonOk({'rows': []}));
    return r;
  }
}
