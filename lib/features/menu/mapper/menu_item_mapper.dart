import 'package:yummy/features/menu/data/models/menu_item_model.dart';
import 'package:yummy/features/menu/domain/entities/menu_item_entity.dart';

class MenuItemMapper {
  static MenuItemEntity toEntity(MenuItemModel model) {
    return MenuItemEntity(
      name: model.name ?? '',
      category: model.category ?? '',
      price: model.price ?? 0,
      description: model.description ?? '',
      imageUrl: model.imageUrl ?? '',
    );
  }

  static MenuItemModel fromEntity(MenuItemEntity entity) {
    return MenuItemModel(
      name: entity.name,
      category: entity.category,
      price: entity.price,
      description: entity.description,
      imageUrl: entity.imageUrl,
    );
  }
}
