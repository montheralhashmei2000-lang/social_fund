import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../db/repositories/treasury_repository.dart';
import '../../core/currency_math.dart';
import '../../db/repositories/currencies_repository.dart';
import '../middleware.dart';

class TreasuryRoutes {
  final AppDatabase db;
  TreasuryRoutes(this.db);

  Router get router {
    final r = Router();
    final repo = TreasuryRepository(db);

    r.get('/treasury', (Request req) async {
      final q = req.url.queryParameters;
      final list = await repo.list(type: q['type'], limit: int.tryParse(q['limit'] ?? '') ?? 200, offset: int.tryParse(q['offset'] ?? '') ?? 0);
      return jsonOk(list.map(_toJson).toList());
    });

    r.get('/treasury/summary', (Request req) async {
      final all = await repo.list(limit: 100000);
      var income = 0, expense = 0;
      for (final e in all) {
        if (e.type == 'إيراد') income += e.amount;
        else if (e.type == 'مصروف') expense += e.amount;
      }
      return jsonOk({
        'total_income': income, 'total_expense': expense,
        'balance': income - expense, 'count': all.length,
      });
    });

    r.post('/treasury', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final type = (b['type'] ?? '').toString().trim();
      final category = (b['category'] ?? '').toString().trim();
      final description = (b['description'] ?? '').toString().trim();
      final rawAmount = (b['amount'] as num?)?.toInt() ?? 0;
      final ResolvedMoney money;
      try {
        money = await CurrenciesRepository(db).resolve(
          code: b['currency'] as String?,
          originalAmount: b['original_amount'] as num?,
          localAmount: rawAmount,
        );
      } on CurrencyException catch (e) {
        return jsonErr(400, e.message);
      }
      final amount = money.amount;
      final entryDate = (b['entry_date'] ?? '').toString().trim();
      if (type.isEmpty || category.isEmpty || amount <= 0 || entryDate.isEmpty) {
        return jsonErr(400, 'type, category, amount, entry_date required');
      }
      final e = await repo.create(
        type: type, category: category, description: description,
        amount: amount, entryDate: entryDate,
        referenceNo: b['reference_no'] as String?,
        currencyCode: money.currencyCode, originalAmount: money.originalAmount, exchangeRate: money.exchangeRate,
      );
      return jsonOk(_toJson(e));
    });

    r.delete('/treasury/<id>', (Request req, String id) async {
      final ok = await repo.softDelete(id);
      if (!ok) return jsonErr(404, 'Entry not found');
      return jsonOk({'ok': true});
    });

    return r;
  }

  static Map<String, dynamic> _toJson(TreasuryEntry e) => {
    'id': e.id, 'type': e.type, 'category': e.category,
    'description': e.description, 'amount': e.amount,
    'entry_date': e.entryDate, 'reference_no': e.referenceNo,
    'currency': e.currencyCode, 'original_amount': e.originalAmount, 'exchange_rate': e.exchangeRate,
  };
}
