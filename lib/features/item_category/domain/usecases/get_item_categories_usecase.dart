import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/item_category/domain/entities/item_category_entity.dart';
import 'package:yummy/features/item_category/domain/repositories/item_category_repository.dart';

class GetItemCategoriesUseCase {
  final ItemCategoryRepository repository;

  GetItemCategoriesUseCase(this.repository);

  Future<Either<Failure, List<ItemCategoryEntity>>> call(int restaurantId) {
    return repository.getItemCategories(restaurantId: restaurantId);
  }
}
