import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';

class FundSettingsRepository {
  final AppDatabase db;
  FundSettingsRepository(this.db);

  Future<FundSetting?> get() =>
      (db.select(db.fundSettings)..where((t) => t.deleted.equals(false)))
          .getSingleOrNull();

  Future<FundSetting> upsert({
    String? name, String? logoBase64, String? phone,
    String? email, String? address, String? registrationNo,
  }) async {
    final existing = await get();
    final now = DateTime.now();
    if (existing == null) {
      final id = const Uuid().v4();
      await db.into(db.fundSettings).insert(FundSettingsCompanion.insert(
        id: id,
        name: Value(name ?? 'الصندوق الاجتماعي التنموي'),
        logoBase64: Value(logoBase64), phone: Value(phone),
        email: Value(email), address: Value(address),
        registrationNo: Value(registrationNo),
        createdAt: now, updatedAt: now,
      ));
      return (await get())!;
    }
    await (db.update(db.fundSettings)..where((t) => t.id.equals(existing.id))).write(
      FundSettingsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        logoBase64: Value(logoBase64),
        phone: Value(phone), email: Value(email),
        address: Value(address), registrationNo: Value(registrationNo),
        updatedAt: Value(now),
      ),
    );
    return (await get())!;
  }
}
