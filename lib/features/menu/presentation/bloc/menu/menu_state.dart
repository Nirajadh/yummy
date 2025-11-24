part of 'menu_bloc.dart';

enum MenuStatus { initial, loading, success, failure }

class MenuState extends Equatable {
  final MenuStatus status;
  final List<MenuItemEntity> items;
  final String? errorMessage;

  const MenuState({
    this.status = MenuStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  MenuState copyWith({
    MenuStatus? status,
    List<MenuItemEntity>? items,
    String? errorMessage,
  }) {
    return MenuState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
