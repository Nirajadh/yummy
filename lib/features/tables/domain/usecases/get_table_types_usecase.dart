import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/tables/domain/entities/table_type_entity.dart';
import 'package:yummy/features/tables/domain/repositories/table_type_repository.dart';

class GetTableTypesUseCase {
  final TableTypeRepository repository;

  GetTableTypesUseCase(this.repository);

  Future<Either<Failure, List<TableTypeEntity>>> call({
    required int restaurantId,
  }) {
    return repository.getTableTypes(restaurantId: restaurantId);
  }
}
