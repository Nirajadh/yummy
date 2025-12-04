import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:yummy/core/app_apis.dart';
import 'package:yummy/core/error/exceptions.dart';
import 'package:yummy/features/orders/data/models/order_create_request.dart';
import 'package:yummy/features/orders/data/models/order_list_model.dart';
import 'package:yummy/features/orders/data/models/order_model.dart';
import 'package:yummy/features/orders/domain/entities/order_enums.dart';
import 'package:yummy/features/orders/domain/entities/order_inputs.dart';

abstract interface class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
    required int restaurantId,
    required OrderChannel channel,
    required List<OrderItemInput> items,
    int? tableId,
    int? groupId,
    String? customerName,
    String? customerPhone,
    String? notes,
    List<OrderPaymentInput>? payments,
  });

  Future<OrderModel> addItemsToOrder({
    required int orderId,
    required List<OrderItemInput> items,
  });

  Future<OrderListModel> listOrders({
    required int restaurantId,
    String? status,
    OrderChannel? channel,
    int? tableId,
    String? search,
    int? skip,
    int? limit,
  });
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl({required this.appApis});

  final AppApis appApis;

  @override
  Future<OrderModel> createOrder({
    required int restaurantId,
    required OrderChannel channel,
    required List<OrderItemInput> items,
    int? tableId,
    int? groupId,
    String? customerName,
    String? customerPhone,
    String? notes,
    List<OrderPaymentInput>? payments,
  }) async {
    final payload = OrderCreateRequest(
      restaurantId: restaurantId,
      channel: channel,
      items: items,
      tableId: tableId,
      groupId: groupId,
      customerName: customerName,
      customerPhone: customerPhone,
      notes: notes,
      payments: payments,
    ).toJson();

    try {
      log('Creating order payload: $payload');
      final response = await appApis.sendRequest.post('/orders/', data: payload);
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return OrderModel.fromJson(data);
        }
        throw const ServerException('Missing order data');
      }
      throw ServerException(
        'Unexpected error: ${response.statusCode ?? 'no status'}',
      );
    } on DioException catch (e) {
      final resp = e.response?.data;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response!.data['detail'] ??
                e.response!.data['message'] ??
                'Request failed')
          : (resp?.toString().isNotEmpty == true ? resp.toString() : e.message);
      log('Create order failed: status=${e.response?.statusCode} body=$resp');
      throw ServerException(message?.toString() ?? 'Request failed');
    } on SocketException {
      throw const NetworkException('No Internet Connection');
    } on FormatException {
      throw const DataParsingException('Bad response format');
    }
  }

  @override
  Future<OrderModel> addItemsToOrder({
    required int orderId,
    required List<OrderItemInput> items,
  }) async {
    final payload = {
      'items': items.map((e) => e.toJson()).toList(),
    };

    try {
      log('Adding items to order $orderId payload: $payload');
      final response = await appApis.sendRequest.post(
        '/orders/$orderId/items',
        data: payload,
      );
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return OrderModel.fromJson(data);
        }
        throw const ServerException('Missing order data');
      }
      throw ServerException(
        'Unexpected error: ${response.statusCode ?? 'no status'}',
      );
    } on DioException catch (e) {
      final resp = e.response?.data;
      final message = resp is Map<String, dynamic>
          ? (resp['detail'] ?? resp['message'] ?? 'Request failed')
          : (resp?.toString().isNotEmpty == true ? resp.toString() : e.message);
      log(
        'Add items failed: orderId=$orderId status=${e.response?.statusCode} body=$resp',
      );
      throw ServerException(message?.toString() ?? 'Request failed');
    } on SocketException {
      throw const NetworkException('No Internet Connection');
    } on FormatException {
      throw const DataParsingException('Bad response format');
    }
  }

  @override
  Future<OrderListModel> listOrders({
    required int restaurantId,
    String? status,
    OrderChannel? channel,
    int? tableId,
    String? search,
    int? skip,
    int? limit,
  }) async {
    final Map<String, dynamic> query = {'restaurant_id': restaurantId};
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (channel != null) query['channel'] = channel.apiValue;
    if (tableId != null) query['table_id'] = tableId;
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (skip != null) query['skip'] = skip;
    if (limit != null) query['limit'] = limit;

    try {
      final response = await appApis.sendRequest.get(
        '/orders/',
        queryParameters: query,
      );
      final statusCode = response.statusCode ?? 0;
      if (statusCode >= 200 && statusCode < 300 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final data = map['data'];
        if (data is Map<String, dynamic>) {
          return OrderListModel.fromJson(data);
        }
        throw const ServerException('Missing orders data');
      }
      throw ServerException(
        'Unexpected error: ${response.statusCode ?? 'no status'}',
      );
    } on DioException catch (e) {
      final resp = e.response?.data;
      final message = resp is Map<String, dynamic>
          ? (resp['detail'] ?? resp['message'] ?? 'Request failed')
          : (resp?.toString().isNotEmpty == true ? resp.toString() : e.message);
      log('List orders failed: status=${e.response?.statusCode} body=$resp');
      throw ServerException(message?.toString() ?? 'Request failed');
    } on SocketException {
      throw const NetworkException('No Internet Connection');
    } on FormatException {
      throw const DataParsingException('Bad response format');
    }
  }
}
