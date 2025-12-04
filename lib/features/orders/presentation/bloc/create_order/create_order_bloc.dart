import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/core/services/restaurant_details_service.dart';
import 'package:yummy/features/orders/domain/entities/order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_enums.dart';
import 'package:yummy/features/orders/domain/entities/order_inputs.dart';
import 'package:yummy/features/orders/domain/usecases/create_order_usecase.dart';

part 'create_order_event.dart';
part 'create_order_state.dart';

class CreateOrderBloc extends Bloc<CreateOrderEvent, CreateOrderState> {
  CreateOrderBloc({
    required CreateOrderUseCase createOrder,
    required RestaurantDetailsService restaurantDetailsService,
  })  : _createOrder = createOrder,
        _restaurantDetailsService = restaurantDetailsService,
        super(const CreateOrderState()) {
    on<CreateOrderSubmitted>(_onSubmitted);
  }

  final CreateOrderUseCase _createOrder;
  final RestaurantDetailsService _restaurantDetailsService;

  Future<int?> _getRestaurantId() async {
    final details = await _restaurantDetailsService.getDetails();
    return details.id;
  }

  Future<void> _onSubmitted(
    CreateOrderSubmitted event,
    Emitter<CreateOrderState> emit,
  ) async {
    emit(state.copyWith(status: CreateOrderStatus.submitting, message: null));

    if (event.channel == OrderChannel.table &&
        (event.tableId == null || event.tableId == 0)) {
      emit(
        state.copyWith(
          status: CreateOrderStatus.failure,
          message: 'Table ID is required for table orders.',
        ),
      );
      return;
    }

    final restaurantId = await _getRestaurantId();
    if (restaurantId == null || restaurantId == 0) {
      emit(
        state.copyWith(
          status: CreateOrderStatus.failure,
          message: 'Restaurant not set. Complete restaurant setup first.',
        ),
      );
      return;
    }

    final result = await _createOrder(
      restaurantId: restaurantId,
      channel: event.channel,
      items: event.items,
      tableId: event.tableId,
      groupId: event.groupId,
      customerName: event.customerName,
      customerPhone: event.customerPhone,
      notes: event.notes,
      payments: event.payments,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CreateOrderStatus.failure,
          message: failure.message,
        ),
      ),
      (order) => emit(
        state.copyWith(
          status: CreateOrderStatus.success,
          order: order,
          message: 'Order created',
        ),
      ),
    );
  }
}
