import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/config.dart';
import 'core/theme.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'services/push_service.dart';
import 'state/controllers.dart';
import 'state/expansion_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  AppConfig.assertSafeConfiguration();
  // Firebase اختياري للإشعارات - غيابه لا يوقف التطبيق.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase غير مهيأ (غير حرج): $e');
  }
  runApp(const AppProviders());
}

class AppProviders extends StatelessWidget {
  const AppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()..load()),
        ChangeNotifierProvider(create: (_) => ConnectivityController()),
        ChangeNotifierProvider(create: (_) => AuthController()..boot()),
        ChangeNotifierProvider(create: (_) => DataController()),
        ChangeNotifierProvider(create: (_) => ExpansionController()),
      ],
      child: const SocialFundApp(),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SocialFundApp extends StatefulWidget {
  const SocialFundApp({super.key});

  @override
  State<SocialFundApp> createState() => _SocialFundAppState();
}

class _SocialFundAppState extends State<SocialFundApp> {
  @override
  void initState() {
    super.initState();
    PushService.navigatorKey = navigatorKey;
    PushService.init();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.theme(AppColors.light),
      darkTheme: AppTheme.theme(AppColors.dark),
      themeMode: theme.dark ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _Gate(),
    );
  }
}

/// بوابة الجلسة: شاشة التحميل ← البصمة (إن فعّلها المستخدم) ← الدخول ← الرئيسية.
class _Gate extends StatelessWidget {
  const _Gate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (auth.booting) {
      return Scaffold(
        body: Container(
          alignment: Alignment.center,
          decoration: const LinearGradient(
            colors: [AppColorsDeep.dark, AppColorsDeep.mid],
          ).toDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFFF9A825)),
              const SizedBox(height: 14),
              Text('جارٍ تحميل النظام…',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
            ],
          ),
        ),
      );
    }

    if (auth.user != null) return const HomeShell();
    if (auth.needsBiometricUnlock) return const LoginScreen(initialStep: LoginStep.biometric);
    return const LoginScreen(initialStep: LoginStep.splash);
  }
}

/// ألوان مساعدة لتدرجات شاشة البداية.
class AppColorsDeep {
  static const Color dark = Color(0xFF003300);
  static const Color mid = Color(0xFF2E7D32);
}

extension LinearGradientX on LinearGradient {
  Decoration toDecoration() => BoxDecoration(gradient: this);
}
