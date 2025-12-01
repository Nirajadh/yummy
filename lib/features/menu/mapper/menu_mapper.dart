import 'package:yummy/core/app_apis.dart';
import 'package:yummy/features/menu/data/models/menu_model.dart';
import 'package:yummy/features/menu/domain/entities/menu_item_entity.dart';

class MenuMapper {
  static MenuItemEntity toEntity(MenuModel model) {
    return MenuItemEntity(
      id: model.id,
      name: model.name,
      price: model.price,
      description: model.description,
      imageUrl: _resolveImage(model.image),
      restaurantId: model.restaurantId,
      itemCategoryId: model.itemCategoryId,
      categoryName: model.categoryName,
    );
  }

  static String _resolveImage(String image) {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    // If backend returns raw base64, wrap it into a data URI so Image.network
    // or other consumers can render it.
    if (_looksBase64(image)) {
      return 'data:image/jpeg;base64,$image';
    }
    final cleaned = image.startsWith('/') ? image.substring(1) : image;
    return '$baseUrl/$cleaned';
  }

  static bool _looksBase64(String value) {
    if (value.length < 16) return false;
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return base64Pattern.hasMatch(value.replaceAll('\n', '').replaceAll('\r', ''));
  }
}
