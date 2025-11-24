import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';

class UpsertTableUseCase {
  final RestaurantRepository repository;

  const UpsertTableUseCase(this.repository);

  Future<void> call(TableEntity table) {
    return repository.upsertTable(table);
  }
}
