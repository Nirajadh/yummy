class OrderHistoryEntryModel {
  String? id;
  String? type;
  double? amount;
  String? status;
  String? timestamp;

  OrderHistoryEntryModel({
    this.id,
    this.type,
    this.amount,
    this.status,
    this.timestamp,
  });

  factory OrderHistoryEntryModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '');

    return OrderHistoryEntryModel(
      id: (json['id'] as String?)?.trim(),
      type: (json['type'] as String?)?.trim(),
      amount: amount,
      status: (json['status'] as String?)?.trim(),
      timestamp: (json['timestamp'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
