import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/tables/domain/entities/table_type_entity.dart';

abstract interface class TableTypeRepository {
  Future<Either<Failure, TableTypeEntity>> createTableType({
    required int restaurantId,
    required String name,
  });

  Future<Either<Failure, List<TableTypeEntity>>> getTableTypes({
    required int restaurantId,
  });
}
