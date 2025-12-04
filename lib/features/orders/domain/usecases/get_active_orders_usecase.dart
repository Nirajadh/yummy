import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_enums.dart';
import 'package:yummy/features/orders/domain/repositories/order_repository.dart';

class GetActiveOrdersUseCase {
  final OrderRepository repository;

  const GetActiveOrdersUseCase(this.repository);

  Future<Either<Failure, List<ActiveOrderEntity>>> call({
    required int restaurantId,
    String? status,
    OrderChannel? channel,
    int? tableId,
    String? search,
    int? skip,
    int? limit,
  }) {
    return repository.listOrders(
      restaurantId: restaurantId,
      status: status,
      channel: channel,
      tableId: tableId,
      search: search,
      skip: skip,
      limit: limit,
    );
  }
}
