part of 'add_order_items_bloc.dart';

enum AddOrderItemsStatus { initial, submitting, success, failure }

class AddOrderItemsState extends Equatable {
  final AddOrderItemsStatus status;
  final String? message;
  final OrderEntity? order;

  const AddOrderItemsState({
    this.status = AddOrderItemsStatus.initial,
    this.message,
    this.order,
  });

  AddOrderItemsState copyWith({
    AddOrderItemsStatus? status,
    String? message,
    OrderEntity? order,
  }) {
    return AddOrderItemsState(
      status: status ?? this.status,
      message: message,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [status, message, order];
}
