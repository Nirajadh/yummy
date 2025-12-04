part of 'create_order_bloc.dart';

abstract class CreateOrderEvent extends Equatable {
  const CreateOrderEvent();

  @override
  List<Object?> get props => [];
}

class CreateOrderSubmitted extends CreateOrderEvent {
  final OrderChannel channel;
  final List<OrderItemInput> items;
  final int? tableId;
  final int? groupId;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final List<OrderPaymentInput>? payments;

  const CreateOrderSubmitted({
    required this.channel,
    required this.items,
    this.tableId,
    this.groupId,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.payments,
  });

  @override
  List<Object?> get props => [
        channel,
        items,
        tableId,
        groupId,
        customerName,
        customerPhone,
        notes,
        payments,
      ];
}
