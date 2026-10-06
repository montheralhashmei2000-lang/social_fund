import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';

class JournalException implements Exception {
  final String message;
  JournalException(this.message);
  @override
  String toString() => message;
}

class ManualLine {
  final String accountId;
  final double debit;
  final double credit;
  const ManualLine({required this.accountId, required this.debit, required this.credit});
}

class JournalRepository {
  final AppDatabase db;
  JournalRepository(this.db);

  /// يولّد رقم قيد تسلسلي: JE-000001
  Future<String> _nextEntryNo() async {
    final row = await (db.select(db.counters)
          ..where((t) => t.name.equals('journal_entry')))
        .getSingleOrNull();
    var next = 1;
    if (row == null) {
      await db.into(db.counters).insert(
        CountersCompanion.insert(name: 'journal_entry', value: const Value(1)),
      );
    } else {
      next = row.value + 1;
      await (db.update(db.counters)..where((t) => t.name.equals('journal_entry')))
          .write(CountersCompanion(value: Value(next)));
    }
    return 'JE-${next.toString().padLeft(6, '0')}';
  }

  /// ينشئ قيداً متوازناً من سطرين (مدين + دائن).
  /// يعيد معرّف القيد.
  Future<String> createEntry({
    required String description,
    required String entryDate,           // YYYY-MM-DD
    required String entryType,           // voucher_receipt | voucher_payment | ...
    required String debitAccountId,
    required String creditAccountId,
    required double amount,
    String? reference,
    String? voucherId,
    String? memberId,
    String? aidId,
    String? createdBy,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('amount must be > 0');
    }

    final entryNo = await _nextEntryNo();
    final entryId = const Uuid().v4();
    final now = DateTime.now();

    await db.transaction(() async {
      await db.into(db.journalEntries).insert(JournalEntriesCompanion.insert(
        id: entryId,
        entryNo: entryNo,
        entryDate: entryDate,
        description: description,
        entryType: entryType,
        reference: Value(reference),
        status: const Value('posted'),
        voucherId: Value(voucherId),
        memberId: Value(memberId),
        aidId: Value(aidId),
        createdBy: Value(createdBy),
        createdAt: now,
      ));

      // سطر المدين
      await db.into(db.journalLines).insert(JournalLinesCompanion.insert(
        id: const Uuid().v4(),
        entryId: entryId,
        accountId: debitAccountId,
        debit: Value(amount),
        credit: const Value(0),
        memo: Value(description),
      ));

      // سطر الدائن
      await db.into(db.journalLines).insert(JournalLinesCompanion.insert(
        id: const Uuid().v4(),
        entryId: entryId,
        accountId: creditAccountId,
        debit: const Value(0),
        credit: Value(amount),
        memo: Value(description),
      ));
    });

    return entryId;
  }

  /// قيد يدوي متعدد الأسطر: يجب أن يتوازن (مدين = دائن) وكل سطر في جانب واحد،
  /// والحسابات موجودة ونشطة وقابلة للترحيل.
  Future<String> createManual({
    required String entryDate,
    required String description,
    required String entryType,
    required List<ManualLine> lines,
    String? createdBy,
  }) async {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(entryDate)) {
      throw JournalException('تاريخ القيد بصيغة YYYY-MM-DD');
    }
    if (lines.length < 2) throw JournalException('القيد يتطلب سطرين على الأقل');
    var totalDebit = 0.0, totalCredit = 0.0;
    for (final l in lines) {
      if (l.debit < 0 || l.credit < 0) throw JournalException('المبالغ لا تكون سالبة');
      if ((l.debit > 0) == (l.credit > 0)) {
        throw JournalException('كل سطر إما مدين أو دائن (وليس الاثنين ولا صفراً)');
      }
      totalDebit += l.debit;
      totalCredit += l.credit;
    }
    if ((totalDebit - totalCredit).abs() > 0.005) {
      throw JournalException('القيد غير متوازن: مدين $totalDebit ≠ دائن $totalCredit');
    }
    for (final l in lines) {
      final a = await (db.select(db.accounts)..where((t) => t.id.equals(l.accountId))).getSingleOrNull();
      if (a == null) throw JournalException('حساب غير موجود');
      if (!a.isPostable) throw JournalException('الحساب «${a.name}» غير قابل للترحيل (حساب رئيسي)');
    }

    final entryNo = await _nextEntryNo();
    final entryId = const Uuid().v4();
    await db.transaction(() async {
      await db.into(db.journalEntries).insert(JournalEntriesCompanion.insert(
        id: entryId, entryNo: entryNo, entryDate: entryDate,
        description: description.isEmpty ? 'قيد يومية' : description,
        entryType: entryType.isEmpty ? 'manual' : entryType,
        status: const Value('posted'),
        createdBy: Value(createdBy), createdAt: DateTime.now(),
      ));
      for (final l in lines) {
        await db.into(db.journalLines).insert(JournalLinesCompanion.insert(
          id: const Uuid().v4(), entryId: entryId, accountId: l.accountId,
          debit: Value(l.debit), credit: Value(l.credit), memo: Value(description),
        ));
      }
    });
    return entryId;
  }

  /// قائمة القيود مع أسطرها.
  Future<List<Map<String, dynamic>>> list({int limit = 200}) async {
    final entries = await (db.select(db.journalEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();

    final result = <Map<String, dynamic>>[];
    for (final e in entries) {
      final lines = await (db.select(db.journalLines)
            ..where((t) => t.entryId.equals(e.id)))
          .get();
      final accountIds = lines.map((l) => l.accountId).toSet();
      final accounts = <String, Account>{};
      for (final id in accountIds) {
        final a = await (db.select(db.accounts)..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (a != null) accounts[id] = a;
      }
      result.add({
        'id': e.id,
        'entry_no': e.entryNo,
        'entry_date': e.entryDate,
        'description': e.description,
        'entry_type': e.entryType,
        'entry_type_label': _typeLabel(e.entryType),
        'reference': e.reference,
        'status': e.status,
        'total': lines.fold<double>(0, (s, l) => s + l.debit),
        'lines': lines.map((l) {
          final a = accounts[l.accountId];
          return {
            'account_id': l.accountId,
            'account_name': a?.name ?? '—',
            'account_code': a?.code,
            'memo': l.memo,
            'debit': l.debit,
            'credit': l.credit,
          };
        }).toList(),
      });
    }
    return result;
  }

  static String _typeLabel(String type) {
    switch (type) {
      case 'voucher_receipt': return 'سند قبض';
      case 'voucher_payment': return 'سند صرف';
      case 'transfer': return 'تحويل';
      default: return 'قيد عام';
    }
  }
}
