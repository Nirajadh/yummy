part of 'order_cart_bloc.dart';

class OrderCartState extends Equatable {
  final String selectedCategory;
  final Map<String, OrderCartItem> items;
  final bool sentToKitchen;

  const OrderCartState({
    this.selectedCategory = 'All',
    this.items = const {},
    this.sentToKitchen = false,
  });

  double get subtotal => items.values.fold(
        0,
        (total, item) => total + item.lineTotal,
      );

  bool get hasItems => items.isNotEmpty;

  OrderCartState copyWith({
    String? selectedCategory,
    Map<String, OrderCartItem>? items,
    bool? sentToKitchen,
  }) {
    return OrderCartState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      items: items ?? this.items,
      sentToKitchen: sentToKitchen ?? this.sentToKitchen,
    );
  }

  @override
  List<Object?> get props => [selectedCategory, items, sentToKitchen];
}

class OrderCartItem extends Equatable {
  final MenuItemEntity item;
  final int quantity;

  const OrderCartItem({required this.item, required this.quantity});

  double get lineTotal => item.price * quantity;

  OrderCartItem copyWith({MenuItemEntity? item, int? quantity}) {
    return OrderCartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [item, quantity];
}
