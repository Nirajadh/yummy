import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/finance/domain/entities/income_entry_entity.dart';

class GetIncomeUseCase {
  final RestaurantRepository repository;

  const GetIncomeUseCase(this.repository);

  Future<List<IncomeEntryEntity>> call() {
    return repository.getIncome();
  }
}
