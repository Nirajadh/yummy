import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/menu/domain/entities/menu_item_entity.dart';

class GetMenuItemsUseCase {
  final RestaurantRepository repository;

  const GetMenuItemsUseCase(this.repository);

  Future<List<MenuItemEntity>> call() {
    return repository.getMenuItems();
  }
}
