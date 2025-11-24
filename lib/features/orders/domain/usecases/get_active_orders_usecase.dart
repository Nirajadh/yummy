import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';

class GetActiveOrdersUseCase {
  final RestaurantRepository repository;

  const GetActiveOrdersUseCase(this.repository);

  Future<List<ActiveOrderEntity>> call() {
    return repository.getActiveOrders();
  }
}
