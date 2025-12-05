import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_enums.dart';
import 'package:yummy/features/orders/domain/entities/order_inputs.dart';

abstract interface class OrderRepository {
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
  });

  Future<Either<Failure, OrderEntity>> addItemsToOrder({
    required int orderId,
    required List<OrderItemInput> items,
  });

  Future<Either<Failure, OrderEntity>> updateOrderItems({
    required int orderId,
    required List<OrderItemInput> items,
  });

  Future<Either<Failure, List<ActiveOrderEntity>>> listOrders({
    required int restaurantId,
    String? status,
    OrderChannel? channel,
    int? tableId,
    String? search,
    int? skip,
    int? limit,
  });
}
