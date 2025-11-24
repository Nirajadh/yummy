import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/finance/domain/entities/purchase_entry_entity.dart';

class GetPurchasesUseCase {
  final RestaurantRepository repository;

  const GetPurchasesUseCase(this.repository);

  Future<List<PurchaseEntryEntity>> call() {
    return repository.getPurchases();
  }
}
