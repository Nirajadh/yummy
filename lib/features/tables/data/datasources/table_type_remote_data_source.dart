import 'dart:io';

import 'package:dio/dio.dart';
import 'package:yummy/core/app_apis.dart';
import 'package:yummy/core/error/exceptions.dart';
import 'package:yummy/features/tables/data/models/table_type_model.dart';

abstract interface class TableTypeRemoteDataSource {
  Future<TableTypeModel> createTableType({
    required int restaurantId,
    required String name,
  });

  Future<List<TableTypeModel>> getTableTypes({required int restaurantId});
}

class TableTypeRemoteDataSourceImpl implements TableTypeRemoteDataSource {
  TableTypeRemoteDataSourceImpl({required this.appApis});

  final AppApis appApis;

  @override
  Future<TableTypeModel> createTableType({
    required int restaurantId,
    required String name,
  }) async {
    try {
      final response = await appApis.sendRequest.post(
        '/restaurants/table-types/$restaurantId',
        data: {'name': name},
      );
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return TableTypeModel.fromJson(data);
        }
        throw const ServerException('Missing table type data');
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
  Future<List<TableTypeModel>> getTableTypes({
    required int restaurantId,
  }) async {
    try {
      final response = await appApis.sendRequest.get(
        '/restaurants/table-types/$restaurantId',
      );
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(TableTypeModel.fromJson)
              .toList();
        }
        throw const ServerException('Missing table type data');
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
