import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../db/repositories/messages_repository.dart';
import '../middleware.dart';

class MessagesRoutes {
  final AppDatabase db;
  MessagesRoutes(this.db);

  Router get router {
    final r = Router();
    final repo = MessagesRepository(db);

    r.get('/messages', (Request req) async {
      final uid = req.context['userId'] as String?;
      if (uid == null) return jsonOk([]);
      final list = await repo.inbox(uid);
      return jsonOk(list.map(_toJson).toList());
    });

    r.post('/messages', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final toUserId = (b['to_user_id'] ?? '').toString();
      final body = (b['body'] ?? '').toString();
      if (toUserId.isEmpty || body.isEmpty) return jsonErr(400, 'to_user_id and body required');
      final fromId = req.context['userId'] as String? ?? '';
      final sender = await (db.select(db.users)..where((t) => t.id.equals(fromId))).getSingleOrNull();
      final recipient = await (db.select(db.users)..where((t) => t.id.equals(toUserId))).getSingleOrNull();
      if (recipient == null || !recipient.isActive) return jsonErr(404, 'المستلم غير موجود');
      // الأسماء من قاعدة البيانات لا من العميل (منع انتحال اسم المرسل)
      final m = await repo.create(
        fromUserId: fromId, fromName: sender?.fullName ?? 'مستخدم',
        toUserId: toUserId, toName: recipient.fullName, body: body,
      );
      return jsonOk(_toJson(m));
    });

    r.put('/messages/<id>/read', (Request req, String id) async {
      await repo.markRead(id);
      return jsonOk({'ok': true});
    });

    return r;
  }

  static Map<String, dynamic> _toJson(Message m) => {
    'id': m.id, 'from_user_id': m.fromUserId, 'from_name': m.fromName,
    'to_user_id': m.toUserId, 'to_name': m.toName,
    'body': m.body, 'read': m.read,
  };
}
