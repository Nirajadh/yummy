import 'dart:io';

import 'package:dio/dio.dart';
import 'package:yummy/core/app_apis.dart';
import 'package:yummy/core/error/exceptions.dart';
import 'package:yummy/features/menu/data/models/menu_model.dart';

abstract interface class MenuRemoteDataSource {
  Future<List<MenuModel>> getMenusByRestaurant({
    required int restaurantId,
    int? itemCategoryId,
  });
  Future<MenuModel> createMenu({
    required int restaurantId,
    required String name,
    required double price,
    required int itemCategoryId,
    String? description,
    String? imagePath,
  });
  Future<MenuModel> updateMenu({
    required int id,
    String? name,
    double? price,
    int? itemCategoryId,
    String? description,
    String? imagePath,
  });
  Future<void> deleteMenu({required int id});
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  MenuRemoteDataSourceImpl({required this.appApis});

  final AppApis appApis;

  @override
  Future<List<MenuModel>> getMenusByRestaurant({
    required int restaurantId,
    int? itemCategoryId,
  }) async {
    try {
      if (itemCategoryId != null) {
        final response = await appApis.sendRequest.get(
          '/menus/restaurant/$restaurantId',
          queryParameters: {'item_category_id': itemCategoryId},
        );
        final status = response.statusCode ?? 0;
        if (status >= 200 && status < 300 && response.data is Map) {
          final map = response.data as Map<String, dynamic>;
          final data = map['data'];
          if (data is List) {
            return data
                .whereType<Map<String, dynamic>>()
                .map(MenuModel.fromJson)
                .toList();
          }
          return const <MenuModel>[];
        }
        throw ServerException(
          'Unexpected error: ${response.statusCode ?? 'no status'}',
        );
      }

      // Default: grouped endpoint to include category names.
      final response = await appApis.sendRequest.get(
        '/menus/restaurant/$restaurantId/grouped',
      );
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is List) {
          final List<MenuModel> items = [];
          for (final group in data.whereType<Map<String, dynamic>>()) {
            final categoryName = (group['category_name'] ?? '').toString();
            final groupItems = group['items'];
            if (groupItems is List) {
              for (final raw in groupItems.whereType<Map<String, dynamic>>()) {
                items.add(
                  MenuModel.fromJson(raw).copyWith(
                    categoryName: categoryName.isNotEmpty ? categoryName : null,
                  ),
                );
              }
            }
          }
          return items;
        }
        return const <MenuModel>[];
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
  Future<MenuModel> createMenu({
    required int restaurantId,
    required String name,
    required double price,
    required int itemCategoryId,
    String? description,
    String? imagePath,
  }) async {
    final form = FormData.fromMap({
      'name': name,
      'price': price,
      'item_category_id': itemCategoryId,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (imagePath != null && imagePath.isNotEmpty)
        'image': await MultipartFile.fromFile(imagePath),
    });
    try {
      final response = await appApis.sendRequest.post(
        '/menus/$restaurantId',
        data: form,
      );
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return MenuModel.fromJson(data);
        }
        throw const ServerException('Missing menu data');
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
  Future<MenuModel> updateMenu({
    required int id,
    String? name,
    double? price,
    int? itemCategoryId,
    String? description,
    String? imagePath,
  }) async {
    final form = FormData.fromMap({
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (itemCategoryId != null) 'item_category_id': itemCategoryId,
      if (description != null) 'description': description,
      if (imagePath != null && imagePath.isNotEmpty)
        'image': await MultipartFile.fromFile(imagePath),
    });
    try {
      final response = await appApis.sendRequest.put('/menus/$id', data: form);
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return MenuModel.fromJson(data);
        }
        throw const ServerException('Missing menu data');
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
  Future<void> deleteMenu({required int id}) async {
    try {
      final response = await appApis.sendRequest.delete('/menus/$id');
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
