// lib/db/database.dart
// فتح الاتصال بـ SQLite + المخطط الكامل + الترقيات.

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Users,
  Members,
  AidRequests,
  Subscriptions,
  TreasuryEntries,
  Vouchers,
  Messages,
  Events,
  FundSettings,
  Accounts,
  JournalEntries,
  JournalLines,
  BankStatementLines,
  Donors,
  Pledges,
  Campaigns,
  Beneficiaries,
  PeriodicAids,
  InKindItems,
  InKindMovements,
  Budgets,
  OtpCodes,
  RefreshSessions,
  DeviceTokens,
  AuditLogs,
  Counters,
  Currencies,
  CurrencyRates,
])
/// قاعدة بيانات النظام. Drift يولّد منها استعلامات بأنواع آمنة.
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.open(String filePath)
      : super(NativeDatabase(File(filePath), setup: (db) {
          db.execute('PRAGMA journal_mode = WAL;');
          db.execute('PRAGMA foreign_keys = ON;');
          db.execute('PRAGMA busy_timeout = 5000;');
        }));

  AppDatabase.memory()
      : super(NativeDatabase.memory(setup: (db) {
          db.execute('PRAGMA foreign_keys = ON;');
        }));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await createIndexes();
        },
        onUpgrade: (m, from, to) async {
          await m.createAll();
          if (from < 3) {
            // v3: العملات المتعددة. createAll لا يضيف أعمدة لجداول موجودة.
            await m.addColumn(aidRequests, aidRequests.currencyCode);
            await m.addColumn(aidRequests, aidRequests.originalAmount);
            await m.addColumn(aidRequests, aidRequests.exchangeRate);
            await m.addColumn(subscriptions, subscriptions.currencyCode);
            await m.addColumn(subscriptions, subscriptions.originalAmount);
            await m.addColumn(subscriptions, subscriptions.exchangeRate);
            await m.addColumn(treasuryEntries, treasuryEntries.currencyCode);
            await m.addColumn(treasuryEntries, treasuryEntries.originalAmount);
            await m.addColumn(treasuryEntries, treasuryEntries.exchangeRate);
            await m.addColumn(vouchers, vouchers.currencyCode);
            await m.addColumn(vouchers, vouchers.originalAmount);
            await m.addColumn(vouchers, vouchers.exchangeRate);
          }
          await createIndexes();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
          await seedCurrencies();
        },
      );

  /// عملات افتراضية عند أول تشغيل: الريال اليمني محلية وافتراضية. الدولار والريال
  /// السعودي غير مفعّلين وبسعر 0 حتى يُدخل المدير السعر الحقيقي (لا أسعار مخمَّنة).
  Future<void> seedCurrencies() async {
    final count = await (selectOnly(currencies)..addColumns([currencies.id.count()]))
        .map((r) => r.read(currencies.id.count()) ?? 0)
        .getSingle();
    if (count > 0) return;
    final now = DateTime.now();
    Future<void> add(String code, String name, String symbol, int dec,
        {double rate = 0, bool local = false, bool active = false}) async {
      await into(currencies).insert(CurrenciesCompanion.insert(
        id: 'cur-$code', code: code, nameAr: name, symbol: symbol,
        decimals: Value(dec), rate: Value(rate),
        isLocal: Value(local), isDefault: Value(local), isActive: Value(active),
        createdAt: now, updatedAt: now,
      ));
    }
    await add('YER', 'ريال يمني', '﷼', 0, rate: 1, local: true, active: true);
    await add('USD', 'دولار أمريكي', '\$', 2);
    await add('SAR', 'ريال سعودي', 'ر.س', 2);
  }

  /// الفهارس الصريحة: Drift لا يولّد فهارس الأداء تلقائياً.
  Future<void> createIndexes() async {
    const indexes = [
      'CREATE INDEX IF NOT EXISTS idx_members_name ON members(name);',
      'CREATE INDEX IF NOT EXISTS idx_members_nid ON members(national_id_search);',
      'CREATE INDEX IF NOT EXISTS idx_members_deleted ON members(deleted);',
      'CREATE INDEX IF NOT EXISTS idx_aids_member ON aid_requests(member_id);',
      'CREATE INDEX IF NOT EXISTS idx_aids_date ON aid_requests(request_date DESC);',
      'CREATE INDEX IF NOT EXISTS idx_subs_member ON subscriptions(member_id);',
      'CREATE INDEX IF NOT EXISTS idx_subs_date ON subscriptions(payment_date DESC);',
      'CREATE INDEX IF NOT EXISTS idx_treasury_date ON treasury_entries(entry_date DESC);',
      'CREATE INDEX IF NOT EXISTS idx_vouchers_date ON vouchers(voucher_date DESC);',
      'CREATE INDEX IF NOT EXISTS idx_vouchers_member ON vouchers(member_id);',
      'CREATE INDEX IF NOT EXISTS idx_messages_to ON messages(to_user_id);',
      'CREATE INDEX IF NOT EXISTS idx_events_date ON events(event_date);',
      'CREATE INDEX IF NOT EXISTS idx_je_date ON journal_entries(entry_date DESC);',
      'CREATE INDEX IF NOT EXISTS idx_je_status ON journal_entries(status);',
      'CREATE INDEX IF NOT EXISTS idx_jl_entry ON journal_lines(entry_id);',
      'CREATE INDEX IF NOT EXISTS idx_jl_account ON journal_lines(account_id);',
      'CREATE INDEX IF NOT EXISTS idx_bsl_account ON bank_statement_lines(account_id);',
      'CREATE INDEX IF NOT EXISTS idx_audit_ts ON audit_logs(timestamp DESC);',
      'CREATE INDEX IF NOT EXISTS idx_otp_token ON otp_codes(token);',
      'CREATE UNIQUE INDEX IF NOT EXISTS uq_budget_period_account'
          ' ON budgets(period, account_id);',
    ];
    for (final sql in indexes) {
      await customStatement(sql);
    }
  }
}

/// يفتح قاعدة البيانات في المسار الافتراضي الخاص بالخادم.
AppDatabase openDatabaseFile({String? overridePath}) {
  final filePath = overridePath ?? p.join(_defaultDataDir(), 'social_fund.db');
  File(filePath).parent.createSync(recursive: true);
  return AppDatabase.open(filePath);
}

String _defaultDataDir() {
  final env = Platform.environment;
  final configured = env['DATA_DIR'];
  if (configured != null && configured.isNotEmpty) return configured;
  if (Platform.isWindows) {
    return p.join(env['APPDATA'] ?? '.', 'SocialFund');
  }
  if (Platform.isLinux) {
    return p.join(env['HOME'] ?? '.', '.local', 'share', 'social_fund');
  }
  return p.join(Directory.systemTemp.path, 'social_fund');
}