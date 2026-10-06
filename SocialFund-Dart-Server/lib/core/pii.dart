import 'crypto.dart';

/// تشفير البيانات الشخصية الحساسة (رقم الهوية، الهاتف، البريد) في قاعدة البيانات.
///
/// - التشفير AES-256-GCM بمفتاح ENCRYPTION_KEY، والـAAD يربط الشفرة بالجدول والحقل
///   والسجل فلا يمكن نقلها بين سجلات أو حقول.
/// - القيم القديمة غير المشفّرة (قبل التفعيل) تُقرأ كما هي وتُشفَّر عند أول تشغيل
///   عبر [PiiMigration] في db/pii_migration.dart.
/// - **ضياع ENCRYPTION_KEY = ضياع هذه الحقول نهائياً.** احتفظ بنسخة منه مستقلة
///   عن النسخ الاحتياطية للقاعدة (النسخ تحوي الشفرة فقط).
class Pii {
  Pii._();

  static const prefix = 'v1.';

  static bool isEncrypted(String? v) => v != null && v.startsWith(prefix);

  /// يشفّر قيمة (null/فارغ يبقيان كما هما).
  static Future<String?> enc(String? value, String aad) async {
    if (value == null || value.isEmpty) return value;
    if (isEncrypted(value)) return value;
    return encryptField(value, aad: aad);
  }

  /// يفك التشفير؛ القيمة غير المشفّرة (قديمة) تُعاد كما هي. فشل الفك يعيد نصاً
  /// صريحاً بدل قيمة خاطئة (مفتاح مفقود/بيانات تالفة).
  static Future<String?> dec(String? stored, String aad) async {
    if (stored == null || stored.isEmpty || !isEncrypted(stored)) return stored;
    return await decryptField(stored, aad: aad) ?? '[تعذّر فك التشفير]';
  }

  /// توحيد رقم الهوية قبل الفهرسة: أرقام لاتينية فقط بلا مسافات/شرطات.
  static String normalizeId(String v) {
    final b = StringBuffer();
    for (final r in v.trim().runes) {
      if (r >= 0x0660 && r <= 0x0669) {
        b.writeCharCode(r - 0x0660 + 0x30);
      } else if (r >= 0x06F0 && r <= 0x06F9) {
        b.writeCharCode(r - 0x06F0 + 0x30);
      } else if (r == 0x20 || r == 0x2D) {
        continue;
      } else {
        b.writeCharCode(r);
      }
    }
    return b.toString();
  }

  /// فهرس أعمى للهوية: HMAC حتمي للبحث بالتطابق التام ومنع التكرار دون كشف القيمة.
  static String idHash(String nationalId) => searchHash(normalizeId(nationalId));
}
