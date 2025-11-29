import 'package:equatable/equatable.dart';

class TableEntity extends Equatable {
  final String name;
  final int capacity;
  final String status;
  final String notes;
  final List<String> activeItems;
  final List<String> pastOrders;
  final String? reservationName;
  final String category;

  const TableEntity({
    required this.name,
    required this.capacity,
    required this.status,
    this.category = 'General',
    this.notes = '',
    this.activeItems = const [],
    this.pastOrders = const [],
    this.reservationName,
  });

  TableEntity copyWith({
    String? name,
    int? capacity,
    String? status,
    String? category,
    String? notes,
    List<String>? activeItems,
    List<String>? pastOrders,
    String? reservationName,
  }) {
    return TableEntity(
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      category: category ?? this.category,
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
        notes,
        activeItems,
        pastOrders,
        reservationName,
      ];
}
