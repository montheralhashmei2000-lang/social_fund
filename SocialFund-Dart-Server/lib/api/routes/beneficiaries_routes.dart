import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../db/database.dart';
import '../../db/repositories/beneficiaries_repository.dart';
import '../middleware.dart';

class BeneficiariesRoutes {
  final AppDatabase db;
  BeneficiariesRoutes(this.db);
  Router get router {
    final r = Router();
    final repo = BeneficiariesRepository(db);
    r.get('/beneficiaries', (Request req) async {
      final list = await repo.list();
      return jsonOk(list.map((b) => {
        'id': b.id, 'full_name': b.fullName, 'national_id': b.nationalId,
        'phone': b.phone, 'housing': b.housing, 'case_summary': b.caseSummary,
        'family_size': b.familySize, 'monthly_income': b.monthlyIncome,
        'status': b.status,
      }).toList());
    });
    r.post('/beneficiaries', (Request req) async {
      final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
      final name = (body['full_name'] ?? '').toString();
      if (name.isEmpty) return jsonErr(400, 'full_name required');
      final b = await repo.create(fullName: name,
        nationalId: body['national_id'] as String?,
        phone: body['phone'] as String?,
        familySize: (body['family_size'] as num?)?.toInt() ?? 1,
        monthlyIncome: (body['monthly_income'] as num?)?.toDouble() ?? 0,
        housing: body['housing'] as String?,
        caseSummary: body['case_summary'] as String?);
      return jsonOk({'id': b.id, 'full_name': b.fullName});
    });
    return r;
  }
}
