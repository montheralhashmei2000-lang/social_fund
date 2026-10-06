import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../middleware.dart';

class InKindRoutes {
  final AppDatabase db;
  InKindRoutes(this.db);
  Router get router {
    final r = Router();
    r.get('/inkind/items', (Request req) async => jsonOk([]));
    r.post('/inkind/items', (Request req) async => jsonOk({'ok': true}));
    r.post('/inkind/movements', (Request req) async => jsonOk({'ok': true}));
    return r;
  }
}
