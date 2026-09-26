import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/models.dart';
import '../state/controllers.dart';
import '../widgets/ui.dart';

class FundInfoScreen extends StatefulWidget {
  const FundInfoScreen({super.key});

  @override
  State<FundInfoScreen> createState() => _FundInfoScreenState();
}

class _FundInfoScreenState extends State<FundInfoScreen> {
  late final name = TextEditingController();
  late final regNo = TextEditingController();
  late final address = TextEditingController();
  late final phone = TextEditingController();
  late final email = TextEditingController();
  String? logoBase64;
  bool dirty = false;
  bool busy = false;
  bool _loaded = false;

  @override
  void dispose() {
    name.dispose();
    regNo.dispose();
    address.dispose();
    phone.dispose();
    email.dispose();
    super.dispose();
  }

  void _loadOnce() {
    if (_loaded) return;
    _loaded = true;
    final s = context.read<DataController>().fundSettings;
    name.text = s?.name ?? 'الصندوق الاجتماعي التنموي';
    regNo.text = s?.registrationNo ?? '';
    address.text = s?.address ?? '';
    phone.text = s?.phone ?? '';
    email.text = s?.email ?? '';
    logoBase64 = s?.logoBase64;
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 512, maxHeight: 512);
    if (picked == null) return;
    final bytes = await File(picked.path).readAsBytes();
    setState(() {
      logoBase64 = 'data:image/png;base64,${base64Encode(bytes)}';
      dirty = true;
    });
  }

  Future<void> _removeLogo() async {
    setState(() {
      logoBase64 = null;
      dirty = true;
    });
  }

  Future<void> _save() async {
    if (name.text.trim().isEmpty) {
      uiToast(context, 'يرجى إدخال اسم الصندوق', error: true);
      return;
    }
    setState(() => busy = true);
    try {
      await context.read<DataController>().saveFundSettings(FundSettings(
            name: name.text.trim(),
            logoBase64: logoBase64,
            phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
            email: email.text.trim().isEmpty ? null : email.text.trim(),
            address: address.text.trim().isEmpty ? null : address.text.trim(),
            registrationNo: regNo.text.trim().isEmpty ? null : regNo.text.trim(),
          ));
      dirty = false;
      if (mounted) uiToast(context, 'تم حفظ بيانات الصندوق بنجاح', success: true);
    } on ApiException catch (e) {
      if (mounted) uiToast(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadOnce();
    final c = App.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF003300), Color(0xFF2E7D32)]),
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickLogo,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: logoBase64 != null && logoBase64!.contains(',')
                      ? Image.memory(base64Decode(logoBase64!.split(',')[1]), fit: BoxFit.cover)
                      : const Icon(Icons.shield, size: 40, color: Color(0xFF003300)),
                ),
              ),
              const SizedBox(height: 12),
              Text(name.text.isEmpty ? 'اسم الصندوق' : name.text,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
              if (address.text.isNotEmpty)
                Text(address.text,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _pickLogo,
                    icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                    label: const Text('تغيير الشعار', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  if (logoBase64 != null)
                    TextButton.icon(
                      onPressed: _removeLogo,
                      icon: const Icon(Icons.delete, size: 14, color: Colors.white),
                      label: const Text('إزالة', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        UiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('البيانات الأساسية', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: c.mu)),
              UiField(label: 'اسم الصندوق *', controller: name, onChanged: (_) => setState(() => dirty = true)),
              UiField(label: 'رقم السجل / الترخيص', controller: regNo, onChanged: (_) => setState(() => dirty = true)),
              UiField(label: 'العنوان', controller: address, onChanged: (_) => setState(() => dirty = true)),
            ],
          ),
        ),
        UiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('بيانات التواصل', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: c.mu)),
              UiField(label: 'رقم الهاتف', controller: phone, keyboardType: TextInputType.phone, onChanged: (_) => setState(() => dirty = true)),
              UiField(label: 'البريد الإلكتروني', controller: email, keyboardType: TextInputType.emailAddress, onChanged: (_) => setState(() => dirty = true)),
            ],
          ),
        ),
        UiButton(
          text: busy ? 'جارٍ الحفظ…' : (dirty ? 'حفظ التغييرات' : 'تم الحفظ'),
          onPressed: busy || !dirty ? null : _save,
        ),
      ],
    );
  }
}
