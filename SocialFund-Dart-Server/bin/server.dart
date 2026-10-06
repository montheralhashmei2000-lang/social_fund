import 'dart:io';
import 'package:shelf/shelf_io.dart' as io;
import 'package:social_fund_dart_server/api/router.dart';
import 'package:social_fund_dart_server/core/config.dart';
import 'package:social_fund_dart_server/db/database.dart';
import 'package:social_fund_dart_server/db/pii_migration.dart';
import 'package:social_fund_dart_server/db/seed.dart';

Future<void> main(List<String> args) async {
  print('Starting Social Fund server...');
  // في الإنتاج المفاتيح إلزامية من البيئة: مفتاح مولَّد تلقائياً قد يضيع مع القرص،
  // وضياع ENCRYPTION_KEY يعني ضياع البيانات المشفّرة نهائياً.
  if (ServerConfig.isProduction) {
    final env = Platform.environment;
    for (final k in ['JWT_SECRET', 'ENCRYPTION_KEY']) {
      if ((env[k] ?? '').length < 32) {
        stderr.writeln('FATAL: ' + k + ' must be set (32+ chars) when APP_ENV=production');
        exit(1);
      }
    }
  }
  final db = openDatabaseFile();
  await seedDefaultAdmin(db);
  final encrypted = await PiiMigration.run(db);
  if (encrypted > 0) print('Encrypted personal data for ' + encrypted.toString() + ' records.');
  final handler = buildHandler(db);
  final port = ServerConfig.port;
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Server listening on http://localhost:' + server.port.toString());
  print('Health:  http://localhost:' + port.toString() + '/health');
  print('Login:   POST http://localhost:' + port.toString() + '/auth/login');
}
