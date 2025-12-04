import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/core/services/restaurant_details_service.dart';
import 'package:yummy/features/orders/domain/entities/order_enums.dart';
import 'package:yummy/features/orders/domain/usecases/get_active_orders_usecase.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetActiveOrdersUseCase _getActiveOrders;
  final RestaurantDetailsService _restaurantDetailsService;

  OrdersBloc({
    required GetActiveOrdersUseCase getActiveOrders,
    required RestaurantDetailsService restaurantDetailsService,
  })  : _getActiveOrders = getActiveOrders,
        _restaurantDetailsService = restaurantDetailsService,
        super(const OrdersState()) {
    on<OrdersRequested>(_onRequested);
  }

  Future<void> _onRequested(
    OrdersRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(status: OrdersStatus.loading));
    final details = await _restaurantDetailsService.getDetails();
    final restaurantId = details.id;
    if (restaurantId == null || restaurantId == 0) {
      emit(
        state.copyWith(
          status: OrdersStatus.failure,
          errorMessage: 'Restaurant not set. Complete restaurant setup first.',
        ),
      );
      return;
    }

    final result = await _getActiveOrders(
      restaurantId: restaurantId,
      channel: _channelFromFilter(event.filter),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OrdersStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (orders) => emit(
        state.copyWith(
          status: OrdersStatus.success,
          orders: orders,
          errorMessage: null,
        ),
      ),
    );
  }

  OrderChannel? _channelFromFilter(String? filter) {
    switch ((filter ?? '').toLowerCase()) {
      case 'table':
        return OrderChannel.table;
      case 'group':
        return OrderChannel.group;
      case 'pickup':
        return OrderChannel.pickup;
      case 'quick billing':
      case 'quick_billing':
        return OrderChannel.quickBilling;
      case 'delivery':
        return OrderChannel.delivery;
      case 'online':
        return OrderChannel.online;
      default:
        return null;
    }
  }
}
