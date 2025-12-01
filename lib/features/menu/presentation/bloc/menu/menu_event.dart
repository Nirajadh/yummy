part of 'menu_bloc.dart';

sealed class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class MenuRequested extends MenuEvent {
  final int? itemCategoryId;

  const MenuRequested({this.itemCategoryId});

  @override
  List<Object?> get props => [itemCategoryId];
}

class MenuItemCreated extends MenuEvent {
  final String name;
  final double price;
  final int itemCategoryId;
  final String? categoryName;
  final String? description;
  final String? imagePath;

  const MenuItemCreated({
    required this.name,
    required this.price,
    required this.itemCategoryId,
    this.categoryName,
    this.description,
    this.imagePath,
  });

  @override
  List<Object?> get props => [
    name,
    price,
    itemCategoryId,
    categoryName,
    description,
    imagePath,
  ];
}

class MenuItemUpdated extends MenuEvent {
  final int id;
  final String? name;
  final double? price;
  final int? itemCategoryId;
  final String? categoryName;
  final String? description;
  final String? imagePath;

  const MenuItemUpdated({
    required this.id,
    this.name,
    this.price,
    this.itemCategoryId,
    this.categoryName,
    this.description,
    this.imagePath,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    itemCategoryId,
    categoryName,
    description,
    imagePath,
  ];
}

class MenuItemDeleted extends MenuEvent {
  final int id;

  const MenuItemDeleted(this.id);

  @override
  List<Object?> get props => [id];
}
