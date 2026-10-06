import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';

class VouchersRepository {
  final AppDatabase db;
  VouchersRepository(this.db);

  Future<List<Voucher>> list({String? kind, int limit = 200, int offset = 0}) {
    final q = db.select(db.vouchers)..where((t) => t.deleted.equals(false));
    if (kind != null && kind.isNotEmpty) q.where((t) => t.kind.equals(kind));
    q.limit(limit, offset: offset);
    return q.get();
  }

  Future<Voucher?> byId(String id) =>
      (db.select(db.vouchers)..where((t) => t.id.equals(id) & t.deleted.equals(false)))
          .getSingleOrNull();

  Future<Voucher> create({
    required String voucherNo, required String kind, required int amount,
    required String voucherDate, required String method, required String description,
    required String issuedByName,
    String? memberId, String? memberName, String? donorId, String? beneficiaryId,
    String? partyName, String? issuedById,
    String? treasuryAccountId, String? counterAccountId, String? journalEntryId,
    String? currencyCode, double? originalAmount, double? exchangeRate,
  }) async {
    final now = DateTime.now();
    final id = const Uuid().v4();
    await db.into(db.vouchers).insert(VouchersCompanion.insert(
      id: id, voucherNo: voucherNo, kind: kind, amount: amount,
      voucherDate: voucherDate, method: method, description: description,
      issuedByName: issuedByName,
      memberId: Value(memberId), memberName: Value(memberName),
      donorId: Value(donorId), beneficiaryId: Value(beneficiaryId),
      partyName: Value(partyName), issuedById: Value(issuedById),
      treasuryAccountId: Value(treasuryAccountId),
      counterAccountId: Value(counterAccountId),
      journalEntryId: Value(journalEntryId),
      currencyCode: Value(currencyCode), originalAmount: Value(originalAmount),
      exchangeRate: Value(exchangeRate),
      createdAt: now, updatedAt: now,
    ));
    return (await byId(id))!;
  }

  Future<bool> softDelete(String id) async {
    final n = await (db.update(db.vouchers)..where((t) => t.id.equals(id)))
        .write(VouchersCompanion(deleted: const Value(true), updatedAt: Value(DateTime.now())));
    return n > 0;
  }
}

