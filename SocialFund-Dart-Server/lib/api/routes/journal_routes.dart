import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../db/repositories/journal_repository.dart';
import '../middleware.dart';

class JournalRoutes {
  final AppDatabase db;
  JournalRoutes(this.db);
  Router get router {
    final r = Router();
    final repo = JournalRepository(db);

    r.get('/journal', (Request req) async {
      final limit = int.tryParse(req.url.queryParameters['limit'] ?? '') ?? 200;
      final list = await repo.list(limit: limit);
      return jsonOk(list);
    });

    r.get('/journal/entry-types', (Request req) async => jsonOk([
      {'key': 'general', 'label': 'قيد عام'},
      {'key': 'voucher_receipt', 'label': 'سند قبض'},
      {'key': 'voucher_payment', 'label': 'سند صرف'},
      {'key': 'transfer', 'label': 'تحويل'},
    ]));

    return r;
  }
}
