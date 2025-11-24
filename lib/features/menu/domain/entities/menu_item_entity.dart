import 'package:equatable/equatable.dart';

class MenuItemEntity extends Equatable {
  final String name;
  final String category;
  final double price;
  final String description;
  final String imageUrl;

  const MenuItemEntity({
    required this.name,
    required this.category,
    required this.price,
    this.description = '',
    this.imageUrl = '',
  });

  MenuItemEntity copyWith({
    String? name,
    String? category,
    double? price,
    String? description,
    String? imageUrl,
  }) {
    return MenuItemEntity(
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [name, category, price, description, imageUrl];
}
