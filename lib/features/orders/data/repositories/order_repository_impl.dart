import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/exceptions.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:yummy/features/orders/data/models/order_list_model.dart';

import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_enums.dart';
import 'package:yummy/features/orders/domain/entities/order_inputs.dart';
import 'package:yummy/features/orders/domain/repositories/order_repository.dart';
import 'package:yummy/features/orders/mapper/order_mapper.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({required this.remote});

  final OrderRemoteDataSource remote;

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
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
    try {
      final model = await remote.createOrder(
        restaurantId: restaurantId,
        channel: channel,
        items: items,
        tableId: tableId,
        groupId: groupId,
        customerName: customerName,
        customerPhone: customerPhone,
        notes: notes,
        payments: payments,
      );
      return Right(OrderMapper.toOrderEntity(model));
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on NetworkException catch (e) {
      return Left(Failure(e.message));
    } on DataParsingException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> addItemsToOrder({
    required int orderId,
    required List<OrderItemInput> items,
  }) async {
    try {
      final model = await remote.addItemsToOrder(
        orderId: orderId,
        items: items,
      );
      return Right(OrderMapper.toOrderEntity(model));
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on NetworkException catch (e) {
      return Left(Failure(e.message));
    } on DataParsingException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderItems({
    required int orderId,
    required List<OrderItemInput> items,
  }) async {
    try {
      final model = await remote.updateOrderItems(
        orderId: orderId,
        items: items,
      );
      return Right(OrderMapper.toOrderEntity(model));
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on NetworkException catch (e) {
      return Left(Failure(e.message));
    } on DataParsingException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ActiveOrderEntity>>> listOrders({
    required int restaurantId,
    String? status,
    OrderChannel? channel,
    int? tableId,
    String? search,
    int? skip,
    int? limit,
  }) async {
    try {
      final OrderListModel list = await remote.listOrders(
        restaurantId: restaurantId,
        status: status,
        channel: channel,
        tableId: tableId,
        search: search,
        skip: skip,
        limit: limit,
      );
      final active = list.orders.map(OrderMapper.toActiveFromOrder).toList();
      return Right(active);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on NetworkException catch (e) {
      return Left(Failure(e.message));
    } on DataParsingException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred: $e'));
    }
  }
}
