class ItemCategoryModel {
  final int id;
  final String name;
  final int restaurantId;

  ItemCategoryModel({
    required this.id,
    required this.name,
    required this.restaurantId,
  });

  factory ItemCategoryModel.fromJson(Map<String, dynamic> json) {
    return ItemCategoryModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? '').toString(),
      restaurantId: json['restaurant_id'] is int
          ? json['restaurant_id'] as int
          : int.tryParse('${json['restaurant_id']}') ?? 0,
    );
  }
}
