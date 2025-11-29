class TableOrderArgs {
  final String tableName;
  final String status;
  final int capacity;
  final String notes;
  final List<String> activeItems;
  final List<String> pastOrders;
  final String? reservationName;
  final String category;

  const TableOrderArgs({
    required this.tableName,
    required this.status,
    this.capacity = 0,
    this.category = 'General',
    this.notes = '',
    this.activeItems = const [],
    this.pastOrders = const [],
    this.reservationName,
  });
}
