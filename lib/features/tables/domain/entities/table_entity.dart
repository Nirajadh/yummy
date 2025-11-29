import 'package:equatable/equatable.dart';

class TableEntity extends Equatable {
  final int? id;
  final String name;
  final int capacity;
  final String status;
  final String notes;
  final List<String> activeItems;
  final List<String> pastOrders;
  final String? reservationName;
  final String category;
  final int tableTypeId;

  const TableEntity({
    this.id,
    required this.name,
    required this.capacity,
    required this.status,
    this.category = 'General',
    this.tableTypeId = 0,
    this.notes = '',
    this.activeItems = const [],
    this.pastOrders = const [],
    this.reservationName,
  });

  TableEntity copyWith({
    int? id,
    String? name,
    int? capacity,
    String? status,
    String? category,
    int? tableTypeId,
    String? notes,
    List<String>? activeItems,
    List<String>? pastOrders,
    String? reservationName,
  }) {
    return TableEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      category: category ?? this.category,
      tableTypeId: tableTypeId ?? this.tableTypeId,
      notes: notes ?? this.notes,
      activeItems: activeItems ?? this.activeItems,
      pastOrders: pastOrders ?? this.pastOrders,
      reservationName: reservationName ?? this.reservationName,
    );
  }

  @override
  List<Object?> get props => [
        name,
        capacity,
        status,
        category,
        tableTypeId,
        id,
        notes,
        activeItems,
        pastOrders,
        reservationName,
      ];
}
