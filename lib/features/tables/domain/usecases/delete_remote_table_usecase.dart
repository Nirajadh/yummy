import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/tables/domain/repositories/remote_table_repository.dart';

class DeleteRemoteTableUseCase {
  final RemoteTableRepository repository;

  DeleteRemoteTableUseCase(this.repository);

  Future<Either<Failure, void>> call({required int tableId}) {
    return repository.deleteTable(tableId: tableId);
  }
}
