import 'package:equatable/equatable.dart';

class KotTicketEntity extends Equatable {
  final String id;
  final String type;
  final String reference;
  final List<String> items;
  final String time;
  final String status;

  const KotTicketEntity({
    required this.id,
    required this.type,
    required this.reference,
    required this.items,
    required this.time,
    this.status = 'Pending',
  });

  @override
  List<Object?> get props => [id, type, reference, items, time, status];
}
