import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';

class TreasuryRepository {
  final AppDatabase db;
  TreasuryRepository(this.db);

  Future<List<TreasuryEntry>> list({String? type, int limit = 200, int offset = 0}) {
    final q = db.select(db.treasuryEntries)..where((t) => t.deleted.equals(false));
    if (type != null && type.isNotEmpty) q.where((t) => t.type.equals(type));
    q.limit(limit, offset: offset);
    return q.get();
  }

  Future<TreasuryEntry?> byId(String id) =>
      (db.select(db.treasuryEntries)..where((t) => t.id.equals(id) & t.deleted.equals(false)))
          .getSingleOrNull();

  Future<TreasuryEntry> create({
    required String type, required String category, required String description,
    required int amount, required String entryDate, String? referenceNo,
    String? currencyCode, double? originalAmount, double? exchangeRate,
  }) async {
    final now = DateTime.now();
    final id = const Uuid().v4();
    await db.into(db.treasuryEntries).insert(TreasuryEntriesCompanion.insert(
      id: id, type: type, category: category, description: description,
      amount: amount, entryDate: entryDate,
      referenceNo: Value(referenceNo),
      currencyCode: Value(currencyCode), originalAmount: Value(originalAmount),
      exchangeRate: Value(exchangeRate),
      createdAt: now, updatedAt: now,
    ));
    return (await byId(id))!;
  }

  Future<bool> softDelete(String id) async {
    final n = await (db.update(db.treasuryEntries)..where((t) => t.id.equals(id)))
        .write(TreasuryEntriesCompanion(deleted: const Value(true), updatedAt: Value(DateTime.now())));
    return n > 0;
  }
}
