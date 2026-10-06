import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';

/// طبقة الحسابات - بنية هرمية كاملة مع إعدادات محاسبية.
class AccountsRepository {
  final AppDatabase db;
  AccountsRepository(this.db);

  Future<List<Account>> list({bool onlyPostable = false}) {
    final q = db.select(db.accounts)
      ..where((t) => t.isActive.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.code)]);
    if (onlyPostable) q.where((t) => t.isPostable.equals(true));
    return q.get();
  }

  Future<Account?> byId(String id) =>
      (db.select(db.accounts)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Account?> byCode(String code) =>
      (db.select(db.accounts)..where((t) => t.code.equals(code))).getSingleOrNull();

  Future<Account> create({
    required String code, required String name, required String type,
    String? parentId, bool isPostable = true, int level = 1,
    int sortOrder = 0, String? description,
    bool isBank = false, bool isCash = false, bool isWallet = false,
    String? bankName, String? accountNumber, String currency = 'YER',
  }) async {
    final id = const Uuid().v4();
    await db.into(db.accounts).insert(AccountsCompanion.insert(
      id: id, code: code, name: name, type: type,
      parentId: Value(parentId),
      isPostable: Value(isPostable),
      level: Value(level),
      sortOrder: Value(sortOrder),
      description: Value(description),
      isBank: Value(isBank), isCash: Value(isCash), isWallet: Value(isWallet),
      bankName: Value(bankName), accountNumber: Value(accountNumber),
      currency: Value(currency), isActive: const Value(true),
      createdAt: DateTime.now(),
    ));
    return (await byId(id))!;
  }

  Future<void> deleteAll() async {
    await db.delete(db.accounts).go();
  }

  /// إنشاء شجرة الحسابات الافتراضية الكاملة (محاسبة الصناديق الخيرية).
  Future<int> seedDefaults() async {
    final existing = await list();
    if (existing.isNotEmpty) return 0;

    final rows = <_SeedRow>[
      // ============================ 1 - الأصول ============================
      _SeedRow('1000', 'الأصول', 'asset', null, false, 1, 100, 'إجمالي الأصول'),
      _SeedRow('1100', 'الأصول المتداولة', 'asset', '1000', false, 2, 110, null),
      _SeedRow('1110', 'الصندوق (النقدية)', 'asset', '1100', true, 3, 111,
          'النقدية في الصندوق', isCash: true),
      _SeedRow('1120', 'البنوك', 'asset', '1100', false, 3, 112, null, isBank: true),
      _SeedRow('1121', 'البنك الأهلي اليمني', 'asset', '1120', true, 4, 1121,
          null, isBank: true, bankName: 'البنك الأهلي اليمني'),
      _SeedRow('1122', 'بنك التضامن الإسلامي', 'asset', '1120', true, 4, 1122,
          null, isBank: true, bankName: 'بنك التضامن الإسلامي'),
      _SeedRow('1123', 'بنك الكريمي', 'asset', '1120', true, 4, 1123,
          null, isBank: true, bankName: 'بنك الكريمي'),
      _SeedRow('1130', 'المحافظ الإلكترونية', 'asset', '1100', false, 3, 113,
          null, isWallet: true),
      _SeedRow('1131', 'محفظة جوالي', 'asset', '1130', true, 4, 1131,
          null, isWallet: true),
      _SeedRow('1132', 'محفظة كاش', 'asset', '1130', true, 4, 1132,
          null, isWallet: true),
      _SeedRow('1133', 'محفظة أم فلوس', 'asset', '1130', true, 4, 1133,
          null, isWallet: true),
      _SeedRow('1140', 'الذمم المدينة', 'asset', '1100', false, 3, 114, null),
      _SeedRow('1141', 'ذمم الأعضاء (اشتراكات مستحقة)', 'asset', '1140', true, 4, 1141, null),
      _SeedRow('1142', 'ذمم المانحين (تعهدات مستحقة)', 'asset', '1140', true, 4, 1142, null),
      _SeedRow('1150', 'مصروفات مدفوعة مقدماً', 'asset', '1100', true, 3, 115, null),

      _SeedRow('1200', 'الأصول الثابتة', 'asset', '1000', false, 2, 120, null),
      _SeedRow('1210', 'الأثاث والتجهيزات', 'asset', '1200', true, 3, 121, null),
      _SeedRow('1220', 'الأجهزة الإلكترونية', 'asset', '1200', true, 3, 122, null),
      _SeedRow('1230', 'وسائل النقل', 'asset', '1200', true, 3, 123, null),
      _SeedRow('1240', 'عقارات وأراضي', 'asset', '1200', true, 3, 124, null),

      // ============================ 2 - الالتزامات ============================
      _SeedRow('2000', 'الالتزامات', 'liability', null, false, 1, 200, 'إجمالي الالتزامات'),
      _SeedRow('2100', 'الالتزامات المتداولة', 'liability', '2000', false, 2, 210, null),
      _SeedRow('2110', 'الذمم الدائنة (موردون)', 'liability', '2100', true, 3, 211, null),
      _SeedRow('2120', 'أمانات واشتراكات مقدمة', 'liability', '2100', true, 3, 212,
          'اشتراكات مستلمة لشهور قادمة'),
      _SeedRow('2130', 'مستحقات الموظفين', 'liability', '2100', true, 3, 213, null),
      _SeedRow('2140', 'مصروفات مستحقة', 'liability', '2100', true, 3, 214, null),
      _SeedRow('2200', 'التزامات طويلة الأجل', 'liability', '2000', false, 2, 220, null),
      _SeedRow('2210', 'قروض طويلة الأجل', 'liability', '2200', true, 3, 221, null),

      // ============================ 3 - حقوق الملكية ============================
      _SeedRow('3000', 'حقوق الملكية', 'equity', null, false, 1, 300, null),
      _SeedRow('3100', 'رأس المال الموقوف', 'equity', '3000', true, 2, 310,
          'رأس مال الصندوق الأساسي'),
      _SeedRow('3200', 'الفائض / العجز المتراكم', 'equity', '3000', true, 2, 320, null),
      _SeedRow('3300', 'فائض / عجز العام الحالي', 'equity', '3000', true, 2, 330, null),

      // ============================ 4 - الإيرادات ============================
      _SeedRow('4000', 'الإيرادات', 'income', null, false, 1, 400, 'إجمالي الإيرادات'),
      _SeedRow('4100', 'إيرادات الاشتراكات', 'income', '4000', false, 2, 410, null),
      _SeedRow('4110', 'اشتراكات الأعضاء الشهرية', 'income', '4100', true, 3, 411, null),
      _SeedRow('4120', 'اشتراكات سنوية', 'income', '4100', true, 3, 412, null),
      _SeedRow('4130', 'اشتراكات انتساب (مرة واحدة)', 'income', '4100', true, 3, 413, null),

      _SeedRow('4200', 'التبرعات والهبات', 'income', '4000', false, 2, 420, null),
      _SeedRow('4210', 'تبرعات نقدية', 'income', '4200', true, 3, 421, null),
      _SeedRow('4220', 'هبات ومنح', 'income', '4200', true, 3, 422, null),
      _SeedRow('4230', 'تبرعات عينية (مقابلة نقدية)', 'income', '4200', true, 3, 423, null),

      _SeedRow('4300', 'إيرادات حملات التبرع', 'income', '4000', false, 2, 430, null),
      _SeedRow('4310', 'حملات التبرعات العامة', 'income', '4300', true, 3, 431, null),
      _SeedRow('4320', 'حملات مخصصة', 'income', '4300', true, 3, 432, null),

      _SeedRow('4400', 'إيرادات أخرى', 'income', '4000', false, 2, 440, null),
      _SeedRow('4410', 'إيرادات فوائد بنكية', 'income', '4400', true, 3, 441, null),
      _SeedRow('4420', 'إيرادات متنوعة', 'income', '4400', true, 3, 442, null),

      // ============================ 5 - المصروفات ============================
      _SeedRow('5000', 'المصروفات', 'expense', null, false, 1, 500, 'إجمالي المصروفات'),
      _SeedRow('5100', 'المساعدات والمنافع', 'expense', '5000', false, 2, 510, null),
      _SeedRow('5110', 'مساعدات نقدية طارئة', 'expense', '5100', true, 3, 511, null),
      _SeedRow('5120', 'مساعدات طبية', 'expense', '5100', true, 3, 512, null),
      _SeedRow('5130', 'مساعدات تعليمية', 'expense', '5100', true, 3, 513, null),
      _SeedRow('5140', 'مساعدات غذائية', 'expense', '5100', true, 3, 514, null),
      _SeedRow('5150', 'مساعدات دورية (أيتام/أرامل)', 'expense', '5100', true, 3, 515, null),
      _SeedRow('5160', 'مساعدات عينية', 'expense', '5100', true, 3, 516, null),
      _SeedRow('5170', 'مساعدات سكنية وإيجار', 'expense', '5100', true, 3, 517, null),

      _SeedRow('5200', 'مصروفات تشغيلية', 'expense', '5000', false, 2, 520, null),
      _SeedRow('5210', 'الرواتب والأجور', 'expense', '5200', true, 3, 521, null),
      _SeedRow('5220', 'الإيجارات', 'expense', '5200', true, 3, 522, null),
      _SeedRow('5230', 'الكهرباء والماء', 'expense', '5200', true, 3, 523, null),
      _SeedRow('5240', 'الاتصالات والإنترنت', 'expense', '5200', true, 3, 524, null),
      _SeedRow('5250', 'قرطاسية ومستلزمات مكتبية', 'expense', '5200', true, 3, 525, null),
      _SeedRow('5260', 'صيانة وإصلاحات', 'expense', '5200', true, 3, 526, null),
      _SeedRow('5270', 'وقود ونقل', 'expense', '5200', true, 3, 527, null),

      _SeedRow('5300', 'مصروفات إدارية وعمومية', 'expense', '5000', false, 2, 530, null),
      _SeedRow('5310', 'رسوم بنكية', 'expense', '5300', true, 3, 531, null),
      _SeedRow('5320', 'ضيافة واستقبال', 'expense', '5300', true, 3, 532, null),
      _SeedRow('5330', 'دعاية وإعلان', 'expense', '5300', true, 3, 533, null),
      _SeedRow('5340', 'تأمينات', 'expense', '5300', true, 3, 534, null),
      _SeedRow('5350', 'مصروفات متنوعة', 'expense', '5300', true, 3, 535, null),

      _SeedRow('5400', 'الإهلاك', 'expense', '5000', false, 2, 540, null),
      _SeedRow('5410', 'إهلاك الأثاث والتجهيزات', 'expense', '5400', true, 3, 541, null),
      _SeedRow('5420', 'إهلاك الأجهزة الإلكترونية', 'expense', '5400', true, 3, 542, null),
      _SeedRow('5430', 'إهلاك وسائل النقل', 'expense', '5400', true, 3, 543, null),
    ];

    // إنشاء على مراحل حسب المستوى (المستوى 1 ثم 2 ثم 3 ثم 4)
    final idByCode = <String, String>{};
    final byLevel = <int, List<_SeedRow>>{};
    for (final r in rows) {
      byLevel.putIfAbsent(r.level, () => []).add(r);
    }

    var count = 0;
    for (final lvl in [1, 2, 3, 4]) {
      final batch = byLevel[lvl] ?? [];
      for (final r in batch) {
        final parentId = r.parentCode == null ? null : idByCode[r.parentCode!];
        final id = const Uuid().v4();
        await db.into(db.accounts).insert(AccountsCompanion.insert(
          id: id,
          code: r.code,
          name: r.name,
          type: r.type,
          parentId: Value(parentId),
          isPostable: Value(r.isPostable),
          level: Value(r.level),
          sortOrder: Value(r.sortOrder),
          description: Value(r.description),
          isBank: Value(r.isBank),
          isCash: Value(r.isCash),
          isWallet: Value(r.isWallet),
          bankName: Value(r.bankName),
          currency: const Value('YER'),
          isActive: const Value(true),
          createdAt: DateTime.now(),
        ));
        idByCode[r.code] = id;
        count++;
      }
    }
    return count;
  }
}

class _SeedRow {
  final String code;
  final String name;
  final String type;
  final String? parentCode;
  final bool isPostable;
  final int level;
  final int sortOrder;
  final String? description;
  final bool isBank;
  final bool isCash;
  final bool isWallet;
  final String? bankName;

  const _SeedRow(
    this.code, this.name, this.type, this.parentCode, this.isPostable,
    this.level, this.sortOrder, this.description, {
    this.isBank = false,
    this.isCash = false,
    this.isWallet = false,
    this.bankName,
  });
}
