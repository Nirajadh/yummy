part of 'orders_bloc.dart';

enum OrdersStatus { initial, loading, success, failure }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<ActiveOrderEntity> orders;
  final String? errorMessage;
  final bool hasMore;
  final bool isLoadingMore;
  final String? activeFilter;
  final int pageSize;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.errorMessage,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.activeFilter,
    this.pageSize = 20,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    List<ActiveOrderEntity>? orders,
    String? errorMessage,
    bool? hasMore,
    bool? isLoadingMore,
    String? activeFilter,
    int? pageSize,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      activeFilter: activeFilter ?? this.activeFilter,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
        status,
        orders,
        errorMessage,
        hasMore,
        isLoadingMore,
        activeFilter,
        pageSize,
      ];
}
