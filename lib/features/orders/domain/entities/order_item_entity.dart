import 'package:equatable/equatable.dart';
import 'package:yummy/features/orders/domain/entities/order_enums.dart';

class OrderItemEntity extends Equatable {
  final int id;
  final int? menuItemId;
  final String name;
  final String? categoryName;
  final double unitPrice;
  final int qty;
  final double lineTotal;
  final String? notes;

  const OrderItemEntity({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.categoryName,
    required this.unitPrice,
    required this.qty,
    required this.lineTotal,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        menuItemId,
        name,
        categoryName,
        unitPrice,
        qty,
        lineTotal,
        notes,
      ];
}

class OrderPaymentEntity extends Equatable {
  final int id;
  final PaymentMethod method;
  final double amount;
  final String? reference;
  final PaymentStatus status;
  final String createdAt;

  const OrderPaymentEntity({
    required this.id,
    required this.method,
    required this.amount,
    required this.reference,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, method, amount, reference, status, createdAt];
}
