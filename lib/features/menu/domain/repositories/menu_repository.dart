import 'package:fpdart/fpdart.dart';
import 'package:yummy/core/error/failure.dart';
import 'package:yummy/features/menu/domain/entities/menu_item_entity.dart';

abstract interface class MenuRepository {
  Future<Either<Failure, List<MenuItemEntity>>> getMenusByRestaurant({
    required int restaurantId,
    int? itemCategoryId,
  });
  Future<Either<Failure, MenuItemEntity>> createMenu({
    required int restaurantId,
    required String name,
    required double price,
    required int itemCategoryId,
    String? description,
    String? imagePath,
  });
  Future<Either<Failure, MenuItemEntity>> updateMenu({
    required int id,
    String? name,
    double? price,
    int? itemCategoryId,
    String? description,
    String? imagePath,
  });
  Future<Either<Failure, void>> deleteMenu({required int id});
}
