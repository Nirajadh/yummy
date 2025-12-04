part of 'add_order_items_bloc.dart';

abstract class AddOrderItemsEvent extends Equatable {
  const AddOrderItemsEvent();

  @override
  List<Object?> get props => [];
}

class AddOrderItemsSubmitted extends AddOrderItemsEvent {
  final int orderId;
  final List<OrderItemInput> items;

  const AddOrderItemsSubmitted({
    required this.orderId,
    required this.items,
  });

  @override
  List<Object?> get props => [orderId, items];
}
