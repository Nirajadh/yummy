import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/restaurant/domain/entities/restaurant_entity.dart';

abstract interface class RestaurantRepository {
  Future<Either<Failure, RestaurantEntity>> createRestaurant({
    required String name,
    required String address,
    required String phone,
    String? description,
  });

  Future<Either<Failure, RestaurantEntity>> getRestaurantByUser();

  Future<Either<Failure, RestaurantEntity>> updateRestaurant({
    required int id,
    required String name,
    required String address,
    required String phone,
    String? description,
  });
}
