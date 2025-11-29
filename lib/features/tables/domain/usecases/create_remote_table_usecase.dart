import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';
import 'package:yummy/features/tables/domain/repositories/remote_table_repository.dart';

class CreateRemoteTableUseCase {
  final RemoteTableRepository repository;

  CreateRemoteTableUseCase(this.repository);

  Future<Either<Failure, TableEntity>> call({
    required int restaurantId,
    required String name,
    required int capacity,
    required int tableTypeId,
    String status = 'free',
  }) {
    return repository.createTable(
      restaurantId: restaurantId,
      name: name,
      capacity: capacity,
      tableTypeId: tableTypeId,
      status: status,
    );
  }
}
