import 'dart:io';

import 'package:dio/dio.dart';
import 'package:yummy/core/app_apis.dart';
import 'package:yummy/core/error/error_response_mapper.dart';
import 'package:yummy/core/error/error_response_model.dart';
import 'package:yummy/core/error/exceptions.dart';
import 'package:yummy/features/auth/data/models/admin_register_model.dart';
import 'package:yummy/features/auth/data/models/login_model.dart';
import 'package:yummy/features/auth/data/models/register_model.dart';
import 'package:yummy/features/auth/data/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginModel> login({required String email, required String password});
  Future<RegisterModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? confirmPassword,
  });
  Future<AdminRegisterModel> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  });
  Future<List<UserModel>> getAllUsers();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.appApis});

  final AppApis appApis;

  @override
  Future<LoginModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await appApis.sendRequest.post(
        AppApi.authApis.login,
        data: {'username': email, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final apiStatus = (map['status'] ?? '').toString().toLowerCase();
        if (apiStatus != 'success' || map['data'] == null) {
          throw ServerException(map['message']?.toString() ?? 'Login failed');
        }
        return LoginModel.fromJson(map);
      }
      throw ServerException(
        'Unexpected error: ${response.statusCode ?? 'no status'}',
      );
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response!.data['detail'] ??
                e.response!.data['message'] ??
                'Login failed')
          : e.message;
      throw ServerException(message?.toString() ?? 'Login failed');
    } on SocketException {
      throw const NetworkException('No Internet Connection');
    } on FormatException {
      throw const DataParsingException('Bad response format');
    }
  }

  @override
  Future<RegisterModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? confirmPassword,
  }) async {
    try {
      final response = await appApis.sendRequest.post(
        AppApi.authApis.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword ?? password,
          'role': role,
        },
      );

      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        final apiStatus = (map['status'] ?? '').toString().toLowerCase();
        if (apiStatus != 'success') {
          throw ServerException(map['message']?.toString() ?? 'Register failed');
        }
        return RegisterModel.fromJson(map);
      }

      throw ServerException(
        'Unexpected error: ${response.statusCode ?? 'no status'}',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422 && e.response?.data != null) {
        final errorResponse = ErrorResponseMapper.toEntity(
          ErrorResponseModel.fromJson(e.response!.data),
        );
        final topError = errorResponse.errors.join('\n');
        throw ServerException(topError);
      }

      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data['message'] != null) {
          throw ServerException(data['message'].toString());
        }
        if (data['detail'] != null) {
          throw ServerException(data['detail'].toString());
        }
      }

      throw ServerException('Network error occurred');
    } on SocketException {
      throw const NetworkException('No Internet Connection');
    } on FormatException {
      throw const DataParsingException('Bad response format');
    }
  }

  @override
  Future<AdminRegisterModel> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await appApis.sendRequest.post(
        AppApi.authApis.registerAdmin,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        return AdminRegisterModel.fromJson(map);
      }

      throw ServerException(
        'Unexpected error: ${response.statusCode ?? 'no status'}',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422 && e.response?.data != null) {
        final errorResponse = ErrorResponseMapper.toEntity(
          ErrorResponseModel.fromJson(e.response!.data),
        );
        final topError = errorResponse.errors.join('\n');
        throw ServerException(topError);
      }

      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data['message'] != null) {
          throw ServerException(data['message'].toString());
        }
        if (data['detail'] != null) {
          throw ServerException(data['detail'].toString());
        }
      }

      throw ServerException('Network error occurred');
    } on SocketException {
      throw const NetworkException('No Internet Connection');
    } on FormatException {
      throw const DataParsingException('Bad response format');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await appApis.sendRequest.get(AppApi.authApis.listUsers);
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final apiStatus = (map['status'] ?? '').toString().toLowerCase();
        if (apiStatus != 'success') {
          throw ServerException(map['message']?.toString() ?? 'Request failed');
        }
        final data = map['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(UserModel.fromJson)
              .toList();
        }
        return const <UserModel>[];
      }
      throw ServerException(
        'Unexpected error: ${response.statusCode ?? 'no status'}',
      );
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response!.data['detail'] ??
                e.response!.data['message'] ??
                'Request failed')
          : e.message;
      throw ServerException(message?.toString() ?? 'Request failed');
    } on SocketException {
      throw const NetworkException('No Internet Connection');
    } on FormatException {
      throw const DataParsingException('Bad response format');
    }
  }
}
