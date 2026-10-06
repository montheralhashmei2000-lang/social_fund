import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';

class CampaignsRepository {
  final AppDatabase db;
  CampaignsRepository(this.db);

  Future<List<Campaign>> list() =>
      (db.select(db.campaigns)..where((t) => t.status.equals('active').not()))
          .get()
          .then((_) => db.select(db.campaigns).get());

  Future<Campaign> create({required String name, required double goalAmount,
      required String startDate, String? description, String? endDate}) async {
    final id = const Uuid().v4();
    await db.into(db.campaigns).insert(CampaignsCompanion.insert(
      id: id, name: name, goalAmount: goalAmount, startDate: startDate,
      description: Value(description), endDate: Value(endDate),
      status: const Value('active'), createdAt: DateTime.now(),
    ));
    return (await (db.select(db.campaigns)..where((t) => t.id.equals(id))).getSingle());
  }
}
