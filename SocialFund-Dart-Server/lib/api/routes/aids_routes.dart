import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../db/repositories/aids_repository.dart';
import '../../core/currency_math.dart';
import '../../db/repositories/currencies_repository.dart';
import '../middleware.dart';

class AidsRoutes {
  final AppDatabase db;
  AidsRoutes(this.db);

  Router get router {
    final r = Router();
    final repo = AidsRepository(db);

    r.get('/aids', (Request req) async {
      final q = req.url.queryParameters;
      final list = await repo.list(memberId: q['member_id'], status: q['status'], limit: int.tryParse(q['limit'] ?? '') ?? 200, offset: int.tryParse(q['offset'] ?? '') ?? 0);
      return jsonOk(list.map(_toJson).toList());
    });

    r.get('/aids/<id>', (Request req, String id) async {
      final a = await repo.byId(id);
      if (a == null) return jsonErr(404, 'Aid not found');
      return jsonOk(_toJson(a));
    });

    r.post('/aids', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final memberId = (b['member_id'] ?? '').toString().trim();
      final memberName = (b['member_name'] ?? '').toString().trim();
      final aidType = (b['aid_type'] ?? '').toString().trim();
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
      final requestDate = (b['request_date'] ?? '').toString().trim();
      if (memberId.isEmpty || aidType.isEmpty || amount <= 0 || requestDate.isEmpty) {
        return jsonErr(400, 'member_id, aid_type, amount, request_date required');
      }
      final a = await repo.create(
        memberId: memberId, memberName: memberName, aidType: aidType,
        amount: amount, requestDate: requestDate,
        note: b['note'] as String?, createdBy: req.context['userId'] as String?,
        beneficiaryId: b['beneficiary_id'] as String?,
        currencyCode: money.currencyCode, originalAmount: money.originalAmount, exchangeRate: money.exchangeRate,
      );
      return jsonOk(_toJson(a));
    });

    r.put('/aids/<id>', (Request req, String id) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final status = (b['status'] ?? '').toString().trim();
      if (status.isEmpty) return jsonErr(400, 'status required');
      final a = await repo.updateStatus(id, status: status,
        reviewerName: b['reviewer_name'] as String?,
        reviewerId: req.context['userId'] as String?,
        note: b['note'] as String?,
      );
      if (a == null) return jsonErr(404, 'Aid not found');
      return jsonOk(_toJson(a));
    });

    r.delete('/aids/<id>', (Request req, String id) async {
      final ok = await repo.softDelete(id);
      if (!ok) return jsonErr(404, 'Aid not found');
      return jsonOk({'ok': true});
    });

    return r;
  }

  static Map<String, dynamic> _toJson(AidRequest a) => {
    'id': a.id, 'member_id': a.memberId, 'member_name': a.memberName,
    'aid_type': a.aidType, 'amount': a.amount,
    'request_date': a.requestDate, 'status': a.status,
    'note': a.note, 'reviewer_name': a.reviewerName,
    'currency': a.currencyCode, 'original_amount': a.originalAmount, 'exchange_rate': a.exchangeRate,
  };
}
