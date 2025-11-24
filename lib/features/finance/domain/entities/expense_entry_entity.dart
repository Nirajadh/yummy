import 'package:equatable/equatable.dart';

class ExpenseEntryEntity extends Equatable {
  final String category;
  final String vendor;
  final double amount;
  final String date;
  final String paymentMode;
  final String notes;

  const ExpenseEntryEntity({
    required this.category,
    required this.vendor,
    required this.amount,
    required this.date,
    required this.paymentMode,
    required this.notes,
  });

  @override
  List<Object?> get props =>
      [category, vendor, amount, date, paymentMode, notes];
}
