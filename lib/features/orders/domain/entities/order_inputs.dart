import 'package:yummy/features/orders/domain/entities/order_enums.dart';

class OrderItemInput {
  final int menuItemId;
  final int qty;
  final String? notes;

  const OrderItemInput({
    required this.menuItemId,
    required this.qty,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'menu_item_id': menuItemId,
      'qty': qty,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

class OrderPaymentInput {
  final PaymentMethod method;
  final double amount;
  final String? reference;
  final PaymentStatus status;

  const OrderPaymentInput({
    required this.method,
    required this.amount,
    this.reference,
    this.status = PaymentStatus.success,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method.apiValue,
      'amount': amount,
      if (reference != null && reference!.isNotEmpty) 'reference': reference,
      if (status != PaymentStatus.success) 'status': status.apiValue,
    };
  }
}
