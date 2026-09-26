/// أدوار المستخدمين وصلاحياتهم - مطابقة تماماً لجدول ROLE_PERMISSIONS
/// في الخادم (app/models/user.py). الخادم يفرض الصلاحيات فعلياً؛ هذا
/// الملف يستخدم لإخفاء الشاشات والأزرار غير المصرح بها في الواجهة فقط.
class Rbac {
  Rbac._();

  static const String admin = 'admin';
  static const String accountant = 'accountant';
  static const String reviewer = 'reviewer';
  static const String viewer = 'viewer';

  static const Map<String, String> labels = {
    admin: 'مدير النظام',
    accountant: 'محاسب',
    reviewer: 'مراجع',
    viewer: 'مراقب',
  };

  static const Map<String, Set<String>> _permissions = {
    admin: {
      'members', 'subscriptions', 'aids', 'treasury', 'vouchers',
      'messages', 'scheduler', 'reports', 'settings', 'users',
      'accounting', 'donors', 'campaigns', 'beneficiaries', 'inkind', 'budgets',
    },
    accountant: {
      'members', 'subscriptions', 'treasury', 'vouchers', 'reports',
      'accounting', 'donors', 'campaigns', 'budgets', 'inkind',
    },
    reviewer: {'members', 'aids', 'reports', 'beneficiaries'},
    viewer: {'reports'},
  };

  static bool can(String? role, String resource) =>
      _permissions[role]?.contains(resource) ?? false;

  static String label(String? role) => labels[role] ?? (role ?? '');
}
