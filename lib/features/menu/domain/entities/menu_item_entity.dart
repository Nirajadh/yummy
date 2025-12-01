import 'package:equatable/equatable.dart';

class MenuItemEntity extends Equatable {
  final int? id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final int? restaurantId;
  final int? itemCategoryId;
  final String? categoryName;

  const MenuItemEntity({
    this.id,
    required this.name,
    required this.price,
    this.description = '',
    this.imageUrl = '',
    this.restaurantId,
    this.itemCategoryId,
    this.categoryName,
  });

  MenuItemEntity copyWith({
    int? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    int? restaurantId,
    int? itemCategoryId,
    String? categoryName,
  }) {
    return MenuItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      restaurantId: restaurantId ?? this.restaurantId,
      itemCategoryId: itemCategoryId ?? this.itemCategoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    description,
    imageUrl,
    restaurantId,
    itemCategoryId,
    categoryName,
  ];
}
