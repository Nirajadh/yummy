import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';

class GetTablesUseCase {
  final RestaurantRepository repository;

  const GetTablesUseCase(this.repository);

  Future<List<TableEntity>> call() {
    return repository.getTables();
  }
}
