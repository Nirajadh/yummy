import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/exceptions.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/restaurant/data/datasources/restaurant_remote_data_source.dart';
import 'package:yummy/features/restaurant/data/models/restaurant_model.dart';
import 'package:yummy/features/restaurant/domain/entities/restaurant_entity.dart';
import 'package:yummy/features/restaurant/domain/repositories/restaurant_repository.dart';
import 'package:yummy/core/mapper/restaurant_mapper.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  RestaurantRepositoryImpl({required this.remote});

  final RestaurantRemoteDataSource remote;

  RestaurantEntity _mapModel(RestaurantModel model) =>
      RestaurantMapper.toEntity(model);

  @override
  Future<Either<Failure, RestaurantEntity>> createRestaurant({
    required String name,
    required String address,
    required String phone,
    String? description,
  }) async {
    try {
      final model = await remote.createRestaurant(
        name: name,
        address: address,
        phone: phone,
        description: description,
      );
      return Right(_mapModel(model));
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
  Future<Either<Failure, RestaurantEntity>> getRestaurantByUser() async {
    try {
      final model = await remote.getRestaurantByUser();
      return Right(_mapModel(model));
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
  Future<Either<Failure, RestaurantEntity>> updateRestaurant({
    required int id,
    required String name,
    required String address,
    required String phone,
    String? description,
  }) async {
    try {
      final model = await remote.updateRestaurant(
        id: id,
        name: name,
        address: address,
        phone: phone,
        description: description,
      );
      return Right(_mapModel(model));
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
