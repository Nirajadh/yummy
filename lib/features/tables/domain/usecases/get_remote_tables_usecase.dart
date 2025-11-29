import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';
import 'package:yummy/features/tables/domain/repositories/remote_table_repository.dart';

class GetRemoteTablesUseCase {
  final RemoteTableRepository repository;

  GetRemoteTablesUseCase(this.repository);

  Future<Either<Failure, List<TableEntity>>> call({
    required int restaurantId,
  }) {
    return repository.getTables(restaurantId: restaurantId);
  }
}
