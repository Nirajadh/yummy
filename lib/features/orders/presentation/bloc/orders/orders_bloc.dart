import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/orders/domain/usecases/get_active_orders_usecase.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetActiveOrdersUseCase _getActiveOrders;

  OrdersBloc({required GetActiveOrdersUseCase getActiveOrders})
    : _getActiveOrders = getActiveOrders,
      super(const OrdersState()) {
    on<OrdersRequested>(_onRequested);
  }

  Future<void> _onRequested(
    OrdersRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(status: OrdersStatus.loading));
    try {
      final orders = await _getActiveOrders();
      emit(state.copyWith(status: OrdersStatus.success, orders: orders));
    } catch (e) {
      emit(
        state.copyWith(
          status: OrdersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
