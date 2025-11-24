import 'package:equatable/equatable.dart';

class PurchaseEntryEntity extends Equatable {
  final String vendor;
  final String category;
  final double amount;
  final String date;
  final String reference;

  const PurchaseEntryEntity({
    required this.vendor,
    required this.category,
    required this.amount,
    required this.date,
    required this.reference,
  });

  @override
  List<Object?> get props => [vendor, category, amount, date, reference];
}
