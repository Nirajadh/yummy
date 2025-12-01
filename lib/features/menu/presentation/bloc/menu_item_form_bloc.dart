import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'menu_item_form_event.dart';
part 'menu_item_form_state.dart';

class MenuItemFormBloc extends Bloc<MenuItemFormEvent, MenuItemFormState> {
  MenuItemFormBloc({String? initialCategory})
    : super(MenuItemFormState(selectedCategory: initialCategory)) {
    on<MenuItemFormCategoryUpdated>(
      (event, emit) => emit(state.copyWith(selectedCategory: event.category)),
    );
  }
}
