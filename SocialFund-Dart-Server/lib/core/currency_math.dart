/// نتيجة تحويل مبلغ: `amount` دائماً بالعملة المحلية (عدد صحيح).
class ResolvedMoney {
  final int amount;
  final String? currencyCode;
  final double? originalAmount;
  final double? exchangeRate;
  const ResolvedMoney({
    required this.amount, this.currencyCode, this.originalAmount, this.exchangeRate,
  });
}

/// مبلغ بعملة أجنبية ← العملة المحلية (تقريب لأقرب وحدة صحيحة).
int convertToLocal(double original, double rate) => (original * rate).round();

/// سعر عملة بعد جعل عملة أخرى هي المحلية: oldRate / newLocalOldRate.
double rebaseRate(double oldRate, double newLocalOldRate) => oldRate / newLocalOldRate;
