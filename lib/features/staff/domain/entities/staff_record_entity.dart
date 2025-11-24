import 'package:equatable/equatable.dart';

class StaffRecordEntity extends Equatable {
  final String staffName;
  final String type;
  final double amount;
  final String date;
  final String note;

  const StaffRecordEntity({
    required this.staffName,
    required this.type,
    required this.amount,
    required this.date,
    required this.note,
  });

  @override
  List<Object?> get props => [staffName, type, amount, date, note];
}
