import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yummy/features/menu/domain/entities/menu_item_entity.dart';
import 'package:yummy/features/menu/domain/usecases/get_menu_items_usecase.dart';
import 'package:yummy/features/menu/domain/usecases/upsert_menu_item_usecase.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetMenuItemsUseCase _getMenuItems;
  final UpsertMenuItemUseCase _upsertMenuItem;

  MenuBloc({
    required GetMenuItemsUseCase getMenuItems,
    required UpsertMenuItemUseCase upsertMenuItem,
  })  : _getMenuItems = getMenuItems,
        _upsertMenuItem = upsertMenuItem,
        super(const MenuState()) {
    on<MenuRequested>(_onRequested);
    on<MenuItemSaved>(_onSaved);
  }

  Future<void> _onRequested(
    MenuRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(state.copyWith(status: MenuStatus.loading));
    try {
      final items = await _getMenuItems();
      emit(state.copyWith(status: MenuStatus.success, items: items));
    } catch (e) {
      emit(
        state.copyWith(
          status: MenuStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSaved(
    MenuItemSaved event,
    Emitter<MenuState> emit,
  ) async {
    await _upsertMenuItem(event.item);
    add(const MenuRequested());
  }
}
