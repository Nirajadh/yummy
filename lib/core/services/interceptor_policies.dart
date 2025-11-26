import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:yummy/core/services/shared_prefrences.dart';

class JwtInterceptor implements dio.Interceptor {
  @override
  Future<dio.RequestOptions> onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) async {
    String? accessToken = await SecureStorageService().getValue(key: "token");
    options.headers['content-type'] = 'application/json';
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    options.headers['Accept'] = 'application/json';
    return options;
  }

  @override
  dio.Response onResponse(
    dio.Response response,
    dio.ResponseInterceptorHandler handler,
  ) {
    return response;
  }

  @override
  dio.DioException onError(
    dio.DioException err,
    dio.ErrorInterceptorHandler handler,
  ) {
    return err;
  }
}
