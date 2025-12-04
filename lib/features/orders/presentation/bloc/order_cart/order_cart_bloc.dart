import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/menu/domain/entities/menu_item_entity.dart';

part 'order_cart_event.dart';
part 'order_cart_state.dart';

class OrderCartBloc extends Bloc<OrderCartEvent, OrderCartState> {
  OrderCartBloc() : super(const OrderCartState()) {
    on<OrderCartCategorySelected>(_onCategorySelected);
    on<OrderCartItemAdded>(_onItemAdded);
    on<OrderCartQuantityChanged>(_onQuantityChanged);
    on<OrderCartMarkedSent>(_onMarkedSent);
  }

  void _onCategorySelected(
    OrderCartCategorySelected event,
    Emitter<OrderCartState> emit,
  ) {
    emit(state.copyWith(selectedCategory: event.category));
  }

  void _onItemAdded(
    OrderCartItemAdded event,
    Emitter<OrderCartState> emit,
  ) {
    final updated = Map<String, OrderCartItem>.from(state.items);
    final existing = updated[event.item.name];
    if (existing != null) {
      updated[event.item.name] =
          existing.copyWith(quantity: existing.quantity + 1);
    } else {
      updated[event.item.name] =
          OrderCartItem(item: event.item, quantity: 1);
    }
    emit(state.copyWith(items: updated, sentToKitchen: false));
  }

  void _onQuantityChanged(
    OrderCartQuantityChanged event,
    Emitter<OrderCartState> emit,
  ) {
    final updated = Map<String, OrderCartItem>.from(state.items);
    final current = updated[event.name];
    if (current == null) return;
    final nextQty = current.quantity + event.delta;
    if (nextQty <= 0) {
      updated.remove(event.name);
    } else {
      updated[event.name] = current.copyWith(quantity: nextQty);
    }
    emit(state.copyWith(items: updated, sentToKitchen: false));
  }

  void _onMarkedSent(
    OrderCartMarkedSent event,
    Emitter<OrderCartState> emit,
  ) {
    emit(state.copyWith(sentToKitchen: true));
  }
}
