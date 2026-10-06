import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';

class DonorsRepository {
  final AppDatabase db;
  DonorsRepository(this.db);

  Future<List<Donor>> list() =>
      (db.select(db.donors)..where((t) => t.isActive.equals(true))).get();

  Future<Donor> create({required String name, String donorType = 'individual',
      String tier = 'silver', String? phone, String? email, String? notes}) async {
    final id = const Uuid().v4();
    await db.into(db.donors).insert(DonorsCompanion.insert(
      id: id, name: name,
      donorType: Value(donorType), tier: Value(tier),
      phone: Value(phone), email: Value(email), notes: Value(notes),
      isActive: const Value(true), createdAt: DateTime.now(),
    ));
    return (await (db.select(db.donors)..where((t) => t.id.equals(id))).getSingle());
  }
}
