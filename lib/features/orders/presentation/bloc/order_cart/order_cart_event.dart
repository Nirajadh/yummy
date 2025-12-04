part of 'order_cart_bloc.dart';

abstract class OrderCartEvent extends Equatable {
  const OrderCartEvent();

  @override
  List<Object?> get props => [];
}

class OrderCartCategorySelected extends OrderCartEvent {
  final String category;
  const OrderCartCategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

class OrderCartItemAdded extends OrderCartEvent {
  final MenuItemEntity item;
  const OrderCartItemAdded(this.item);

  @override
  List<Object?> get props => [item];
}

class OrderCartQuantityChanged extends OrderCartEvent {
  final String name;
  final int delta;
  const OrderCartQuantityChanged(this.name, this.delta);

  @override
  List<Object?> get props => [name, delta];
}

class OrderCartMarkedSent extends OrderCartEvent {
  const OrderCartMarkedSent();
}
