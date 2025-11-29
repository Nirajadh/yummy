import 'dart:io';

import 'package:dio/dio.dart';
import 'package:yummy/core/app_apis.dart';
import 'package:yummy/core/error/exceptions.dart';
import 'package:yummy/features/restaurant/data/models/restaurant_model.dart';

abstract interface class RestaurantRemoteDataSource {
  Future<RestaurantModel> createRestaurant({
    required String name,
    required String address,
    required String phone,
    String? description,
  });

  Future<RestaurantModel> getRestaurantByUser();

  Future<RestaurantModel> updateRestaurant({
    required int id,
    required String name,
    required String address,
    required String phone,
    String? description,
  });
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  RestaurantRemoteDataSourceImpl({required this.appApis});

  final AppApis appApis;

  @override
  Future<RestaurantModel> createRestaurant({
    required String name,
    required String address,
    required String phone,
    String? description,
  }) async {
    try {
      final response = await appApis.sendRequest.post(
        '/restaurants/',
        data: {
          'name': name,
          'address': address,
          'phone': phone,
          if (description != null) 'description': description,
        },
      );

      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return RestaurantModel.fromJson(data);
        }
        throw const ServerException('Missing restaurant data');
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

  @override
  Future<RestaurantModel> getRestaurantByUser() async {
    try {
      final response = await appApis.sendRequest.get('/restaurants/by-user');
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return RestaurantModel.fromJson(data);
        }
        throw const ServerException('Missing restaurant data');
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

  @override
  Future<RestaurantModel> updateRestaurant({
    required int id,
    required String name,
    required String address,
    required String phone,
    String? description,
  }) async {
    try {
      final response = await appApis.sendRequest.put(
        '/restaurants/$id',
        data: {
          'name': name,
          'address': address,
          'phone': phone,
          if (description != null) 'description': description,
        },
      );

      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return RestaurantModel.fromJson(data);
        }
        throw const ServerException('Missing restaurant data');
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
