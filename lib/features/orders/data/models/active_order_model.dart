import 'package:yummy/features/common/data/dummy_data.dart' as dummy;

class ActiveOrderModel {
  String? id;
  String? type;
  String? reference;
  double? amount;
  int? itemsCount;
  int? guests;
  String? startedAt;
  String? status;
  String? channel;
  String? contact;

  ActiveOrderModel({
    this.id,
    this.type,
    this.reference,
    this.amount,
    this.itemsCount,
    this.guests,
    this.startedAt,
    this.status,
    this.channel,
    this.contact,
  });

  factory ActiveOrderModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '');

    return ActiveOrderModel(
      id: (json['id'] as String?)?.trim(),
      type: (json['type'] as String?)?.trim(),
      reference: (json['reference'] as String?)?.trim(),
      amount: amount,
      itemsCount: _parseInt(json['itemsCount']),
      guests: _parseInt(json['guests']),
      startedAt: (json['startedAt'] as String?)?.trim(),
      status: (json['status'] as String?)?.trim(),
      channel: (json['channel'] as String?)?.trim(),
      contact: (json['contact'] as String?)?.trim(),
    );
  }

  factory ActiveOrderModel.fromDummy(dummy.ActiveOrder order) {
    return ActiveOrderModel(
      id: order.id,
      type: order.type,
      reference: order.reference,
      amount: order.amount,
      itemsCount: order.itemsCount,
      guests: order.guests,
      startedAt: order.startedAt,
      status: order.status,
      channel: order.channel,
      contact: order.contact,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'reference': reference,
      'amount': amount,
      'itemsCount': itemsCount,
      'guests': guests,
      'startedAt': startedAt,
      'status': status,
      'channel': channel,
      'contact': contact,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
