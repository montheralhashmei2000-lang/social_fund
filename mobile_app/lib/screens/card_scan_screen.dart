import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/rbac.dart';
import '../services/api_service.dart';
import '../state/controllers.dart';
import '../widgets/ui.dart';

/// التحقق الميداني من بطاقة عضوية: مسح QR البطاقة (SF-MEMBER:<id>)
/// والتحقق الفوري من الخادم — تُستخدم عند الصرف والتسليم الميداني.
class CardScanScreen extends StatefulWidget {
  const CardScanScreen({super.key});

  @override
  State<CardScanScreen> createState() => _CardScanScreenState();
}

class _CardScanScreenState extends State<CardScanScreen> {
  bool checking = false;
  bool resumed = true;

  Future<void> _verify(String memberId) async {
    if (checking) return;
    setState(() => checking = true);
    try {
      final r = await ApiService.instance.request('GET', '/members/$memberId/card-verify');
      final data = Map<String, dynamic>.from(r as Map);
      if (!mounted) return;
      await _showResult(data);
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    } catch (_) {
      if (mounted) uiToast(context, 'تعذر التحقق - حاول مرة أخرى', error: true);
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  Future<void> _showResult(Map<String, dynamic> m) async {
    final ok = m['verified'] == true;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(ok ? Icons.verified : Icons.gpp_bad, color: ok ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C)),
          const SizedBox(width: 8),
          Text(ok ? 'بطاقة صالحة' : 'بطاقة غير صالحة', style: const TextStyle(fontSize: 17)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${m['name']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            Text('الحالة: ${m['status']}'),
            Text('المدفوع: ${money((m['total_paid'] as num?)?.toInt() ?? 0)}'),
            Text('المستحق: ${money((m['balance_due'] as num?)?.toInt() ?? 0)}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
    if (mounted) setState(() => resumed = true); // السماح بمسح تالٍ
  }

  @override
  Widget build(BuildContext context) {
    final c = App.of(context);
    final role = context.read<AuthController>().user?.role;
    if (!Rbac.can(role, 'aids')) {
      return Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(title: const Text('تحقق ميداني'), backgroundColor: c.primaryDark),
        body: const EmptyState(icon: Icons.no_accounts, text: 'تحقق من البطاقات متاح لمن يملك صلاحية المساعدات'),
      );
    }
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(title: const Text('تحقق من بطاقة عضوية'), backgroundColor: c.primaryDark),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (!resumed || checking) return;
              for (final bar in capture.barcodes) {
                final v = bar.rawValue ?? '';
                if (v.startsWith('SF-MEMBER:')) {
                  setState(() { resumed = false; });
                  _verify(v.substring('SF-MEMBER:'.length));
                  break;
                }
              }
            },
          ),
          Positioned(
            left: 0, right: 0, bottom: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: c.primaryDark.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(30)),
                child: Text(
                  checking ? 'جارٍ التحقق من الخادم…' : 'وجّه الكاميرا إلى بطاقة العضوية',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
