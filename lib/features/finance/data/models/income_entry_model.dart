class IncomeEntryModel {
  String? source;
  double? amount;
  String? date;
  String? type;
  String? note;

  IncomeEntryModel({
    this.source,
    this.amount,
    this.date,
    this.type,
    this.note,
  });

  factory IncomeEntryModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '');

    return IncomeEntryModel(
      source: (json['source'] as String?)?.trim(),
      amount: amount,
      date: (json['date'] as String?)?.trim(),
      type: (json['type'] as String?)?.trim(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'amount': amount,
      'date': date,
      'type': type,
      'note': note,
    };
  }
}
