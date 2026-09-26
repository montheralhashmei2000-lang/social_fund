import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/rbac.dart';
import '../services/api_service.dart';

/// متحكم التوسعة: المحاسبة، المانحون، الحملات، المستفيدون، العينية، الموازنات.
/// كل قسم يُحمَّل عند فتح شاشته حسب صلاحية الدور.
class ExpansionController extends ChangeNotifier {
  final ApiService _api = ApiService.instance;

  bool loading = false;
  String? lastError;

  List<Account> accounts = [];
  List<JournalEntryModel> journal = [];
  List<Donor> donors = [];
  List<Pledge> pledges = [];
  List<Campaign> campaigns = [];
  List<Beneficiary> beneficiaries = [];
  List<PeriodicAidModel> periodicAids = [];
  List<InKindItem> inKindItems = [];

  bool can(String? role, String resource) => Rbac.can(role, resource);

  Future<void> _run(Future<void> Function() task) async {
    loading = true;
    notifyListeners();
    try {
      await task();
      lastError = null;
    } on ApiException catch (e) {
      lastError = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> loadAccounts() => _run(() async {
        accounts = await _api.accounts();
      }).then((_) => lastError == null);

  Future<bool> loadJournal() => _run(() async {
        journal = await _api.journal();
      }).then((_) => lastError == null);

  Future<bool> loadDonors() => _run(() async {
        donors = await _api.donors();
        pledges = await _api.pledges();
      }).then((_) => lastError == null);

  Future<bool> loadCampaigns() => _run(() async {
        campaigns = await _api.campaigns();
      }).then((_) => lastError == null);

  Future<bool> loadBeneficiaries() => _run(() async {
        beneficiaries = await _api.beneficiaries();
        periodicAids = await _api.periodicAids();
      }).then((_) => lastError == null);

  Future<bool> loadInKind() => _run(() async {
        inKindItems = await _api.inKindItems();
      }).then((_) => lastError == null);

  // ===== Actions =====

  Future<void> createAccount(Map<String, dynamic> data) => _run(() async {
        await _api.createAccount(data);
        accounts = await _api.accounts();
      });

  Future<void> transfer(Map<String, dynamic> data) => _run(() async {
        await _api.transfer(
          fromId: data['from_account_id'] as String,
          toId: data['to_account_id'] as String,
          amount: (data['amount'] as num).toDouble(),
          description: data['description'] as String,
          date: data['entry_date'] as String,
        );
        accounts = await _api.accounts();
      });

  Future<void> createJournalEntry(Map<String, dynamic> data) => _run(() async {
        await _api.createJournalEntry(data);
        journal = await _api.journal();
      });

  Future<void> createDonor(Map<String, dynamic> data) => _run(() async {
        await _api.createDonor(data);
        donors = await _api.donors();
      });

  Future<void> createPledge(Map<String, dynamic> data) => _run(() async {
        await _api.createPledge(data);
        pledges = await _api.pledges();
      });

  Future<void> fulfillPledge(String id) => _run(() async {
        await _api.fulfillPledge(id);
        pledges = await _api.pledges();
      });

  Future<void> createCampaign(Map<String, dynamic> data) => _run(() async {
        await _api.createCampaign(data);
        campaigns = await _api.campaigns();
      });

  Future<void> closeCampaign(String id) => _run(() async {
        await _api.closeCampaign(id);
        campaigns = await _api.campaigns();
      });

  Future<void> createBeneficiary(Map<String, dynamic> data) => _run(() async {
        await _api.createBeneficiary(data);
        beneficiaries = await _api.beneficiaries();
      });

  Future<void> createPeriodicAid(Map<String, dynamic> data) => _run(() async {
        await _api.createPeriodicAid(data);
        periodicAids = await _api.periodicAids();
      });

  Future<void> payPeriodicAid(String id, Map<String, dynamic> data) => _run(() async {
        await _api.payPeriodicAid(id, data);
        periodicAids = await _api.periodicAids();
      });

  Future<void> createInKindItem(Map<String, dynamic> data) => _run(() async {
        await _api.createInKindItem(data);
        inKindItems = await _api.inKindItems();
      });

  Future<void> createMovement(Map<String, dynamic> data) => _run(() async {
        await _api.createMovement(data);
        inKindItems = await _api.inKindItems();
      });
}
