import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:yummy/core/services/interceptor_policies.dart';
import 'package:yummy/core/services/shared_prefrences.dart';

// const String baseUrl = 'http://192.168.1.85:8000';
const String baseUrl = "https://yummy-2xfq.onrender.com";

/// Simple Dio wrapper plus centralized endpoint builders.
class AppApis {
  final Dio _dio = Dio();
  final SecureStorageService _storage = SecureStorageService();
  String? accessToken;
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;
  final StreamController<void> _logoutController =
      StreamController<void>.broadcast();
  late final Future<void> _initFuture;
  static const Duration _accessTokenTtl = Duration(hours: 24);
  static const Duration _refreshBuffer = Duration(minutes: 5);

  AppApis() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 40);
    _dio.options.receiveTimeout = const Duration(seconds: 40);
    _initFuture = _initToken();
    // Ensure token hydration is completed before the request leaves.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _initFuture;
          await _ensureFreshToken();
          handler.next(options);
        },
      ),
    );
    _dio.interceptors.add(JwtInterceptor());
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (!_shouldAttemptRefresh(error)) {
            handler.next(error);
            return;
          }

          final refreshed = await _refreshAccessToken();
          if (refreshed) {
            try {
              final response = await _retryRequest(error.requestOptions);
              return handler.resolve(response);
            } catch (_) {
              // If retry fails, fall back to the original error.
            }
          }
          handler.next(error);
        },
      ),
    );
    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger());
    }
  }

  Future<void> _initToken() async {
    accessToken = await _storage.getValue(key: "token");
    await _storage.getValue(key: 'token_issued_at'); // Warm prefs cache.
    log('API Access Token: $accessToken');
    if (accessToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    }
  }

  bool _shouldAttemptRefresh(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode != 401) return false;
    final path = error.requestOptions.path.toLowerCase();
    if (path.contains('/auth/login') || path.contains('/auth/refresh')) {
      return false;
    }
    if (error.requestOptions.extra['retried'] == true) {
      return false;
    }
    return true;
  }

  Future<void> _ensureFreshToken() async {
    final issuedAtRaw = await _storage.getValue(key: 'token_issued_at');
    if (issuedAtRaw == null) return;
    final issuedAt = DateTime.tryParse(issuedAtRaw);
    if (issuedAt == null) return;
    final elapsed = DateTime.now().difference(issuedAt);
    final willExpireSoon = elapsed >= (_accessTokenTtl - _refreshBuffer);
    if (willExpireSoon) {
      await _refreshAccessToken();
    }
  }

  Future<bool> _refreshAccessToken() async {
    final storedRefresh = await _storage.getValue(key: 'refresh_token');
    if (storedRefresh == null || storedRefresh.isEmpty) {
      await _clearStoredTokens();
      return false;
    }

    if (_isRefreshing) {
      try {
        return await _refreshCompleter?.future ?? false;
      } catch (_) {
        return false;
      }
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {'Accept': 'application/json'},
          connectTimeout: _dio.options.connectTimeout,
          receiveTimeout: _dio.options.receiveTimeout,
        ),
      );

      final response = await refreshDio.post(
        AppApi.authApis.refresh,
        data: {'refresh_token': storedRefresh},
      );
      final status = response.statusCode ?? 0;
      if (status >= 200 &&
          status < 300 &&
          response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          final newAccess = data['access_token']?.toString() ?? '';
          final newRefresh = data['refresh_token']?.toString() ?? '';
          if (newAccess.isNotEmpty) {
            await _persistTokens(
              accessToken: newAccess,
              refreshToken: newRefresh.isNotEmpty ? newRefresh : storedRefresh,
            );
            _refreshCompleter?.complete(true);
            return true;
          }
        }
      }

      await _clearStoredTokens();
      _refreshCompleter?.complete(false);
      return false;
    } catch (e) {
      await _clearStoredTokens();
      _refreshCompleter?.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    final latestToken = await _storage.getValue(key: 'token');
    if (latestToken != null && latestToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $latestToken';
    }

    final options = Options(
      method: requestOptions.method,
      headers: headers,
      contentType: requestOptions.contentType,
      responseType: requestOptions.responseType,
      followRedirects: requestOptions.followRedirects,
      validateStatus: requestOptions.validateStatus,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
      extra: Map<String, dynamic>.from(requestOptions.extra)
        ..['retried'] = true,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<void> _persistTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    await _storage.setValue(key: 'token', value: accessToken);
    await _storage.setValue(key: 'refresh_token', value: refreshToken);
    await _storage.setValue(
      key: 'token_issued_at',
      value: DateTime.now().toIso8601String(),
    );
  }

  Future<void> _clearStoredTokens() async {
    accessToken = null;
    _dio.options.headers.remove('Authorization');
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'token_issued_at');
    // Notify listeners (e.g., auth bloc) that auth is no longer valid.
    if (!_logoutController.isClosed) {
      _logoutController.add(null);
    }
  }

  Dio get sendRequest => _dio;
  Stream<void> get onUnauthorizedLogout => _logoutController.stream;
}

class AppApi {
  static AuthApis authApis = AuthApis();
}

class AuthApis {
  AuthApis();
  // Trailing slash avoids 307 redirect from the backend.
  String get register => '/users/';
  String get registerAdmin => '/users/admin/register';
  String get adminRegisterVerify => '/users/admin/register/verify';
  String get adminRegisterResend => '/users/admin/register/resend';
  String userById(String id) => '/users/$id';
  String get login => '/auth/login';
  String get refresh => '/auth/refresh';
  String get logout => '/auth/logout';
  String get listUsers => '/users/all';
}
