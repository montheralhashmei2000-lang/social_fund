import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';
import '../../core/password.dart';

class UsersFullRepository {
  final AppDatabase db;
  UsersFullRepository(this.db);

  Future<List<User>> list() =>
      (db.select(db.users)..where((t) => t.deleted.equals(false))).get();

  Future<List<User>> colleagues(String excludeId) =>
      (db.select(db.users)
            ..where((t) => t.deleted.equals(false) & t.isActive.equals(true) & t.id.equals(excludeId).not()))
          .get();

  Future<User?> byId(String id) =>
      (db.select(db.users)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<User> create({
    required String username, required String password, required String fullName,
    required String role, String? phone,
  }) async {
    final now = DateTime.now();
    final id = const Uuid().v4();
    final hash = await hashPassword(password);
    await db.into(db.users).insert(UsersCompanion.insert(
      id: id, username: username, fullName: fullName, passwordHash: hash,
      role: Value(role), phone: Value(phone),
      isActive: const Value(true),
      otpEnabled: const Value(false),
      createdAt: now, updatedAt: now,
    ));
    return (await byId(id))!;
  }

  Future<User?> update(String id, {String? fullName, String? role, String? phone, bool? isActive}) async {
    if (await byId(id) == null) return null;
    await (db.update(db.users)..where((t) => t.id.equals(id))).write(
      UsersCompanion(
        fullName: fullName != null ? Value(fullName) : const Value.absent(),
        role: role != null ? Value(role) : const Value.absent(),
        phone: Value(phone),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return byId(id);
  }

  Future<bool> softDelete(String id) async {
    final n = await (db.update(db.users)..where((t) => t.id.equals(id)))
        .write(UsersCompanion(deleted: const Value(true), updatedAt: Value(DateTime.now())));
    return n > 0;
  }
}

