import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:yummy/core/services/shared_prefrences.dart';

const String baseUrl = 'https://yummy-2xfq.onrender.com';

/// Simple Dio wrapper plus centralized endpoint builders.
class AppApis {
  final Dio _dio = Dio();
  String? accessToken;

  AppApis() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 40);
    _dio.options.receiveTimeout = const Duration(seconds: 40);
    _dio.interceptors.add(PrettyDioLogger());
    _initToken();
  }

  Future<void> _initToken() async {
    accessToken = await SecureStorageService().getValue(key: "token");
    log('API Access Token: $accessToken');
    if (accessToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    }
  }

  Dio get sendRequest => _dio;
}

class AppApi {
  static AuthApis authApis = AuthApis();
}

class AuthApis {
  AuthApis();
  // Trailing slash avoids 307 redirect from the backend.
  String get register => '/users/';
  String get registerAdmin => '/users/admin/register';
  String userById(String id) => '/users/$id';
  String get login => '/auth/login';
  String get listUsers => '/users/all';
}
