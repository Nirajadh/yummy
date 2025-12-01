import 'package:yummy/features/item_category/data/models/item_category_model.dart';
import 'package:yummy/features/item_category/domain/entities/item_category_entity.dart';

class ItemCategoryMapper {
  static ItemCategoryEntity toEntity(ItemCategoryModel model) {
    return ItemCategoryEntity(
      id: model.id,
      name: model.name,
      restaurantId: model.restaurantId,
    );
  }
}
