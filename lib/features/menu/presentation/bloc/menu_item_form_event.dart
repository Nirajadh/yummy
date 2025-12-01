part of 'menu_item_form_bloc.dart';

abstract class MenuItemFormEvent extends Equatable {
  const MenuItemFormEvent();

  @override
  List<Object?> get props => [];
}

class MenuItemFormCategoryUpdated extends MenuItemFormEvent {
  final String? category;

  const MenuItemFormCategoryUpdated(this.category);

  @override
  List<Object?> get props => [category];
}
