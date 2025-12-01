import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/menu/domain/entities/menu_item_entity.dart';
import 'package:yummy/features/menu/domain/repositories/menu_repository.dart';

class GetMenusByRestaurantUseCase {
  final MenuRepository repository;

  GetMenusByRestaurantUseCase(this.repository);

  Future<Either<Failure, List<MenuItemEntity>>> call({
    required int restaurantId,
    int? itemCategoryId,
  }) {
    return repository.getMenusByRestaurant(
      restaurantId: restaurantId,
      itemCategoryId: itemCategoryId,
    );
  }
}
