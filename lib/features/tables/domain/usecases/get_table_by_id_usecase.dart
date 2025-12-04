import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';
import 'package:yummy/features/tables/domain/repositories/remote_table_repository.dart';

class GetTableByIdUseCase {
  final RemoteTableRepository repository;

  const GetTableByIdUseCase(this.repository);

  Future<Either<Failure, TableEntity>> call(int id) {
    return repository.getTableById(tableId: id);
  }
}
