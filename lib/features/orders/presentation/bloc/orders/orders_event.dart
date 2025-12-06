part of 'orders_bloc.dart';

sealed class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class OrdersRequested extends OrdersEvent {
  final String? filter;
  const OrdersRequested({this.filter});

  @override
  List<Object?> get props => [filter];
}

class OrdersNextPage extends OrdersEvent {
  const OrdersNextPage();
}
