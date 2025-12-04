part of 'create_order_bloc.dart';

enum CreateOrderStatus { initial, submitting, success, failure }

class CreateOrderState extends Equatable {
  final CreateOrderStatus status;
  final OrderEntity? order;
  final String? message;

  const CreateOrderState({
    this.status = CreateOrderStatus.initial,
    this.order,
    this.message,
  });

  CreateOrderState copyWith({
    CreateOrderStatus? status,
    OrderEntity? order,
    String? message,
  }) {
    return CreateOrderState(
      status: status ?? this.status,
      order: order ?? this.order,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, order, message];
}
