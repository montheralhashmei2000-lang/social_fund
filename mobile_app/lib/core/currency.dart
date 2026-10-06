import 'package:intl/intl.dart';

/// عملة معرّفة في النظام. [rate] = كم وحدة من العملة المحلية تساوي وحدة منها.
class Currency {
  final String code;
  final String nameAr;
  final String symbol;
  final int decimals;
  final double rate;
  final bool isLocal;
  final bool isDefault;
  final bool isActive;

  const Currency({
    required this.code,
    required this.nameAr,
    required this.symbol,
    required this.decimals,
    required this.rate,
    required this.isLocal,
    required this.isDefault,
    required this.isActive,
  });

  factory Currency.fromJson(Map<String, dynamic> j) => Currency(
        code: (j['code'] ?? '').toString(),
        nameAr: (j['name_ar'] ?? '').toString(),
        symbol: (j['symbol'] ?? '').toString(),
        decimals: (j['decimals'] as num?)?.toInt() ?? 2,
        rate: (j['rate'] as num?)?.toDouble() ?? 0,
        isLocal: j['is_local'] == true,
        isDefault: j['is_default'] == true,
        isActive: j['is_active'] != false,
      );

  /// مبلغ بهذه العملة ← العملة المحلية (نفس تقريب الخادم).
  int toLocal(double original) => (original * rate).round();

  /// مبلغ بالعملة المحلية ← هذه العملة.
  double fromLocal(num local) => rate > 0 ? local / rate : 0;

  String format(num amountInThisCurrency) {
    final f = NumberFormat(decimals > 0 ? '#,##0.${'0' * decimals}' : '#,##0');
    return '${f.format(amountInThisCurrency)} $symbol';
  }
}

/// أصل المبلغ عند إدخاله بعملة غير المحلية (للعرض والتدقيق فقط؛ المجاميع بالمحلية).
class MoneyOrigin {
  final String currency;
  final double original;
  final double rate;
  const MoneyOrigin(this.currency, this.original, this.rate);

  static MoneyOrigin? from(Map<String, dynamic> j) {
    final c = j['currency'];
    final o = j['original_amount'];
    if (c is! String || c.isEmpty || o is! num) return null;
    return MoneyOrigin(c, o.toDouble(), (j['exchange_rate'] as num?)?.toDouble() ?? 0);
  }

  /// مثال: 100 USD @ 2,530
  String get label {
    final f = NumberFormat('#,##0.##');
    final r = rate > 0 ? ' @ ${f.format(rate)}' : '';
    return '${f.format(original)} $currency$r';
  }
}

/// تنسيق المبالغ على مستوى التطبيق: كل المبالغ المخزّنة بالعملة المحلية تُعرض
/// بعملة العرض المختارة. يُحدَّث من CurrencyController.
class CurrencyFormat {
  CurrencyFormat._();

  static Currency? local;
  static Currency? display;

  /// يحوّل مبلغاً محلياً إلى نص بعملة العرض.
  static String format(num localAmount) {
    final loc = local;
    final disp = display;
    if (loc == null) {
      return '${NumberFormat('#,##0').format(localAmount)} ﷼';
    }
    if (disp == null || disp.code == loc.code || disp.rate <= 0) {
      return loc.format(localAmount);
    }
    return disp.format(disp.fromLocal(localAmount));
  }
}
