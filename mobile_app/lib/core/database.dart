/// إدارة SQLite المحلية للوضع الأول محلياً (Local-First Architecture):
/// - جميع العمليات تُنفَّذ محلياً أولاً في SQLite، حتى دون اتصال بالشبكة
/// - المزامنة المؤجلة: عندما تتاح شبكة الإنترنت ولو لفترة قصيرة، يتم رفع
///   جميع العمليات المتراكمة (طابور المزامنة) إلى السحابة دفعة واحدة
/// - التطبيق يعمل بالكامل دون اتصال بالإنترنت، مع ضمان التزامن مع السحابة
library;

import 'dart:convert';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String _databaseName = 'social_fund_local.db';
  static const int _databaseVersion = 4;

  /// قاعدة البيانات الرئيسية - تُنشأ تلقائياً عند أول طلب.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // تهيئة sqflite_common_ffi لنظام Windows/Linux/macOS سطح المكتب
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(docsDir.path, _databaseName);
    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createCoreTables(db);
        await _createSyncTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // ترقية آمنة: إضافة الجداول/الأعمدة الناقصة دون فقدان البيانات المحلية.
        if (oldVersion < 2) {
          await db.execute('''CREATE TABLE IF NOT EXISTS subscriptions (
            id TEXT PRIMARY KEY, member_id TEXT, member_name TEXT, amount INTEGER,
            payment_date TEXT, method TEXT, reference_no TEXT,
            dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
            created_at TEXT DEFAULT (datetime('now')),
            updated_at TEXT DEFAULT (datetime('now')) )''');
        }
        if (oldVersion < 3) {
          // v3: توحيد مخطط SQLite مع نماذج SQLAlchemy في الخادم.
          // الجداول المتغيّرة تُعاد بناؤها (بياناتها نسخة مؤقتة تُجلب من الخادم).
          await _rebuildV3Tables(db);
        }
      },
    );
  }

  /// إعادة بناء الجداول التي تغيّر مخططها لتطابق الخادم (ترقية إلى v3).
  Future<void> _rebuildV3Tables(Database db) async {
    // vouchers: الأعمدة القديمة (type/request_date/...) استُبدلت بأعمدة الخادم.
    await db.execute('DROP TABLE IF EXISTS vouchers');
    await db.execute('''CREATE TABLE vouchers (
      id TEXT PRIMARY KEY, voucher_no TEXT, kind TEXT,
      member_id TEXT, member_name TEXT, donor_id TEXT, beneficiary_id TEXT,
      party_name TEXT, amount INTEGER, voucher_date TEXT, method TEXT,
      description TEXT, issued_by_name TEXT, status TEXT,
      treasury_account_id TEXT, counter_account_id TEXT,
      journal_entry_id TEXT, journal_entry_no TEXT,
      dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');

    // treasury_entries: account_code/currency_code/... استُبدلت بـ entry_date.
    await db.execute('DROP TABLE IF EXISTS treasury_entries');
    await db.execute('''CREATE TABLE treasury_entries (
      id TEXT PRIMARY KEY, type TEXT, category TEXT, description TEXT,
      amount INTEGER, entry_date TEXT, reference_no TEXT,
      dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');

    // beneficiaries: name → full_name (تسمية الخادم).
    await db.execute('DROP TABLE IF EXISTS beneficiaries');
    await db.execute('''CREATE TABLE beneficiaries (
      id TEXT PRIMARY KEY, full_name TEXT, national_id TEXT, phone TEXT,
      family_size INTEGER, monthly_income REAL, housing TEXT,
      case_summary TEXT, status TEXT,
      dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');

    // fund_settings: حقول الخادم (name/logo_base64/...) بدل fund_name/fund_code.
    await db.execute('DROP TABLE IF EXISTS fund_settings');
    await db.execute('''CREATE TABLE fund_settings (
      id TEXT PRIMARY KEY, name TEXT, logo_base64 TEXT, phone TEXT, email TEXT,
      address TEXT, registration_no TEXT,
      dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');

    // currencies: المفتاح صار id والاسم name_ar كما في الخادم.
    await db.execute('DROP TABLE IF EXISTS currencies');
    await db.execute('''CREATE TABLE currencies (
      id TEXT PRIMARY KEY, code TEXT, name_ar TEXT, symbol TEXT,
      decimals INTEGER DEFAULT 2, rate REAL DEFAULT 0,
      is_local INTEGER DEFAULT 0, is_default INTEGER DEFAULT 0,
      is_active INTEGER DEFAULT 1,
      dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');
  }

  Future<void> _createCoreTables(Database db) async {
    await db.execute('''CREATE TABLE members (
      id TEXT PRIMARY KEY, name TEXT, national_id TEXT, phone TEXT, email TEXT,
      city TEXT, join_date TEXT, status TEXT, monthly_subscription INTEGER,
      total_paid INTEGER, balance_due INTEGER,
      dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');

    await db.execute('''CREATE TABLE aid_requests (
      id TEXT PRIMARY KEY, member_id TEXT, member_name TEXT, aid_type TEXT,
      amount INTEGER, request_date TEXT, status TEXT, note TEXT, reviewer_name TEXT,
      dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');

    await db.execute('''CREATE TABLE vouchers (
      id TEXT PRIMARY KEY, voucher_no TEXT, kind TEXT,
      member_id TEXT, member_name TEXT, donor_id TEXT, beneficiary_id TEXT,
      party_name TEXT, amount INTEGER, voucher_date TEXT, method TEXT,
      description TEXT, issued_by_name TEXT, status TEXT,
      treasury_account_id TEXT, counter_account_id TEXT,
      journal_entry_id TEXT, journal_entry_no TEXT,
      dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');

    await db.execute('''CREATE TABLE periodic_aids (
      id TEXT PRIMARY KEY, beneficiary_id TEXT, beneficiary_name TEXT,
      started_on TEXT, status TEXT, monthly_amount REAL, last_paid_period TEXT,
      due_period TEXT, notes TEXT, days_overdue INTEGER,
      dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');

    await db.execute('''CREATE TABLE subscriptions (
      id TEXT PRIMARY KEY, member_id TEXT, member_name TEXT, amount INTEGER,
      payment_date TEXT, method TEXT, reference_no TEXT,
      dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');

    await db.execute('''CREATE TABLE beneficiaries (
      id TEXT PRIMARY KEY, full_name TEXT, national_id TEXT, phone TEXT,
      family_size INTEGER, monthly_income REAL, housing TEXT,
      case_summary TEXT, status TEXT,
      dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');

    await db.execute('''CREATE TABLE treasury_entries (
      id TEXT PRIMARY KEY, type TEXT, category TEXT, description TEXT,
      amount INTEGER, entry_date TEXT, reference_no TEXT,
      dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');

    await db.execute('''CREATE TABLE events (
      id TEXT PRIMARY KEY, title TEXT, event_date TEXT, event_time TEXT,
      place TEXT, type TEXT, color TEXT,
      dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');

    await db.execute('''CREATE TABLE fund_settings (
      id TEXT PRIMARY KEY, name TEXT, logo_base64 TEXT, phone TEXT, email TEXT,
      address TEXT, registration_no TEXT,
      dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');

    // users: للتخزن محلياً لتسجيل الدخول دون اتصال بالإنترنت.
    await db.execute('''CREATE TABLE users (
      id TEXT PRIMARY KEY, username TEXT UNIQUE, password_hash TEXT,
      full_name TEXT, role TEXT,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');

    await db.execute('''CREATE TABLE currencies (
      id TEXT PRIMARY KEY, code TEXT, name_ar TEXT, symbol TEXT,
      decimals INTEGER DEFAULT 2, rate REAL DEFAULT 0,
      is_local INTEGER DEFAULT 0, is_default INTEGER DEFAULT 0,
      is_active INTEGER DEFAULT 1,
      dirty INTEGER DEFAULT 0, deleted INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');
  }

  Future<void> _createSyncTables(Database db) async {
    await db.execute('''CREATE TABLE outbox (
      id TEXT PRIMARY KEY, op_seq INTEGER, entity_type TEXT, entity_id TEXT,
      operation TEXT, payload TEXT, status TEXT DEFAULT 'pending',
      attempts INTEGER DEFAULT 0, last_error TEXT,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')) )''');

    await db.execute('''CREATE TABLE sync_state (
      key TEXT PRIMARY KEY, value TEXT,
      updated_at TEXT DEFAULT (datetime('now')) )''');

    await db.execute('CREATE INDEX idx_outbox_status ON outbox(status, op_seq)');
    await db.execute('CREATE INDEX idx_members_nid ON members(national_id)');
    await db.execute('CREATE INDEX idx_aid_member ON aid_requests(member_id)');
    await db.execute('CREATE INDEX idx_aid_status ON aid_requests(status)');
  }

  // ============================================================
  //  طبقة CRUD العامة (Generic CRUD over SQLite)
  // ============================================================

  /// إدراج أو تحديث صف محلياً مع تعليمه كـ "قيد المزامنة".
  /// [row] يجب أن يحتوي على 'id' كمفتاح أساسي.
  Future<void> upsert(String table, Map<String, dynamic> row,
      {bool dirty = true, bool deleted = false}) async {
    final db = await database;
    final data = Map<String, dynamic>.from(row);
    data['dirty'] = dirty ? 1 : 0;
    data['deleted'] = deleted ? 1 : 0;
    data['updated_at'] = _now();

    final columns = data.keys.join(', ');
    final placeholders = List.filled(data.length, '?').join(', ');
    final updates = data.keys
        .where((k) => k != 'id')
        .map((k) => '$k = excluded.$k')
        .join(', ');
    final conflict = 'ON CONFLICT(id) DO UPDATE SET $updates';

    await db.rawInsert(
      'INSERT INTO $table ($columns) VALUES ($placeholders) $conflict',
      data.values.toList(),
    );
  }

  /// كتابة محلية + تسجيل في طابور المزامنة داخل معاملة واحدة (ذرّية).
  ///
  /// إما أن ينجح الاثنان معاً، أو يُلغى الاثنان - فلا يمكن أن توجد كتابة
  /// في SQLite بلا عملية في الطابور (والعكس)، فلا تضيع أي بيانات.
  Future<void> upsertAndEnqueue({
    required String table,
    required Map<String, dynamic> row,
    required String entityType,
    required String entityId,
    required String operation,
    Map<String, dynamic>? payload,
  }) async {
    final db = await database;
    final data = Map<String, dynamic>.from(row);
    data['dirty'] = 1;
    data['deleted'] = operation == 'delete' ? 1 : 0;
    data['updated_at'] = _now();

    final columns = data.keys.join(', ');
    final placeholders = List.filled(data.length, '?').join(', ');
    final updates = data.keys
        .where((k) => k != 'id')
        .map((k) => '$k = excluded.$k')
        .join(', ');
    final conflict = 'ON CONFLICT(id) DO UPDATE SET $updates';

    await db.transaction((txn) async {
      await txn.rawInsert(
        'INSERT INTO $table ($columns) VALUES ($placeholders) $conflict',
        data.values.toList(),
      );
      await txn.insert('outbox', {
        'id': 'op_${DateTime.now().microsecondsSinceEpoch}_${data['id']}',
        'op_seq': await _nextSequenceInTxn(txn),
        'entity_type': entityType,
        'entity_id': entityId,
        'operation': operation,
        'payload': jsonEncode(payload ?? data),
        'status': 'pending',
        'attempts': 0,
        'created_at': _now(),
        'updated_at': _now(),
      });
    });
  }

  /// حساب تسلسل العملية التالية داخل معاملة قائمة.
  Future<int> _nextSequenceInTxn(Transaction txn) async {
    final r = await txn.rawQuery('SELECT MAX(op_seq) AS m FROM outbox');
    final current = (r.first['m'] as num?)?.toInt() ?? 0;
    final s = await txn.query('sync_state',
        where: 'key = ?', whereArgs: ['last_op_seq'], limit: 1);
    final last = int.tryParse(s.isEmpty ? '0' : (s.first['value'] as String? ?? '0')) ?? 0;
    final next = (current > last ? current : last) + 1;
    await txn.insert(
      'sync_state',
      {'key': 'last_op_seq', 'value': '$next', 'updated_at': _now()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return next;
  }

  /// حذف منطقي (soft delete) + تسجيل في طابور المزامنة داخل معاملة واحدة.
  /// يُحفظ الصف	current مع رفع علم المحذوف فقط (لا يُمسح أي عمود).
  Future<void> softDeleteAndEnqueue({
    required String table,
    required String entityType,
    required String entityId,
    Map<String, dynamic>? payload,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        table,
        {'deleted': 1, 'dirty': 1, 'updated_at': _now()},
        where: 'id = ?',
        whereArgs: [entityId],
      );
      await txn.insert('outbox', {
        'id': 'op_${DateTime.now().microsecondsSinceEpoch}_$entityId',
        'op_seq': await _nextSequenceInTxn(txn),
        'entity_type': entityType,
        'entity_id': entityId,
        'operation': 'delete',
        'payload': jsonEncode(payload ?? {'id': entityId}),
        'status': 'pending',
        'attempts': 0,
        'created_at': _now(),
        'updated_at': _now(),
      });
    });
  }

  /// إدراج أو تحديث بدون تعليم dirtiness (يُستخدم عند السحب من السحابة).
  Future<void> upsertRemote(String table, Map<String, dynamic> row) =>
      upsert(table, row, dirty: false);

  /// حذف منطقي (soft delete) محلياً مع تسجيل عملية حذف في الطابور.
  Future<void> softDelete(String table, String id) async {
    final db = await database;
    await db.update(
      table,
      {'deleted': 1, 'dirty': 1, 'updated_at': _now()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> rows(String table,
      {bool includeDeleted = false, String? orderBy}) async {
    final db = await database;
    final where = includeDeleted ? '' : 'WHERE deleted = 0';
    final order = orderBy == null ? '' : 'ORDER BY $orderBy';
    return db.query(table, where: where.isEmpty ? null : where,
        orderBy: order.isEmpty ? null : order);
  }

  Future<Map<String, dynamic>?> row(String table, String id) async {
    final db = await database;
    final r = await db.query(table, where: 'id = ?', whereArgs: [id], limit: 1);
    return r.isEmpty ? null : r.first;
  }

  Future<int> count(String table, {bool includeDeleted = false}) async {
    final db = await database;
    final where = includeDeleted ? '' : 'WHERE deleted = 0';
    final r = await db.rawQuery('SELECT COUNT(*) AS c FROM $table $where');
    return (r.first['c'] as num?)?.toInt() ?? 0;
  }

  Future<void> deleteWhere(String table, String where, List<Object?> args) async {
    final db = await database;
    await db.delete(table, where: where, whereArgs: args);
  }

  Future<void> clear(String table) async {
    final db = await database;
    await db.delete(table);
  }
// ============================================================
  //  طابور المزامنة (Outbox)
  // ============================================================

  /// إضافة عملية إلى طابور المزامنة. تُستدعى بعد نجاح الكتابة المحلية.
  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final db = await database;
    final seq = await nextSequence();
    final id = 'op_${DateTime.now().microsecondsSinceEpoch}_$seq';
    await db.insert('outbox', {
      'id': id,
      'op_seq': seq,
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation,
      'payload': jsonEncode(payload),
      'status': 'pending',
      'attempts': 0,
      'created_at': _now(),
      'updated_at': _now(),
    });
  }

  /// العمليات المعلّقة مرتبة بالتسلسل الزمني (الأقدم أولاً).
  Future<List<Map<String, dynamic>>> pendingOperations({int limit = 200}) async {
    final db = await database;
    return db.query(
      'outbox',
      where: "status IN ('pending','failed')",
      orderBy: 'op_seq ASC',
      limit: limit,
    );
  }

  Future<void> markOperationDone(String opId) async {
    final db = await database;
    await db.delete('outbox', where: 'id = ?', whereArgs: [opId]);
  }

  Future<void> markOperationFailed(String opId, String error) async {
    final db = await database;
    await db.rawUpdate(
      "UPDATE outbox SET status = CASE WHEN attempts >= 4 THEN 'dead' ELSE 'failed' END, "
      'attempts = attempts + 1, last_error = ?, updated_at = ? WHERE id = ?',
      [error, _now(), opId],
    );
  }

  Future<int> pendingCount() async {
    final db = await database;
    final r = await db.rawQuery(
      "SELECT COUNT(*) AS c FROM outbox WHERE status IN ('pending','failed')");
    return (r.first['c'] as num?)?.toInt() ?? 0;
  }

  /// عدد الكيانات المحلية التي لم تُ全面提升 إلى السحابة.
  Future<int> dirtyCount(String table) async {
    final db = await database;
    final r = await db.rawQuery('SELECT COUNT(*) AS c FROM $table WHERE dirty = 1');
    return (r.first['c'] as num?)?.toInt() ?? 0;
  }

  Future<void> clearDirty(String table, String id) async {
    final db = await database;
    await db.update(table, {'dirty': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  /// تنظيف السجلات المحذوفة بعد مزامنتها مع السحابة.
  Future<void> purgeDeleted(String table) async {
    final db = await database;
    await db.delete(table, where: 'deleted = 1');
  }

  // ============================================================
  //  حالة المزامنة (Sync state)
  // ============================================================

  Future<void> setState(String key, String value) async {
    final db = await database;
    await db.insert('sync_state', {'key': key, 'value': value, 'updated_at': _now()},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getState(String key) async {
    final db = await database;
    final r = await db.query('sync_state', where: 'key = ?', whereArgs: [key],
        limit: 1);
    return r.isEmpty ? null : r.first['value'] as String?;
  }

  /// عدّاد تسلسلي رتيب لعمليات المزامنة (يجعل الترتيب على السحابة).
  Future<int> nextSequence() async {
    final db = await database;
    final r = await db.rawQuery('SELECT MAX(op_seq) AS m FROM outbox');
    final current = (r.first['m'] as num?)?.toInt() ?? 0;
    final last = int.tryParse(await getState('last_op_seq') ?? '0') ?? 0;
    final next = (current > last ? current : last) + 1;
    await setState('last_op_seq', '$next');
    return next;
  }

  static String _now() =>
      DateTime.now().toUtc().toIso8601String().replaceFirst('T', ' ').split('.').first;

  /// التحقق من وجود مستخدم محلي ومقارنة كلمة المرور.
  /// يعيد بيانات المستخدم إن كانت كلمة المرور صحيحة، أو null إن لم يوجد.
  Future<Map<String, dynamic>?> getLocalUser(String username, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final expectedHash = _hash(password);
    if (row['password_hash'] != expectedHash) return null;
    return row;
  }

  /// حفظ مستخدم محلياً بعد successful login من الخادم.
  Future<void> upsertLocalUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert('users', {
      'id': user['id'].toString(),
      'username': user['username'].toString(),
      'password_hash': _hash(user['password'].toString()),
      'full_name': user['full_name'] ?? '',
      'role': user['role'] ?? 'viewer',
      'updated_at': _now(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// حذف بيانات المستخدم المحلي عند تسجيل الخروج.
  Future<void> wipeLocalUsers() async {
    final db = await database;
    await db.delete('users');
  }

  static String _hash(String s) {
    final bytes = utf8.encode(s);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// حذف كل البيانات المحلية (عند تسجيل الخروج أو تبديل الخادم).
  Future<void> wipe() async {
    final db = await database;
    const tables = [
      'members', 'aid_requests', 'vouchers', 'periodic_aids', 'beneficiaries',
      'subscriptions', 'treasury_entries', 'events', 'fund_settings',
      'currencies', 'outbox', 'sync_state',
    ];
    for (final t in tables) {
      await db.delete(t);
    }
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
