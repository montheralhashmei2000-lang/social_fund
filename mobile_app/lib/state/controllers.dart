import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/rbac.dart';
import '../core/secure_store.dart';
import '../services/api_service.dart';
import '../services/push_service.dart';

/// وضع النظام/الثيم - يُحفظ في التخزين الآمن.
class ThemeController extends ChangeNotifier {
  bool dark = false;

  Future<void> load() async {
    dark = await SecureStore.isDarkMode();
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    dark = value;
    await SecureStore.setDarkMode(value);
    notifyListeners();
  }
}

/// فحص الاتصال - التطبيق أونلاين فقط: عند فقد الاتصال تُعطَّل عمليات
/// الكتابة وتظهر شريط تنبيه، ولا شيء يُخزَّن محلياً بانتظار مزامنة.
class ConnectivityController extends ChangeNotifier {
  bool online = true;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  ConnectivityController() {
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      online = results.any((r) => r != ConnectivityResult.none);
      notifyListeners();
    });
    _check();
  }

  Future<void> _check() async {
    final results = await Connectivity().checkConnectivity();
    online = results.any((r) => r != ConnectivityResult.none);
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// المصادقة: دخول على خطوتين (كلمة مرور ← OTP)، جلسة مخزنة في التخزين
/// الآمن، وبصمة حقيقية عبر local_auth كبوابة لفتح الجلسة المحفوظة
/// (إصلاح ملاحظة الفحص 13: لم تعد البصمة محاكاة).
class AuthController extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  AppUser? user;
  bool booting = true;
  bool needsBiometricUnlock = false;
  bool biometricsAvailable = false;

  Future<void> boot() async {
    await ApiClient.instance.loadStoredTokens();
    biometricsAvailable = await _checkBiometrics();
    needsBiometricUnlock =
        ApiClient.instance.hasTokens && await SecureStore.biometricEnabled();
    if (ApiClient.instance.hasTokens && !needsBiometricUnlock) {
      await tryRestoreSession();
    }
    booting = false;
    notifyListeners();
  }

  Future<bool> _checkBiometrics() async {
    try {
      final la = LocalAuthentication();
      return await la.canCheckBiometrics || await la.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<void> tryRestoreSession() async {
    try {
      user = await _api.me();
      await PushService.onLogin();
    } on AuthException {
      user = null;
      needsBiometricUnlock = false;
      await SecureStore.setBiometricEnabled(false);
      await ApiClient.instance.clearTokens();
    } on NetworkException {
      // لا اتصال الآن - يبقى المستخدم على شاشة البصمة/الدخول
      user = null;
    }
  }

  /// خطوة 1: اسم المستخدم وكلمة المرور - يعرف بيانات خطوة OTP.
  Future<Map<String, dynamic>> login(String username, String password) =>
      _api.login(username, password);

  /// خطوة 2: التحقق من الرمز وحفظ الجلسة.
  Future<void> verifyOtp(String otpToken, String code) async {
    final deviceId = await SecureStore.deviceId();
    final tokens = await _api.verifyOtp(otpToken, code, deviceId);
    await ApiClient.instance
        .saveTokens(tokens['access_token'] as String, tokens['refresh_token'] as String);
    user = await _api.me();
    await PushService.onLogin();
    notifyListeners();
  }

  /// فتح الجلسة المحفوظة بالبصمة/قفل الجهاز - مصادقة بيومترية فعلية.
  Future<bool> unlockWithBiometrics() async {
    if (!biometricsAvailable) return false;
    final la = LocalAuthentication();
    final ok = await la.authenticate(
      localizedReason: 'افتح نظام الصندوق الاجتماعي التنموي',
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
        useErrorDialogs: true,
      ),
    );
    if (!ok) return false;
    await tryRestoreSession();
    notifyListeners();
    return user != null;
  }

  /// تفعيل البصمة يتطلب التحقق البيومتري فعلياً قبل الحفظ.
  Future<bool> enableBiometrics() async {
    if (!biometricsAvailable) return false;
    final la = LocalAuthentication();
    final ok = await la.authenticate(
      localizedReason: 'تأكيد الهوية لتفعيل الدخول بالبصمة',
      options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
    );
    if (!ok) return false;
    await SecureStore.setBiometricEnabled(true);
    notifyListeners();
    return true;
  }

  Future<void> disableBiometrics() async {
    await SecureStore.setBiometricEnabled(false);
    notifyListeners();
  }

  Future<bool> biometricEnabled() => SecureStore.biometricEnabled();

  Future<void> changePassword(String oldPassword, String newPassword) =>
      _api.changePassword(oldPassword, newPassword);

  Future<void> logout() async {
    try {
      final refresh = await SecureStore.refreshToken();
      await _api.logout(refresh);
    } catch (_) {
      // الخروج المحلي يتم دائماً حتى لو فشل استدعاء الخادم
    }
    await PushService.onLogout();
    await ApiClient.instance.clearTokens();
    user = null;
    needsBiometricUnlock = false;
    notifyListeners();
  }

  Future<void> logoutAllDevices() async {
    try {
      await _api.logoutAll();
    } catch (_) {}
    await logout();
  }
}

/// بيانات النظام - كلها من الخادم مباشرة (أونلاين فقط). لا تخزين محلي
/// لأي بيانات أعضاء أو معاملات مالية (إصلاح ملاحظة الفحص 12).
class DataController extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  bool loading = false;
  String? lastError;

  List<Member> members = [];
  List<AidRequest> aids = [];
  List<Subscription> subscriptions = [];
  List<TreasuryEntry> treasury = [];
  List<Voucher> vouchers = [];
  List<MessageModel> messages = [];
  List<EventModel> events = [];
  FundSettings? fundSettings;

  List<Colleague>? _colleagues;
  List<AdminUser>? _users;
  List<AuditEntry>? _auditLogs;

  // ================= إحصائيات محسوبة =================

  int get totalIncome =>
      treasury.where((t) => t.isIncome).fold(0, (s, t) => s + t.amount);
  int get totalExpense =>
      treasury.where((t) => !t.isIncome).fold(0, (s, t) => s + t.amount);
  int get treasuryBalance => totalIncome - totalExpense;
  int get collectedSubscriptions =>
      subscriptions.fold(0, (s, x) => s + x.amount);
  int get disbursedAids => aids
      .where((a) => a.status == 'مصروفة')
      .fold(0, (s, a) => s + a.amount);
  int get memberTotalPaid => members.fold(0, (s, m) => s + m.totalPaid);
  int get pendingAidsCount =>
      aids.where((a) => a.status == 'قيد المراجعة').length;
  int get unreadMessagesCount =>
      messages.where((m) => !m.read).length;

  void clear() {
    members = [];
    aids = [];
    subscriptions = [];
    treasury = [];
    vouchers = [];
    messages = [];
    events = [];
    fundSettings = null;
    _colleagues = null;
    _users = null;
    _auditLogs = null;
    notifyListeners();
  }

  /// تحميل كل ما يسمح به دور المستخدم (نظام الصلاحيات مطبق في الواجهة
  /// والخادم معاً). يعيد false إذا فشل التحميل (شبكة/صلاحيات).
  Future<bool> refreshAll(String? role, {bool silent = false}) async {
    if (!silent) {
      loading = true;
      notifyListeners();
    }
    try {
      final futures = <Future<void>>[
        if (Rbac.can(role, 'members'))
          _api.members().then((v) => members = v),
        if (Rbac.can(role, 'aids')) _api.aids().then((v) => aids = v),
        if (Rbac.can(role, 'subscriptions'))
          _api.subscriptions().then((v) => subscriptions = v),
        if (Rbac.can(role, 'treasury'))
          _api.treasury().then((v) => treasury = v),
        if (Rbac.can(role, 'vouchers'))
          _api.vouchers().then((v) => vouchers = v),
        _api.myMessages().then((v) => messages = v),
        if (Rbac.can(role, 'scheduler')) _api.events().then((v) => events = v),
        if (Rbac.can(role, 'settings'))
          _api.fundSettings().then((v) {
            fundSettings = v;
          }).catchError((_) {}),
      ];
      await Future.wait(futures);
      lastError = null;
      return true;
    } on ApiException catch (e) {
      lastError = e.message;
      return false;
    } finally {
      if (!silent) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _reloadMembers() async {
    try {
      members = await _api.members();
    } catch (_) {}
  }

  // ================= Members =================

  Future<void> addMember({
    required String name,
    required String nationalId,
    required String phone,
    String? email,
    String? city,
    String? joinDate,
    required int monthlySubscription,
  }) async {
    final created = await _api.createMember(
      name: name,
      nationalId: nationalId,
      phone: phone,
      email: email,
      city: city,
      joinDate: joinDate,
      monthlySubscription: monthlySubscription,
    );
    members.add(created);
    notifyListeners();
  }

  Future<void> updateMember(String id, Map<String, dynamic> updates) async {
    final updated = await _api.updateMember(id, updates);
    final i = members.indexWhere((m) => m.id == id);
    if (i >= 0) members[i] = updated;
    notifyListeners();
  }

  Future<void> deleteMember(String id) async {
    await _api.deleteMember(id);
    members.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  Future<void> toggleMemberStatus(Member m) =>
      updateMember(m.id, {'status': m.isActive ? 'معلق' : 'نشط'});

  // ================= Aids =================

  Future<void> createAid({
    required String memberId,
    required String memberName,
    required String aidType,
    required int amount,
    required String requestDate,
    String? note,
  }) async {
    final created = await _api.createAid(
      memberId: memberId,
      aidType: aidType,
      amount: amount,
      requestDate: requestDate,
      note: note,
    );
    aids.insert(0, created);
    notifyListeners();
  }

  Future<void> setAidStatus(String id, String status) async {
    final updated = await _api.updateAidStatus(id, status);
    final i = aids.indexWhere((a) => a.id == id);
    if (i >= 0) aids[i] = updated;
    notifyListeners();
  }

  Future<void> deleteAid(String id) async {
    await _api.deleteAid(id);
    aids.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // ================= Subscriptions =================

  Future<void> createSubscription({
    required String memberId,
    required int amount,
    required String paymentDate,
    required String method,
  }) async {
    final created = await _api.createSubscription(
      memberId: memberId,
      amount: amount,
      paymentDate: paymentDate,
      method: method,
    );
    subscriptions.insert(0, created);

    // الخادم يحدّث مجاميع العضو - نطبق نفس المنطق محلياً للعرض الفوري
    final i = members.indexWhere((m) => m.id == memberId);
    if (i >= 0) {
      final m = members[i];
      members[i] = Member(
        id: m.id,
        name: m.name,
        nationalId: m.nationalId,
        phone: m.phone,
        email: m.email,
        city: m.city,
        joinDate: m.joinDate,
        status: m.status,
        monthlySubscription: m.monthlySubscription,
        totalPaid: m.totalPaid + amount,
        balanceDue: m.balanceDue - amount > 0 ? m.balanceDue - amount : 0,
      );
    }
    notifyListeners();
  }

  Future<void> deleteSubscription(String id) async {
    await _api.deleteSubscription(id);
    subscriptions.removeWhere((s) => s.id == id);
    await _reloadMembers();
    notifyListeners();
  }

  // ================= Treasury =================

  Future<void> createTreasuryEntry({
    required String type,
    required String category,
    required String description,
    required int amount,
    required String entryDate,
  }) async {
    final created = await _api.createTreasuryEntry(
      type: type,
      category: category,
      description: description,
      amount: amount,
      entryDate: entryDate,
    );
    treasury.insert(0, created);
    notifyListeners();
  }

  Future<void> deleteTreasuryEntry(String id) async {
    await _api.deleteTreasuryEntry(id);
    treasury.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // ================= Vouchers =================

  /// إصدار سند قبض/صرف (يرسل الحمولة الكاملة: الطرف والحسابات).
  Future<void> createVoucher(Map<String, dynamic> data) async {
    final created = await _api.createVoucher(data);
    vouchers.insert(0, created);
    notifyListeners();
  }

  /// إلغاء سند معتمد — الخادم ينشئ قيداً عكسياً ويعيد السند المحدث.
  Future<void> voidVoucher(String id) async {
    final updated = await _api.voidVoucher(id);
    vouchers = [for (final v in vouchers) if (v.id == id) updated else v];
    notifyListeners();
  }

  // ================= Messages =================

  Future<List<Colleague>> colleagues({bool force = false}) async {
    if (_colleagues != null && !force) return _colleagues!;
    _colleagues = await _api.colleagues();
    return _colleagues!;
  }

  Future<void> sendMessage(String toUserId, String body) async {
    final created = await _api.sendMessage(toUserId, body);
    messages.insert(0, created);
    notifyListeners();
  }

  Future<void> markMessageRead(String id) async {
    await _api.markMessageRead(id);
    final i = messages.indexWhere((m) => m.id == id);
    if (i >= 0) {
      final m = messages[i];
      messages[i] = MessageModel(
        id: m.id,
        fromUserId: m.fromUserId,
        fromName: m.fromName,
        toUserId: m.toUserId,
        toName: m.toName,
        body: m.body,
        read: true,
      );
    }
    notifyListeners();
  }

  // ================= Events =================

  Future<void> createEvent({
    required String title,
    required String eventDate,
    String? eventTime,
    String? place,
    String? type,
    String color = '#1B5E20',
  }) async {
    final created = await _api.createEvent(
      title: title,
      eventDate: eventDate,
      eventTime: eventTime,
      place: place,
      type: type,
      color: color,
    );
    events.add(created);
    events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    notifyListeners();
  }

  Future<void> deleteEvent(String id) async {
    await _api.deleteEvent(id);
    events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // ================= Fund settings =================

  Future<void> saveFundSettings(FundSettings s) async {
    fundSettings = await _api.updateFundSettings(s);
    notifyListeners();
  }

  // ================= Users management (admin) =================

  Future<List<AdminUser>> users({bool force = false}) async {
    if (_users != null && !force) return _users!;
    _users = await _api.users();
    return _users!;
  }

  Future<void> createUser({
    required String username,
    required String password,
    required String fullName,
    required String role,
    String? phone,
  }) async {
    await _api.createUser(
      username: username,
      password: password,
      fullName: fullName,
      role: role,
      phone: phone,
    );
    _users = await _api.users();
    notifyListeners();
  }

  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    await _api.updateUser(id, updates);
    _users = await _api.users();
    notifyListeners();
  }

  Future<void> deleteUser(String id) async {
    await _api.deleteUser(id);
    _users = await _api.users();
    notifyListeners();
  }

  Future<List<AuditEntry>> auditLogs() async {
    _auditLogs = await _api.auditLogs();
    return _auditLogs!;
  }
}
