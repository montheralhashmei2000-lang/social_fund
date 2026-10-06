import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';

class SubscriptionsRepository {
  final AppDatabase db;
  SubscriptionsRepository(this.db);

  Future<List<Subscription>> list({
    String? memberId, String? period,
    int limit = 200, int offset = 0,
  }) {
    final q = db.select(db.subscriptions)..where((t) => t.deleted.equals(false));
    if (memberId != null && memberId.isNotEmpty) q.where((t) => t.memberId.equals(memberId));
    if (period != null && period.isNotEmpty) q.where((t) => t.period.equals(period));
    q.limit(limit, offset: offset);
    return q.get();
  }

  Future<Subscription?> byId(String id) =>
      (db.select(db.subscriptions)..where((t) => t.id.equals(id) & t.deleted.equals(false)))
          .getSingleOrNull();

  Future<Subscription> create({
    required String memberId, required String memberName, required int amount,
    required String paymentDate, String? period,
    required String method, String? referenceNo,
    String? currencyCode, double? originalAmount, double? exchangeRate,
  }) async {
    final now = DateTime.now();
    final id = const Uuid().v4();
    await db.into(db.subscriptions).insert(SubscriptionsCompanion.insert(
      id: id, memberId: memberId, memberName: memberName, amount: amount,
      paymentDate: paymentDate, period: Value(period),
      method: method, referenceNo: Value(referenceNo),
      currencyCode: Value(currencyCode), originalAmount: Value(originalAmount),
      exchangeRate: Value(exchangeRate),
      createdAt: now, updatedAt: now,
    ));
    return (await byId(id))!;
  }

  Future<bool> softDelete(String id) async {
    final n = await (db.update(db.subscriptions)..where((t) => t.id.equals(id)))
        .write(SubscriptionsCompanion(deleted: const Value(true), updatedAt: Value(DateTime.now())));
    return n > 0;
  }

  Future<List<Map<String, dynamic>>> summaryByPeriod({String? from, String? to}) async {
    final all = await (db.select(db.subscriptions)
          ..where((t) => t.deleted.equals(false)))
        .get();
    final map = <String, Map<String, dynamic>>{};
    for (final s in all) {
      final raw = s.period ?? '';
      final p = raw.isEmpty ? 'غير محدد' : raw;
      if (from != null && from.isNotEmpty && p != 'غير محدد' && p.compareTo(from) < 0) continue;
      if (to != null && to.isNotEmpty && p != 'غير محدد' && p.compareTo(to) > 0) continue;
      final row = map.putIfAbsent(p, () => {'period': p, 'count': 0, 'total': 0, 'members': <String>{}});
      row['count'] = (row['count'] as int) + 1;
      row['total'] = (row['total'] as int) + s.amount;
      (row['members'] as Set<String>).add(s.memberName);
    }
    return map.values.map((r) {
      r['members'] = (r['members'] as Set<String>).toList();
      return r;
    }).toList();
  }
}
