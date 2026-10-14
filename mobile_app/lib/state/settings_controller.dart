import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../services/api_service.dart';

/// إعدادات النظام المخزّنة في الخادم (أنواع المساعدات، طرق الدفع، سياسات…).
/// القيم الافتراضية هنا تطابق الخادم، فيعمل التطبيق بها مع خوادم لا تدعم الإعدادات
/// (مثل FastAPI) أو قبل اكتمال التحميل.
class SettingsController extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  static const Map<String, Object?> defaults = {
    'aids.types': [
      'مساعدة طارئة', 'مساعدة مرضية', 'مساعدة تعليمية', 'مساعدة زواج', 'مساعدة وفاة', 'مساعدة سكن', 'سلة غذائية',
    ],
    'aids.require_second_approver': false,
    'aids.max_amount': 0,
    'payments.methods': ['نقداً', 'تحويل بنكي', 'محفظة إلكترونية', 'شيك'],
    'subscriptions.default_amount': 0,
    'vouchers.block_overdraft': false,
    'vouchers.default_treasury_account_id': '',
    'vouchers.receipt_prefix': 'REC',
    'vouchers.payment_prefix': 'PAY',
    'accounting.fiscal_year_start_month': 1,
    'reports.default_period': 'month',
    'reports.default_format': 'pdf',
  };

  Map<String, Object?> values = Map.of(defaults);

  /// هل الخادم الحالي يدعم الإعدادات؟ (false = تُعرض الأقسام للقراءة فقط بالقيم الافتراضية)
  bool supported = true;
  bool loaded = false;
  String? lastError;

  Future<void> load() async {
    try {
      final remote = await _api.appSettings();
      values = {...defaults, ...remote};
      supported = true;
      lastError = null;
    } on ApiException catch (e) {
      supported = e.status != 404;
      lastError = e.message;
    } catch (_) {
      lastError = 'تعذّر تحميل الإعدادات';
    }
    loaded = true;
    notifyListeners();
  }

  /// يحفظ مجموعة تغييرات دفعة واحدة. يرمي [ApiException] برسالة الخادم عند الرفض.
  Future<void> save(Map<String, Object?> patch) async {
    final updated = await _api.updateAppSettings(patch);
    values = {...defaults, ...updated};
    notifyListeners();
  }

  void clear() {
    values = Map.of(defaults);
    loaded = false;
    supported = true;
    lastError = null;
    notifyListeners();
  }

  // ───────── قراءات مكتوبة ─────────

  List<String> _list(String k) => List<String>.from((values[k] as List?) ?? (defaults[k] as List));
  bool _bool(String k) => (values[k] as bool?) ?? (defaults[k] as bool);
  num _num(String k) => (values[k] as num?) ?? (defaults[k] as num);
  String _str(String k) => (values[k] as String?) ?? (defaults[k] as String);

  List<String> get aidTypes => _list('aids.types');
  List<String> get paymentMethods => _list('payments.methods');
  bool get requireSecondApprover => _bool('aids.require_second_approver');
  num get maxAidAmount => _num('aids.max_amount');
  num get defaultSubscription => _num('subscriptions.default_amount');
  bool get blockOverdraft => _bool('vouchers.block_overdraft');
  String get defaultTreasuryAccountId => _str('vouchers.default_treasury_account_id');
  String get receiptPrefix => _str('vouchers.receipt_prefix');
  String get paymentPrefix => _str('vouchers.payment_prefix');
  int get fiscalStartMonth => _num('accounting.fiscal_year_start_month').toInt();
  String get reportsPeriod => _str('reports.default_period');
  String get reportsFormat => _str('reports.default_format');

  /// بداية السنة المالية الحالية (حسب شهر البداية المضبوط) كنص yyyy-MM-dd.
  String fiscalYearStart([DateTime? now]) {
    final n = now ?? DateTime.now();
    final m = fiscalStartMonth;
    final year = n.month >= m ? n.year : n.year - 1;
    return '$year-${m.toString().padLeft(2, '0')}-01';
  }

  /// بداية الفترة الافتراضية للتقارير (شهر/ربع/سنة مالية) كنص yyyy-MM-dd.
  String periodStart([DateTime? now]) {
    final n = now ?? DateTime.now();
    switch (reportsPeriod) {
      case 'year':
        return fiscalYearStart(n);
      case 'quarter':
        final q = ((n.month - 1) ~/ 3) * 3 + 1;
        return '${n.year}-${q.toString().padLeft(2, '0')}-01';
      default:
        return '${n.year}-${n.month.toString().padLeft(2, '0')}-01';
    }
  }
}
