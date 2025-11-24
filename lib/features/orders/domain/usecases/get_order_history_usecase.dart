import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/orders/domain/entities/order_history_entry_entity.dart';

class GetOrderHistoryUseCase {
  final RestaurantRepository repository;

  const GetOrderHistoryUseCase(this.repository);

  Future<List<OrderHistoryEntryEntity>> call() {
    return repository.getOrderHistory();
  }
}
