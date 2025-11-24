import 'package:equatable/equatable.dart';

class ActiveOrderEntity extends Equatable {
  final String id;
  final String type;
  final String reference;
  final double amount;
  final int itemsCount;
  final int guests;
  final String startedAt;
  final String status;
  final String channel;
  final String? contact;

  const ActiveOrderEntity({
    required this.id,
    required this.type,
    required this.reference,
    required this.amount,
    required this.itemsCount,
    required this.guests,
    required this.startedAt,
    required this.status,
    required this.channel,
    this.contact,
  });

  ActiveOrderEntity copyWith({
    String? id,
    String? type,
    String? reference,
    double? amount,
    int? itemsCount,
    int? guests,
    String? startedAt,
    String? status,
    String? channel,
    String? contact,
  }) {
    return ActiveOrderEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      reference: reference ?? this.reference,
      amount: amount ?? this.amount,
      itemsCount: itemsCount ?? this.itemsCount,
      guests: guests ?? this.guests,
      startedAt: startedAt ?? this.startedAt,
      status: status ?? this.status,
      channel: channel ?? this.channel,
      contact: contact ?? this.contact,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        reference,
        amount,
        itemsCount,
        guests,
        startedAt,
        status,
        channel,
        contact,
      ];
}
