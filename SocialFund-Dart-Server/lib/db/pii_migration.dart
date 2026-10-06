import 'package:drift/drift.dart';
import '../core/pii.dart';
import 'database.dart';

/// يشفّر البيانات الشخصية القديمة (غير المشفّرة) ويملأ الفهرس الأعمى للهوية.
/// آمن للتكرار: لا يلمس إلا القيم غير المشفّرة. يعيد عدد السجلات التي عُدّلت.
class PiiMigration {
  /// يُنفَّذ داخل معاملة واحدة: إما أن يُشفَّر الكل أو لا شيء.
  static Future<int> run(AppDatabase db) async {
    var changed = 0;
    await db.transaction(() async {
      final members = await db.select(db.members).get();
      for (final m in members) {
        final needsEnc = !Pii.isEncrypted(m.nationalId) ||
            !Pii.isEncrypted(m.phone) ||
            (m.email != null && m.email!.isNotEmpty && !Pii.isEncrypted(m.email));
        final needsHash = m.nationalIdSearch == null || m.nationalIdSearch!.isEmpty;
        if (!needsEnc && !needsHash) continue;
        final plainNid = Pii.isEncrypted(m.nationalId)
            ? null // مشفّر سلفاً: الفهرس يُحسب من القيمة المفكوكة أدناه
            : Pii.normalizeId(m.nationalId);
        String? hash = m.nationalIdSearch;
        if (needsHash) {
          final nid = plainNid ?? await Pii.dec(m.nationalId, 'members.national_id:${m.id}');
          if (nid != null && nid.isNotEmpty) hash = Pii.idHash(nid);
        } else if (plainNid != null) {
          hash = Pii.idHash(plainNid);
        }
        await (db.update(db.members)..where((t) => t.id.equals(m.id))).write(MembersCompanion(
          nationalId: Value((await Pii.enc(plainNid ?? m.nationalId, 'members.national_id:${m.id}'))!),
          nationalIdSearch: Value(hash),
          phone: Value((await Pii.enc(m.phone, 'members.phone:${m.id}'))!),
          email: Value(await Pii.enc(m.email, 'members.email:${m.id}')),
        ));
        changed++;
      }

      final bens = await db.select(db.beneficiaries).get();
      for (final b in bens) {
        final needs = (b.nationalId != null && b.nationalId!.isNotEmpty && !Pii.isEncrypted(b.nationalId)) ||
            (b.phone != null && b.phone!.isNotEmpty && !Pii.isEncrypted(b.phone));
        if (!needs) continue;
        final plainNid = (b.nationalId == null || b.nationalId!.isEmpty || Pii.isEncrypted(b.nationalId))
            ? null
            : Pii.normalizeId(b.nationalId!);
        await (db.update(db.beneficiaries)..where((t) => t.id.equals(b.id))).write(BeneficiariesCompanion(
          nationalId: Value(await Pii.enc(plainNid ?? b.nationalId, 'beneficiaries.national_id:${b.id}')),
          nationalIdSearch: plainNid != null ? Value(Pii.idHash(plainNid)) : const Value.absent(),
          phone: Value(await Pii.enc(b.phone, 'beneficiaries.phone:${b.id}')),
        ));
        changed++;
      }
    });
    return changed;
  }
}
