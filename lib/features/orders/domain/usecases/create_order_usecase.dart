import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/orders/domain/entities/order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_enums.dart';
import 'package:yummy/features/orders/domain/entities/order_inputs.dart';
import 'package:yummy/features/orders/domain/repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  const CreateOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call({
    required int restaurantId,
    required OrderChannel channel,
    required List<OrderItemInput> items,
    int? tableId,
    int? groupId,
    String? customerName,
    String? customerPhone,
    String? notes,
    List<OrderPaymentInput>? payments,
  }) {
    return repository.createOrder(
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
  }
}
