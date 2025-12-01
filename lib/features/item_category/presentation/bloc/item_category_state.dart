part of 'item_category_bloc.dart';

enum ItemCategoryStatus { initial, loading, success, failure }

class ItemCategoryState extends Equatable {
  final ItemCategoryStatus status;
  final List<ItemCategoryEntity> categories;
  final bool submitting;
  final int? deletingId;
  final String? message;

  const ItemCategoryState({
    this.status = ItemCategoryStatus.initial,
    this.categories = const [],
    this.submitting = false,
    this.deletingId,
    this.message,
  });

  ItemCategoryState copyWith({
    ItemCategoryStatus? status,
    List<ItemCategoryEntity>? categories,
    bool? submitting,
    int? deletingId,
    String? message,
  }) {
    return ItemCategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      submitting: submitting ?? this.submitting,
      deletingId: deletingId,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    categories,
    submitting,
    deletingId,
    message,
  ];
}
