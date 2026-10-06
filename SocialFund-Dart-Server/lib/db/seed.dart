import 'package:uuid/uuid.dart';
import '../core/config.dart';
import '../core/password.dart';
import 'repositories/users_repository.dart';
import 'database.dart';

Future<void> seedDefaultAdmin(AppDatabase db) async {
  final repo = UsersRepository(db);
  final existing = await repo.byUsername('admin');
  if (existing != null) return;
  // كلمة المرور الأولى: من ADMIN_PASSWORD إن ضُبطت (8 أحرف فأكثر)، وفي الإنتاج
  // بدونها تُولَّد عشوائياً وتُطبع مرة واحدة. الثابتة تُستخدم في التطوير فقط.
  final fromEnv = ServerConfig.adminBootstrapPassword;
  final String password;
  if (fromEnv != null && fromEnv.length >= 8) {
    password = fromEnv;
  } else if (ServerConfig.isProduction) {
    password = ServerConfig.randomSecret().substring(0, 16);
  } else {
    password = 'Admin@12345';
  }
  final hash = await hashPassword(password);
  await repo.create(
    id: const Uuid().v4(), username: 'admin', fullName: 'المدير العام',
    role: 'admin', passwordHash: hash, phone: null,
  );
  if (fromEnv != null && fromEnv.length >= 8) {
    print('Created user admin (password from ADMIN_PASSWORD).');
  } else {
    print('Created user: admin / ' + password + '   <-- change it after first login');
  }
}
