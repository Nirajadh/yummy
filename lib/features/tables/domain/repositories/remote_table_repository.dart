import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';

abstract interface class RemoteTableRepository {
  Future<Either<Failure, TableEntity>> createTable({
    required int restaurantId,
    required String name,
    required int capacity,
    required int tableTypeId,
    String status,
  });

  Future<Either<Failure, TableEntity>> updateTable({
    required int tableId,
    required String name,
    required int capacity,
    required int tableTypeId,
    String status,
  });

  Future<Either<Failure, List<TableEntity>>> getTables({
    required int restaurantId,
  });

  Future<Either<Failure, void>> deleteTable({required int tableId});

  Future<Either<Failure, TableEntity>> getTableById({required int tableId});
}
