import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/item_category/domain/entities/item_category_entity.dart';

abstract interface class ItemCategoryRepository {
  Future<Either<Failure, List<ItemCategoryEntity>>> getItemCategories({
    required int restaurantId,
  });
  Future<Either<Failure, ItemCategoryEntity>> createItemCategory({
    required int restaurantId,
    required String name,
  });
  Future<Either<Failure, ItemCategoryEntity>> updateItemCategory({
    required int id,
    required String name,
  });
  Future<Either<Failure, void>> deleteItemCategory({required int id});
}
