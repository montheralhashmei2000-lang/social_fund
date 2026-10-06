import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../middleware.dart';

class HealthRoutes {
  Router get router {
    final r = Router();
    r.get('/health', (Request req) => Response.ok(
      jsonEncode({'status': 'ok', 'service': 'social_fund_dart_server', 'time': DateTime.now().toIso8601String()}),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    ));
    r.get('/health', (Request req) => jsonOk({'status': 'ok'}));
    return r;
  }
}
