import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/core/services/restaurant_details_service.dart';
import 'package:yummy/features/item_category/domain/entities/item_category_entity.dart';
import 'package:yummy/features/item_category/domain/usecases/create_item_category_usecase.dart';
import 'package:yummy/features/item_category/domain/usecases/delete_item_category_usecase.dart';
import 'package:yummy/features/item_category/domain/usecases/get_item_categories_usecase.dart';
import 'package:yummy/features/item_category/domain/usecases/update_item_category_usecase.dart';

part 'item_category_event.dart';
part 'item_category_state.dart';

class ItemCategoryBloc extends Bloc<ItemCategoryEvent, ItemCategoryState> {
  ItemCategoryBloc({
    required this.getCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
    required this.restaurantDetailsService,
  }) : super(const ItemCategoryState()) {
    on<ItemCategoriesRequested>(_onLoadRequested);
    on<ItemCategoryCreated>(_onCreated);
    on<ItemCategoryUpdated>(_onUpdated);
    on<ItemCategoryDeleted>(_onDeleted);
  }

  final GetItemCategoriesUseCase getCategories;
  final CreateItemCategoryUseCase createCategory;
  final UpdateItemCategoryUseCase updateCategory;
  final DeleteItemCategoryUseCase deleteCategory;
  final RestaurantDetailsService restaurantDetailsService;

  Future<int?> _getRestaurantId() async {
    final details = await restaurantDetailsService.getDetails();
    return details.id;
  }

  Future<void> _onLoadRequested(
    ItemCategoriesRequested event,
    Emitter<ItemCategoryState> emit,
  ) async {
    emit(state.copyWith(status: ItemCategoryStatus.loading, message: null));
    final restaurantId = await _getRestaurantId();
    if (restaurantId == null || restaurantId == 0) {
      emit(
        state.copyWith(
          status: ItemCategoryStatus.failure,
          message: 'Restaurant not set. Complete restaurant setup first.',
        ),
      );
      return;
    }

    final result = await getCategories(restaurantId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ItemCategoryStatus.failure,
          message: failure.message,
        ),
      ),
      (categories) => emit(
        state.copyWith(
          status: ItemCategoryStatus.success,
          categories: categories,
          message: null,
        ),
      ),
    );
  }

  Future<void> _onCreated(
    ItemCategoryCreated event,
    Emitter<ItemCategoryState> emit,
  ) async {
    final restaurantId = await _getRestaurantId();
    if (restaurantId == null || restaurantId == 0) {
      emit(
        state.copyWith(
          message: 'Restaurant not set. Complete restaurant setup first.',
        ),
      );
      return;
    }
    emit(state.copyWith(submitting: true, message: null));
    final result = await createCategory(
      restaurantId: restaurantId,
      name: event.name,
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(submitting: false, message: failure.message)),
      (category) {
        final updated = List<ItemCategoryEntity>.from(state.categories)
          ..insert(0, category);
        emit(
          state.copyWith(
            submitting: false,
            categories: updated,
            message: 'Item category created',
            status: ItemCategoryStatus.success,
          ),
        );
      },
    );
  }

  Future<void> _onUpdated(
    ItemCategoryUpdated event,
    Emitter<ItemCategoryState> emit,
  ) async {
    emit(state.copyWith(submitting: true, message: null));
    final result = await updateCategory(id: event.id, name: event.name);
    result.fold(
      (failure) =>
          emit(state.copyWith(submitting: false, message: failure.message)),
      (category) {
        final updated = state.categories.map((c) {
          if (c.id == category.id) return category;
          return c;
        }).toList();
        emit(
          state.copyWith(
            submitting: false,
            categories: updated,
            message: 'Item category updated',
            status: ItemCategoryStatus.success,
          ),
        );
      },
    );
  }

  Future<void> _onDeleted(
    ItemCategoryDeleted event,
    Emitter<ItemCategoryState> emit,
  ) async {
    emit(state.copyWith(deletingId: event.id, message: null));
    final result = await deleteCategory(event.id);
    result.fold(
      (failure) =>
          emit(state.copyWith(deletingId: null, message: failure.message)),
      (_) {
        final updated = state.categories
            .where((category) => category.id != event.id)
            .toList();
        emit(
          state.copyWith(
            deletingId: null,
            categories: updated,
            message: 'Item category removed',
            status: ItemCategoryStatus.success,
          ),
        );
      },
    );
  }
}
