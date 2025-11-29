import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/exceptions.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/tables/mapper/table_type_mapper.dart';
import 'package:yummy/features/tables/data/datasources/table_type_remote_data_source.dart';
import 'package:yummy/features/tables/domain/entities/table_type_entity.dart';
import 'package:yummy/features/tables/domain/repositories/table_type_repository.dart';

class TableTypeRepositoryImpl implements TableTypeRepository {
  final TableTypeRemoteDataSource remote;

  TableTypeRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, TableTypeEntity>> createTableType({
    required int restaurantId,
    required String name,
  }) async {
    try {
      final model = await remote.createTableType(
        restaurantId: restaurantId,
        name: name,
      );
      return Right(TableTypeMapper.toEntity(model));
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on NetworkException catch (e) {
      return Left(Failure(e.message));
    } on DataParsingException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TableTypeEntity>>> getTableTypes({
    required int restaurantId,
  }) async {
    try {
      final models = await remote.getTableTypes(restaurantId: restaurantId);
      return Right(models.map(TableTypeMapper.toEntity).toList());
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on NetworkException catch (e) {
      return Left(Failure(e.message));
    } on DataParsingException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred: $e'));
    }
  }
}
