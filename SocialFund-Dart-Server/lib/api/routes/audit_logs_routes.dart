import 'package:drift/drift.dart' show OrderingTerm;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../middleware.dart';

class AuditLogsRoutes {
  final AppDatabase db;
  AuditLogsRoutes(this.db);

  Router get router {
    final r = Router();

    r.get('/audit-logs', (Request req) async {
      final limit = int.tryParse(req.url.queryParameters['limit'] ?? '') ?? 200;
      final rows = await (db.select(db.auditLogs)
            ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
            ..limit(limit))
          .get();
      return jsonOk(rows.map((a) => {
        'id': a.id,
        'timestamp': a.timestamp.toIso8601String(),
        'user_id': a.userId,
        'user_name': a.userName,
        'action': a.action,
        'resource_type': a.resourceType,
        'resource_id': a.resourceId,
        'summary': a.summary,
        'ip_address': a.ipAddress,
      }).toList());
    });

    return r;
  }
}

