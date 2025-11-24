import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/menu/domain/entities/menu_item_entity.dart';

class UpsertMenuItemUseCase {
  final RestaurantRepository repository;

  const UpsertMenuItemUseCase(this.repository);

  Future<void> call(MenuItemEntity item) {
    return repository.upsertMenuItem(item);
  }
}
