import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../db/repositories/currencies_repository.dart';
import '../middleware.dart';

/// العملات وأسعار الصرف. القراءة لكل مستخدم مسجَّل (التطبيق يحتاجها لتنسيق
/// المبالغ)، والتعديل لمن يملك صلاحية settings (انظر Authorization).
class CurrenciesRoutes {
  final AppDatabase db;
  CurrenciesRoutes(this.db);

  Router get router {
    final r = Router();
    final repo = CurrenciesRepository(db);

    r.get('/currencies', (Request req) async {
      final all = req.url.queryParameters['all'] == '1';
      final list = await repo.list(onlyActive: !all);
      return jsonOk(list.map(_toJson).toList());
    });

    r.post('/currencies', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      try {
        final c = await repo.upsert(
          code: (b['code'] ?? '').toString(),
          nameAr: (b['name_ar'] ?? '').toString().trim(),
          symbol: (b['symbol'] ?? '').toString().trim(),
          decimals: (b['decimals'] as num?)?.toInt() ?? 2,
          rate: (b['rate'] as num?)?.toDouble(),
          isActive: b['is_active'] as bool?,
          changedBy: req.context['userId'] as String?,
        );
        return jsonOk(_toJson(c));
      } on CurrencyException catch (e) {
        return jsonErr(400, e.message);
      }
    });

    r.put('/currencies/<code>', (Request req, String code) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final existing = await repo.byCode(code);
      if (existing == null) return jsonErr(404, 'العملة غير موجودة');
      try {
        final c = await repo.upsert(
          code: existing.code,
          nameAr: (b['name_ar'] ?? existing.nameAr).toString().trim(),
          symbol: (b['symbol'] ?? existing.symbol).toString().trim(),
          decimals: (b['decimals'] as num?)?.toInt() ?? existing.decimals,
          rate: (b['rate'] as num?)?.toDouble(),
          isActive: b['is_active'] as bool?,
          changedBy: req.context['userId'] as String?,
        );
        return jsonOk(_toJson(c));
      } on CurrencyException catch (e) {
        return jsonErr(400, e.message);
      }
    });

    r.get('/currencies/<code>/history', (Request req, String code) async {
      final h = await repo.history(code);
      return jsonOk([
        for (final x in h)
          {'rate': x.rate, 'changed_by': x.changedBy, 'at': x.createdAt.toIso8601String()},
      ]);
    });

    /// اختيار العملة المحلية و/أو الافتراضية: {"local": "YER", "default": "USD"}
    r.put('/currencies-config', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      try {
        await repo.setConfig(
          localCode: b['local'] as String?,
          defaultCode: b['default'] as String?,
        );
      } on CurrencyException catch (e) {
        return jsonErr(400, e.message);
      }
      final list = await repo.list(onlyActive: false);
      return jsonOk(list.map(_toJson).toList());
    });

    return r;
  }

  static Map<String, dynamic> _toJson(Currency c) => {
    'code': c.code, 'name_ar': c.nameAr, 'symbol': c.symbol,
    'decimals': c.decimals, 'rate': c.rate,
    'is_local': c.isLocal, 'is_default': c.isDefault, 'is_active': c.isActive,
  };
}
