import 'package:equatable/equatable.dart';

class OrderHistoryEntryEntity extends Equatable {
  final String id;
  final String type;
  final double amount;
  final String status;
  final String timestamp;

  const OrderHistoryEntryEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, type, amount, status, timestamp];
}
