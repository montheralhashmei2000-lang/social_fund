/// طبقة "محلياً أولاً" (Local-First Repository).
///
/// القاعدة الذهبية: كل عملية كتابة تُنفَّذ في SQLite أولاً (فتنجح فوراً حتى
/// لو كان الإنترنت مقطوعاً)، ثم تُسجَّل في طابور المزامنة (outbox) ليُرفع
/// لاحقاً إلى سحابة Oracle Cloud عند توفّر الشبكة.
library;

import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../services/sync_service.dart';
import 'database.dart';

/// أسماء الكيانات كما يتوقعها الخادم في /sync/push.
class EntityType {
  static const member = 'member';
  static const aidRequest = 'aid_request';
  static const voucher = 'voucher';
  static const subscription = 'subscription';
  static const treasuryEntry = 'treasury_entry';
  static const event = 'event';
  static const beneficiary = 'beneficiary';
  static const periodicAid = 'periodic_aid';
  static const fundSettings = 'fund_settings';
  static const currency = 'currency';
}

/// جداول SQLite المقابلة.
class LocalTable {
  static const members = 'members';
  static const aidRequests = 'aid_requests';
  static const vouchers = 'vouchers';
  static const subscriptions = 'subscriptions';
  static const treasuryEntries = 'treasury_entries';
  static const events = 'events';
  static const beneficiaries = 'beneficiaries';
  static const periodicAids = 'periodic_aids';
  static const fundSettings = 'fund_settings';
  static const currencies = 'currencies';
}

/// مستودع محلي موحّد: كتابة محلية + تسجيل في طابور المزامنة.
class LocalStore {
  static final LocalStore _instance = LocalStore._internal();
  factory LocalStore() => _instance;
  LocalStore._internal();

  final DatabaseHelper _db = DatabaseHelper();
  static const _uuid = Uuid();

  /// توليد معرّف محلي فريد (UUID v4) يُستخدم كـ primary key في SQLite.
  String newId() => _uuid.v4();

  /// كتابة عضو محلياً + تسجيل العملية في الطابور (ذرّية).
  Future<String> upsertMember(Map<String, dynamic> data, {String? id}) async {
    final memberId = id ?? newId();
    final row = {
      'id': memberId,
      'name': data['name'],
      'national_id': data['national_id'],
      'phone': data['phone'],
      'email': data['email'],
      'city': data['city'],
      'join_date': data['join_date'],
      'status': data['status'] ?? 'نشط',
      'monthly_subscription': data['monthly_subscription'] ?? 0,
      'total_paid': data['total_paid'] ?? 0,
      'balance_due': data['balance_due'] ?? 0,
    };
    await _db.upsertAndEnqueue(
      table: LocalTable.members,
      row: row,
      entityType: EntityType.member,
      entityId: memberId,
      operation: 'upsert',
      payload: row,
    );
    await _trySync();
    return memberId;
  }

  /// كتابة حدث محلياً + تسجيل العملية.
  Future<String> upsertEvent(Map<String, dynamic> data, {String? id}) async {
    final eventId = id ?? newId();
    final row = {
      'id': eventId,
      'title': data['title'],
      'event_date': data['event_date'],
      'event_time': data['event_time'],
      'place': data['place'],
      'type': data['type'],
      'color': data['color'] ?? '#1B5E20',
    };
    await _db.upsertAndEnqueue(
      table: LocalTable.events,
      row: row,
      entityType: EntityType.event,
      entityId: eventId,
      operation: 'upsert',
      payload: row,
    );
    await _trySync();
    return eventId;
  }

  /// كتابة قيد خزينة محلياً + تسجيل العملية.
  Future<String> upsertTreasuryEntry(Map<String, dynamic> data, {String? id}) async {
    final entryId = id ?? newId();
    final row = {
      'id': entryId,
      'type': data['type'],
      'category': data['category'],
      'description': data['description'],
      'amount': data['amount'],
      'entry_date': data['entry_date'],
      'reference_no': data['reference_no'],
    };
    await _db.upsertAndEnqueue(
      table: LocalTable.treasuryEntries,
      row: row,
      entityType: EntityType.treasuryEntry,
      entityId: entryId,
      operation: 'upsert',
      payload: row,
    );
    await _trySync();
    return entryId;
  }

  /// كتابة طلب مساعدة محلياً + تسجيل العملية.
  Future<String> upsertAidRequest(Map<String, dynamic> data, {String? id}) async {
    final aidId = id ?? newId();
    final row = {
      'id': aidId,
      'member_id': data['member_id'],
      'member_name': data['member_name'],
      'aid_type': data['aid_type'],
      'amount': data['amount'],
      'request_date': data['request_date'],
      'status': data['status'] ?? 'قيد المراجعة',
      'note': data['note'],
      'reviewer_name': data['reviewer_name'],
    };
    await _db.upsertAndEnqueue(
      table: LocalTable.aidRequests,
      row: row,
      entityType: EntityType.aidRequest,
      entityId: aidId,
      operation: 'upsert',
      payload: row,
    );
    await _trySync();
    return aidId;
  }

  /// كتابة سند محلياً + تسجيل العملية.
  Future<String> upsertVoucher(Map<String, dynamic> data, {String? id}) async {
    final voucherId = id ?? newId();
    final row = {
      'id': voucherId,
      'voucher_no': data['voucher_no'],
      'kind': data['kind'],
      'member_id': data['member_id'],
      'member_name': data['member_name'],
      'donor_id': data['donor_id'],
      'beneficiary_id': data['beneficiary_id'],
      'party_name': data['party_name'],
      'amount': data['amount'],
      'voucher_date': data['voucher_date'],
      'method': data['method'],
      'description': data['description'],
      'issued_by_name': data['issued_by_name'],
      'status': data['status'] ?? 'معتمد',
      'treasury_account_id': data['treasury_account_id'],
      'counter_account_id': data['counter_account_id'],
      'journal_entry_id': data['journal_entry_id'],
      'journal_entry_no': data['journal_entry_no'],
    };
    await _db.upsertAndEnqueue(
      table: LocalTable.vouchers,
      row: row,
      entityType: EntityType.voucher,
      entityId: voucherId,
      operation: 'upsert',
      payload: row,
    );
    await _trySync();
    return voucherId;
  }

  /// كتابة اشتراك محلياً + تسجيل العملية.
  Future<String> upsertSubscription(Map<String, dynamic> data,
      {String? id}) async {
    final subId = id ?? newId();
    final row = {
      'id': subId,
      'member_id': data['member_id'],
      'member_name': data['member_name'],
      'amount': data['amount'],
      'payment_date': data['payment_date'],
      'method': data['method'],
      'reference_no': data['reference_no'],
    };
    await _db.upsertAndEnqueue(
      table: LocalTable.subscriptions,
      row: row,
      entityType: EntityType.subscription,
      entityId: subId,
      operation: 'upsert',
      payload: row,
    );
    await _trySync();
    return subId;
  }

  /// حذف منطقي محلي مع تسجيل عملية حذف في الطابور (ذرّية).
  Future<void> deleteLocal(
    String table,
    String entityType,
    String id, {
    Map<String, dynamic>? payload,
  }) async {
    await _db.softDeleteAndEnqueue(
      table: table,
      entityType: entityType,
      entityId: id,
      payload: payload ?? {'id': id},
    );
    await _trySync();
  }

  /// قراءة كل صفوف جدول محلياً.
  Future<List<Map<String, dynamic>>> readAll(String table, {String? orderBy}) =>
      _db.rows(table, orderBy: orderBy);

  /// تخزين بيانات قادمة من الخادم دون تعليمها كـ "قيد مزامنة".
  Future<void> cacheRemote(String table, List<Map<String, dynamic>> rows) async {
    for (final r in rows) {
      await _db.upsertRemote(table, r);
    }
  }

  /// عدد العمليات المعلّقة.
  Future<int> pendingCount() => _db.pendingCount();

  /// محاولة رفع التراكم فوراً إن كانت الشبكة متاحة (غير حاجزة).
  Future<void> _trySync() async {
    try {
      await syncService.forceSync();
    } catch (_) {
      // الفشل لا يقطع العملية - العملية محفوظة محلياً وستُرفع لاحقاً.
    }
  }

  /// تصدير البيانات المحلية كـ JSON (نسخة احتياطية محلية).
  Future<String> exportLocal() async {
    final tables = <String, dynamic>{};
    for (final t in const [
      LocalTable.members,
      LocalTable.aidRequests,
      LocalTable.vouchers,
      LocalTable.treasuryEntries,
      LocalTable.events,
      LocalTable.beneficiaries,
      LocalTable.periodicAids,
    ]) {
      tables[t] = await _db.rows(t, includeDeleted: true);
    }
    return jsonEncode({
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'tables': tables,
    });
  }
}