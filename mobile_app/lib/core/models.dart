/// نماذج النظام - مطابقة لمخرجات FastAPI (schemas/domain.py).
/// المبالغ المالية بالريال اليمني الصحيح (قرار صريح: Integer بدون كسور).
library;

class AppUser {
  final String id;
  final String username;
  final String fullName;
  final String role;
  final String avatarInitial;
  final String? phone;

  const AppUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.avatarInitial,
    this.phone,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'].toString(),
        username: (j['username'] ?? '').toString(),
        fullName: (j['full_name'] ?? '').toString(),
        role: (j['role'] ?? 'viewer').toString(),
        avatarInitial: (j['avatar_initial'] ?? '?').toString(),
        phone: j['phone'] as String?,
      );
}

class Member {
  final String id;
  final String name;
  final String nationalId;
  final String phone;
  final String? email;
  final String? city;
  final String? joinDate;
  final String status;
  final int monthlySubscription;
  final int totalPaid;
  final int balanceDue;

  const Member({
    required this.id,
    required this.name,
    required this.nationalId,
    required this.phone,
    this.email,
    this.city,
    this.joinDate,
    required this.status,
    required this.monthlySubscription,
    required this.totalPaid,
    required this.balanceDue,
  });

  bool get isActive => status == 'نشط';

  factory Member.fromJson(Map<String, dynamic> j) => Member(
        id: j['id'].toString(),
        name: (j['name'] ?? '').toString(),
        nationalId: (j['national_id'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
        email: j['email'] as String?,
        city: j['city'] as String?,
        joinDate: j['join_date'] as String?,
        status: (j['status'] ?? 'نشط').toString(),
        monthlySubscription: (j['monthly_subscription'] as num?)?.toInt() ?? 0,
        totalPaid: (j['total_paid'] as num?)?.toInt() ?? 0,
        balanceDue: (j['balance_due'] as num?)?.toInt() ?? 0,
      );
}

class AidRequest {
  final String id;
  final String memberId;
  final String memberName;
  final String aidType;
  final int amount;
  final String requestDate;
  final String status;
  final String? note;
  final String? reviewerName;

  const AidRequest({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.aidType,
    required this.amount,
    required this.requestDate,
    required this.status,
    this.note,
    this.reviewerName,
  });

  factory AidRequest.fromJson(Map<String, dynamic> j) => AidRequest(
        id: j['id'].toString(),
        memberId: (j['member_id'] ?? '').toString(),
        memberName: (j['member_name'] ?? '').toString(),
        aidType: (j['aid_type'] ?? '').toString(),
        amount: (j['amount'] as num?)?.toInt() ?? 0,
        requestDate: (j['request_date'] ?? '').toString(),
        status: (j['status'] ?? '').toString(),
        note: j['note'] as String?,
        reviewerName: j['reviewer_name'] as String?,
      );
}

class Subscription {
  final String id;
  final String memberId;
  final String memberName;
  final int amount;
  final String paymentDate;
  final String method;
  final String? referenceNo;

  const Subscription({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.paymentDate,
    required this.method,
    this.referenceNo,
  });

  factory Subscription.fromJson(Map<String, dynamic> j) => Subscription(
        id: j['id'].toString(),
        memberId: (j['member_id'] ?? '').toString(),
        memberName: (j['member_name'] ?? '').toString(),
        amount: (j['amount'] as num?)?.toInt() ?? 0,
        paymentDate: (j['payment_date'] ?? '').toString(),
        method: (j['method'] ?? '').toString(),
        referenceNo: j['reference_no'] as String?,
      );
}

class TreasuryEntry {
  final String id;
  final String type; // إيراد / مصروف
  final String category;
  final String description;
  final int amount;
  final String entryDate;
  final String? referenceNo;

  const TreasuryEntry({
    required this.id,
    required this.type,
    required this.category,
    required this.description,
    required this.amount,
    required this.entryDate,
    this.referenceNo,
  });

  bool get isIncome => type == 'إيراد';

  factory TreasuryEntry.fromJson(Map<String, dynamic> j) => TreasuryEntry(
        id: j['id'].toString(),
        type: (j['type'] ?? '').toString(),
        category: (j['category'] ?? '').toString(),
        description: (j['description'] ?? '').toString(),
        amount: (j['amount'] as num?)?.toInt() ?? 0,
        entryDate: (j['entry_date'] ?? '').toString(),
        referenceNo: j['reference_no'] as String?,
      );
}

class Voucher {
  final String id;
  final String voucherNo;
  final String kind; // قبض / صرف
  final String memberId;
  final String memberName;
  final String? donorId;
  final String? beneficiaryId;
  final String? partyName;
  final int amount;
  final String voucherDate;
  final String method;
  final String description;
  final String issuedByName;
  final String status;
  final String? journalEntryNo;
  final String? journalEntryId;

  const Voucher({
    required this.id,
    required this.voucherNo,
    required this.kind,
    required this.memberId,
    required this.memberName,
    this.donorId,
    this.beneficiaryId,
    this.partyName,
    required this.amount,
    required this.voucherDate,
    required this.method,
    required this.description,
    required this.issuedByName,
    required this.status,
    this.journalEntryNo,
    this.journalEntryId,
  });

  bool get isReceipt => kind == 'قبض';

  bool get isVoid => status == 'ملغي';

  /// اسم طرف السند: عضو أو مانح أو مستفيد أو جهة حرة.
  String get party => memberName.isNotEmpty ? memberName : (partyName ?? '');

  factory Voucher.fromJson(Map<String, dynamic> j) => Voucher(
        id: j['id'].toString(),
        voucherNo: (j['voucher_no'] ?? '').toString(),
        kind: (j['kind'] ?? '').toString(),
        memberId: (j['member_id'] ?? '').toString(),
        memberName: (j['member_name'] ?? '').toString(),
        donorId: j['donor_id']?.toString(),
        beneficiaryId: j['beneficiary_id']?.toString(),
        partyName: j['party_name']?.toString(),
        amount: (j['amount'] as num?)?.toInt() ?? 0,
        voucherDate: (j['voucher_date'] ?? '').toString(),
        method: (j['method'] ?? '').toString(),
        description: (j['description'] ?? '').toString(),
        issuedByName: (j['issued_by_name'] ?? '').toString(),
        status: (j['status'] ?? '').toString(),
        journalEntryNo: j['journal_entry_no']?.toString(),
        journalEntryId: j['journal_entry_id']?.toString(),
      );
}

class MessageModel {
  final String id;
  final String fromUserId;
  final String fromName;
  final String toUserId;
  final String toName;
  final String body;
  final bool read;

  const MessageModel({
    required this.id,
    required this.fromUserId,
    required this.fromName,
    required this.toUserId,
    required this.toName,
    required this.body,
    required this.read,
  });

  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
        id: j['id'].toString(),
        fromUserId: (j['from_user_id'] ?? '').toString(),
        fromName: (j['from_name'] ?? '').toString(),
        toUserId: (j['to_user_id'] ?? '').toString(),
        toName: (j['to_name'] ?? '').toString(),
        body: (j['body'] ?? '').toString(),
        read: j['read'] == true,
      );
}

class EventModel {
  final String id;
  final String title;
  final String eventDate;
  final String? eventTime;
  final String? place;
  final String? type;
  final String color;

  const EventModel({
    required this.id,
    required this.title,
    required this.eventDate,
    this.eventTime,
    this.place,
    this.type,
    this.color = '#1B5E20',
  });

  factory EventModel.fromJson(Map<String, dynamic> j) => EventModel(
        id: j['id'].toString(),
        title: (j['title'] ?? '').toString(),
        eventDate: (j['event_date'] ?? '').toString(),
        eventTime: j['event_time'] as String?,
        place: j['place'] as String?,
        type: j['type'] as String?,
        color: (j['color'] ?? '#1B5E20').toString(),
      );
}

class FundSettings {
  final String name;
  final String? logoBase64;
  final String? phone;
  final String? email;
  final String? address;
  final String? registrationNo;

  const FundSettings({
    required this.name,
    this.logoBase64,
    this.phone,
    this.email,
    this.address,
    this.registrationNo,
  });

  factory FundSettings.fromJson(Map<String, dynamic> j) => FundSettings(
        name: (j['name'] ?? 'الصندوق الاجتماعي التنموي').toString(),
        logoBase64: j['logo_base64'] as String?,
        phone: j['phone'] as String?,
        email: j['email'] as String?,
        address: j['address'] as String?,
        registrationNo: j['registration_no'] as String?,
      );

  Map<String, dynamic> toApi() => {
        'name': name,
        'logo_base64': logoBase64,
        'phone': phone,
        'email': email,
        'address': address,
        'registration_no': registrationNo,
      };
}

class AdminUser {
  final String id;
  final String username;
  final String fullName;
  final String role;
  final bool isActive;
  final String? phone;

  const AdminUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.phone,
  });

  factory AdminUser.fromJson(Map<String, dynamic> j) => AdminUser(
        id: j['id'].toString(),
        username: (j['username'] ?? '').toString(),
        fullName: (j['full_name'] ?? '').toString(),
        role: (j['role'] ?? '').toString(),
        isActive: j['is_active'] == true,
        phone: j['phone'] as String?,
      );
}

class Colleague {
  final String id;
  final String username;
  final String fullName;
  final String role;
  final String? avatarInitial;

  const Colleague({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.avatarInitial,
  });

  factory Colleague.fromJson(Map<String, dynamic> j) => Colleague(
        id: j['id'].toString(),
        username: (j['username'] ?? '').toString(),
        fullName: (j['full_name'] ?? '').toString(),
        role: (j['role'] ?? '').toString(),
        avatarInitial: j['avatar_initial'] as String?,
      );
}

class AuditEntry {
  final String id;
  final String timestamp;
  final String? userName;
  final String action;
  final String resourceType;
  final String? summary;
  final String? ipAddress;

  const AuditEntry({
    required this.id,
    required this.timestamp,
    this.userName,
    required this.action,
    required this.resourceType,
    this.summary,
    this.ipAddress,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> j) => AuditEntry(
        id: j['id'].toString(),
        timestamp: (j['timestamp'] ?? '').toString(),
        userName: j['user_name'] as String?,
        action: (j['action'] ?? '').toString(),
        resourceType: (j['resource_type'] ?? '').toString(),
        summary: j['summary'] as String?,
        ipAddress: j['ip_address'] as String?,
      );
}


// ================= كيانات التوسعة المحاسبية والخيرية =================

class Account {
  final String id, code, name, type, typeLabel, currency;
  final bool isBank, isCash, isWallet, isActive;
  final String? bankName, accountNumber;
  final double balance;

  const Account({
    required this.id, required this.code, required this.name, required this.type,
    required this.typeLabel, required this.currency, required this.isBank,
    required this.isCash, required this.isWallet, required this.isActive,
    required this.balance, this.bankName, this.accountNumber,
  });

  bool get isLiquid => isBank || isCash || isWallet;

  factory Account.fromJson(Map<String, dynamic> j) => Account(
        id: j['id'].toString(),
        code: (j['code'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        type: (j['type'] ?? '').toString(),
        typeLabel: (j['type_label'] ?? '').toString(),
        currency: (j['currency'] ?? 'YER').toString(),
        isBank: j['is_bank'] == true,
        isCash: j['is_cash'] == true,
        isWallet: j['is_wallet'] == true,
        isActive: j['is_active'] != false,
        balance: (j['balance'] as num?)?.toDouble() ?? 0,
        bankName: j['bank_name'] as String?,
        accountNumber: j['account_number'] as String?,
      );
}

class JournalLineModel {
  final String accountId, accountName;
  final String? accountCode, memo;
  final double debit, credit;

  const JournalLineModel({
    required this.accountId, required this.accountName,
    this.accountCode, this.memo, required this.debit, required this.credit,
  });

  factory JournalLineModel.fromJson(Map<String, dynamic> j) => JournalLineModel(
        accountId: j['account_id'].toString(),
        accountName: (j['account_name'] ?? '').toString(),
        accountCode: j['account_code'] as String?,
        memo: j['memo'] as String?,
        debit: (j['debit'] as num?)?.toDouble() ?? 0,
        credit: (j['credit'] as num?)?.toDouble() ?? 0,
      );
}

class JournalEntryModel {
  final String id, entryNo, entryDate, description, entryType, entryTypeLabel, status;
  final String? reference;
  final double total;
  final List<JournalLineModel> lines;

  const JournalEntryModel({
    required this.id, required this.entryNo, required this.entryDate,
    required this.description, required this.entryType, required this.entryTypeLabel,
    required this.status, required this.total, required this.lines,
    this.reference,
  });

  factory JournalEntryModel.fromJson(Map<String, dynamic> j) => JournalEntryModel(
        id: j['id'].toString(),
        entryNo: (j['entry_no'] ?? '').toString(),
        entryDate: (j['entry_date'] ?? '').toString(),
        description: (j['description'] ?? '').toString(),
        entryType: (j['entry_type'] ?? '').toString(),
        entryTypeLabel: (j['entry_type_label'] ?? '').toString(),
        status: (j['status'] ?? '').toString(),
        reference: j['reference'] as String?,
        total: (j['total'] as num?)?.toDouble() ?? 0,
        lines: ((j['lines'] as List?) ?? [])
            .map((e) => JournalLineModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class Donor {
  final String id, name, donorType, donorTypeLabel, tier, tierLabel;
  final String? phone, email, notes;
  final bool isActive;
  final double totalDonated;

  const Donor({
    required this.id, required this.name, required this.donorType,
    required this.donorTypeLabel, required this.tier, required this.tierLabel,
    required this.isActive, required this.totalDonated,
    this.phone, this.email, this.notes,
  });

  factory Donor.fromJson(Map<String, dynamic> j) => Donor(
        id: j['id'].toString(),
        name: (j['name'] ?? '').toString(),
        donorType: (j['donor_type'] ?? '').toString(),
        donorTypeLabel: (j['donor_type_label'] ?? '').toString(),
        tier: (j['tier'] ?? '').toString(),
        tierLabel: (j['tier_label'] ?? '').toString(),
        phone: j['phone'] as String?,
        email: j['email'] as String?,
        notes: j['notes'] as String?,
        isActive: j['is_active'] != false,
        totalDonated: (j['total_donated'] as num?)?.toDouble() ?? 0,
      );
}

class Pledge {
  final String id, donorId, donorName, frequency, frequencyLabel, startDate, status;
  final String? endDate, lastFulfilledOn, nextDue, notes;
  final double amount;
  final int? daysOverdue;

  const Pledge({
    required this.id, required this.donorId, required this.donorName,
    required this.frequency, required this.frequencyLabel, required this.startDate,
    required this.status, required this.amount, this.endDate, this.lastFulfilledOn,
    this.nextDue, this.notes, this.daysOverdue,
  });

  factory Pledge.fromJson(Map<String, dynamic> j) => Pledge(
        id: j['id'].toString(),
        donorId: (j['donor_id'] ?? '').toString(),
        donorName: (j['donor_name'] ?? '').toString(),
        frequency: (j['frequency'] ?? '').toString(),
        frequencyLabel: (j['frequency_label'] ?? '').toString(),
        startDate: (j['start_date'] ?? '').toString(),
        status: (j['status'] ?? '').toString(),
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        endDate: j['end_date'] as String?,
        lastFulfilledOn: j['last_fulfilled_on'] as String?,
        nextDue: j['next_due'] as String?,
        notes: j['notes'] as String?,
        daysOverdue: (j['days_overdue'] as num?)?.toInt(),
      );
}

class Campaign {
  final String id, name, status, startDate;
  final String? description, endDate;
  final double goalAmount, raised, spent, net, percent;

  const Campaign({
    required this.id, required this.name, required this.status,
    required this.startDate, required this.goalAmount,
    required this.raised, required this.spent, required this.net, required this.percent,
    this.description, this.endDate,
  });

  factory Campaign.fromJson(Map<String, dynamic> j) => Campaign(
        id: j['id'].toString(),
        name: (j['name'] ?? '').toString(),
        status: (j['status'] ?? '').toString(),
        startDate: (j['start_date'] ?? '').toString(),
        description: j['description'] as String?,
        endDate: j['end_date'] as String?,
        goalAmount: (j['goal_amount'] as num?)?.toDouble() ?? 0,
        raised: (j['raised'] as num?)?.toDouble() ?? 0,
        spent: (j['spent'] as num?)?.toDouble() ?? 0,
        net: (j['net'] as num?)?.toDouble() ?? 0,
        percent: (j['percent'] as num?)?.toDouble() ?? 0,
      );
}

class Beneficiary {
  final String id, fullName, status;
  final String? nationalId, phone, housing, caseSummary;
  final int familySize;
  final double monthlyIncome;

  const Beneficiary({
    required this.id, required this.fullName, required this.status,
    required this.familySize, required this.monthlyIncome,
    this.nationalId, this.phone, this.housing, this.caseSummary,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> j) => Beneficiary(
        id: j['id'].toString(),
        fullName: (j['full_name'] ?? '').toString(),
        status: (j['status'] ?? 'active').toString(),
        nationalId: j['national_id'] as String?,
        phone: j['phone'] as String?,
        housing: j['housing'] as String?,
        caseSummary: j['case_summary'] as String?,
        familySize: (j['family_size'] as num?)?.toInt() ?? 1,
        monthlyIncome: (j['monthly_income'] as num?)?.toDouble() ?? 0,
      );
}

class PeriodicAidModel {
  final String id, beneficiaryId, beneficiaryName, startedOn, status;
  final String? lastPaidPeriod, duePeriod, notes;
  final double monthlyAmount;
  final int? daysOverdue;

  const PeriodicAidModel({
    required this.id, required this.beneficiaryId, required this.beneficiaryName,
    required this.startedOn, required this.status, required this.monthlyAmount,
    this.lastPaidPeriod, this.duePeriod, this.notes, this.daysOverdue,
  });

  factory PeriodicAidModel.fromJson(Map<String, dynamic> j) => PeriodicAidModel(
        id: j['id'].toString(),
        beneficiaryId: (j['beneficiary_id'] ?? '').toString(),
        beneficiaryName: (j['beneficiary_name'] ?? '').toString(),
        startedOn: (j['started_on'] ?? '').toString(),
        status: (j['status'] ?? '').toString(),
        monthlyAmount: (j['monthly_amount'] as num?)?.toDouble() ?? 0,
        lastPaidPeriod: j['last_paid_period'] as String?,
        duePeriod: j['due_period'] as String?,
        notes: j['notes'] as String?,
        daysOverdue: (j['days_overdue'] as num?)?.toInt(),
      );
}

class InKindItem {
  final String id, name, unit;
  final double quantity, reorderLevel;
  final bool lowStock;

  const InKindItem({
    required this.id, required this.name, required this.unit,
    required this.quantity, required this.reorderLevel, required this.lowStock,
  });

  factory InKindItem.fromJson(Map<String, dynamic> j) => InKindItem(
        id: j['id'].toString(),
        name: (j['name'] ?? '').toString(),
        unit: (j['unit'] ?? '').toString(),
        quantity: (j['quantity'] as num?)?.toDouble() ?? 0,
        reorderLevel: (j['reorder_level'] as num?)?.toDouble() ?? 0,
        lowStock: j['low_stock'] == true,
      );
}

class BudgetReportRow {
  final String accountCode, accountName;
  final double planned, actual, usagePct;

  const BudgetReportRow({
    required this.accountCode, required this.accountName,
    required this.planned, required this.actual, required this.usagePct,
  });

  factory BudgetReportRow.fromJson(Map<String, dynamic> j) => BudgetReportRow(
        accountCode: (j['account_code'] ?? '').toString(),
        accountName: (j['account_name'] ?? '').toString(),
        planned: (j['planned'] as num?)?.toDouble() ?? 0,
        actual: (j['actual'] as num?)?.toDouble() ?? 0,
        usagePct: (j['usage_pct'] as num?)?.toDouble() ?? 0,
      );
}

class TrialBalanceRow {
  final String code, account;
  final double debit, credit, net;

  const TrialBalanceRow({
    required this.code, required this.account,
    required this.debit, required this.credit, required this.net,
  });

  factory TrialBalanceRow.fromJson(Map<String, dynamic> j) => TrialBalanceRow(
        code: (j['code'] ?? '').toString(),
        account: (j['account'] ?? '').toString(),
        debit: (j['debit'] as num?)?.toDouble() ?? 0,
        credit: (j['credit'] as num?)?.toDouble() ?? 0,
        net: (j['net'] as num?)?.toDouble() ?? 0,
      );
}
