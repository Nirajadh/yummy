import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/restaurant/domain/entities/restaurant_entity.dart';
import 'package:yummy/features/restaurant/domain/repositories/restaurant_repository.dart';

class GetRestaurantByUserUsecase {
  GetRestaurantByUserUsecase(this.repository);

  final RestaurantRepository repository;

  Future<Either<Failure, RestaurantEntity>> call() {
    return repository.getRestaurantByUser();
  }
}
