import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/tables/domain/entities/table_type_entity.dart';
import 'package:yummy/features/tables/domain/repositories/table_type_repository.dart';

class CreateTableTypeUseCase {
  final TableTypeRepository repository;

  CreateTableTypeUseCase(this.repository);

  Future<Either<Failure, TableTypeEntity>> call({
    required int restaurantId,
    required String name,
  }) {
    return repository.createTableType(restaurantId: restaurantId, name: name);
  }
}
