import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../services/app_settings_service.dart';
import '../middleware.dart';

/// إعدادات النظام: القراءة لكل مستخدم مسجَّل (الشاشات تبني عليها)،
/// والتعديل لمن يملك صلاحية settings (انظر Authorization).
class AppSettingsRoutes {
  final AppDatabase db;
  AppSettingsRoutes(this.db);

  Router get router {
    final r = Router();
    final svc = AppSettingsService(db);

    r.get('/app-settings', (Request req) async => jsonOk(await svc.all()));

    r.put('/app-settings', (Request req) async {
      final Object? body;
      try {
        body = jsonDecode(await req.readAsString());
      } catch (_) {
        return jsonErr(400, 'جسم الطلب ليس JSON صالحاً');
      }
      if (body is! Map<String, dynamic> || body.isEmpty) {
        return jsonErr(400, 'أرسل كائناً بالإعدادات المراد تغييرها');
      }
      try {
        return jsonOk(await svc.update(body));
      } on SettingsException catch (e) {
        return jsonErr(400, e.message);
      }
    });

    return r;
  }
}
