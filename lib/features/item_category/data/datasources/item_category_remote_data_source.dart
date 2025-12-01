import 'dart:io';

import 'package:dio/dio.dart';
import 'package:yummy/core/app_apis.dart';
import 'package:yummy/core/error/exceptions.dart';
import 'package:yummy/features/item_category/data/models/item_category_model.dart';

abstract interface class ItemCategoryRemoteDataSource {
  Future<List<ItemCategoryModel>> getItemCategories({
    required int restaurantId,
  });
  Future<ItemCategoryModel> createItemCategory({
    required int restaurantId,
    required String name,
  });
  Future<ItemCategoryModel> updateItemCategory({
    required int id,
    required String name,
  });
  Future<void> deleteItemCategory({required int id});
}

class ItemCategoryRemoteDataSourceImpl implements ItemCategoryRemoteDataSource {
  ItemCategoryRemoteDataSourceImpl({required this.appApis});

  final AppApis appApis;

  @override
  Future<List<ItemCategoryModel>> getItemCategories({
    required int restaurantId,
  }) async {
    try {
      final response = await appApis.sendRequest.get(
        '/item-categories/restaurant/$restaurantId',
      );
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(ItemCategoryModel.fromJson)
              .toList();
        }
        // Some backends return a single object; normalize to list.
        if (data is Map<String, dynamic>) {
          return [ItemCategoryModel.fromJson(data)];
        }
        return const <ItemCategoryModel>[];
      }
      // Gracefully degrade if listing is not implemented server-side.
      if (status == 404 || status == 405) {
        return const <ItemCategoryModel>[];
      }
      throw ServerException(
        'Unexpected error: ${response.statusCode ?? 'no status'}',
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404 || status == 405) {
        return const <ItemCategoryModel>[];
      }
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
  Future<ItemCategoryModel> createItemCategory({
    required int restaurantId,
    required String name,
  }) async {
    try {
      final response = await appApis.sendRequest.post(
        '/item-categories/$restaurantId',
        data: {'name': name},
      );
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return ItemCategoryModel.fromJson(data);
        }
        throw const ServerException('Missing item category data');
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
  Future<ItemCategoryModel> updateItemCategory({
    required int id,
    required String name,
  }) async {
    try {
      final response = await appApis.sendRequest.put(
        '/item-categories/$id',
        data: {'name': name},
      );
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return ItemCategoryModel.fromJson(data);
        }
        throw const ServerException('Missing item category data');
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
  Future<void> deleteItemCategory({required int id}) async {
    try {
      final response = await appApis.sendRequest.delete('/item-categories/$id');
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        return;
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
