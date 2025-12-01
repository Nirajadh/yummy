part of 'item_category_bloc.dart';

abstract class ItemCategoryEvent extends Equatable {
  const ItemCategoryEvent();

  @override
  List<Object?> get props => [];
}

class ItemCategoriesRequested extends ItemCategoryEvent {
  const ItemCategoriesRequested();
}

class ItemCategoryCreated extends ItemCategoryEvent {
  final String name;

  const ItemCategoryCreated(this.name);

  @override
  List<Object?> get props => [name];
}

class ItemCategoryUpdated extends ItemCategoryEvent {
  final int id;
  final String name;

  const ItemCategoryUpdated({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class ItemCategoryDeleted extends ItemCategoryEvent {
  final int id;

  const ItemCategoryDeleted(this.id);

  @override
  List<Object?> get props => [id];
}
