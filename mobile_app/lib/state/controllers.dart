import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:local_auth/local_auth.dart';

import '../core/api_client.dart';
import '../core/database.dart';
import '../core/local_store.dart';
import '../core/models.dart';
import '../core/rbac.dart';
import '../core/secure_store.dart';
import '../core/server_profiles.dart';
import '../services/api_service.dart';
import '../services/push_service.dart';
import '../services/sync_service.dart';

T? _firstWhere<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}

class ThemeController extends ChangeNotifier {
  ThemeMode mode = ThemeMode.system;
  double textScale = 1.0;
  bool get dark => mode == ThemeMode.dark;
  static const scales = <(String, double)>[('صغير', 0.9), ('عادي', 1.0), ('كبير', 1.15), ('كبير جداً', 1.3)];

  Future<void> load() async {
    mode = switch (await SecureStore.themeMode()) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
    textScale = await SecureStore.textScale();
    notifyListeners();
  }

  Future<void> setMode(ThemeMode m) async {
    mode = m;
    await SecureStore.setThemeMode(m.name);
    notifyListeners();
  }

  Future<void> setDark(bool value) => setMode(value ? ThemeMode.dark : ThemeMode.light);

  Future<void> setTextScale(double v) async {
    textScale = v;
    await SecureStore.setTextScale(v);
    notifyListeners();
  }
}

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

class AuthController extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  AppUser? user;
  bool booting = true;
  bool needsBiometricUnlock = false;
  bool biometricsAvailable = false;

  AuthController() {
    ApiClient.instance.sessionExpired.addListener(() {
      user = null;
      needsBiometricUnlock = false;
      notifyListeners();
    });
  }

  Future<void> onServerChanged() async {
    user = null;
    needsBiometricUnlock = false;
    notifyListeners();
  }

  Future<void> boot() async {
    await ServerProfiles.load();
    await ApiClient.instance.loadStoredTokens();
    biometricsAvailable = await _checkBiometrics();
    needsBiometricUnlock = ApiClient.instance.hasTokens && await SecureStore.biometricEnabled();
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
      final fetchedUser = await _api.me();
      // إجبار حساب admin أن يكون مديراً حتى لو أعاد الخادم دوراً آخر
      if (fetchedUser.username == 'admin' && fetchedUser.role != 'admin') {
        user = AppUser(
          id: fetchedUser.id,
          username: fetchedUser.username,
          fullName: fetchedUser.fullName,
          role: 'admin',
          avatarInitial: fetchedUser.avatarInitial,
          phone: fetchedUser.phone,
        );
      } else {
        user = fetchedUser;
      }
      await PushService.onLogin();
    } on AuthException {
      user = null;
      needsBiometricUnlock = false;
      await SecureStore.setBiometricEnabled(false);
      await ApiClient.instance.clearTokens();
    } on NetworkException {
      user = null;
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final db = DatabaseHelper();
    
    // 1. Local-first: check SQLite
    final localUser = await db.getLocalUser(username, password);
    if (localUser != null) {
      // إجبار حساب admin أن يكون مديراً حتى لو كان محفوظاً بشكل خاطئ
      String role = (localUser['role'] ?? 'viewer').toString();
      if (username == 'admin') role = 'admin';

      final userJson = {
        'id': localUser['id'].toString(),
        'username': localUser['username'].toString(),
        'full_name': (localUser['full_name'] ?? '').toString(),
        'role': role,
      };
      debugPrint('LOCAL LOGIN SUCCESS: $userJson'); // طباعة للتشخيص
      user = AppUser.fromJson(userJson);
      notifyListeners();
      return {'logged_in': true, 'user': userJson};
    }
    
    // 2. Remote API
    final res = await _api.login(username, password);
    debugPrint('REMOTE API RESPONSE: $res'); // طباعة استجابة الخادم للتشخيص

    final access = res['access_token'];
    final refresh = res['refresh_token'];
    
    if (access is String && refresh is String) {
      await ApiClient.instance.saveTokens(access, refresh);
      
      final userData = (res['user'] is Map) ? res['user'] as Map<String, dynamic> : res;
      
      // إجبار حساب admin أن يكون مديراً
      String role = (userData['role'] ?? res['role'] ?? 'viewer').toString();
      if (username == 'admin') role = 'admin';

      final userJson = {
        'id': (userData['id'] ?? res['user_id'] ?? username).toString(),
        'username': (userData['username'] ?? username).toString(),
        'full_name': (userData['full_name'] ?? userData['user_name'] ?? res['user_name'] ?? '').toString(),
        'role': role,
        'password': password,
      };
      
      await db.upsertLocalUser(userJson);
      
      user = AppUser.fromJson(userJson);
      await PushService.onLogin();
      notifyListeners();
      return {...res, 'logged_in': true};
    }
    return res;
  }

  Future<void> verifyOtp(String otpToken, String code) async {
    final deviceId = await SecureStore.deviceId();
    final tokens = await _api.verifyOtp(otpToken, code, deviceId);
    await ApiClient.instance.saveTokens(tokens['access_token'] as String, tokens['refresh_token'] as String);
    final fetchedUser = await _api.me();
    // إجبار حساب admin أن يكون مديراً حتى لو أعاد الخادم دوراً آخر
    if (fetchedUser.username == 'admin' && fetchedUser.role != 'admin') {
      user = AppUser(
        id: fetchedUser.id,
        username: fetchedUser.username,
        fullName: fetchedUser.fullName,
        role: 'admin',
        avatarInitial: fetchedUser.avatarInitial,
        phone: fetchedUser.phone,
      );
    } else {
      user = fetchedUser;
    }
    await PushService.onLogin();
    notifyListeners();
  }

  Future<bool> unlockWithBiometrics() async {
    if (!biometricsAvailable) return false;
    final la = LocalAuthentication();
    final ok = await la.authenticate(
      localizedReason: 'افتح نظام الصندوق الاجتماعي التنموي',
      options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true, useErrorDialogs: true),
    );
    if (!ok) return false;
    await tryRestoreSession();
    notifyListeners();
    return user != null;
  }

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

  Future<void> changePassword(String oldPassword, String newPassword) => _api.changePassword(oldPassword, newPassword);

  Future<void> logout() async {
    try {
      final refresh = await SecureStore.refreshToken();
      await _api.logout(refresh);
    } catch (_) {}
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

class DataController extends ChangeNotifier {
  final ApiService _api = ApiService.instance;
  final LocalStore _local = LocalStore();

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

  int pendingSyncCount = 0;

  int get totalIncome => treasury.where((t) => t.isIncome).fold(0, (s, t) => s + t.amount);
  int get totalExpense => treasury.where((t) => !t.isIncome).fold(0, (s, t) => s + t.amount);
  int get treasuryBalance => totalIncome - totalExpense;
  int get collectedSubscriptions => subscriptions.fold(0, (s, x) => s + x.amount);
  int get disbursedAids => aids.where((a) => a.status == 'مصروفة').fold(0, (s, a) => s + a.amount);
  int get memberTotalPaid => members.fold(0, (s, m) => s + m.totalPaid);
  int get pendingAidsCount => aids.where((a) => a.status == 'قيد المراجعة').length;
  int get unreadMessagesCount => messages.where((m) => !m.read).length;

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

  Future<bool> refreshAll(String? role, {bool silent = false}) async {
    if (!silent) {
      loading = true;
      notifyListeners();
    }
    try {
      final futures = <Future<void>>[
        if (Rbac.can(role, 'members'))
          _api.members().then((v) { members = v; _cacheMembers(v); }),
        if (Rbac.can(role, 'aids'))
          _api.aids().then((v) { aids = v; _cacheAids(v); }),
        if (Rbac.can(role, 'subscriptions'))
          _api.subscriptions().then((v) { subscriptions = v; _cacheSubscriptions(v); }),
        if (Rbac.can(role, 'treasury'))
          _api.treasury().then((v) { treasury = v; _cacheTreasury(v); }),
        if (Rbac.can(role, 'vouchers'))
          _api.vouchers().then((v) { vouchers = v; _cacheVouchers(v); }),
        _api.myMessages().then((v) => messages = v),
        if (Rbac.can(role, 'scheduler'))
          _api.events().then((v) { events = v; _cacheEvents(v); }),
        if (Rbac.can(role, 'settings'))
          _api.fundSettings().then((v) { fundSettings = v; }).catchError((_) {}),
      ];
      await Future.wait(futures);
      lastError = null;
      await _refreshPendingCount();
      return true;
    } on ApiException catch (e) {
      lastError = e.message;
      await _loadFromLocal(role);
      return false;
    } finally {
      if (!silent) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadFromLocal(String? role) async {
    try {
      if (Rbac.can(role, 'members')) {
        final rows = await _local.readAll(LocalTable.members, orderBy: 'name');
        if (rows.isNotEmpty) members = rows.map(_memberFromRow).toList();
      }
      if (Rbac.can(role, 'aids')) {
        final rows = await _local.readAll(LocalTable.aidRequests, orderBy: 'request_date DESC');
        if (rows.isNotEmpty) aids = rows.map(_aidFromRow).toList();
      }
      if (Rbac.can(role, 'subscriptions')) {
        final rows = await _local.readAll(LocalTable.subscriptions, orderBy: 'payment_date DESC');
        if (rows.isNotEmpty) subscriptions = rows.map(_subscriptionFromRow).toList();
      }
      if (Rbac.can(role, 'treasury')) {
        final rows = await _local.readAll(LocalTable.treasuryEntries, orderBy: 'entry_date DESC');
        if (rows.isNotEmpty) treasury = rows.map(_treasuryFromRow).toList();
      }
      if (Rbac.can(role, 'vouchers')) {
        final rows = await _local.readAll(LocalTable.vouchers, orderBy: 'request_date DESC');
        if (rows.isNotEmpty) vouchers = rows.map(_voucherFromRow).toList();
      }
      if (Rbac.can(role, 'scheduler')) {
        final rows = await _local.readAll(LocalTable.events, orderBy: 'event_date');
        if (rows.isNotEmpty) events = rows.map(_eventFromRow).toList();
      }
      notifyListeners();
    } catch (_) {}
  }

  Member _memberFromRow(Map<String, dynamic> r) => Member(
        id: r['id'].toString(), name: (r['name'] ?? '').toString(), nationalId: (r['national_id'] ?? '').toString(),
        phone: (r['phone'] ?? '').toString(), email: r['email'] as String?, city: r['city'] as String?,
        joinDate: r['join_date'] as String?, status: (r['status'] ?? 'نشط').toString(),
        monthlySubscription: (r['monthly_subscription'] as num?)?.toInt() ?? 0,
        totalPaid: (r['total_paid'] as num?)?.toInt() ?? 0, balanceDue: (r['balance_due'] as num?)?.toInt() ?? 0,
      );

  AidRequest _aidFromRow(Map<String, dynamic> r) => AidRequest(
        id: r['id'].toString(), memberId: (r['member_id'] ?? '').toString(), memberName: (r['member_name'] ?? '').toString(),
        aidType: (r['aid_type'] ?? '').toString(), amount: (r['amount'] as num?)?.toInt() ?? 0,
        requestDate: (r['request_date'] ?? '').toString(), status: (r['status'] ?? '').toString(),
        note: r['note'] as String?, reviewerName: r['reviewer_name'] as String?,
      );

  Subscription _subscriptionFromRow(Map<String, dynamic> r) => Subscription(
        id: r['id'].toString(), memberId: (r['member_id'] ?? '').toString(), memberName: (r['member_name'] ?? '').toString(),
        amount: (r['amount'] as num?)?.toInt() ?? 0, paymentDate: (r['payment_date'] ?? '').toString(),
        method: (r['method'] ?? '').toString(), referenceNo: r['reference_no'] as String?,
      );

  TreasuryEntry _treasuryFromRow(Map<String, dynamic> r) => TreasuryEntry(
        id: r['id'].toString(), type: (r['type'] ?? '').toString(), category: (r['category'] ?? '').toString(),
        description: (r['description'] ?? '').toString(), amount: (r['amount'] as num?)?.toInt() ?? 0,
        entryDate: (r['entry_date'] ?? '').toString(), referenceNo: r['reference_no'] as String?,
      );

  Voucher _voucherFromRow(Map<String, dynamic> r) => Voucher(
        id: r['id'].toString(), voucherNo: (r['voucher_no'] ?? '').toString(), kind: (r['kind'] ?? '').toString(),
        memberId: (r['member_id'] ?? '').toString(), memberName: (r['member_name'] ?? '').toString(),
        donorId: r['donor_id'] as String?, beneficiaryId: r['beneficiary_id'] as String?, partyName: r['party_name'] as String?,
        amount: (r['amount'] as num?)?.toInt() ?? 0, voucherDate: (r['voucher_date'] ?? '').toString(),
        method: (r['method'] ?? '').toString(), description: (r['description'] ?? '').toString(),
        issuedByName: (r['issued_by_name'] ?? '').toString(), status: (r['status'] ?? '').toString(),
        journalEntryNo: r['journal_entry_no'] as String?, journalEntryId: r['journal_entry_id'] as String?,
      );

  EventModel _eventFromRow(Map<String, dynamic> r) => EventModel(
        id: r['id'].toString(), title: (r['title'] ?? '').toString(), eventDate: (r['event_date'] ?? '').toString(),
        eventTime: r['event_time'] as String?, place: r['place'] as String?, type: r['type'] as String?,
        color: (r['color'] ?? '#1B5E20').toString(),
      );

  Future<void> _refreshPendingCount() async {
    pendingSyncCount = await _local.pendingCount();
    notifyListeners();
  }

  Future<void> syncNow() async {
    await syncService.forceSync();
    await _refreshPendingCount();
    notifyListeners();
  }

  Future<void> _cacheMembers(List<Member> v) async {
    await _local.cacheRemote(LocalTable.members, [
      for (final m in v) {'id': m.id, 'name': m.name, 'national_id': m.nationalId, 'phone': m.phone, 'email': m.email, 'city': m.city, 'join_date': m.joinDate, 'status': m.status, 'monthly_subscription': m.monthlySubscription, 'total_paid': m.totalPaid, 'balance_due': m.balanceDue}
    ]);
  }

  Future<void> _cacheAids(List<AidRequest> v) async {
    await _local.cacheRemote(LocalTable.aidRequests, [
      for (final a in v) {'id': a.id, 'member_id': a.memberId, 'member_name': a.memberName, 'aid_type': a.aidType, 'amount': a.amount, 'request_date': a.requestDate, 'status': a.status, 'note': a.note, 'reviewer_name': a.reviewerName}
    ]);
  }

  Future<void> _cacheSubscriptions(List<Subscription> v) async {
    await _local.cacheRemote(LocalTable.subscriptions, [
      for (final s in v) {'id': s.id, 'member_id': s.memberId, 'member_name': s.memberName, 'amount': s.amount, 'payment_date': s.paymentDate, 'method': s.method, 'reference_no': s.referenceNo}
    ]);
  }

  Future<void> _cacheTreasury(List<TreasuryEntry> v) async {
    await _local.cacheRemote(LocalTable.treasuryEntries, [
      for (final t in v) {'id': t.id, 'type': t.type, 'category': t.category, 'description': t.description, 'amount': t.amount, 'entry_date': t.entryDate, 'reference_no': t.referenceNo}
    ]);
  }

  Future<void> _cacheVouchers(List<Voucher> v) async {
    await _local.cacheRemote(LocalTable.vouchers, [
      for (final x in v) {'id': x.id, 'voucher_no': x.voucherNo, 'kind': x.kind, 'member_id': x.memberId, 'member_name': x.memberName, 'donor_id': x.donorId, 'beneficiary_id': x.beneficiaryId, 'party_name': x.partyName, 'amount': x.amount, 'voucher_date': x.voucherDate, 'method': x.method, 'description': x.description, 'issued_by_name': x.issuedByName, 'status': x.status, 'journal_entry_no': x.journalEntryNo, 'journal_entry_id': x.journalEntryId}
    ]);
  }

  Future<void> _cacheEvents(List<EventModel> v) async {
    await _local.cacheRemote(LocalTable.events, [
      for (final e in v) {'id': e.id, 'title': e.title, 'event_date': e.eventDate, 'event_time': e.eventTime, 'place': e.place, 'type': e.type, 'color': e.color}
    ]);
  }

  Future<void> addMember({required String name, required String nationalId, required String phone, String? email, String? city, String? joinDate, required int monthlySubscription}) async {
    final localId = _local.newId();
    final localData = <String, dynamic>{'name': name, 'national_id': nationalId, 'phone': phone, 'email': email, 'city': city, 'join_date': joinDate, 'monthly_subscription': monthlySubscription};
    try {
      final created = await _api.createMember(name: name, nationalId: nationalId, phone: phone, email: email, city: city, joinDate: joinDate, monthlySubscription: monthlySubscription);
      members.add(created); await _cacheMembers([created]); notifyListeners();
    } on NetworkException {
      await _local.upsertMember(localData, id: localId);
      members.add(Member(id: localId, name: name, nationalId: nationalId, phone: phone, email: email, city: city, joinDate: joinDate, status: 'نشط', monthlySubscription: monthlySubscription, totalPaid: 0, balanceDue: 0));
      await _refreshPendingCount(); notifyListeners();
    }
  }

  Future<void> updateMember(String id, Map<String, dynamic> updates) async {
    try {
      final updated = await _api.updateMember(id, updates);
      final i = members.indexWhere((m) => m.id == id); if (i >= 0) members[i] = updated;
      await _cacheMembers([updated]); notifyListeners();
    } on NetworkException {
      final current = _firstWhere(members, (m) => m.id == id);
      if (current != null) {
        final merged = <String, dynamic>{'name': updates['name'] ?? current.name, 'national_id': updates['national_id'] ?? current.nationalId, 'phone': updates['phone'] ?? current.phone, 'email': updates['email'] ?? current.email, 'city': updates['city'] ?? current.city, 'join_date': updates['join_date'] ?? current.joinDate, 'status': updates['status'] ?? current.status, 'monthly_subscription': updates['monthly_subscription'] ?? current.monthlySubscription, 'total_paid': updates['total_paid'] ?? current.totalPaid, 'balance_due': updates['balance_due'] ?? current.balanceDue};
        await _local.upsertMember(merged, id: id);
        final i = members.indexWhere((m) => m.id == id); if (i >= 0) members[i] = _memberFromRow({'id': id, ...merged});
        await _refreshPendingCount(); notifyListeners();
      }
    }
  }

  Future<void> deleteMember(String id) async {
    try { await _api.deleteMember(id); members.removeWhere((m) => m.id == id); notifyListeners(); }
    on NetworkException { await _local.deleteLocal(LocalTable.members, EntityType.member, id); members.removeWhere((m) => m.id == id); await _refreshPendingCount(); notifyListeners(); }
  }

  Future<void> toggleMemberStatus(Member m) => updateMember(m.id, {'status': m.isActive ? 'معلق' : 'نشط'});

  Future<void> createAid({required String memberId, required String memberName, required String aidType, required int amount, required String requestDate, String? note, Map<String, dynamic>? money}) async {
    final localId = _local.newId();
    try {
      final created = await _api.createAid(memberId: memberId, aidType: aidType, amount: amount, requestDate: requestDate, note: note, money: money);
      aids.insert(0, created); await _cacheAids([created]); notifyListeners();
    } on NetworkException {
      await _local.upsertAidRequest({'member_id': memberId, 'member_name': memberName, 'aid_type': aidType, 'amount': amount, 'request_date': requestDate, 'status': 'قيد المراجعة', 'note': note}, id: localId);
      aids.insert(0, _aidFromRow({'id': localId, 'member_id': memberId, 'member_name': memberName, 'aid_type': aidType, 'amount': amount, 'request_date': requestDate, 'status': 'قيد المراجعة', 'note': note}));
      await _refreshPendingCount(); notifyListeners();
    }
  }

  Future<void> setAidStatus(String id, String status) async {
    try {
      final updated = await _api.updateAidStatus(id, status);
      final i = aids.indexWhere((a) => a.id == id); if (i >= 0) aids[i] = updated;
      await _cacheAids([updated]); notifyListeners();
    } on NetworkException {
      final current = _firstWhere(aids, (a) => a.id == id);
      if (current != null) {
        await _local.upsertAidRequest({'member_id': current.memberId, 'member_name': current.memberName, 'aid_type': current.aidType, 'amount': current.amount, 'request_date': current.requestDate, 'status': status, 'note': current.note, 'reviewer_name': current.reviewerName}, id: id);
        final i = aids.indexWhere((a) => a.id == id);
        if (i >= 0) aids[i] = AidRequest(id: current.id, memberId: current.memberId, memberName: current.memberName, aidType: current.aidType, amount: current.amount, requestDate: current.requestDate, status: status, note: current.note, reviewerName: current.reviewerName);
        await _refreshPendingCount(); notifyListeners();
      }
    }
  }

  Future<void> deleteAid(String id) async {
    try { await _api.deleteAid(id); aids.removeWhere((a) => a.id == id); notifyListeners(); }
    on NetworkException { await _local.deleteLocal(LocalTable.aidRequests, EntityType.aidRequest, id); aids.removeWhere((a) => a.id == id); await _refreshPendingCount(); notifyListeners(); }
  }

  Future<void> createSubscription({required String memberId, required int amount, required String paymentDate, required String method, Map<String, dynamic>? money}) async {
    final localId = _local.newId();
    final memberName = _firstWhere(members, (m) => m.id == memberId)?.name ?? '';
    try {
      final created = await _api.createSubscription(memberId: memberId, amount: amount, paymentDate: paymentDate, method: method, money: money);
      subscriptions.insert(0, created); await _cacheSubscriptions([created]); _applySubscriptionTotals(memberId, amount); notifyListeners();
    } on NetworkException {
      await _local.upsertSubscription({'member_id': memberId, 'member_name': memberName, 'amount': amount, 'payment_date': paymentDate, 'method': method}, id: localId);
      subscriptions.insert(0, _subscriptionFromRow({'id': localId, 'member_id': memberId, 'member_name': memberName, 'amount': amount, 'payment_date': paymentDate, 'method': method}));
      _applySubscriptionTotals(memberId, amount); await _refreshPendingCount(); notifyListeners();
    }
  }

  void _applySubscriptionTotals(String memberId, int amount) {
    final i = members.indexWhere((m) => m.id == memberId);
    if (i >= 0) {
      final m = members[i];
      members[i] = Member(id: m.id, name: m.name, nationalId: m.nationalId, phone: m.phone, email: m.email, city: m.city, joinDate: m.joinDate, status: m.status, monthlySubscription: m.monthlySubscription, totalPaid: m.totalPaid + amount, balanceDue: m.balanceDue - amount > 0 ? m.balanceDue - amount : 0);
    }
  }

  Future<void> deleteSubscription(String id) async {
    try { await _api.deleteSubscription(id); subscriptions.removeWhere((s) => s.id == id); notifyListeners(); }
    on NetworkException { await _local.deleteLocal(LocalTable.subscriptions, EntityType.subscription, id); subscriptions.removeWhere((s) => s.id == id); await _refreshPendingCount(); notifyListeners(); }
  }

  Future<void> createTreasuryEntry({required String type, required String category, required String description, required int amount, required String entryDate, Map<String, dynamic>? money}) async {
    final localId = _local.newId();
    try {
      final created = await _api.createTreasuryEntry(type: type, category: category, description: description, amount: amount, entryDate: entryDate, money: money);
      treasury.insert(0, created); await _cacheTreasury([created]); notifyListeners();
    } on NetworkException {
      await _local.upsertTreasuryEntry({'type': type, 'category': category, 'description': description, 'amount': amount, 'entry_date': entryDate}, id: localId);
      treasury.insert(0, _treasuryFromRow({'id': localId, 'type': type, 'category': category, 'description': description, 'amount': amount, 'entry_date': entryDate}));
      await _refreshPendingCount(); notifyListeners();
    }
  }

  Future<void> deleteTreasuryEntry(String id) async {
    try { await _api.deleteTreasuryEntry(id); treasury.removeWhere((t) => t.id == id); notifyListeners(); }
    on NetworkException { await _local.deleteLocal(LocalTable.treasuryEntries, EntityType.treasuryEntry, id); treasury.removeWhere((t) => t.id == id); await _refreshPendingCount(); notifyListeners(); }
  }

  Future<void> createVoucher(Map<String, dynamic> data) async {
    final localId = _local.newId();
    try {
      final created = await _api.createVoucher(data);
      vouchers.insert(0, created); await _cacheVouchers([created]); notifyListeners();
    } on NetworkException {
      await _local.upsertVoucher(data, id: localId);
      vouchers.insert(0, _voucherFromRow({'id': localId, 'voucher_no': data['voucher_no'] ?? '', 'kind': data['kind'], 'member_id': data['member_id'], 'member_name': data['member_name'], 'donor_id': data['donor_id'], 'beneficiary_id': data['beneficiary_id'], 'party_name': data['party_name'], 'amount': data['amount'], 'voucher_date': data['voucher_date'], 'method': data['method'], 'description': data['description'], 'issued_by_name': data['issued_by_name'] ?? '', 'status': data['status'] ?? 'معتمد', 'treasury_account_id': data['treasury_account_id'], 'counter_account_id': data['counter_account_id']}));
      await _refreshPendingCount(); notifyListeners();
    }
  }

  Future<void> voidVoucher(String id) async {
    try {
      final updated = await _api.voidVoucher(id);
      vouchers = [for (final v in vouchers) if (v.id == id) updated else v]; await _cacheVouchers([updated]); notifyListeners();
    } on NetworkException {
      final current = _firstWhere(vouchers, (v) => v.id == id);
      if (current != null) {
        await _local.upsertVoucher({'voucher_no': current.voucherNo, 'kind': current.kind, 'member_id': current.memberId, 'member_name': current.memberName, 'donor_id': current.donorId, 'beneficiary_id': current.beneficiaryId, 'party_name': current.partyName, 'amount': current.amount, 'voucher_date': current.voucherDate, 'method': current.method, 'description': current.description, 'issued_by_name': current.issuedByName, 'status': 'ملغى'}, id: id);
        await _refreshPendingCount(); notifyListeners();
      }
    }
  }

  Future<List<Colleague>> colleagues({bool force = false}) async {
    if (_colleagues != null && !force) return _colleagues!;
    _colleagues = await _api.colleagues(); return _colleagues!;
  }

  Future<void> sendMessage(String toUserId, String body) async {
    final created = await _api.sendMessage(toUserId, body);
    messages.insert(0, created); notifyListeners();
  }

  Future<void> markMessageRead(String id) async {
    await _api.markMessageRead(id);
    final i = messages.indexWhere((m) => m.id == id);
    if (i >= 0) {
      final m = messages[i];
      messages[i] = MessageModel(id: m.id, fromUserId: m.fromUserId, fromName: m.fromName, toUserId: m.toUserId, toName: m.toName, body: m.body, read: true);
    }
    notifyListeners();
  }

  Future<void> createEvent({required String title, required String eventDate, String? eventTime, String? place, String? type, String color = '#1B5E20'}) async {
    final localId = _local.newId();
    try {
      final created = await _api.createEvent(title: title, eventDate: eventDate, eventTime: eventTime, place: place, type: type, color: color);
      events.add(created); events.sort((a, b) => a.eventDate.compareTo(b.eventDate)); await _cacheEvents([created]); notifyListeners();
    } on NetworkException {
      await _local.upsertEvent({'title': title, 'event_date': eventDate, 'event_time': eventTime, 'place': place, 'type': type, 'color': color}, id: localId);
      events.add(_eventFromRow({'id': localId, 'title': title, 'event_date': eventDate, 'event_time': eventTime, 'place': place, 'type': type, 'color': color}));
      events.sort((a, b) => a.eventDate.compareTo(b.eventDate)); await _refreshPendingCount(); notifyListeners();
    }
  }

  Future<void> deleteEvent(String id) async {
    try { await _api.deleteEvent(id); events.removeWhere((e) => e.id == id); notifyListeners(); }
    on NetworkException { await _local.deleteLocal(LocalTable.events, EntityType.event, id); events.removeWhere((e) => e.id == id); await _refreshPendingCount(); notifyListeners(); }
  }

  Future<void> saveFundSettings(FundSettings s) async {
    fundSettings = await _api.updateFundSettings(s); notifyListeners();
  }

  Future<List<AdminUser>> users({bool force = false}) async {
    if (_users != null && !force) return _users!;
    _users = await _api.users(); return _users!;
  }

  Future<void> createUser({required String username, required String password, required String fullName, required String role, String? phone}) async {
    await _api.createUser(username: username, password: password, fullName: fullName, role: role, phone: phone);
    _users = await _api.users(); notifyListeners();
  }

  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    await _api.updateUser(id, updates); _users = await _api.users(); notifyListeners();
  }

  Future<void> deleteUser(String id) async {
    await _api.deleteUser(id); _users = await _api.users(); notifyListeners();
  }

  Future<List<AuditEntry>> auditLogs() async {
    _auditLogs = await _api.auditLogs(); return _auditLogs!;
  }
}