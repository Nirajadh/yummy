import 'package:equatable/equatable.dart';
import 'package:yummy/features/orders/domain/entities/order_item_entity.dart';

class ActiveOrderEntity extends Equatable {
  final String id;
  final String type;
  final String reference;
  final String? tableName;
  final double amount;
  final int itemsCount;
  final int guests;
  final String startedAt;
  final String status;
  final String channel;
  final String? contact;
  final int? tableId;
  final List<OrderItemEntity> items;

  const ActiveOrderEntity({
    required this.id,
    required this.type,
    required this.reference,
    this.tableName,
    required this.amount,
    required this.itemsCount,
    required this.guests,
    required this.startedAt,
    required this.status,
    required this.channel,
    this.contact,
    this.tableId,
    this.items = const [],
  });

  ActiveOrderEntity copyWith({
    String? id,
    String? type,
    String? reference,
    String? tableName,
    double? amount,
    int? itemsCount,
    int? guests,
    String? startedAt,
    String? status,
    String? channel,
    String? contact,
    int? tableId,
    List<OrderItemEntity>? items,
  }) {
    return ActiveOrderEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      reference: reference ?? this.reference,
      tableName: tableName ?? this.tableName,
      amount: amount ?? this.amount,
      itemsCount: itemsCount ?? this.itemsCount,
      guests: guests ?? this.guests,
      startedAt: startedAt ?? this.startedAt,
      status: status ?? this.status,
      channel: channel ?? this.channel,
      contact: contact ?? this.contact,
      tableId: tableId ?? this.tableId,
      items: items ?? this.items,
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
    tableId,
    tableName,
    items,
  ];
}
