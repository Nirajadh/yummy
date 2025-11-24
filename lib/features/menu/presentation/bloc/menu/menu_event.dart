part of 'menu_bloc.dart';

sealed class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

class MenuRequested extends MenuEvent {
  const MenuRequested();
}

class MenuItemSaved extends MenuEvent {
  final MenuItemEntity item;

  const MenuItemSaved(this.item);

  @override
  List<Object?> get props => [item];
}
