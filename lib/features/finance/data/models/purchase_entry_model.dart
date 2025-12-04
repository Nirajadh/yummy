class PurchaseEntryModel {
  String? vendor;
  String? category;
  double? amount;
  String? date;
  String? reference;

  PurchaseEntryModel({
    this.vendor,
    this.category,
    this.amount,
    this.date,
    this.reference,
  });

  factory PurchaseEntryModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '');

    return PurchaseEntryModel(
      vendor: (json['vendor'] as String?)?.trim(),
      category: (json['category'] as String?)?.trim(),
      amount: amount,
      date: (json['date'] as String?)?.trim(),
      reference: (json['reference'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor': vendor,
      'category': category,
      'amount': amount,
      'date': date,
      'reference': reference,
    };
  }
}
