import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';

import 'api_service.dart';

/// إشعارات Firebase (FCM):
/// - طلب إذن الإشعارات والحصول على token الجهاز.
/// - رفع الـtoken للخادم بعد كل دخول ناجح، وإلغاؤه عند الخروج.
/// - الرسائل أمامية تُعرض كمعلومة داخل التطبيق عبر [foregroundMessage].
/// - النقر على الإشعار يفتح الشاشة المناسبة عبر [openScreen].
class PushService {
  PushService._();

  static final ValueNotifier<Map<String, dynamic>?> foregroundMessage =
      ValueNotifier(null);

  static String? _currentToken;
  static bool _initialized = false;
  static bool _loggedInRegistered = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        foregroundMessage.value = {
          'title': message.notification?.title ?? 'إشعار جديد',
          'body': message.notification?.body ?? '',
        };
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        openScreen(message.data);
      });

      final initial = await messaging.getInitialMessage();
      if (initial != null) openScreen(initial.data);

      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        _currentToken = token;
        if (_loggedInRegistered) {
          ApiService()
              .registerPushToken(token, Platform.operatingSystem)
              .catchError((_) {});
        }
      });

      _initialized = true;
    } catch (e) {
      debugPrint('تعذّر تهيئة الإشعارات (غير حرج): $e');
    }
  }

  /// بعد نجاح تسجيل الدخول - يربط token الجهاز بحساب المستخدم على الخادم.
  static Future<void> onLogin() async {
    _loggedInRegistered = true;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        _currentToken = token;
        await ApiService().registerPushToken(token, Platform.operatingSystem);
      }
    } catch (e) {
      debugPrint('تعذّر تسجيل token الإشعارات (غير حرج): $e');
    }
  }

  /// عند الخروج - يزيل token هذا الجهاز من الخادم (ملكيته محفوظة للخادم).
  static Future<void> onLogout() async {
    try {
      final token = _currentToken ?? await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await ApiService().unregisterPushToken(token);
      }
    } catch (e) {
      debugPrint('تعذّر إلغاء تسجيل الإشعارات (غير حرج): $e');
    } finally {
      _loggedInRegistered = false;
    }
  }

  static void openScreen(Map<String, dynamic> data) {
    final ctx = navigatorKey?.currentContext;
    if (ctx == null) return;
    final target = switch (data['type']) {
      'aid_new' || 'aid_status_changed' => 3, // طلبات المساعدة
      'message_new' => 6, // الرسائل
      'subscription_overdue' => 2, // الاشتراكات
      'event_reminder' => 7, // المواعيد
      _ => 0, // الرئيسية
    };
    openTab.value = target;
    Navigator.of(ctx).popUntil((r) => r.isFirst);
  }

  static GlobalKey<NavigatorState>? navigatorKey;
  static final ValueNotifier<int> openTab = ValueNotifier(0);
}
