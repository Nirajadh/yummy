import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/item_category/domain/entities/item_category_entity.dart';
import 'package:yummy/features/item_category/domain/repositories/item_category_repository.dart';

class CreateItemCategoryUseCase {
  final ItemCategoryRepository repository;

  CreateItemCategoryUseCase(this.repository);

  Future<Either<Failure, ItemCategoryEntity>> call({
    required int restaurantId,
    required String name,
  }) {
    return repository.createItemCategory(
      restaurantId: restaurantId,
      name: name,
    );
  }
}
