import 'package:drift/drift.dart' show Variable;
import 'dart:convert';

import '../db/database.dart';

class SettingsException implements Exception {
  final String message;
  SettingsException(this.message);
  @override
  String toString() => message;
}

/// تعريف إعداد: نوعه وقيمته الافتراضية وحدوده. كل إعداد هنا إما يطبّقه الخادم
/// (مثل منع السحب فوق الرصيد) أو يقرؤه التطبيق ليبني عليه شاشاته (مثل أنواع المساعدات).
class SettingDef {
  final String key;
  final String type; // bool | int | num | string | list | enum
  final Object? def;
  final List<String>? options;
  final num? min;
  final num? max;
  const SettingDef(this.key, this.type, this.def, {this.options, this.min, this.max});
}

/// إعدادات النظام (مفتاح/قيمة JSON) + عدّادات تسلسلية ذرّية لترقيم السندات.
class AppSettingsService {
  final AppDatabase db;
  AppSettingsService(this.db);

  static const List<SettingDef> definitions = [
    // المساعدات
    SettingDef('aids.types', 'list', [
      'مساعدة طارئة', 'مساعدة مرضية', 'مساعدة تعليمية', 'مساعدة زواج', 'مساعدة وفاة', 'مساعدة سكن', 'سلة غذائية',
    ]),
    SettingDef('aids.require_second_approver', 'bool', false),
    SettingDef('aids.max_amount', 'num', 0, min: 0), // 0 = بلا حد (بالعملة المحلية)
    // المدفوعات والاشتراكات
    SettingDef('payments.methods', 'list', ['نقداً', 'تحويل بنكي', 'محفظة إلكترونية', 'شيك']),
    SettingDef('subscriptions.default_amount', 'num', 0, min: 0),
    // السندات
    SettingDef('vouchers.block_overdraft', 'bool', false),
    SettingDef('vouchers.default_treasury_account_id', 'string', ''),
    SettingDef('vouchers.receipt_prefix', 'string', 'REC'),
    SettingDef('vouchers.payment_prefix', 'string', 'PAY'),
    // المحاسبة والتقارير
    SettingDef('accounting.fiscal_year_start_month', 'int', 1, min: 1, max: 12),
    SettingDef('reports.default_period', 'enum', 'month', options: ['month', 'quarter', 'year']),
    SettingDef('reports.default_format', 'enum', 'pdf', options: ['pdf', 'xlsx']),
  ];

  static final Map<String, SettingDef> _byKey = {for (final d in definitions) d.key: d};

  /// الجداول الداعمة (تُنشأ عند فتح القاعدة؛ بلا هجرة Drift لأنها جداول خام صغيرة).
  static const List<String> createTablesSql = [
    'CREATE TABLE IF NOT EXISTS app_settings ('
        'key TEXT PRIMARY KEY, value TEXT NOT NULL, updated_at TEXT NOT NULL)',
    'CREATE TABLE IF NOT EXISTS sequences (name TEXT PRIMARY KEY, value INTEGER NOT NULL)',
  ];

  Future<Map<String, Object?>> all() async {
    final rows = await db.customSelect('SELECT key, value FROM app_settings').get();
    final stored = {for (final r in rows) r.read<String>('key'): r.read<String>('value')};
    final out = <String, Object?>{};
    for (final d in definitions) {
      final raw = stored[d.key];
      if (raw == null) {
        out[d.key] = d.def;
        continue;
      }
      try {
        out[d.key] = jsonDecode(raw);
      } catch (_) {
        out[d.key] = d.def;
      }
    }
    return out;
  }

  Future<T> get<T>(String key) async {
    final rows = await db.customSelect('SELECT value FROM app_settings WHERE key = ?',
        variables: [_v(key)]).get();
    final def = _byKey[key]!.def;
    if (rows.isEmpty) return def as T;
    try {
      return jsonDecode(rows.first.read<String>('value')) as T;
    } catch (_) {
      return def as T;
    }
  }

  /// يحدّث مجموعة إعدادات. يرمي [SettingsException] عند مفتاح مجهول أو قيمة غير صالحة،
  /// ولا يكتب شيئاً إن فشل أي منها (كل أو لا شيء).
  Future<Map<String, Object?>> update(Map<String, dynamic> patch) async {
    final clean = <String, Object?>{};
    for (final e in patch.entries) {
      final d = _byKey[e.key];
      if (d == null) throw SettingsException('إعداد غير معروف: ${e.key}');
      clean[e.key] = await _validate(d, e.value);
    }
    final now = DateTime.now().toIso8601String();
    await db.transaction(() async {
      for (final e in clean.entries) {
        await db.customStatement(
          'INSERT INTO app_settings(key, value, updated_at) VALUES(?, ?, ?) '
          'ON CONFLICT(key) DO UPDATE SET value = excluded.value, updated_at = excluded.updated_at',
          [e.key, jsonEncode(e.value), now],
        );
      }
    });
    return all();
  }

  Future<Object?> _validate(SettingDef d, Object? v) async {
    switch (d.type) {
      case 'bool':
        if (v is! bool) throw SettingsException('${d.key}: قيمة منطقية مطلوبة');
        return v;
      case 'int':
      case 'num':
        if (v is! num) throw SettingsException('${d.key}: رقم مطلوب');
        if (d.type == 'int' && v != v.roundToDouble()) throw SettingsException('${d.key}: رقم صحيح مطلوب');
        if (d.min != null && v < d.min!) throw SettingsException('${d.key}: الحد الأدنى ${d.min}');
        if (d.max != null && v > d.max!) throw SettingsException('${d.key}: الحد الأقصى ${d.max}');
        return d.type == 'int' ? v.toInt() : v;
      case 'enum':
        if (v is! String || !(d.options ?? const []).contains(v)) {
          throw SettingsException('${d.key}: القيم المسموحة ${d.options!.join(', ')}');
        }
        return v;
      case 'list':
        if (v is! List) throw SettingsException('${d.key}: قائمة مطلوبة');
        final seen = <String>{};
        final out = <String>[];
        for (final x in v) {
          final s = x.toString().trim();
          if (s.isEmpty) continue;
          if (s.length > 60) throw SettingsException('${d.key}: العنصر أطول من 60 حرفاً');
          if (seen.add(s)) out.add(s);
        }
        if (out.isEmpty) throw SettingsException('${d.key}: يلزم عنصر واحد على الأقل');
        if (out.length > 40) throw SettingsException('${d.key}: الحد الأقصى 40 عنصراً');
        return out;
      default: // string
        final s = (v ?? '').toString().trim();
        if (d.key == 'vouchers.default_treasury_account_id' && s.isNotEmpty) {
          final row = await db.customSelect(
              'SELECT is_cash, is_bank, is_wallet, is_postable FROM accounts WHERE id = ?',
              variables: [_v(s)]).get();
          if (row.isEmpty) throw SettingsException('حساب الخزينة الافتراضي غير موجود');
          final r = row.first;
          if (!(r.read<bool>('is_cash') || r.read<bool>('is_bank') || r.read<bool>('is_wallet'))) {
            throw SettingsException('الحساب الافتراضي يجب أن يكون صندوقاً أو بنكاً أو محفظة');
          }
        }
        if (d.key.endsWith('_prefix')) {
          if (!RegExp(r'^[A-Za-z0-9]{1,8}$').hasMatch(s)) {
            throw SettingsException('${d.key}: 1-8 أحرف إنجليزية أو أرقام');
          }
        }
        return s;
    }
  }

  /// رقم تسلسلي ذرّي (يبدأ من 1) باسم عدّاد معيّن.
  Future<int> nextSequence(String name) async {
    return db.transaction(() async {
      await db.customStatement(
        'INSERT INTO sequences(name, value) VALUES(?, 1) '
        'ON CONFLICT(name) DO UPDATE SET value = value + 1',
        [name],
      );
      final rows = await db.customSelect('SELECT value FROM sequences WHERE name = ?',
          variables: [_v(name)]).get();
      return rows.first.read<int>('value');
    });
  }

  /// رقم سند: REC-2026-0001 (البادئة من الإعدادات، والسنة من تاريخ السند).
  Future<String> nextVoucherNo(String kind, String voucherDate) async {
    final isReceipt = kind == 'قبض';
    final prefix = await get<String>(isReceipt ? 'vouchers.receipt_prefix' : 'vouchers.payment_prefix');
    final year = voucherDate.length >= 4 ? voucherDate.substring(0, 4) : DateTime.now().year.toString();
    final seq = await nextSequence('voucher_${isReceipt ? 'receipt' : 'payment'}_$year');
    return '$prefix-$year-${seq.toString().padLeft(4, '0')}';
  }

  /// رصيد حساب (مدين − دائن) من القيود المرحّلة فقط.
  Future<double> accountBalance(String accountId) async {
    final rows = await db.customSelect(
      'SELECT COALESCE(SUM(l.debit), 0) - COALESCE(SUM(l.credit), 0) AS bal '
      'FROM journal_lines l JOIN journal_entries e ON e.id = l.entry_id '
      "WHERE l.account_id = ? AND e.status = 'posted'",
      variables: [_v(accountId)],
    ).get();
    return (rows.first.data['bal'] as num).toDouble();
  }

  static Variable<String> _v(String s) => Variable<String>(s);
}
