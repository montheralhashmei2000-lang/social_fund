import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../db/repositories/accounts_repository.dart';
import '../../db/repositories/journal_repository.dart';
import '../middleware.dart';

class AccountsRoutes {
  final AppDatabase db;
  AccountsRoutes(this.db);
  Router get router {
    final r = Router();
    final repo = AccountsRepository(db);

    r.get('/accounts', (Request req) async {
      final onlyPostable = req.url.queryParameters['postable'] == 'true';
      final list = await repo.list(onlyPostable: onlyPostable);
      return jsonOk(list.map(_toJson).toList());
    });

    /// شجرة هرمية كاملة (متوافقة مع UI الشجرة).
    r.get('/accounts/tree', (Request req) async {
      final list = await repo.list();
      // نبني قائمة مسطحة مع حقل parent_id — الواجهة تبني الشجرة
      return jsonOk(list.map(_toJson).toList());
    });

    r.post('/accounts', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final code = (b['code'] ?? '').toString();
      final name = (b['name'] ?? '').toString();
      final type = (b['type'] ?? 'asset').toString();
      if (code.isEmpty || name.isEmpty) return jsonErr(400, 'code, name required');
      final a = await repo.create(
        code: code, name: name, type: type,
        parentId: b['parent_id'] as String?,
        isPostable: b['is_postable'] != false,
        level: (b['level'] as num?)?.toInt() ?? 1,
        isBank: b['is_bank'] == true, isCash: b['is_cash'] == true,
        isWallet: b['is_wallet'] == true,
        bankName: b['bank_name'] as String?,
        accountNumber: b['account_number'] as String?,
      );
      return jsonOk(_toJson(a));
    });

    r.post('/accounts/seed-defaults', (Request req) async {
      final count = await repo.seedDefaults();
      if (count == 0) {
        return jsonOk({'ok': true, 'created': 0, 'message': 'شجرة الحسابات موجودة مسبقاً'});
      }
      return jsonOk({'ok': true, 'created': count});
    });

    r.post('/accounts/reset', (Request req) async {
      await repo.deleteAll();
      return jsonOk({'ok': true});
    });

    // تحويل بين حسابين (خزينة/بنك): قيد مزدوج فعلي. كان سابقاً يعيد ok دون تنفيذ.
    r.post('/accounts/transfer', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final fromId = (b['from_account_id'] ?? '').toString();
      final toId = (b['to_account_id'] ?? '').toString();
      final amount = (b['amount'] as num?)?.toDouble() ?? 0;
      final date = (b['entry_date'] ?? '').toString().trim();
      if (fromId.isEmpty || toId.isEmpty || fromId == toId || amount <= 0 || date.isEmpty) {
        return jsonErr(400, 'حساب المصدر والوجهة (مختلفان) والمبلغ والتاريخ مطلوبة');
      }
      final from = await (db.select(db.accounts)..where((t) => t.id.equals(fromId))).getSingleOrNull();
      final to = await (db.select(db.accounts)..where((t) => t.id.equals(toId))).getSingleOrNull();
      if (from == null || to == null) return jsonErr(400, 'حساب غير موجود');
      if (!from.isPostable || !to.isPostable) return jsonErr(400, 'لا يمكن التحويل من/إلى حساب رئيسي');
      final desc = (b['description'] ?? '').toString().trim();
      final id = await JournalRepository(db).createEntry(
        description: desc.isEmpty ? 'تحويل من ${from.name} إلى ${to.name}' : desc,
        entryDate: date,
        entryType: 'transfer',
        debitAccountId: toId,
        creditAccountId: fromId,
        amount: amount,
        createdBy: req.context['userId'] as String?,
      );
      return jsonOk({'ok': true, 'journal_entry_id': id});
    });

    return r;
  }

  static Map<String, dynamic> _toJson(Account a) => {
    'id': a.id, 'code': a.code, 'name': a.name, 'type': a.type,
    'type_label': _typeLabel(a.type),
    'parent_id': a.parentId,
    'is_postable': a.isPostable,
    'level': a.level,
    'sort_order': a.sortOrder,
    'description': a.description,
    'is_bank': a.isBank, 'is_cash': a.isCash, 'is_wallet': a.isWallet,
    'bank_name': a.bankName, 'account_number': a.accountNumber,
    'currency': a.currency, 'is_active': a.isActive, 'balance': 0,
  };

  static String _typeLabel(String type) {
    switch (type) {
      case 'asset': return 'أصول';
      case 'liability': return 'التزامات';
      case 'equity': return 'حقوق ملكية';
      case 'income': return 'إيرادات';
      case 'expense': return 'مصروفات';
      default: return type;
    }
  }
}
