import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/pii.dart';
import '../database.dart';

/// المستفيدون. رقم الهوية والهاتف مشفّران في القاعدة ومفكوكان عند القراءة.
class BeneficiariesRepository {
  final AppDatabase db;
  BeneficiariesRepository(this.db);

  static String _aad(String id, String field) => 'beneficiaries.$field:$id';

  Future<Beneficiary> _dec(Beneficiary b) async => b.copyWith(
        nationalId: Value(await Pii.dec(b.nationalId, _aad(b.id, 'national_id'))),
        phone: Value(await Pii.dec(b.phone, _aad(b.id, 'phone'))),
      );

  Future<List<Beneficiary>> list() async {
    final rows = await (db.select(db.beneficiaries)..where((t) => t.status.equals('active'))).get();
    return [for (final b in rows) await _dec(b)];
  }

  Future<Beneficiary> create({required String fullName, String? nationalId,
      String? phone, int familySize = 1, double monthlyIncome = 0,
      String? housing, String? caseSummary}) async {
    final id = const Uuid().v4();
    final nid = (nationalId == null || nationalId.trim().isEmpty) ? null : Pii.normalizeId(nationalId);
    await db.into(db.beneficiaries).insert(BeneficiariesCompanion.insert(
      id: id, fullName: fullName,
      nationalId: Value(await Pii.enc(nid, _aad(id, 'national_id'))),
      nationalIdSearch: Value(nid == null ? null : Pii.idHash(nid)),
      phone: Value(await Pii.enc(phone, _aad(id, 'phone'))),
      familySize: Value(familySize), monthlyIncome: Value(monthlyIncome),
      housing: Value(housing), caseSummary: Value(caseSummary),
      status: const Value('active'), createdAt: DateTime.now(),
    ));
    return _dec(await (db.select(db.beneficiaries)..where((t) => t.id.equals(id))).getSingle());
  }
}
