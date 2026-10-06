import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../db/database.dart';
import 'middleware.dart';
import 'routes/auth_routes.dart';
import 'routes/health_routes.dart';
import 'routes/members_routes.dart';
import 'routes/aids_routes.dart';
import 'routes/subscriptions_routes.dart';
import 'routes/treasury_routes.dart';
import 'routes/vouchers_routes.dart';
import 'routes/messages_routes.dart';
import 'routes/events_routes.dart';
import 'routes/fund_settings_routes.dart';
import 'routes/users_routes.dart';
import 'routes/audit_logs_routes.dart';
import 'routes/accounts_routes.dart';
import 'routes/journal_routes.dart';
import 'routes/donors_routes.dart';
import 'routes/campaigns_routes.dart';
import 'routes/beneficiaries_routes.dart';
import 'routes/inkind_routes.dart';
import 'routes/budgets_routes.dart';
import 'routes/financial_reports_routes.dart';
import 'routes/pledges_routes.dart';
import 'routes/periodic_aids_routes.dart';
import 'routes/currencies_routes.dart';
import 'routes/app_routes.dart';

Handler buildHandler(AppDatabase db) {
  final root = Router();

  root.mount('/', HealthRoutes().router.call);
  root.mount('/', AuthRoutes(db).router.call);

  root.mount('/', MembersRoutes(db).router.call);
  root.mount('/', AidsRoutes(db).router.call);
  root.mount('/', SubscriptionsRoutes(db).router.call);
  root.mount('/', TreasuryRoutes(db).router.call);
  root.mount('/', VouchersRoutes(db).router.call);
  root.mount('/', MessagesRoutes(db).router.call);
  root.mount('/', EventsRoutes(db).router.call);
  root.mount('/', FundSettingsRoutes(db).router.call);
  root.mount('/', UsersRoutes(db).router.call);
  root.mount('/', AuditLogsRoutes(db).router.call);
  root.mount('/', AccountsRoutes(db).router.call);
  root.mount('/', JournalRoutes(db).router.call);
  root.mount('/', DonorsRoutes(db).router.call);
  root.mount('/', CampaignsRoutes(db).router.call);
  root.mount('/', BeneficiariesRoutes(db).router.call);
  root.mount('/', InKindRoutes(db).router.call);
  root.mount('/', BudgetsRoutes(db).router.call);
  root.mount('/', FinancialReportsRoutes(db).router.call);
  root.mount('/', PledgesRoutes(db).router.call);
  root.mount('/', PeriodicAidsRoutes(db).router.call);
  root.mount('/', CurrenciesRoutes(db).router.call);
  root.mount('/', AppRoutes(db).router.call);

  return const Pipeline()
      .addMiddleware(loggingMiddleware())
      .addMiddleware(authIfApiMiddleware(db))
      .addMiddleware(jsonErrorMiddleware())
      .addMiddleware(corsMiddleware())
      .addHandler(root.call);
}

Middleware optionalAuth() => authMiddleware(required: false);
Middleware requireAuth() => authMiddleware(required: true);
