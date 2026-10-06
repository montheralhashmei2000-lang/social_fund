/// فرض الصلاحيات في الخادم (وليس في الواجهة فقط).
///
/// الجدول مطابق لـ Rbac في التطبيق (mobile_app/lib/core/rbac.dart). كل مسار
/// يُربط بمورد؛ والمستخدم يحتاج صلاحية المورد لأي طلب عليه (قراءة أو كتابة)،
/// عدا الاستثناءات الصريحة أدناه.
class Authorization {
  Authorization._();

  static const Map<String, Set<String>> _permissions = {
    'admin': {
      'members', 'subscriptions', 'aids', 'treasury', 'vouchers',
      'messages', 'scheduler', 'reports', 'settings', 'users',
      'accounting', 'donors', 'campaigns', 'beneficiaries', 'inkind', 'budgets',
    },
    'accountant': {
      'members', 'subscriptions', 'treasury', 'vouchers', 'reports',
      'accounting', 'donors', 'campaigns', 'budgets', 'inkind',
    },
    'reviewer': {'members', 'aids', 'reports', 'beneficiaries'},
    'viewer': {'reports'},
  };

  /// أول مقطع من المسار ← المورد المطلوب.
  static const Map<String, String> _resourceByPrefix = {
    'members': 'members',
    'aids': 'aids',
    'subscriptions': 'subscriptions',
    'treasury': 'treasury',
    'vouchers': 'vouchers',
    'events': 'scheduler',
    'audit-logs': 'users',
    'users': 'users',
    'accounts': 'accounting',
    'journal': 'accounting',
    'budgets': 'budgets',
    'financial-reports': 'reports',
    'reports': 'reports',
    'donors': 'donors',
    'pledges': 'donors',
    'campaigns': 'campaigns',
    'beneficiaries': 'beneficiaries',
    'periodic-aids': 'beneficiaries',
    'inkind': 'inkind',
    'backup': 'settings',
  };

  /// هل يُسمح للدور [role] بتنفيذ [method] على [path]؟
  /// المسارات غير المعرّفة (رسائل، زملاء، بيانات الصندوق للقراءة…) تتطلب تسجيل
  /// الدخول فقط، أما المجهولة كلياً فتُرفض افتراضياً (default-deny).
  static bool allowed(String? role, String method, String path) {
    final segs = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segs.isEmpty) return false;
    final first = segs.first;

    // متاح لكل مستخدم مسجَّل
    if (first == 'messages') return true;
    if (first == 'users' && segs.length == 2 && segs[1] == 'colleagues' && method == 'GET') {
      return true;
    }
    // رموز الإشعارات: لكل مستخدم مسجَّل (تخص جهازه هو)
    if (first == 'push') return true;
    // العملات: قراءة لكل مستخدم (لتنسيق المبالغ)، تعديل لمن يملك settings
    if (first == 'currencies' || first == 'currencies-config') {
      return method == 'GET' || _can(role, 'settings');
    }
    // بيانات الصندوق: قراءة للجميع (تظهر على السندات)، تعديل لمن يملك settings
    if (first == 'fund-settings') {
      return method == 'GET' || _can(role, 'settings');
    }
    // مسح بطاقة العضو ميدانياً: من يملك الأعضاء أو المساعدات
    if (first == 'members' && segs.length == 3 && segs[2] == 'card-verify') {
      return _can(role, 'members') || _can(role, 'aids');
    }

    final resource = _resourceByPrefix[first];
    if (resource == null) return false; // مسار غير معروف: رفض
    return _can(role, resource);
  }

  static bool _can(String? role, String resource) =>
      _permissions[role]?.contains(resource) ?? false;
}
