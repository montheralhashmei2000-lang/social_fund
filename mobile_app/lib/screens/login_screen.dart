import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/config.dart';
import '../core/server_profiles.dart';
import 'servers_screen.dart';
import '../core/theme.dart';
import '../state/controllers.dart';
import '../widgets/ui.dart';

enum LoginStep { splash, creds, otp, biometric }

class LoginScreen extends StatefulWidget {
  final LoginStep initialStep;
  const LoginScreen({super.key, this.initialStep = LoginStep.splash});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginStep step;
  final _un = TextEditingController();
  final _pw = TextEditingController();
  bool _showPw = false;
  String? _err;
  bool _busy = false;

  String? _otpToken;
  String? _pendingName;
  String? _phoneHint;
  final List<TextEditingController> _otp =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());
  Timer? _countdown;
  int _cd = 0;

  @override
  void initState() {
    super.initState();
    step = widget.initialStep;
  }

  @override
  void dispose() {
    _un.dispose();
    _pw.dispose();
    for (final c in _otp) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    _countdown?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _cd = 60;
    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _cd = _cd <= 1 ? 0 : _cd - 1);
      if (_cd == 0) t.cancel();
    });
  }

  Future<void> _tryLogin() async {
    if (_un.text.isEmpty || _pw.text.isEmpty) {
      setState(() => _err = 'يرجى إدخال اسم المستخدم وكلمة المرور');
      return;
    }
    setState(() {
      _err = null;
      _busy = true;
    });
    try {
      final res = await context.read<AuthController>().login(
            _un.text.trim(),
            _pw.text,
          );
      if (res['logged_in'] == true) return; // خادم بلا OTP: البوابة تنقلنا للرئيسية
      setState(() {
        _otpToken = res['otp_token'] as String?;
        _pendingName = res['user_name'] as String?;
        _phoneHint = res['phone_hint'] as String?;
        step = LoginStep.otp;
        _startCountdown();
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _otpFocus[0].requestFocus();
      });
    } on ApiException catch (e) {
      setState(() => _err = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    if (_cd > 0) return;
    await _tryLogin();
  }

  Future<void> _submitOtp(String code) async {
    if (_otpToken == null) return;
    setState(() {
      _err = null;
      _busy = true;
    });
    try {
      await context.read<AuthController>().verifyOtp(_otpToken!, code);
      // نجاح الدخول - بوابة الجلسة (_Gate) تنتقل للرئيسية تلقائياً
    } on ApiException catch (e) {
      setState(() {
        _err = e.message;
        for (final c in _otp) {
          c.clear();
        }
        _otpFocus[0].requestFocus();
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _tryBiometric() async {
    setState(() {
      _err = null;
      _busy = true;
    });
    final ok = await context.read<AuthController>().unlockWithBiometrics();
    if (!mounted) return;
    if (!ok) {
      setState(() => _err = 'تعذّر التحقق البيومتري - حاول مجدداً أو سجّل الدخول يدوياً');
    }
    if (mounted) setState(() => _busy = false);
  }

  void _toManualLogin() {
    context.read<AuthController>().needsBiometricUnlock = false;
    setState(() => step = LoginStep.creds);
  }

  @override
  Widget build(BuildContext context) {
    return switch (step) {
      LoginStep.splash => _splash(),
      LoginStep.creds => _creds(),
      LoginStep.otp => _otpStep(),
      LoginStep.biometric => _biometric(),
    };
  }

  Widget _gradientBg({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF003300), Color(0xFF2E7D32)],
        ),
      ),
      child: child,
    );
  }

  Widget _splash() {
    final auth = context.watch<AuthController>();
    return _gradientBg(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 52),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: AppColors.light.gold,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Icon(Icons.shield, size: 58, color: Color(0xFF003300)),
                    ),
                    const SizedBox(height: 22),
                    Text('الجمهورية اليمنية',
                        style: TextStyle(
                            color: AppColors.light.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3)),
                    const SizedBox(height: 10),
                    const Text('الصندوق الاجتماعي\nالتنموي',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            height: 1.3)),
                    const SizedBox(height: 10),
                    Text('نظام الإدارة الشامل · أونلاين · الإصدار 9.0',
                        style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13)),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => setState(() => step = LoginStep.creds),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.light.primaryMid,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.lock, color: Colors.white),
                  label: const Text('تسجيل الدخول',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              if (auth.biometricsAvailable)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => step = LoginStep.biometric),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.35)),
                      backgroundColor: Colors.white.withOpacity(0.10),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.fingerprint, color: Colors.white),
                    label: const Text('الدخول بالبصمة',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  await Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const ServersScreen()));
                  if (mounted) setState(() {});
                },
                icon: Icon(Icons.dns, size: 16, color: Colors.white.withOpacity(0.7)),
                label: Text('الخادم: ${ServerProfiles.active?.name ?? AppConfig.baseUrl}',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              ),
              Text(AppConfig.isSecureBaseUrl ? 'اتصال مشفر HTTPS' : 'شبكة محلية (غير مشفر)',
                  style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerBar(String smallLabel, String title, {VoidCallback? onBack}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF003300), Color(0xFF2E7D32)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: TextButton.icon(
                onPressed: onBack,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.16),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                ),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('رجوع', style: TextStyle(fontSize: 13)),
              ),
            ),
          Text(smallLabel,
              style: TextStyle(
                  color: AppColors.light.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _errBox() {
    if (_err == null) return const SizedBox.shrink();
    final c = App.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.err.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: c.err, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(_err!,
                  style: TextStyle(color: c.err, fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _creds() {
    final c = App.of(context);
    final auth = context.watch<AuthController>();
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          _headerBar('تسجيل الدخول', 'مرحباً بك', onBack: () => setState(() => step = LoginStep.splash)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Color(0x16000000), blurRadius: 12, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    UiField(
                      label: 'اسم المستخدم',
                      controller: _un,
                      hint: 'أدخل اسم المستخدم',
                      icon: Icons.person_outline,
                    ),
                    UiField(
                      label: 'كلمة المرور',
                      controller: _pw,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscure: !_showPw,
                      suffix: IconButton(
                        icon: Icon(_showPw ? Icons.visibility_off : Icons.visibility,
                            size: 19, color: c.mu),
                        onPressed: () => setState(() => _showPw = !_showPw),
                      ),
                    ),
                    _errBox(),
                    UiButton(
                      text: _busy ? 'جارٍ الاتصال بالخادم…' : 'دخول إلى النظام',
                      onPressed: _busy ? null : _tryLogin,
                    ),
                    if (auth.biometricsAvailable)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TextButton.icon(
                          onPressed: () => setState(() => step = LoginStep.biometric),
                          icon: const Icon(Icons.fingerprint, size: 18),
                          label: const Text('دخول بالبصمة',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpStep() {
    final c = App.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          _headerBar('التحقق الثنائي · OTP', 'أدخل رمز التحقق',
              onBack: () => setState(() => step = LoginStep.creds)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Color(0x16000000), blurRadius: 12, offset: Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: c.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.security, color: c.primary, size: 30),
                    ),
                    const SizedBox(height: 12),
                    Text('مرحباً، ${_pendingName ?? ''}',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: c.tx)),
                    const SizedBox(height: 4),
                    Text(
                      _phoneHint != null
                          ? 'أُرسل رمز التحقق إلى الهاتف $_phoneHint'
                          : 'أُرسل رمز التحقق إلى هاتفك المسجّل',
                      style: TextStyle(fontSize: 13, color: c.mu),
                    ),
                    const SizedBox(height: 18),
                    _errBox(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (i) => _otpBox(i)),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _busy
                          ? 'جارٍ التحقق…'
                          : _cd > 0
                              ? 'إعادة الإرسال بعد $_cd ث'
                              : '',
                      style: TextStyle(color: c.mu, fontSize: 13),
                    ),
                    if (_cd == 0 && !_busy)
                      TextButton(onPressed: _resend, child: const Text('إعادة إرسال الرمز')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpBox(int i) {
    final c = App.of(context);
    return Container(
      width: 46,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: _otp[i],
        focusNode: _otpFocus[i],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        enabled: !_busy,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: c.primary),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          filled: true,
          fillColor: _otp[i].text.isEmpty ? c.surf : c.primary.withOpacity(0.06),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c.primary, width: 2),
          ),
        ),
        onChanged: (v) {
          if (v.length > 1) return;
          if (v.isNotEmpty && i < 5) _otpFocus[i + 1].requestFocus();
          final code = _otp.map((e) => e.text).join();
          if (code.length == 6 && !code.contains(' ')) {
            FocusManager.instance.primaryFocus?.unfocus();
            _submitOtp(code);
          }
        },
      ),
    );
  }

  Widget _biometric() {
    final c = App.of(context);
    return Scaffold(
      backgroundColor: c.primaryDark,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('المصادقة البيومترية',
                        style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 14)),
                    const SizedBox(height: 8),
                    const Text('تحقّق بهويتك الحيوية\nلفتح الجلسة المحفوظة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.3)),
                    const SizedBox(height: 44),
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.light.gold, width: 3),
                        color: AppColors.light.gold.withOpacity(0.1),
                      ),
                      child: _busy
                          ? const Padding(
                              padding: EdgeInsets.all(50),
                              child: CircularProgressIndicator(color: Color(0xFFF9A825)),
                            )
                          : const Icon(Icons.fingerprint, size: 90, color: Color(0xFFF9A825)),
                    ),
                    const SizedBox(height: 30),
                    if (_err != null)
                      Text(_err!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _busy ? null : _tryBiometric,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.light.gold,
                        foregroundColor: const Color(0xFF003300),
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 36),
                      ),
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('بدء التحقق',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _toManualLogin,
                      child: const Text('تسجيل الدخول يدوياً',
                          style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
