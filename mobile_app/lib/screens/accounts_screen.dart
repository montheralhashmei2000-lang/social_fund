import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../state/expansion_controller.dart';
import '../widgets/ui.dart';
import 'reconciliation_screen.dart';

const accountTypes = [
  ('asset', 'الأصول'),
  ('liability', 'الخصوم'),
  ('equity', 'حقوق الملكية'),
  ('income', 'الإيرادات'),
  ('expense', 'المصروفات'),
];

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpansionController>().loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final ctl = context.watch<ExpansionController>();

    if (ctl.loading && ctl.accounts.isEmpty) return const LoadingView();

    if (ctl.accounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EmptyState(icon: Icons.account_balance, text: 'شجرة الحسابات فارغة'),
            UiButton(
              text: 'إنشاء شجرة الحسابات الافتراضية',
              onPressed: () async {
                await ctl.loadAccounts(); // تحديث الحالة
                try {
                  await ApiService.instance.seedAccounts();
                  await ctl.loadAccounts();
                } on ApiException catch (e) {
                  if (context.mounted) uiToast(context, e.message, error: true);
                }
              },
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final (typeKey, typeLabel) in accountTypes)
              if (ctl.accounts.any((a) => a.type == typeKey)) ...[
                _sectionHeader(context, typeLabel, gold: typeKey == 'asset'),
                ...ctl.accounts.where((a) => a.type == typeKey).map((a) => _accountCard(context, a)),
              ],
          ],
        ),
        Positioned(
          bottom: 18,
          left: 18,
          child: Row(
            children: [
              FloatingActionButton(
                heroTag: 'transfer',
                onPressed: () => _transferSheet(),
                backgroundColor: c.goldDark,
                child: const Icon(Icons.swap_horiz, color: Colors.white),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                heroTag: 'addAccount',
                onPressed: () => _addAccountSheet(),
                backgroundColor: c.primaryMid,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title, {bool gold = false}) {
    final c = App.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Row(
        children: [
          Container(width: 26, height: 3, color: gold ? c.gold : c.primary),
          const SizedBox(width: 8),
          Text(title, style: AppTheme.sectionTitle(c, size: 15)),
        ],
      ),
    );
  }

  Widget _accountCard(BuildContext context, Account a) {
    final c = App.of(context);
    return UiCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (a.isBank ? c.info : a.isWallet ? c.gold : c.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              a.isBank ? Icons.account_balance : a.isWallet ? Icons.wallet : Icons.savings,
              color: a.isBank ? c.info : a.isWallet ? c.goldDark : c.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${a.code} · ${a.name}',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: c.tx)),
                if (a.bankName != null)
                  Text('${a.bankName} · ${a.accountNumber ?? ''}',
                      style: TextStyle(fontSize: 11, color: c.mu)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(money2(a.balance),
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                      color: a.balance >= 0 ? c.primary : c.err)),
              if (a.isLiquid)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ReconciliationScreen(account: a)),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 3),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: c.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('مطابقة كشف الحساب',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.info)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addAccountSheet() async {
    final ctl = context.read<ExpansionController>();
    final code = TextEditingController();
    final name = TextEditingController();
    final bankName = TextEditingController();
    final accountNumber = TextEditingController();
    String type = 'asset';
    bool isBank = false, isCash = false, isWallet = false;

    await uiSheet(
      context,
      title: 'حساب جديد',
      child: StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiField(label: 'رمز الحساب *', controller: code, hint: '1050'),
            UiField(label: 'اسم الحساب *', controller: name, hint: 'حساب بنكي فرعي'),
            UiDropdown<String>(
              label: 'النوع *',
              value: type,
              items: accountTypes.map((t) => DropdownMenuItem(value: t.$1, child: Text(t.$2))).toList(),
              onChanged: (v) => setSheet(() => type = v ?? type),
            ),
            SwitchListTile(
              title: const Text('حساب بنكي'),
              value: isBank,
              activeColor: App.of(context).primary,
              onChanged: (v) => setSheet(() { isBank = v; if (v) isWallet = false; }),
            ),
            SwitchListTile(
              title: const Text('محفظة إلكترونية'),
              value: isWallet,
              activeColor: App.of(context).primary,
              onChanged: (v) => setSheet(() { isWallet = v; if (v) isBank = false; }),
            ),
            SwitchListTile(
              title: const Text('صندوق نقدي'),
              value: isCash,
              activeColor: App.of(context).primary,
              onChanged: (v) => setSheet(() => isCash = v),
            ),
            if (isBank) ...[
              UiField(label: 'اسم البنك', controller: bankName),
              UiField(label: 'رقم الحساب', controller: accountNumber),
            ],
            UiButton(
              text: 'إنشاء الحساب',
              onPressed: () async {
                if (code.text.trim().isEmpty || name.text.trim().isEmpty) {
                  uiToast(ctx, 'أكمل الرمز والاسم', error: true);
                  return;
                }
                try {
                  await ctl.createAccount({
                    'code': code.text.trim(), 'name': name.text.trim(), 'type': type,
                    'is_bank': isBank, 'is_cash': isCash, 'is_wallet': isWallet,
                    'bank_name': bankName.text.trim().isEmpty ? null : bankName.text.trim(),
                    'account_number': accountNumber.text.trim().isEmpty ? null : accountNumber.text.trim(),
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                } on ApiException catch (e) {
                  if (ctx.mounted) uiToast(ctx, e.message, error: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _transferSheet({Account? presetFrom}) async {
    final ctl = context.read<ExpansionController>();
    String? from = presetFrom?.id;
    String? to;
    final amount = TextEditingController();
    final desc = TextEditingController();

    await uiSheet(
      context,
      title: 'تحويل بين الحسابات',
      accent: App.of(context).goldDark,
      child: StatefulBuilder(
        builder: (ctx, setSheet) {
          final liquid = ctl.accounts.where((a) => a.isLiquid && a.isActive).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (liquid.length < 2)
                Text('يحتاج حسابين سائلين على الأقل (نقد/بنك/محفظة)',
                    style: TextStyle(fontSize: 12, color: App.of(context).warn))
              else ...[
                UiDropdown<String>(
                  label: 'من حساب *',
                  value: from ?? liquid.first.id,
                  items: liquid.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.code} - ${a.name}'))).toList(),
                  onChanged: (v) => setSheet(() => from = v),
                ),
                UiDropdown<String>(
                  label: 'إلى حساب *',
                  value: to ?? liquid.last.id,
                  items: liquid.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.code} - ${a.name}'))).toList(),
                  onChanged: (v) => setSheet(() => to = v),
                ),
                UiField(label: 'المبلغ *', controller: amount, keyboardType: TextInputType.number),
                UiField(label: 'الوصف', controller: desc, hint: 'إيداع بنكي / سحب نقدي…'),
                UiButton(
                  text: 'تنفيذ التحويل',
                  variant: 'gold',
                  onPressed: () async {
                    final amt = double.tryParse(amount.text.trim()) ?? 0;
                    final fromId = from ?? liquid.first.id;
                    final toId = to ?? liquid.last.id;
                    if (amt <= 0 || fromId == toId) {
                      uiToast(ctx, 'أكمل المبلغ وتأكد من اختلاف الحسابين', error: true);
                      return;
                    }
                    try {
                      await ctl.transfer({
                        'from_account_id': fromId, 'to_account_id': toId, 'amount': amt,
                        'description': desc.text.trim().isEmpty ? 'تحويل داخلي' : desc.text.trim(),
                        'entry_date': DateTime.now().toIso8601String().split('T').first,
                      });
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        uiToast(ctx, 'تم التحويل بقيد متوازن', success: true);
                      }
                    } on ApiException catch (e) {
                      if (ctx.mounted) uiToast(ctx, e.message, error: true);
                    }
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
