import 'package:yummy/features/common/data/dummy_data.dart' as dummy;

class ExpenseEntryModel {
  String? category;
  String? vendor;
  double? amount;
  String? date;
  String? paymentMode;
  String? notes;

  ExpenseEntryModel({
    this.category,
    this.vendor,
    this.amount,
    this.date,
    this.paymentMode,
    this.notes,
  });

  factory ExpenseEntryModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '');

    return ExpenseEntryModel(
      category: (json['category'] as String?)?.trim(),
      vendor: (json['vendor'] as String?)?.trim(),
      amount: amount,
      date: (json['date'] as String?)?.trim(),
      paymentMode: (json['paymentMode'] as String?)?.trim(),
      notes: json['notes'] as String?,
    );
  }

  factory ExpenseEntryModel.fromDummy(dummy.ExpenseEntry entry) {
    return ExpenseEntryModel(
      category: entry.category,
      vendor: entry.vendor,
      amount: entry.amount,
      date: entry.date,
      paymentMode: entry.paymentMode,
      notes: entry.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'vendor': vendor,
      'amount': amount,
      'date': date,
      'paymentMode': paymentMode,
      'notes': notes,
    };
  }
}
