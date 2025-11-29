import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/exceptions.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/tables/mapper/restaurant_table_mapper.dart';
import 'package:yummy/features/tables/data/datasources/table_remote_data_source.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';
import 'package:yummy/features/tables/domain/repositories/remote_table_repository.dart';

class RemoteTableRepositoryImpl implements RemoteTableRepository {
  RemoteTableRepositoryImpl({required this.remote});

  final TableRemoteDataSource remote;

  @override
  Future<Either<Failure, TableEntity>> createTable({
    required int restaurantId,
    required String name,
    required int capacity,
    required int tableTypeId,
    String status = 'free',
  }) async {
    try {
      final model = await remote.createTable(
        restaurantId: restaurantId,
        name: name,
        capacity: capacity,
        tableTypeId: tableTypeId,
        status: status,
      );
      return Right(RestaurantTableMapper.toEntity(model));
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
  Future<Either<Failure, List<TableEntity>>> getTables({
    required int restaurantId,
  }) async {
    try {
      final models = await remote.getTables(restaurantId: restaurantId);
      final entities =
          models.map((model) => RestaurantTableMapper.toEntity(model)).toList();
      return Right(entities);
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
  Future<Either<Failure, void>> deleteTable({required int tableId}) async {
    try {
      await remote.deleteTable(tableId: tableId);
      return const Right(null);
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
