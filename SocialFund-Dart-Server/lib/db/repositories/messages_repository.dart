import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';

class MessagesRepository {
  final AppDatabase db;
  MessagesRepository(this.db);

  Future<List<Message>> inbox(String userId) =>
      (db.select(db.messages)
            ..where((t) => t.toUserId.equals(userId) & t.deleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<Message> create({
    required String fromUserId, required String fromName,
    required String toUserId, required String toName, required String body,
  }) async {
    final now = DateTime.now();
    final id = const Uuid().v4();
    await db.into(db.messages).insert(MessagesCompanion.insert(
      id: id, fromUserId: fromUserId, fromName: fromName,
      toUserId: toUserId, toName: toName, body: body,
      createdAt: now, updatedAt: now,
    ));
    return (await (db.select(db.messages)..where((t) => t.id.equals(id))).getSingle());
  }

  Future<bool> markRead(String id) async {
    final n = await (db.update(db.messages)..where((t) => t.id.equals(id)))
        .write(MessagesCompanion(
      read: const Value(true), updatedAt: Value(DateTime.now()),
    ));
    return n > 0;
  }
}
