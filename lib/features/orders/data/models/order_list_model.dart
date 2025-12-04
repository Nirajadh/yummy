import 'package:yummy/features/orders/data/models/order_model.dart';

class OrderListModel {
  final List<OrderModel> orders;
  final int total;

  OrderListModel({required this.orders, required this.total});

  factory OrderListModel.fromJson(Map<String, dynamic> json) {
    final ordersRaw = json['orders'];
    final totalRaw = json['total'];
    final orders = ordersRaw is List
        ? ordersRaw
            .whereType<Map<String, dynamic>>()
            .map(OrderModel.fromJson)
            .toList()
        : <OrderModel>[];
    final total = totalRaw is num ? totalRaw.toInt() : 0;
    return OrderListModel(orders: orders, total: total);
  }
}
