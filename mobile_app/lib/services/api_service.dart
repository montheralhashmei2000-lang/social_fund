import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/currency.dart';
import '../core/models.dart';

/// كل استدعاءات الخادم في مكان واحد - النظام أونلاين فقط:
/// لا يوجد outbox ولا مزامنة ولا قاعدة بيانات محلية، أي عملية كتابة
/// تصل الخادم مباشرة وتُحفظ هناك.
class ApiService {
  static final ApiService instance = ApiService._();
  ApiService._();
  factory ApiService() => instance;

  final ApiClient _c = ApiClient.instance;

  Future<Map<String, dynamic>> _map(Future<dynamic> f) async {
    final r = await f;
    return Map<String, dynamic>.from(r as Map);
  }

  Future<List<Map<String, dynamic>>> _list(Future<dynamic> f) async {
    final r = await f;
    return (r as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ================= Auth =================

  Future<Map<String, dynamic>> login(String username, String password) =>
      _map(_c.request('POST', '/auth/login',
          data: {'username': username, 'password': password}, skipAuth: true));

  Future<Map<String, dynamic>> verifyOtp(String otpToken, String code, String deviceId) =>
      _map(_c.request('POST', '/auth/verify-otp',
          data: {'otp_token': otpToken, 'code': code, 'device_id': deviceId},
          skipAuth: true));

  Future<AppUser> me() async => AppUser.fromJson(await _map(_c.request('GET', '/auth/me')));

  Future<void> changePassword(String oldPassword, String newPassword) =>
      _c.request('POST', '/auth/change-password',
          data: {'old_password': oldPassword, 'new_password': newPassword});

  Future<void> logout(String? refreshToken) =>
      _c.request('POST', '/auth/logout', data: {'refresh_token': refreshToken});

  Future<void> logoutAll() => _c.request('POST', '/auth/logout-all', data: {});

  // ================= Push tokens =================

  Future<void> registerPushToken(String token, String platform) =>
      _c.request('POST', '/push/register-token', data: {'token': token, 'platform': platform});

  Future<void> unregisterPushToken(String token) =>
      _c.request('POST', '/push/unregister-token', data: {'token': token});

  // ================= Members =================

  Future<List<Member>> members() async =>
      (await _list(_c.request('GET', '/members'))).map(Member.fromJson).toList();

  Future<Member> createMember({
    required String name,
    required String nationalId,
    required String phone,
    String? email,
    String? city,
    String? joinDate,
    required int monthlySubscription,
  }) async =>
      Member.fromJson(await _map(_c.request('POST', '/members', data: {
        'name': name,
        'national_id': nationalId,
        'phone': phone,
        'email': email,
        'city': city,
        'join_date': joinDate,
        'monthly_subscription': monthlySubscription,
      })));

  Future<Member> updateMember(String id, Map<String, dynamic> updates) async =>
      Member.fromJson(await _map(_c.request('PUT', '/members/$id', data: updates)));

  Future<void> deleteMember(String id) => _c.request('DELETE', '/members/$id');

  // ================= Aid requests =================

  Future<List<AidRequest>> aids() async =>
      (await _list(_c.request('GET', '/aids'))).map(AidRequest.fromJson).toList();

  Future<AidRequest> createAid({
    required String memberId,
    required String aidType,
    required int amount,
    required String requestDate,
    String? note,
  }) async =>
      AidRequest.fromJson(await _map(_c.request('POST', '/aids', data: {
        'member_id': memberId,
        'aid_type': aidType,
        'amount': amount,
        'request_date': requestDate,
        'note': note,
      })));

  Future<AidRequest> updateAidStatus(String id, String status) async =>
      AidRequest.fromJson(await _map(_c.request('PATCH', '/aids/$id/status', data: {'status': status})));

  Future<void> deleteAid(String id) => _c.request('DELETE', '/aids/$id');

  // ================= Subscriptions =================

  Future<List<Subscription>> subscriptions() async =>
      (await _list(_c.request('GET', '/subscriptions'))).map(Subscription.fromJson).toList();

  Future<Subscription> createSubscription({
    required String memberId,
    required int amount,
    required String paymentDate,
    required String method,
  }) async =>
      Subscription.fromJson(await _map(_c.request('POST', '/subscriptions', data: {
        'member_id': memberId,
        'amount': amount,
        'payment_date': paymentDate,
        'method': method,
      })));

  Future<void> deleteSubscription(String id) => _c.request('DELETE', '/subscriptions/$id');

  // ================= Treasury =================

  Future<List<TreasuryEntry>> treasury() async =>
      (await _list(_c.request('GET', '/treasury'))).map(TreasuryEntry.fromJson).toList();

  Future<TreasuryEntry> createTreasuryEntry({
    required String type,
    required String category,
    required String description,
    required int amount,
    required String entryDate,
  }) async =>
      TreasuryEntry.fromJson(await _map(_c.request('POST', '/treasury', data: {
        'type': type,
        'category': category,
        'description': description,
        'amount': amount,
        'entry_date': entryDate,
      })));

  Future<void> deleteTreasuryEntry(String id) => _c.request('DELETE', '/treasury/$id');

  // ================= Vouchers =================

  Future<List<Voucher>> vouchers() async =>
      (await _list(_c.request('GET', '/vouchers'))).map(Voucher.fromJson).toList();

  /// إصدار سند قبض/صرف مربوط بالقيد المزدوج (الطرف + الحسابات في الحمولة).
  Future<Voucher> createVoucher(Map<String, dynamic> data) async =>
      Voucher.fromJson(await _map(_c.request('POST', '/vouchers', data: data)));

  /// إلغاء سند معتمد — الخادم ينشئ قيداً عكسياً ويعيد السند المحدث.
  Future<Voucher> voidVoucher(String id) async =>
      Voucher.fromJson(await _map(_c.request('POST', '/vouchers/$id/void', data: {})));

  /// سند PDF رسمي من الخادم (ببيانات الصندوق ورقم القيد المرتبط).
  Future<List<int>> voucherPdfBytes(String id) async {
    return _c.requestBytes('GET', '/vouchers/$id/pdf');
  }

  // ================= Messages =================

  Future<List<MessageModel>> myMessages() async =>
      (await _list(_c.request('GET', '/messages'))).map(MessageModel.fromJson).toList();

  Future<List<Colleague>> colleagues() async =>
      (await _list(_c.request('GET', '/users/colleagues'))).map(Colleague.fromJson).toList();

  Future<MessageModel> sendMessage(String toUserId, String body) async =>
      MessageModel.fromJson(await _map(
          _c.request('POST', '/messages', data: {'to_user_id': toUserId, 'body': body})));

  Future<void> markMessageRead(String id) => _c.request('PATCH', '/messages/$id/read', data: {});

  // ================= Events (Scheduler) =================

  Future<List<EventModel>> events() async =>
      (await _list(_c.request('GET', '/events'))).map(EventModel.fromJson).toList();

  Future<EventModel> createEvent({
    required String title,
    required String eventDate,
    String? eventTime,
    String? place,
    String? type,
    String color = '#1B5E20',
  }) async =>
      EventModel.fromJson(await _map(_c.request('POST', '/events', data: {
        'title': title,
        'event_date': eventDate,
        'event_time': eventTime,
        'place': place,
        'type': type,
        'color': color,
      })));

  Future<void> deleteEvent(String id) => _c.request('DELETE', '/events/$id');

  // ================= Fund settings =================

  Future<FundSettings> fundSettings() async =>
      FundSettings.fromJson(await _map(_c.request('GET', '/fund-settings')));

  Future<FundSettings> updateFundSettings(FundSettings s) async =>
      FundSettings.fromJson(await _map(_c.request('PUT', '/fund-settings', data: s.toApi())));

  // ================= Users management (admin) =================

  Future<List<AdminUser>> users() async =>
      (await _list(_c.request('GET', '/users'))).map(AdminUser.fromJson).toList();

  Future<AdminUser> createUser({
    required String username,
    required String password,
    required String fullName,
    required String role,
    String? phone,
  }) async =>
      AdminUser.fromJson(await _map(_c.request('POST', '/users', data: {
        'username': username,
        'password': password,
        'full_name': fullName,
        'role': role,
        'phone': phone,
      })));

  Future<AdminUser> updateUser(String id, Map<String, dynamic> updates) async =>
      AdminUser.fromJson(await _map(_c.request('PUT', '/users/$id', data: updates)));

  Future<void> deleteUser(String id) => _c.request('DELETE', '/users/$id');

  // ================= Audit log (admin) =================

  Future<List<AuditEntry>> auditLogs({int limit = 200}) async =>
      (await _list(_c.request('GET', '/audit-logs', query: {'limit': limit})))
          .map(AuditEntry.fromJson)
          .toList();

  // ================= Backup (admin) =================

  Future<List<int>> downloadBackup() => _c.requestBytes('POST', '/backup/create');

  // ================= Reports (PDF / Excel) =================

  Future<List<int>> downloadReport(String reportKey, String format) =>
      _c.requestBytes('GET', '/reports/$reportKey/$format');

  // ================= Accounts & Journal =================

  Future<List<Account>> accounts() async =>
      (await _list(_c.request('GET', '/accounts'))).map(Account.fromJson).toList();

  Future<void> seedAccounts() => _c.request('POST', '/accounts/seed-defaults', data: {});

  Future<Account> createAccount(Map<String, dynamic> data) async =>
      Account.fromJson(await _map(_c.request('POST', '/accounts', data: data)));

  Future<void> transfer({required String fromId, required String toId, required double amount, required String description, required String date}) =>
      _c.request('POST', '/accounts/transfer', data: {
        'from_account_id': fromId, 'to_account_id': toId,
        'amount': amount, 'description': description, 'entry_date': date,
      });

  Future<List<JournalEntryModel>> journal() async =>
      (await _list(_c.request('GET', '/journal'))).map(JournalEntryModel.fromJson).toList();

  Future<List<Map<String, String>>> journalEntryTypes() async {
    final r = await _list(_c.request('GET', '/journal/entry-types'));
    return [
      for (final e in r) {'key': '${e['key']}', 'label': '${e['label']}'},
    ];
  }

  Future<void> createJournalEntry(Map<String, dynamic> data) =>
      _c.request('POST', '/journal', data: data);

  /// طلب عام للشاشات (مثل تفاصيل المانح) بإعادة استخدام منطق معالجة الأخطاء.
  Future<dynamic> request(String method, String path, {Object? data, Map<String, dynamic>? query}) =>
      _c.request(method, path, data: data, query: query);

  /// وصول مباشر إلى Dio لحالات خاصة: التنزيلات الثنائية (شهادة PDF…).
  Dio get dio => _c.dio;

  // ================= Reconciliation =================

  Future<Map<String, dynamic>> reconciliation(String accountId) =>
      _map(_c.request('GET', '/accounts/$accountId/reconciliation'));

  Future<List<Map<String, dynamic>>> unmatchedLines(String accountId) =>
      _list(_c.request('GET', '/accounts/$accountId/unmatched-journal-lines'));

  Future<void> addStatementLine(String accountId, Map<String, dynamic> data) =>
      _c.request('POST', '/accounts/$accountId/statement-lines', data: data);

  Future<void> matchStatementLine(String accountId, String lineId, String journalLineId) =>
      _c.request('POST', '/accounts/$accountId/statement-lines/$lineId/match',
          data: {'journal_line_id': journalLineId});

  // ================= Donors & Pledges =================

  Future<List<Donor>> donors() async =>
      (await _list(_c.request('GET', '/donors'))).map(Donor.fromJson).toList();

  Future<void> createDonor(Map<String, dynamic> data) => _c.request('POST', '/donors', data: data);

  Future<List<Pledge>> pledges() async =>
      (await _list(_c.request('GET', '/pledges'))).map(Pledge.fromJson).toList();

  Future<List<Pledge>> pledgesDue() async =>
      (await _list(_c.request('GET', '/pledges/due'))).map(Pledge.fromJson).toList();

  Future<void> createPledge(Map<String, dynamic> data) => _c.request('POST', '/pledges', data: data);

  Future<void> fulfillPledge(String id) => _c.request('POST', '/pledges/$id/fulfill', data: {});

  // ================= Campaigns =================

  Future<List<Campaign>> campaigns() async =>
      (await _list(_c.request('GET', '/campaigns'))).map(Campaign.fromJson).toList();

  Future<void> createCampaign(Map<String, dynamic> data) => _c.request('POST', '/campaigns', data: data);

  Future<void> closeCampaign(String id) => _c.request('POST', '/campaigns/$id/close', data: {});

  // ================= Beneficiaries & Periodic =================

  Future<List<Beneficiary>> beneficiaries() async =>
      (await _list(_c.request('GET', '/beneficiaries'))).map(Beneficiary.fromJson).toList();

  Future<void> createBeneficiary(Map<String, dynamic> data) =>
      _c.request('POST', '/beneficiaries', data: data);

  Future<List<PeriodicAidModel>> periodicAids() async =>
      (await _list(_c.request('GET', '/periodic-aids'))).map(PeriodicAidModel.fromJson).toList();

  Future<List<PeriodicAidModel>> periodicDue() async =>
      (await _list(_c.request('GET', '/periodic-aids/due'))).map(PeriodicAidModel.fromJson).toList();

  Future<void> createPeriodicAid(Map<String, dynamic> data) =>
      _c.request('POST', '/periodic-aids', data: data);

  Future<void> payPeriodicAid(String id, Map<String, dynamic> data) =>
      _c.request('POST', '/periodic-aids/$id/pay', data: data);

  // ================= In-Kind =================

  Future<List<InKindItem>> inKindItems() async =>
      (await _list(_c.request('GET', '/inkind/items'))).map(InKindItem.fromJson).toList();

  Future<void> createInKindItem(Map<String, dynamic> data) =>
      _c.request('POST', '/inkind/items', data: data);

  Future<void> createMovement(Map<String, dynamic> data) =>
      _c.request('POST', '/inkind/movements', data: data);

  // ================= Budgets & Financial reports =================

  Future<Map<String, dynamic>> budgetReport(String period) =>
      _map(_c.request('GET', '/budgets/$period/report'));

  Future<void> createBudget(Map<String, dynamic> data) => _c.request('POST', '/budgets', data: data);

  Future<Map<String, dynamic>> financialReport(String key, Map<String, dynamic> params) {
    final q = <String, dynamic>{};
    params.forEach((k, v) => q[k] = v);
    return _map(_c.request('GET', '/financial-reports/$key', query: q));
  }

  Future<List<int>> financialReportBytes(String key, Map<String, dynamic> params) async {
    final q = <String, dynamic>{};
    params.forEach((k, v) => q[k] = v);
    return _c.requestBytes('GET', '/financial-reports/$key', query: q);
  }

  // ================= Currencies =================

  Future<List<Currency>> currencies({bool all = false}) async =>
      (await _list(_c.request('GET', '/currencies', query: all ? {'all': '1'} : null)))
          .map(Currency.fromJson)
          .toList();

  /// إنشاء عملة، أو تعديل عملة موجودة إذا مُرّر [existingCode].
  Future<void> saveCurrency(Map<String, dynamic> data, {String? existingCode}) =>
      existingCode == null
          ? _c.request('POST', '/currencies', data: data)
          : _c.request('PUT', '/currencies/$existingCode', data: data);

  Future<void> setCurrencyConfig({String? local, String? defaultCode}) =>
      _c.request('PUT', '/currencies-config', data: {
        if (local != null) 'local': local,
        if (defaultCode != null) 'default': defaultCode,
      });

  Future<List<Map<String, dynamic>>> currencyHistory(String code) =>
      _list(_c.request('GET', '/currencies/$code/history'));
}
