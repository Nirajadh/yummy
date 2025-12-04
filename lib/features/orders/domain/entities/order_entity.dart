import 'package:equatable/equatable.dart';
import 'package:yummy/features/orders/domain/entities/order_enums.dart';
import 'package:yummy/features/orders/domain/entities/order_item_entity.dart';

class OrderEntity extends Equatable {
  final int id;
  final int restaurantId;
  final OrderChannel channel;
  final int? tableId;
  final String? tableName;
  final int? groupId;
  final String? customerName;
  final String? customerPhone;
  final OrderStatus status;
  final double subtotal;
  final double taxTotal;
  final double serviceCharge;
  final double discountTotal;
  final double grandTotal;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  final String? completedAt;
  final String? canceledAt;
  final String? cancelReason;
  final List<OrderItemEntity> items;
  final List<OrderPaymentEntity> payments;

  const OrderEntity({
    required this.id,
    required this.restaurantId,
    required this.channel,
    required this.tableId,
    required this.tableName,
    required this.groupId,
    required this.customerName,
    required this.customerPhone,
    required this.status,
    required this.subtotal,
    required this.taxTotal,
    required this.serviceCharge,
    required this.discountTotal,
    required this.grandTotal,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.completedAt,
    required this.canceledAt,
    required this.cancelReason,
    required this.items,
    required this.payments,
  });

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        channel,
        tableId,
        tableName,
        groupId,
        customerName,
        customerPhone,
        status,
        subtotal,
        taxTotal,
        serviceCharge,
        discountTotal,
        grandTotal,
        notes,
        createdAt,
        updatedAt,
        completedAt,
        canceledAt,
        cancelReason,
        items,
        payments,
      ];
}
