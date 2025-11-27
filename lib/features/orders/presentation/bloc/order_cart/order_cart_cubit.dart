import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yummy/features/menu/domain/entities/menu_item_entity.dart';

part 'order_cart_state.dart';

class OrderCartCubit extends Cubit<OrderCartState> {
  OrderCartCubit() : super(const OrderCartState());

  void selectCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void addItem(MenuItemEntity item) {
    final updated = Map<String, OrderCartItem>.from(state.items);
    final existing = updated[item.name];
    if (existing != null) {
      updated[item.name] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      updated[item.name] = OrderCartItem(item: item, quantity: 1);
    }
    emit(state.copyWith(items: updated, sentToKitchen: false));
  }

  void changeQuantity(String name, int delta) {
    final updated = Map<String, OrderCartItem>.from(state.items);
    final current = updated[name];
    if (current == null) return;
    final nextQty = current.quantity + delta;
    if (nextQty <= 0) {
      updated.remove(name);
    } else {
      updated[name] = current.copyWith(quantity: nextQty);
    }
    emit(state.copyWith(items: updated, sentToKitchen: false));
  }

  void markSentToKitchen() {
    emit(state.copyWith(sentToKitchen: true));
  }
}
