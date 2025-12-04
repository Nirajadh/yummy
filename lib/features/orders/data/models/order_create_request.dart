import 'package:yummy/features/orders/domain/entities/order_enums.dart';
import 'package:yummy/features/orders/domain/entities/order_inputs.dart';

class OrderCreateRequest {
  final int restaurantId;
  final OrderChannel channel;
  final int? tableId;
  final int? groupId;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final List<OrderItemInput> items;
  final List<OrderPaymentInput>? payments;

  const OrderCreateRequest({
    required this.restaurantId,
    required this.channel,
    required this.items,
    this.tableId,
    this.groupId,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.payments,
  });

  Map<String, dynamic> toJson() {
    return {
      'restaurant_id': restaurantId,
      'channel': channel.apiValue,
      if (tableId != null) 'table_id': tableId,
      if (groupId != null) 'group_id': groupId,
      if (customerName != null && customerName!.isNotEmpty)
        'customer_name': customerName,
      if (customerPhone != null && customerPhone!.isNotEmpty)
        'customer_phone': customerPhone,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'items': items.map((e) => e.toJson()).toList(),
      if (payments != null && payments!.isNotEmpty)
        'payments': payments!.map((e) => e.toJson()).toList(),
    };
  }
}
