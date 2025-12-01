import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/menu/domain/entities/menu_item_entity.dart';
import 'package:yummy/features/menu/domain/repositories/menu_repository.dart';

class CreateMenuUseCase {
  final MenuRepository repository;

  CreateMenuUseCase(this.repository);

  Future<Either<Failure, MenuItemEntity>> call({
    required int restaurantId,
    required String name,
    required double price,
    required int itemCategoryId,
    String? description,
    String? imagePath,
  }) {
    return repository.createMenu(
      restaurantId: restaurantId,
      name: name,
      price: price,
      itemCategoryId: itemCategoryId,
      description: description,
      imagePath: imagePath,
    );
  }
}
