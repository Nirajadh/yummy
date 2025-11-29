class RestaurantTableModel {
  final int id;
  final String tableName;
  final int capacity;
  final int restaurantId;
  final int tableTypeId;
  final String status;

  RestaurantTableModel({
    required this.id,
    required this.tableName,
    required this.capacity,
    required this.restaurantId,
    required this.tableTypeId,
    required this.status,
  });

  factory RestaurantTableModel.fromJson(Map<String, dynamic> json) {
    return RestaurantTableModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      tableName: (json['table_name'] ?? '').toString(),
      capacity: json['capacity'] is int
          ? json['capacity'] as int
          : int.tryParse('${json['capacity']}') ?? 0,
      restaurantId: json['restaurant_id'] is int
          ? json['restaurant_id'] as int
          : int.tryParse('${json['restaurant_id']}') ?? 0,
      tableTypeId: json['table_type_id'] is int
          ? json['table_type_id'] as int
          : int.tryParse('${json['table_type_id']}') ?? 0,
      status: (json['status'] ?? '').toString(),
    );
  }
}
