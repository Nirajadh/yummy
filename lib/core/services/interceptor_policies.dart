import 'package:dio/dio.dart';
import 'package:yummy/core/services/shared_prefrences.dart';

/// Injects the latest persisted token into each request.
class JwtInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await SecureStorageService().getValue(key: 'token');
    options.headers['content-type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }
}
