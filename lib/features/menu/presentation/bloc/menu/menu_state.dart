part of 'menu_bloc.dart';

enum MenuStatus { initial, loading, success, failure }

class MenuState extends Equatable {
  final MenuStatus status;
  final List<MenuItemEntity> items;
  final bool submitting;
  final int? deletingId;
  final String? message;

  const MenuState({
    this.status = MenuStatus.initial,
    this.items = const [],
    this.submitting = false,
    this.deletingId,
    this.message,
  });

  MenuState copyWith({
    MenuStatus? status,
    List<MenuItemEntity>? items,
    bool? submitting,
    int? deletingId,
    String? message,
  }) {
    return MenuState(
      status: status ?? this.status,
      items: items ?? this.items,
      submitting: submitting ?? this.submitting,
      deletingId: deletingId,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, items, submitting, deletingId, message];
}
