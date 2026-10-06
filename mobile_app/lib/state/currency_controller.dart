import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../core/currency.dart';
import '../core/secure_store.dart';
import '../services/api_service.dart';

/// العملات وأسعار الصرف.
/// - العملة المحلية: عملة الدفاتر (يحددها المدير)، كل المبالغ المخزّنة بها.
/// - عملة النظام الافتراضية: يحددها المدير.
/// - عملة العرض: تفضيل هذا الجهاز إن وُجد، وإلا الافتراضية؛ بها تُعرض المبالغ
///   ويُبدأ الإدخال.
class CurrencyController extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  List<Currency> all = [];
  String? _preferred;
  String? lastError;
  bool loaded = false;

  List<Currency> get active => all.where((c) => c.isActive).toList();

  Currency? get local {
    for (final c in all) {
      if (c.isLocal) return c;
    }
    return null;
  }

  Currency? get systemDefault {
    for (final c in all) {
      if (c.isDefault) return c;
    }
    return local;
  }

  /// عملة العرض الفعلية.
  Currency? get display {
    final p = _preferred;
    if (p != null) {
      for (final c in active) {
        if (c.code == p) return c;
      }
    }
    return systemDefault;
  }

  /// تحميل العملات (مفعّلة فقط لغير المدير، والكل لمن يعدّل). الخطأ لا يوقف التطبيق:
  /// تبقى المبالغ بالعملة المحلية الافتراضية.
  Future<void> load({bool includeInactive = false}) async {
    try {
      _preferred = await SecureStore.displayCurrency();
      all = await _api.currencies(all: includeInactive);
      lastError = null;
      loaded = true;
    } on ApiException catch (e) {
      lastError = e.message;
    } catch (_) {
      lastError = 'تعذّر تحميل العملات';
    }
    _publish();
    notifyListeners();
  }

  void _publish() {
    CurrencyFormat.local = local;
    CurrencyFormat.display = display;
  }

  /// يختار المستخدم عملة العرض لجهازه (null = العودة لافتراضية النظام).
  Future<void> setDisplay(String? code) async {
    _preferred = code;
    await SecureStore.setDisplayCurrency(code);
    _publish();
    notifyListeners();
  }

  // ===== إدارة (للمدير) =====

  Future<void> save(Map<String, dynamic> data, {String? existingCode}) async {
    await _api.saveCurrency(data, existingCode: existingCode);
    await load(includeInactive: true);
  }

  Future<void> setConfig({String? local, String? defaultCode}) async {
    await _api.setCurrencyConfig(local: local, defaultCode: defaultCode);
    await load(includeInactive: true);
  }

  Future<List<Map<String, dynamic>>> history(String code) => _api.currencyHistory(code);

  void clear() {
    all = [];
    _preferred = null;
    loaded = false;
    CurrencyFormat.local = null;
    CurrencyFormat.display = null;
    notifyListeners();
  }
}
