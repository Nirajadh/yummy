import 'package:yummy/features/common/data/dummy_data.dart' as dummy;

class MenuItemModel {
  String? name;
  String? category;
  double? price;
  String? description;
  String? imageUrl;

  MenuItemModel({
    this.name,
    this.category,
    this.price,
    this.description,
    this.imageUrl,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    final price = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '');

    return MenuItemModel(
      name: (json['name'] as String?)?.trim(),
      category: (json['category'] as String?)?.trim(),
      price: price,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  factory MenuItemModel.fromDummy(dummy.MenuItemModel item) {
    return MenuItemModel(
      name: item.name,
      category: item.category,
      price: item.price,
      description: item.description,
      imageUrl: item.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  MenuItemModel copyWith({
    String? name,
    String? category,
    double? price,
    String? description,
    String? imageUrl,
  }) {
    return MenuItemModel(
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
