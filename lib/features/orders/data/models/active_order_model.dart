import 'package:yummy/features/orders/data/models/order_model.dart';

class ActiveOrderModel {
  String? id;
  String? type;
  String? reference;
  String? tableName;
  double? amount;
  int? itemsCount;
  int? guests;
  String? startedAt;
  String? status;
  String? channel;
  String? contact;
  int? tableId;
  List<OrderItemModel> items;

  ActiveOrderModel({
    this.id,
    this.type,
    this.reference,
    this.tableName,
    this.amount,
    this.itemsCount,
    this.guests,
    this.startedAt,
    this.status,
    this.channel,
    this.contact,
    this.tableId,
    this.items = const [],
  });

  factory ActiveOrderModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '');

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    return ActiveOrderModel(
      id: (json['id'] as String?)?.trim(),
      type: (json['type'] as String?)?.trim(),
      reference: (json['reference'] as String?)?.trim(),
      tableName: (json['table_name'] as String?)?.trim(),
      amount: amount,
      itemsCount: _parseInt(json['itemsCount']),
      guests: _parseInt(json['guests']),
      startedAt: (json['startedAt'] as String?)?.trim(),
      status: (json['status'] as String?)?.trim(),
      channel: (json['channel'] as String?)?.trim(),
      contact: (json['contact'] as String?)?.trim(),
      tableId: parseInt(json['table_id']),
      items: (json['items'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(OrderItemModel.fromJson)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'reference': reference,
      'table_name': tableName,
      'amount': amount,
      'itemsCount': itemsCount,
      'guests': guests,
      'startedAt': startedAt,
      'status': status,
      'channel': channel,
      'contact': contact,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
