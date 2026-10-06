import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';

class EventsRepository {
  final AppDatabase db;
  EventsRepository(this.db);

  Future<List<Event>> list() =>
      (db.select(db.events)
            ..where((t) => t.deleted.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.eventDate)]))
          .get();

  Future<Event> create({
    required String title, required String eventDate,
    String? eventTime, String? place, String? type,
    String color = '#1B5E20',
  }) async {
    final now = DateTime.now();
    final id = const Uuid().v4();
    await db.into(db.events).insert(EventsCompanion.insert(
      id: id, title: title, eventDate: eventDate,
      eventTime: Value(eventTime), place: Value(place), type: Value(type),
      color: Value(color), createdAt: now, updatedAt: now,
    ));
    return (await (db.select(db.events)..where((t) => t.id.equals(id))).getSingle());
  }

  Future<bool> softDelete(String id) async {
    final n = await (db.update(db.events)..where((t) => t.id.equals(id)))
        .write(EventsCompanion(deleted: const Value(true), updatedAt: Value(DateTime.now())));
    return n > 0;
  }
}
