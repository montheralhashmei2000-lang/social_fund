import 'package:drift/drift.dart';
import '../database.dart';

class UsersRepository {
  final AppDatabase db;
  UsersRepository(this.db);

  Future<User?> byUsername(String username) =>
      (db.select(db.users)..where((t) => t.username.equals(username))).getSingleOrNull();

  Future<User?> byId(String id) =>
      (db.select(db.users)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> create({
    required String id, required String username, required String fullName,
    required String role, required String passwordHash, String? phone,
  }) async {
    final now = DateTime.now();
    await db.into(db.users).insert(UsersCompanion.insert(
      id: id, username: username, fullName: fullName, passwordHash: passwordHash,
      role: Value(role), phone: Value(phone),
      isActive: const Value(true),
      otpEnabled: const Value(false),       // ← عطّل OTP
      createdAt: now, updatedAt: now,
    ));
  }

  Future<void> deactivate(String id) async {
    await (db.update(db.users)..where((t) => t.id.equals(id))).write(
      UsersCompanion(isActive: const Value(false), updatedAt: Value(DateTime.now())),
    );
  }
}
