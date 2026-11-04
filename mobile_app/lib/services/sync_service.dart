/// Local-First Architecture - Background Synchronization Service
/// 
/// This service handles the "Background Synchronization" pattern:
/// - All operations are written to SQLite (local-first)
/// - Pending operations are queued in the outbox table
/// - When network becomes available, all queued operations are sent to the cloud in one batch
/// - Retry logic with exponential backoff for failed operations
/// - Dead-letter queue for operations that fail after max attempts
library;

import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/api_client.dart';
import '../core/database.dart';

/// Enum defining the sync state
enum SyncState { idle, syncing, completed, error, offline }

/// Data classes for sync state and progress
class SyncProgress {
  final int processed;
  final int total;
  final int percentage;

  const SyncProgress({
    required this.processed,
    required this.total,
    required this.percentage,
  });
}

class SyncCounts {
  final int synced;
  final int failed;
  final int totalPending;

  const SyncCounts({
    required this.synced,
    required this.failed,
    required this.totalPending,
  });
}

/// Main synchronization service - handles background sync of pending operations
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DatabaseHelper _db = DatabaseHelper();
  final ApiClient _api = ApiClient.instance;
  final Connectivity _connectivity = Connectivity();

  /// تُستدعى عند اكتمال المزامنة لتحديث الواجهة.
  final List<void Function()> _onSyncCompleted = [];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Current sync state
  SyncState _syncState = SyncState.idle;
  int _syncedCount = 0;
  int _failedCount = 0;
  int _totalPending = 0;

  /// Stream controllers for listeners
  final _stateController = StreamController<SyncState>.broadcast();
  final _progressController = StreamController<SyncProgress>.broadcast();
  final _countsController = StreamController<SyncCounts>.broadcast();

  /// Stream exposures
  Stream<SyncState> get syncStateStream => _stateController.stream;
  Stream<SyncProgress> get progressStream => _progressController.stream;
  Stream<SyncCounts> get countsStream => _countsController.stream;

  /// Current state getters
  SyncState get syncState => _syncState;
  int get syncedCount => _syncedCount;
  int get failedCount => _failedCount;
  int get totalPending => _totalPending;

  /// Initialize the sync service
  Future<void> init() async {
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);

    // Check initial connectivity
    await _checkInitialConnectivity();

    // Load pending operations count
    await _refreshPendingCount();
  }

  /// تسجيل مستمع يُنفَّذ بعد كل مزامنة ناجحة (لتحديث الواجهة).
  void addSyncListener(void Function() listener) => _onSyncCompleted.add(listener);

  void removeSyncListener(void Function() listener) =>
      _onSyncCompleted.remove(listener);

  /// فحص الاتصال الابتدائي وتشغيل المزامنة إن كان متاحاً.
  Future<void> _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    final isOnline = results.any((r) => r != ConnectivityResult.none);
    if (isOnline) {
      // تأخير بسيط حتى تكتمل مصادقة المستخدم.
      Future.delayed(const Duration(seconds: 3), () => _triggerSync());
    }
  }

  /// عند عودة الشبكة: تشغيل المزامنة المتراكمة دفعة واحدة.
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final isOnline = results.any((r) => r != ConnectivityResult.none);
    if (isOnline && _syncState != SyncState.syncing) {
      _triggerSync();
    } else if (!isOnline) {
      _syncState = SyncState.offline;
      _stateController.add(_syncState);
    }
  }

  /// تشغيل دورة المزامنة كاملة (دورة واحدة في كل وقت).
  Future<void> _triggerSync() async {
    if (_syncState == SyncState.syncing) return;

    _syncState = SyncState.syncing;
    _syncedCount = 0;
    _failedCount = 0;
    _stateController.add(_syncState);

    try {
      await _performSync();
      _syncState = SyncState.completed;
    } on NetworkException {
      _syncState = SyncState.offline;
    } catch (_) {
      _syncState = SyncState.error;
    } finally {
      await _refreshPendingCount();
      _stateController.add(_syncState);
      if (_syncedCount > 0) {
        for (final l in List.of(_onSyncCompleted)) {
          l();
        }
      }
    }
  }

  /// تنفيذ المزامنة: رفع كل العمليات المعلّقة إلى السحابة دفعة واحدة.
  Future<void> _performSync() async {
    final ops = await _db.pendingOperations(limit: 500);
    if (ops.isEmpty) {
      _totalPending = 0;
      _countsController.add(_getCounts());
      return;
    }

    _totalPending = ops.length;
    _countsController.add(_getCounts());

    // تجميع العمليات في حزمة واحدة (batch) مرتبة بالتسلسل الزمني.
    final payload = <String, dynamic>{
      'operations': [
        for (final op in ops)
          {
            'op_id': op['id'],
            'seq': op['op_seq'],
            'entity_type': op['entity_type'],
            'entity_id': op['entity_id'],
            'operation': op['operation'],
            'payload': jsonDecode(op['payload'] as String),
            'attempts': op['attempts'],
          }
      ],
      'device_timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    final res = await _api.request('POST', '/sync/push', data: payload);
    final map = Map<String, dynamic>.from(res as Map);

    final applied = (map['applied'] as List?) ?? const [];
    final failed = (map['failed'] as List?) ?? const [];
    final serverTime = map['server_time'] as String?;

    // تأكيد العمليات التي نجح الخادم في تطبيقها.
    for (final item in applied) {
      final opId = (item is Map ? item['op_id'] : item).toString();
      await _db.markOperationDone(opId);
      final entityType = (item is Map ? item['entity_type'] : null)?.toString();
      final entityId = (item is Map ? item['entity_id'] : null)?.toString();
      if (entityType != null && entityId != null) {
        await _db.clearDirty(_tableFor(entityType), entityId);
      }
      _syncedCount++;
    }

    // العمليات الفاشلة تبقى في الطابور لإعادة المحاولة لاحقاً.
    for (final item in failed) {
      final opId = (item is Map ? item['op_id'] : item).toString();
      final reason = (item is Map ? item['error'] : null)?.toString() ?? 'فشل غير معروف';
      await _db.markOperationFailed(opId, reason);
      _failedCount++;
    }

    if (serverTime != null) {
      await _db.setState('last_server_time', serverTime);
    }
    await _db.setState('last_sync_at', DateTime.now().toUtc().toIso8601String());

    // تنظيف السجلات المحذوفة التي اكتملت مزامنتها.
    await _purgeSyncedDeletions();

    _countsController.add(_getCounts());
    _progressController.add(SyncProgress(
      processed: _syncedCount,
      total: _totalPending,
      percentage:
          _totalPending > 0 ? (_syncedCount * 100 / _totalPending).round() : 0,
    ));
  }

  /// خرائط الكيانات إلى جداول SQLite المحلية.
  static String _tableFor(String entityType) {
    switch (entityType) {
      case 'member':
        return 'members';
      case 'aid_request':
        return 'aid_requests';
      case 'voucher':
        return 'vouchers';
      case 'periodic_aid':
        return 'periodic_aids';
      case 'beneficiary':
        return 'beneficiaries';
      case 'treasury_entry':
        return 'treasury_entries';
      case 'event':
        return 'events';
      case 'fund_settings':
        return 'fund_settings';
      case 'currency':
        return 'currencies';
      default:
        return entityType;
    }
  }

  /// حذف السجلات المحذوفة التي اكتملت مزامنتها مع السحابة.
  Future<void> _purgeSyncedDeletions() async {
    const tables = [
      'members', 'aid_requests', 'vouchers', 'periodic_aids', 'beneficiaries',
      'treasury_entries', 'events', 'fund_settings', 'currencies',
    ];
    for (final t in tables) {
      await _db.purgeDeleted(t);
    }
  }

  SyncCounts _getCounts() => SyncCounts(
        synced: _syncedCount,
        failed: _failedCount,
        totalPending: _totalPending,
      );

  /// تحديث عدّاد العمليات المعلّقة.
  Future<void> _refreshPendingCount() async {
    _totalPending = await _db.pendingCount();
    _countsController.add(_getCounts());
  }

  /// هل توجد عمليات معلّقة؟
  Future<bool> hasPendingOperations() async => await _db.pendingCount() > 0;

  /// مزامنة يدوية فورية (من زر في الواجهة).
  Future<void> forceSync() async {
    if (_syncState == SyncState.syncing) return;
    await _triggerSync();
  }

  /// قائمة العمليات المعلّقة للعرض في الواجهة.
  Future<List<Map<String, dynamic>>> getPendingOperations({int limit = 50}) =>
      _db.pendingOperations(limit: limit);

  /// حذف كل البيانات المحلية (تسجيل خروج أو تبديل الخادم).
  Future<void> resetLocalData() async {
    await _db.wipe();
    await _refreshPendingCount();
  }

  /// إغلاق الموارد.
  void dispose() {
    _connectivitySubscription?.cancel();
    _stateController.close();
    _progressController.close();
    _countsController.close();
  }
}

/// نقطة وصول جاهزة للاستخدام.
final SyncService syncService = SyncService();