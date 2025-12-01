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
    // Respect any content-type already set (e.g., form-encoded for login).
    if (options.contentType != null) {
      options.headers.putIfAbsent('content-type', () => options.contentType!);
    }
    options.headers.putIfAbsent('Accept', () => 'application/json');
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    } else {
      options.headers.remove('Authorization');
    }
    handler.next(options);
  }
}
