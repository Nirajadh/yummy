import 'dart:io';

import 'package:dio/dio.dart';
import 'package:yummy/core/app_apis.dart';
import 'package:yummy/core/error/exceptions.dart';
import 'package:yummy/features/tables/data/models/restaurant_table_model.dart';

abstract interface class TableRemoteDataSource {
  Future<RestaurantTableModel> createTable({
    required int restaurantId,
    required String name,
    required int capacity,
    required int tableTypeId,
    String status,
  });

  Future<RestaurantTableModel> updateTable({
    required int tableId,
    required String name,
    required int capacity,
    required int tableTypeId,
    String status,
  });

  Future<List<RestaurantTableModel>> getTables({required int restaurantId});

  Future<void> deleteTable({required int tableId});
}

class TableRemoteDataSourceImpl implements TableRemoteDataSource {
  TableRemoteDataSourceImpl({required this.appApis});

  final AppApis appApis;

  @override
  Future<RestaurantTableModel> createTable({
    required int restaurantId,
    required String name,
    required int capacity,
    required int tableTypeId,
    String status = 'free',
  }) async {
    try {
      final response = await appApis.sendRequest.post(
        '/restaurants/tables/$restaurantId',
        data: {
          'name': name,
          'capacity': capacity,
          'table_type_id': tableTypeId,
          'status': status,
        },
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return RestaurantTableModel.fromJson(data);
        }
        throw const ServerException('Missing table data');
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
  Future<RestaurantTableModel> updateTable({
    required int tableId,
    required String name,
    required int capacity,
    required int tableTypeId,
    String status = 'free',
  }) async {
    try {
      final response = await appApis.sendRequest.put(
        '/restaurants/tables/$tableId',
        data: {
          'name': name,
          'capacity': capacity,
          'table_type_id': tableTypeId,
          'status': status,
        },
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return RestaurantTableModel.fromJson(data);
        }
        throw const ServerException('Missing table data');
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
  Future<List<RestaurantTableModel>> getTables({
    required int restaurantId,
  }) async {
    try {
      final response = await appApis.sendRequest.get(
        '/restaurants/tables/all/$restaurantId',
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(RestaurantTableModel.fromJson)
              .toList();
        }
        throw const ServerException('Missing table data');
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
  Future<void> deleteTable({required int tableId}) async {
    try {
      final response = await appApis.sendRequest.delete(
        '/restaurants/tables/$tableId',
      );
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300) return;
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
