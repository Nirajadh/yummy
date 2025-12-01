part of 'menu_item_form_bloc.dart';

class MenuItemFormState extends Equatable {
  final String? selectedCategory;

  const MenuItemFormState({this.selectedCategory});

  MenuItemFormState copyWith({String? selectedCategory}) {
    return MenuItemFormState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [selectedCategory];
}
