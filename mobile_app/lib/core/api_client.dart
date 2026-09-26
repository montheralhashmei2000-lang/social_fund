import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'config.dart';
import 'secure_store.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, {this.status});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException() : super('لا يوجد اتصال بالخادم. تحقق من الشبكة أو عنوان الخادم.');
}

class AuthException extends ApiException {
  AuthException(super.message) : super(status: 401);
}

/// عميل HTTP موحّد:
/// - يرفق access token مع كل طلب.
/// - عند 401 يجرب تحديث الجلسة مرة واحدة عبر /auth/refresh (بتدوير
///   الـrefresh token من الخادم) ثم يعيد الطلب الأصلي.
/// - يميز أخطاء الشبكة عن أخطاء الخادم (نظام أونلاين فقط - لا طابور).
class ApiClient {
  static final ApiClient instance = ApiClient._();

  late final Dio dio;
  String? _accessToken;
  String? _refreshToken;
  Future<void>? _refreshFuture;

  ApiClient._() {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 40),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (code) => code != null && code < 500,
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.extra['skipAuth'] != true && _accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        final status = e.response?.statusCode;
        final canRetry = status == 401 &&
            e.requestOptions.extra['skipAuth'] != true &&
            e.requestOptions.extra['retried'] != true;
        if (!canRetry) return handler.next(e);
        try {
          await refreshTokens();
          e.requestOptions.extra['retried'] = true;
          e.requestOptions.headers['Authorization'] = 'Bearer $_accessToken';
          final retry = await dio.fetch(e.requestOptions);
          return handler.resolve(retry);
        } on ApiException catch (_) {
          await clearTokens();
          return handler.next(e);
        }
      },
    ));
  }

  bool get hasTokens => _accessToken != null;

  Future<void> loadStoredTokens() async {
    _accessToken = await SecureStore.accessToken();
    _refreshToken = await SecureStore.refreshToken();
  }

  Future<void> saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    await SecureStore.saveTokens(access: access, refresh: refresh);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await SecureStore.clearTokens();
  }

  /// تحديث واحد فقط في نفس اللحظة (single-flight) مهما تعددت الطلبات الفاشلة.
  Future<void> refreshTokens() {
    final existing = _refreshFuture;
    if (existing != null) return existing;
    final future = _doRefresh();
    _refreshFuture = future;
    return future.whenComplete(() => _refreshFuture = null);
  }

  Future<void> _doRefresh() async {
    final refresh = _refreshToken;
    if (refresh == null) throw AuthException('انتهت الجلسة، يرجى تسجيل الدخول من جديد');
    try {
      final res = await dio.post('/auth/refresh',
          data: {'refresh_token': refresh}, options: Options(extra: {'skipAuth': true}));
      if (res.statusCode != 200) throw AuthException('انتهت الجلسة، يرجى تسجيل الدخول من جديد');
      final data = Map<String, dynamic>.from(res.data as Map);
      await saveTokens(data['access_token'] as String, data['refresh_token'] as String);
      if (kDebugMode) debugPrint('تم تحديث الجلسة وتدوير الـrefresh token');
    } on DioException {
      throw AuthException('انتهت الجلسة، يرجى تسجيل الدخول من جديد');
    }
  }

  Future<dynamic> request(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool skipAuth = false,
  }) async {
    try {
      final res = await dio.request(path,
          data: data,
          queryParameters: query,
          options: Options(method: method, extra: {'skipAuth': skipAuth}));
      final status = res.statusCode ?? 0;
      if (status >= 400) {
        final body = res.data;
        String msg = 'خطأ في الخادم ($status)';
        if (body is Map && body['detail'] != null) msg = body['detail'].toString();
        if (status == 401) throw AuthException(msg);
        throw ApiException(msg, status: status);
      }
      return res.data;
    } on DioException catch (e) {
      final type = e.type;
      final networkIssue = type == DioExceptionType.connectionError ||
          type == DioExceptionType.connectionTimeout ||
          type == DioExceptionType.receiveTimeout ||
          type == DioExceptionType.sendTimeout;
      if (networkIssue) throw NetworkException();
      if (e.error is ApiException) throw e.error as ApiException;
      throw NetworkException();
    }
  }
}
