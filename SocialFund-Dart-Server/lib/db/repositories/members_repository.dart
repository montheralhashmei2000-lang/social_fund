import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/pii.dart';
import '../database.dart';

class DuplicateNationalIdException implements Exception {
  final String message = 'رقم الهوية مسجَّل لعضو آخر';
  @override
  String toString() => message;
}

/// الأعضاء. رقم الهوية والهاتف والبريد **مشفّرة في القاعدة** ومفكوكة هنا: كل ما
/// يُعاد من هذا المستودع واضح للمستدعي، وكل ما يُكتب يُشفَّر قبل التخزين.
class MembersRepository {
  final AppDatabase db;
  MembersRepository(this.db);

  static String _aad(String id, String field) => 'members.$field:$id';

  Future<Member> _dec(Member m) async => m.copyWith(
        nationalId: await Pii.dec(m.nationalId, _aad(m.id, 'national_id')) ?? '',
        phone: await Pii.dec(m.phone, _aad(m.id, 'phone')) ?? '',
        email: Value(await Pii.dec(m.email, _aad(m.id, 'email'))),
      );

  Future<List<Member>> list({String? search, int limit = 200, int offset = 0}) async {
    final base = db.select(db.members)..where((t) => t.deleted.equals(false));
    final term = search?.trim() ?? '';
    if (term.isEmpty) {
      base.limit(limit, offset: offset);
      return [for (final m in await base.get()) await _dec(m)];
    }
    // الحقول مشفّرة فلا يمكن LIKE في SQL: نفكّ ثم نصفّي في الذاكرة.
    final all = [for (final m in await base.get()) await _dec(m)];
    final q = Pii.normalizeId(term);
    final hits = all.where((m) =>
        m.name.contains(term) ||
        m.nationalId.contains(q) ||
        m.phone.contains(term) ||
        (m.city ?? '').contains(term));
    return hits.skip(offset).take(limit).toList();
  }

  Future<Member?> byId(String id) async {
    final m = await (db.select(db.members)
          ..where((t) => t.id.equals(id) & t.deleted.equals(false)))
        .getSingleOrNull();
    return m == null ? null : _dec(m);
  }

  /// هل رقم الهوية مسجَّل لعضو غير [exceptId]؟ (فهرس أعمى، لا فك تشفير)
  Future<bool> _idTaken(String hash, {String? exceptId}) async {
    final q = db.select(db.members)
      ..where((t) => t.nationalIdSearch.equals(hash) & t.deleted.equals(false));
    final rows = await q.get();
    return rows.any((m) => m.id != exceptId);
  }

  Future<Member> create({
    required String name, required String nationalId, required String phone,
    String? email, String? city, String? joinDate, int monthlySubscription = 0,
  }) async {
    final hash = Pii.idHash(nationalId);
    if (await _idTaken(hash)) throw DuplicateNationalIdException();
    final now = DateTime.now();
    final id = const Uuid().v4();
    await db.into(db.members).insert(MembersCompanion.insert(
      id: id, name: name,
      nationalId: (await Pii.enc(Pii.normalizeId(nationalId), _aad(id, 'national_id')))!,
      nationalIdSearch: Value(hash),
      phone: (await Pii.enc(phone, _aad(id, 'phone')))!,
      email: Value(await Pii.enc(email, _aad(id, 'email'))),
      city: Value(city),
      joinDate: Value(joinDate ?? now.toIso8601String().substring(0, 10)),
      monthlySubscription: Value(monthlySubscription),
      createdAt: now, updatedAt: now,
    ));
    return (await byId(id))!;
  }

  Future<Member?> update(String id, {String? name, String? nationalId, String? phone,
      String? email, String? city, String? status, int? monthlySubscription,
      String? joinDate}) async {
    if (await byId(id) == null) return null;
    String? hash;
    if (nationalId != null) {
      hash = Pii.idHash(nationalId);
      if (await _idTaken(hash, exceptId: id)) throw DuplicateNationalIdException();
    }
    await (db.update(db.members)..where((t) => t.id.equals(id))).write(
      MembersCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        nationalId: nationalId != null
            ? Value((await Pii.enc(Pii.normalizeId(nationalId), _aad(id, 'national_id')))!)
            : const Value.absent(),
        nationalIdSearch: hash != null ? Value(hash) : const Value.absent(),
        phone: phone != null ? Value((await Pii.enc(phone, _aad(id, 'phone')))!) : const Value.absent(),
        email: email != null ? Value(await Pii.enc(email, _aad(id, 'email'))) : const Value.absent(),
        city: city != null ? Value(city) : const Value.absent(),
        joinDate: joinDate != null ? Value(joinDate) : const Value.absent(),
        status: status != null ? Value(status) : const Value.absent(),
        monthlySubscription: monthlySubscription != null ? Value(monthlySubscription) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return byId(id);
  }

  /// يزيد المدفوع ويخفض المتبقي بمقدار معيّن.
  Future<void> incrementPaid(String memberId, int amount) async {
    final m = await byId(memberId);
    if (m == null) return;
    final newPaid = m.totalPaid + amount;
    final newDue = (m.balanceDue - amount).clamp(0, 999999999);
    await (db.update(db.members)..where((t) => t.id.equals(memberId))).write(
      MembersCompanion(
        totalPaid: Value(newPaid),
        balanceDue: Value(newDue),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<bool> softDelete(String id) async {
    final n = await (db.update(db.members)..where((t) => t.id.equals(id)))
        .write(MembersCompanion(deleted: const Value(true), updatedAt: Value(DateTime.now())));
    return n > 0;
  }
}
