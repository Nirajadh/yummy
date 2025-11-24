import 'package:equatable/equatable.dart';

class IncomeEntryEntity extends Equatable {
  final String source;
  final double amount;
  final String date;
  final String type;
  final String note;

  const IncomeEntryEntity({
    required this.source,
    required this.amount,
    required this.date,
    required this.type,
    required this.note,
  });

  @override
  List<Object?> get props => [source, amount, date, type, note];
}
