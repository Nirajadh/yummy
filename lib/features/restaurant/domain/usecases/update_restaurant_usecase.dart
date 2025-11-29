import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/restaurant/domain/entities/restaurant_entity.dart';
import 'package:yummy/features/restaurant/domain/repositories/restaurant_repository.dart';

class UpdateRestaurantUseCase {
  final RestaurantRepository repository;

  UpdateRestaurantUseCase(this.repository);

  Future<Either<Failure, RestaurantEntity>> call({
    required int id,
    required String name,
    required String address,
    required String phone,
    String? description,
  }) {
    return repository.updateRestaurant(
      id: id,
      name: name,
      address: address,
      phone: phone,
      description: description,
    );
  }
}
