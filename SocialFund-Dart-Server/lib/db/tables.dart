// lib/db/tables.dart
//
// مخطط قاعدة البيانات الكامل — نسخة Dart 1:1 من نماذج SQLAlchemy السابقة.
// كل جدول متزامن (sync) يحمل: id (UUID نصي) + created_at + updated_at +
// deleted (حذف منطقي) + device_id، مطابقةً لـ SyncMixin في بايثون.
//
// المبالغ:zebrar
//  - أصول/إيرادات/مصروفات الالتزام (الأعضاء، السندات، الخزينة): Int
//    بالريال اليمني الصحيح - بلا كسور (قرار صريح في التطبيق).
//  - الحسابات والقيود والوعود والحملات والموازنات: REAL بدقة عشرية
//    (decision صريح: Numeric(14,2) ← قرار الدقة البنكية).

import 'package:drift/drift.dart';

// ============ المستخدمون والصلاحيات ============

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get fullName => text()();
  TextColumn get role => text().withDefault(const Constant('viewer'))();
  TextColumn get avatarInitial => text().withDefault(const Constant('?'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get phone => text().nullable()();
  BoolColumn get otpEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get biometricEnabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============ الأعضاء ============

class Members extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  // الحقول الحساسة (رقم الهوية، الهاتف، البريد) تُخزَّن مشفّرة (AES-GCM).
  TextColumn get nationalId => text()();
  // هاش حتمي HMAC-SHA256 للبحث عن التكرار دون كشف القيمة الأصلية.
  TextColumn get nationalIdSearch => text().nullable()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get joinDate => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('نشط'))();
  IntColumn get monthlySubscription => integer().withDefault(const Constant(0))();
  IntColumn get totalPaid => integer().withDefault(const Constant(0))();
  IntColumn get balanceDue => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============ طلبات المساعدة ============

class AidRequests extends Table {
  TextColumn get id => text()();
  TextColumn get memberId => text()();
  TextColumn get memberName => text()();
  TextColumn get aidType => text()();
  IntColumn get amount => integer()();
  // العملة الأصلية للمعاملة: null = العملة المحلية. `amount` يبقى دائماً بالعملة المحلية
  // (فتبقى كل المجاميع والقيود صحيحة)، والأصل محفوظ هنا للعرض والتدقيق.
  TextColumn get currencyCode => text().nullable()();
  RealColumn get originalAmount => real().nullable()();
  RealColumn get exchangeRate => real().nullable()();
  TextColumn get requestDate => text()();
  TextColumn get status => text().withDefault(const Constant('قيد المراجعة'))();
  TextColumn get note => text().nullable()();
  TextColumn get reviewerName => text().nullable()();
  TextColumn get reviewerId => text().nullable()();
  // maker-checker: من سجّل الطلب لا يعتمده بنفسه.
  TextColumn get createdBy => text().nullable()();
  TextColumn get beneficiaryId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============ الاشتراكات ============

class Subscriptions extends Table {
  TextColumn get id => text()();
  TextColumn get memberId => text()();
  TextColumn get memberName => text()();
  IntColumn get amount => integer()();
  // العملة الأصلية للمعاملة: null = العملة المحلية. `amount` يبقى دائماً بالعملة المحلية
  // (فتبقى كل المجاميع والقيود صحيحة)، والأصل محفوظ هنا للعرض والتدقيق.
  TextColumn get currencyCode => text().nullable()();
  RealColumn get originalAmount => real().nullable()();
  RealColumn get exchangeRate => real().nullable()();
  TextColumn get paymentDate => text()();
  TextColumn get period => text().nullable()();   // YYYY-MM
  TextColumn get method => text()();
  TextColumn get referenceNo => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============ الخزينة ============

class TreasuryEntries extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // إيراد | مصروف
  TextColumn get category => text()();
  TextColumn get description => text()();
  IntColumn get amount => integer()();
  // العملة الأصلية للمعاملة: null = العملة المحلية. `amount` يبقى دائماً بالعملة المحلية
  // (فتبقى كل المجاميع والقيود صحيحة)، والأصل محفوظ هنا للعرض والتدقيق.
  TextColumn get currencyCode => text().nullable()();
  RealColumn get originalAmount => real().nullable()();
  RealColumn get exchangeRate => real().nullable()();
  TextColumn get entryDate => text()();
  TextColumn get referenceNo => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============ السندات ============

class Vouchers extends Table {
  TextColumn get id => text()();
  TextColumn get voucherNo => text().unique()();
  TextColumn get kind => text()(); // قبض | صرف
  TextColumn get memberId => text().nullable()();
  TextColumn get memberName => text().nullable()();
  TextColumn get donorId => text().nullable()();
  TextColumn get beneficiaryId => text().nullable()();
  TextColumn get partyName => text().nullable()();
  IntColumn get amount => integer()();
  // العملة الأصلية للمعاملة: null = العملة المحلية. `amount` يبقى دائماً بالعملة المحلية
  // (فتبقى كل المجاميع والقيود صحيحة)، والأصل محفوظ هنا للعرض والتدقيق.
  TextColumn get currencyCode => text().nullable()();
  RealColumn get originalAmount => real().nullable()();
  RealColumn get exchangeRate => real().nullable()();
  TextColumn get voucherDate => text()();
  TextColumn get method => text()();
  TextColumn get description => text()();
  TextColumn get issuedByName => text()();
  TextColumn get issuedById => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('معتمد'))();
  TextColumn get treasuryAccountId => text().nullable()();
  TextColumn get counterAccountId => text().nullable()();
  TextColumn get journalEntryId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============ الرسائل والأحداث ============

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get fromUserId => text()();
  TextColumn get fromName => text()();
  TextColumn get toUserId => text()();
  TextColumn get toName => text()();
  TextColumn get body => text()();
  BoolColumn get read => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Events extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get eventDate => text()();
  TextColumn get eventTime => text().nullable()();
  TextColumn get place => text().nullable()();
  TextColumn get type => text().nullable()();
  TextColumn get color => text().withDefault(const Constant('#1B5E20'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============ إعدادات الصندوق ============

class FundSettings extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant('الصندوق الاجتماعي التنموي'))();
  TextColumn get logoBase64 => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get registrationNo => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============ النواة المحاسبية ============

class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get parentId => text().nullable()();
  BoolColumn get isPostable => boolean().withDefault(const Constant(true))();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get description => text().nullable()();
  BoolColumn get isBank => boolean().withDefault(const Constant(false))();
  BoolColumn get isCash => boolean().withDefault(const Constant(false))();
  BoolColumn get isWallet => boolean().withDefault(const Constant(false))();
  TextColumn get bankName => text().nullable()();
  TextColumn get accountNumber => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('YER'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get entryNo => text().unique()(); // JE-000123
  TextColumn get entryDate => text()(); // ISO YYYY-MM-DD (نص للمقارنة المعجمية)
  TextColumn get description => text()();
  TextColumn get entryType => text()();
  TextColumn get reference => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('posted'))();
  TextColumn get campaignId => text().nullable()();
  TextColumn get donorId => text().nullable()();
  TextColumn get memberId => text().nullable()();
  TextColumn get aidId => text().nullable()();
  TextColumn get beneficiaryId => text().nullable()();
  TextColumn get voucherId => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class JournalLines extends Table {
  TextColumn get id => text()();
  TextColumn get entryId => text()();
  TextColumn get accountId => text()();
  RealColumn get debit => real().withDefault(const Constant(0))();
  RealColumn get credit => real().withDefault(const Constant(0))();
  TextColumn get memo => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class BankStatementLines extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  TextColumn get lineDate => text()();
  TextColumn get description => text()();
  RealColumn get amount => real()(); // موجب = وارد، سالب = صادر
  TextColumn get externalRef => text().nullable()();
  TextColumn get matchedLineId => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============ التبرعات ============

class Donors extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get donorType => text().withDefault(const Constant('individual'))();
  TextColumn get tier => text().withDefault(const Constant('silver'))();
  TextColumn get phone => text().nullable()(); // مشفّر
  TextColumn get email => text().nullable()(); // مشفّر
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Pledges extends Table {
  TextColumn get id => text()();
  TextColumn get donorId => text()();
  RealColumn get amount => real()();
  TextColumn get frequency => text().withDefault(const Constant('monthly'))();
  TextColumn get startDate => text()();
  TextColumn get endDate => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get lastFulfilledOn => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Campaigns extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get goalAmount => real()();
  TextColumn get startDate => text()();
  TextColumn get endDate => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============ الوجه الخيري ============

class Beneficiaries extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text()();
  TextColumn get nationalId => text().nullable()(); // مشفّر
  TextColumn get nationalIdSearch => text().nullable()();
  TextColumn get phone => text().nullable()(); // مشفّر
  IntColumn get familySize => integer().withDefault(const Constant(1))();
  RealColumn get monthlyIncome => real().withDefault(const Constant(0))();
  TextColumn get housing => text().nullable()();
  TextColumn get caseSummary => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get registeredBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PeriodicAids extends Table {
  TextColumn get id => text()();
  TextColumn get beneficiaryId => text()();
  RealColumn get monthlyAmount => real()();
  TextColumn get startedOn => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get lastPaidPeriod => text().nullable()(); // YYYY-MM
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class InKindItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get unit => text().withDefault(const Constant('قطعة'))();
  RealColumn get quantity => real().withDefault(const Constant(0))();
  RealColumn get reorderLevel => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class InKindMovements extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get direction => text()(); // in | out
  RealColumn get quantity => real()();
  TextColumn get movementDate => text()();
  TextColumn get beneficiaryId => text().nullable()();
  TextColumn get aidId => text().nullable()();
  TextColumn get campaignId => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get byUserId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get period => text()(); // YYYY-MM
  TextColumn get accountId => text()();
  RealColumn get plannedAmount => real()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============ جداول الخادم فقط (غير متزامنة) ============

class OtpCodes extends Table {
  TextColumn get id => text()();
  TextColumn get token => text().unique()();
  TextColumn get userId => text()();
  // يُخزَّن SHA-256 للرمز (مع SECRET_KEY كملح) لا النص الصريح.
  TextColumn get codeHash => text()();
  DateTimeColumn get expiresAt => dateTime()();
  BoolColumn get consumed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class RefreshSessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get tokenHash => text().unique()();
  TextColumn get deviceId => text().nullable()();
  TextColumn get ipAddress => text().nullable()();
  DateTimeColumn get expiresAt => dateTime()();
  BoolColumn get revoked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class DeviceTokens extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get token => text().unique()();
  TextColumn get platform => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastUsedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class AuditLogs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get userId => text().nullable()();
  TextColumn get userName => text().nullable()();
  TextColumn get action => text()();
  TextColumn get resourceType => text()();
  TextColumn get resourceId => text().nullable()();
  TextColumn get summary => text().nullable()();
  TextColumn get changes => text().nullable()();
  TextColumn get ipAddress => text().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// عدادات تسلسلية ذرّية لأرقام السندات والقيود.
/// على SQLite: التحديث داخل معاملة (transaction) هو قفل الكتابة الوحيد
/// الموجود، فلا يمكن لعميلين أخذ الرقم نفسه. قيد UNIQUE شبكة أمان أخيرة.
class Counters extends Table {
  TextColumn get name => text()();
  IntColumn get value => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {name};
}


// ============ العملات وأسعار الصرف ============

/// عملة معرّفة في النظام. `rate` = كم وحدة من العملة المحلية تساوي وحدة واحدة
/// من هذه العملة (للعملة المحلية = 1). عملة محلية واحدة فقط (isLocal)،
/// وعملة افتراضية واحدة (isDefault) للإدخال والعرض.
class Currencies extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()(); // YER, USD, SAR...
  TextColumn get nameAr => text()();
  TextColumn get symbol => text()();
  IntColumn get decimals => integer().withDefault(const Constant(2))();
  RealColumn get rate => real().withDefault(const Constant(0))();
  BoolColumn get isLocal => boolean().withDefault(const Constant(false))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// سجل تاريخي لتغيّر أسعار الصرف (للتدقيق).
class CurrencyRates extends Table {
  TextColumn get id => text()();
  TextColumn get currencyCode => text()();
  RealColumn get rate => real()();
  TextColumn get changedBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
