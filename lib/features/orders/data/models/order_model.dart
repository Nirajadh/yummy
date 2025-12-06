import 'package:yummy/features/orders/domain/entities/order_enums.dart';
import 'package:yummy/features/orders/domain/entities/order_item_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_entity.dart';

class OrderModel {
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
  final List<OrderItemModel> items;
  final List<OrderPaymentModel> payments;

  OrderModel({
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    OrderStatus? status = OrderStatusX.fromApi(
      json['status']?.toString().toLowerCase(),
    );
    status ??= OrderStatus.pending;

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    final itemsData = json['items'];
    final paymentsData = json['payments'];

    // Infer channel when missing from API response.
    OrderChannel? channel = OrderChannelX.fromApi(
      json['channel']?.toString().toLowerCase(),
    );
    if (channel == null) {
      final hasTable = parseInt(json['table_id']) != null;
      final hasGroup = parseInt(json['group_id']) != null;
      channel = hasTable
          ? OrderChannel.table
          : hasGroup
          ? OrderChannel.group
          : OrderChannel.quickBilling;
    }

    return OrderModel(
      id: parseInt(json['id']) ?? 0,
      restaurantId: parseInt(json['restaurant_id']) ?? 0,
      channel: channel,
      tableId: parseInt(json['table_id']),
      tableName: json['table_name']?.toString(),
      groupId: parseInt(json['group_id']),
      customerName: json['customer_name']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      status: status,
      subtotal: parseDouble(json['subtotal']),
      taxTotal: parseDouble(json['tax_total']),
      serviceCharge: parseDouble(json['service_charge']),
      discountTotal: parseDouble(json['discount_total']),
      grandTotal: parseDouble(json['grand_total']),
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      completedAt: json['completed_at']?.toString(),
      canceledAt: json['canceled_at']?.toString(),
      cancelReason: json['cancel_reason']?.toString(),

      // Persist table/group ids even if channel missing.
      items: itemsData is List
          ? itemsData
                .whereType<Map<String, dynamic>>()
                .map(OrderItemModel.fromJson)
                .toList()
          : const <OrderItemModel>[],
      payments: paymentsData is List
          ? paymentsData
                .whereType<Map<String, dynamic>>()
                .map(OrderPaymentModel.fromJson)
                .toList()
          : const <OrderPaymentModel>[],
    );
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      restaurantId: restaurantId,
      channel: channel,
      tableId: tableId,
      tableName: tableName,
      groupId: groupId,
      customerName: customerName,
      customerPhone: customerPhone,
      status: status,
      subtotal: subtotal,
      taxTotal: taxTotal,
      serviceCharge: serviceCharge,
      discountTotal: discountTotal,
      grandTotal: grandTotal,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
      canceledAt: canceledAt,
      cancelReason: cancelReason,
      items: items.map((e) => e.toEntity()).toList(),
      payments: payments.map((e) => e.toEntity()).toList(),
    );
  }
}

class OrderItemModel {
  final int id;
  final int? menuItemId;
  final String name;
  final String? categoryName;
  final double unitPrice;
  final int qty;
  final double lineTotal;
  final String? notes;

  OrderItemModel({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.categoryName,
    required this.unitPrice,
    required this.qty,
    required this.lineTotal,
    this.notes,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    return OrderItemModel(
      id: parseInt(json['id']) ?? 0,
      menuItemId: parseInt(json['menu_item_id']),
      name: json['name_snapshot']?.toString() ?? '',
      categoryName: json['category_name_snapshot']?.toString(),
      unitPrice: parseDouble(json['unit_price']),
      qty: parseInt(json['qty']) ?? 0,
      lineTotal: parseDouble(json['line_total']),
      notes: json['notes']?.toString(),
    );
  }

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      id: id,
      menuItemId: menuItemId,
      name: name,
      categoryName: categoryName,
      unitPrice: unitPrice,
      qty: qty,
      lineTotal: lineTotal,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item_id': menuItemId,
      'name_snapshot': name,
      'category_name_snapshot': categoryName,
      'unit_price': unitPrice,
      'qty': qty,
      'line_total': lineTotal,
      'notes': notes,
    };
  }
}

class OrderPaymentModel {
  final int id;
  final PaymentMethod method;
  final double amount;
  final String? reference;
  final PaymentStatus status;
  final String createdAt;

  OrderPaymentModel({
    required this.id,
    required this.method,
    required this.amount,
    required this.reference,
    required this.status,
    required this.createdAt,
  });

  factory OrderPaymentModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int parseInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    PaymentMethod? method = PaymentMethodX.fromApi(
      json['method']?.toString().toLowerCase(),
    );
    method ??= PaymentMethod.cash;

    PaymentStatus? status = PaymentStatusX.fromApi(
      json['status']?.toString().toLowerCase(),
    );
    status ??= PaymentStatus.success;

    return OrderPaymentModel(
      id: parseInt(json['id']),
      method: method,
      amount: parseDouble(json['amount']),
      reference: json['reference']?.toString(),
      status: status,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  OrderPaymentEntity toEntity() {
    return OrderPaymentEntity(
      id: id,
      method: method,
      amount: amount,
      reference: reference,
      status: status,
      createdAt: createdAt,
    );
  }
}
