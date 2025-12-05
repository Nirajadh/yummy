import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/orders/domain/entities/order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_inputs.dart';
import 'package:yummy/features/orders/domain/repositories/order_repository.dart';

class UpdateOrderItemsUseCase {
  final OrderRepository repository;

  const UpdateOrderItemsUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call({
    required int orderId,
    required List<OrderItemInput> items,
  }) {
    return repository.updateOrderItems(orderId: orderId, items: items);
  }
}

