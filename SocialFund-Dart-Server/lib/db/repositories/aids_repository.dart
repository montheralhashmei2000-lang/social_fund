import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';

class AidsRepository {
  final AppDatabase db;
  AidsRepository(this.db);

  Future<List<AidRequest>> list({String? memberId, String? status, int limit = 200, int offset = 0}) {
    final q = db.select(db.aidRequests)..where((t) => t.deleted.equals(false));
    if (memberId != null && memberId.isNotEmpty) q.where((t) => t.memberId.equals(memberId));
    if (status != null && status.isNotEmpty) q.where((t) => t.status.equals(status));
    q.limit(limit, offset: offset);
    return q.get();
  }

  Future<AidRequest?> byId(String id) =>
      (db.select(db.aidRequests)..where((t) => t.id.equals(id) & t.deleted.equals(false)))
          .getSingleOrNull();

  Future<AidRequest> create({
    required String memberId, required String memberName, required String aidType,
    required int amount, required String requestDate,
    String? note, String? createdBy, String? beneficiaryId,
    String? currencyCode, double? originalAmount, double? exchangeRate,
  }) async {
    final now = DateTime.now();
    final id = const Uuid().v4();
    await db.into(db.aidRequests).insert(AidRequestsCompanion.insert(
      id: id, memberId: memberId, memberName: memberName, aidType: aidType,
      amount: amount, requestDate: requestDate,
      note: Value(note), createdBy: Value(createdBy), beneficiaryId: Value(beneficiaryId),
      currencyCode: Value(currencyCode), originalAmount: Value(originalAmount),
      exchangeRate: Value(exchangeRate),
      createdAt: now, updatedAt: now,
    ));
    return (await byId(id))!;
  }

  Future<AidRequest?> updateStatus(String id, {required String status,
      String? reviewerName, String? reviewerId, String? note}) async {
    if (await byId(id) == null) return null;
    await (db.update(db.aidRequests)..where((t) => t.id.equals(id))).write(
      AidRequestsCompanion(
        status: Value(status),
        reviewerName: reviewerName != null ? Value(reviewerName) : const Value.absent(),
        reviewerId: reviewerId != null ? Value(reviewerId) : const Value.absent(),
        note: note != null ? Value(note) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return byId(id);
  }

  Future<bool> softDelete(String id) async {
    final n = await (db.update(db.aidRequests)..where((t) => t.id.equals(id)))
        .write(AidRequestsCompanion(deleted: const Value(true), updatedAt: Value(DateTime.now())));
    return n > 0;
  }
}
