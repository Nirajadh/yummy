import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';
import 'package:yummy/features/tables/domain/repositories/remote_table_repository.dart';

class UpdateRemoteTableUseCase {
  final RemoteTableRepository repository;

  UpdateRemoteTableUseCase(this.repository);

  Future<Either<Failure, TableEntity>> call({
    required int tableId,
    required String name,
    required int capacity,
    required int tableTypeId,
    String status = 'free',
  }) {
    return repository.updateTable(
      tableId: tableId,
      name: name,
      capacity: capacity,
      tableTypeId: tableTypeId,
      status: status,
    );
  }
}
