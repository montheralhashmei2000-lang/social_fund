import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../db/repositories/fund_settings_repository.dart';
import '../middleware.dart';

class FundSettingsRoutes {
  final AppDatabase db;
  FundSettingsRoutes(this.db);

  Router get router {
    final r = Router();
    final repo = FundSettingsRepository(db);

    r.get('/fund-settings', (Request req) async {
      final s = await repo.get();
      if (s == null) {
        return jsonOk({
          'name': 'الصندوق الاجتماعي التنموي',
          'logo_base64': null, 'phone': null, 'email': null,
          'address': null, 'registration_no': null,
        });
      }
      return jsonOk(_toJson(s));
    });

    r.put('/fund-settings', (Request req) async {
      final b = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final s = await repo.upsert(
        name: b['name'] as String?, logoBase64: b['logo_base64'] as String?,
        phone: b['phone'] as String?, email: b['email'] as String?,
        address: b['address'] as String?, registrationNo: b['registration_no'] as String?,
      );
      return jsonOk(_toJson(s));
    });

    return r;
  }

  static Map<String, dynamic> _toJson(FundSetting s) => {
    'name': s.name, 'logo_base64': s.logoBase64, 'phone': s.phone,
    'email': s.email, 'address': s.address, 'registration_no': s.registrationNo,
  };
}
