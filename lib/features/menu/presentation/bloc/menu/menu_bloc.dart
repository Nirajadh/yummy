import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/core/services/restaurant_details_service.dart';
import 'package:yummy/features/menu/domain/entities/menu_item_entity.dart';
import 'package:yummy/features/menu/domain/usecases/create_menu_usecase.dart';
import 'package:yummy/features/menu/domain/usecases/delete_menu_usecase.dart';
import 'package:yummy/features/menu/domain/usecases/get_menus_by_restaurant_usecase.dart';
import 'package:yummy/features/menu/domain/usecases/update_menu_usecase.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetMenusByRestaurantUseCase _getMenus;
  final CreateMenuUseCase _createMenu;
  final UpdateMenuUseCase _updateMenu;
  final DeleteMenuUseCase _deleteMenu;
  final RestaurantDetailsService _restaurantDetailsService;

  MenuBloc({
    required GetMenusByRestaurantUseCase getMenus,
    required CreateMenuUseCase createMenu,
    required UpdateMenuUseCase updateMenu,
    required DeleteMenuUseCase deleteMenu,
    required RestaurantDetailsService restaurantDetailsService,
  }) : _getMenus = getMenus,
       _createMenu = createMenu,
       _updateMenu = updateMenu,
       _deleteMenu = deleteMenu,
       _restaurantDetailsService = restaurantDetailsService,
       super(const MenuState()) {
    on<MenuRequested>(_onRequested);
    on<MenuItemCreated>(_onCreated);
    on<MenuItemUpdated>(_onUpdated);
    on<MenuItemDeleted>(_onDeleted);
  }

  Future<int?> _restaurantId() async {
    final details = await _restaurantDetailsService.getDetails();
    return details.id;
  }

  Future<void> _onRequested(
    MenuRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(state.copyWith(status: MenuStatus.loading, message: null));
    final restaurantId = await _restaurantId();
    if (restaurantId == null || restaurantId == 0) {
      emit(
        state.copyWith(
          status: MenuStatus.failure,
          message: 'Restaurant not set. Complete restaurant setup first.',
        ),
      );
      return;
    }
    final result = await _getMenus(
      restaurantId: restaurantId,
      itemCategoryId: event.itemCategoryId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: MenuStatus.failure, message: failure.message),
      ),
      (items) => emit(
        state.copyWith(status: MenuStatus.success, items: items, message: null),
      ),
    );
  }

  Future<void> _onCreated(
    MenuItemCreated event,
    Emitter<MenuState> emit,
  ) async {
    emit(state.copyWith(submitting: true, message: null));
    final restaurantId = await _restaurantId();
    if (restaurantId == null || restaurantId == 0) {
      emit(
        state.copyWith(
          submitting: false,
          message: 'Restaurant not set. Complete restaurant setup first.',
        ),
      );
      return;
    }

    final result = await _createMenu(
      restaurantId: restaurantId,
      name: event.name,
      price: event.price,
      itemCategoryId: event.itemCategoryId,
      description: event.description,
      imagePath: event.imagePath,
    );

    result.fold(
      (failure) =>
          emit(state.copyWith(submitting: false, message: failure.message)),
      (created) {
        final enriched = created.copyWith(
          categoryName:
              event.categoryName ??
              created.categoryName ??
              _categoryLabel(created),
        );
        final updated = List<MenuItemEntity>.from(state.items)
          ..insert(0, enriched);
        emit(
          state.copyWith(
            submitting: false,
            items: updated,
            message: 'Menu item created',
            status: MenuStatus.success,
          ),
        );
      },
    );
  }

  Future<void> _onUpdated(
    MenuItemUpdated event,
    Emitter<MenuState> emit,
  ) async {
    emit(state.copyWith(submitting: true, message: null));
    final result = await _updateMenu(
      id: event.id,
      name: event.name,
      price: event.price,
      itemCategoryId: event.itemCategoryId,
      description: event.description,
      imagePath: event.imagePath,
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(submitting: false, message: failure.message)),
      (updatedItem) {
        final enriched = updatedItem.copyWith(
          categoryName:
              event.categoryName ??
              updatedItem.categoryName ??
              _categoryLabel(updatedItem),
        );
        final updated = state.items.map((item) {
          if (item.id == enriched.id) return enriched;
          return item;
        }).toList();
        emit(
          state.copyWith(
            submitting: false,
            items: updated,
            message: 'Menu item updated',
            status: MenuStatus.success,
          ),
        );
      },
    );
  }

  Future<void> _onDeleted(
    MenuItemDeleted event,
    Emitter<MenuState> emit,
  ) async {
    emit(state.copyWith(deletingId: event.id, message: null));
    final result = await _deleteMenu(event.id);
    result.fold(
      (failure) =>
          emit(state.copyWith(deletingId: null, message: failure.message)),
      (_) {
        final updated = state.items
            .where((item) => item.id != event.id)
            .toList();
        emit(
          state.copyWith(
            deletingId: null,
            items: updated,
            message: 'Menu item deleted',
            status: MenuStatus.success,
          ),
        );
      },
    );
  }

  String _categoryLabel(MenuItemEntity item) {
    if ((item.categoryName ?? '').isNotEmpty) return item.categoryName!;
    if (item.itemCategoryId != null) {
      return 'Category ${item.itemCategoryId}';
    }
    return 'Uncategorized';
  }
}
