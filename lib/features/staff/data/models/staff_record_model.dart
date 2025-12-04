class StaffRecordModel {
  String? staffName;
  String? type;
  double? amount;
  String? date;
  String? note;

  StaffRecordModel({
    this.staffName,
    this.type,
    this.amount,
    this.date,
    this.note,
  });

  factory StaffRecordModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '');

    return StaffRecordModel(
      staffName: (json['staffName'] as String?)?.trim(),
      type: (json['type'] as String?)?.trim(),
      amount: amount,
      date: (json['date'] as String?)?.trim(),
      note: (json['note'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffName': staffName,
      'type': type,
      'amount': amount,
      'date': date,
      'note': note,
    };
  }
}
