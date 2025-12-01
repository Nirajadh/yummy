class MenuModel {
  final int id;
  final String name;
  final double price;
  final String description;
  final String image;
  final int restaurantId;
  final int? itemCategoryId;
  final String? categoryName;

  MenuModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.restaurantId,
    required this.itemCategoryId,
    this.categoryName,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    final priceRaw = json['price'];
    return MenuModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? '').toString(),
      price: priceRaw is num
          ? priceRaw.toDouble()
          : double.tryParse('$priceRaw') ?? 0,
      description: (json['description'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      restaurantId: json['restaurant_id'] is int
          ? json['restaurant_id'] as int
          : int.tryParse('${json['restaurant_id']}') ?? 0,
      itemCategoryId: json['item_category_id'] is int
          ? json['item_category_id'] as int
          : int.tryParse('${json['item_category_id']}'),
      categoryName: (json['category_name'] ?? '').toString().isNotEmpty
          ? (json['category_name'] ?? '').toString()
          : null,
    );
  }

  MenuModel copyWith({String? categoryName}) {
    return MenuModel(
      id: id,
      name: name,
      price: price,
      description: description,
      image: image,
      restaurantId: restaurantId,
      itemCategoryId: itemCategoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
