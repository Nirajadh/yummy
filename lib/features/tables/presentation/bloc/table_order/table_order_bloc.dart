import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/core/services/restaurant_details_service.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/orders/domain/entities/bill_preview.dart';
import 'package:yummy/features/orders/domain/entities/order_enums.dart';

import 'package:yummy/features/orders/domain/usecases/get_active_orders_usecase.dart';
import 'package:yummy/features/tables/domain/entities/table_entity.dart';

part 'table_order_event.dart';
part 'table_order_state.dart';

class TableOrderBloc extends Bloc<TableOrderEvent, TableOrderState> {
  final GetActiveOrdersUseCase _getActiveOrders;
  final RestaurantDetailsService _restaurantDetailsService;

  TableOrderBloc({
    required GetActiveOrdersUseCase getActiveOrders,
    required RestaurantDetailsService restaurantDetailsService,
  }) : _getActiveOrders = getActiveOrders,
       _restaurantDetailsService = restaurantDetailsService,
       super(const TableOrderState()) {
    on<TableOrderStarted>(_onStarted);
    on<TableOrderCartUpdated>(_onCartUpdated);
    on<TableOrderStatusChanged>(_onStatusChanged);
    on<TableOrderTableUpdated>(_onTableUpdated);
  }

  Future<void> _onStarted(
    TableOrderStarted event,
    Emitter<TableOrderState> emit,
  ) async {
    final effectiveTableId =
        event.table?.id ?? event.tableId ?? state.tableId;
    final effectiveName =
        event.table?.name ?? event.tableName ?? state.tableName;

    emit(
      state.copyWith(
        table: event.table ?? state.table,
        tableId: effectiveTableId,
        tableName: effectiveName,
        status: TableOrderStatus.loading,
      ),
    );

    final details = await _restaurantDetailsService.getDetails();
    final restaurantId = details.id;
    if (restaurantId == null || restaurantId == 0) {
      emit(
        state.copyWith(
          status: TableOrderStatus.failure,
          errorMessage: 'Restaurant not set. Complete restaurant setup first.',
        ),
      );
      return;
    }

    final result = await _getActiveOrders(
      restaurantId: restaurantId,
      channel: OrderChannel.table,
      tableId: effectiveTableId,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TableOrderStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (orders) => emit(
        state.copyWith(
          status: TableOrderStatus.success,
          activeOrders: orders,
          errorMessage: null,
        ),
      ),
    );
  }

  void _onCartUpdated(
    TableOrderCartUpdated event,
    Emitter<TableOrderState> emit,
  ) {
    emit(state.copyWith(cartItems: event.items, lastMessage: event.message));
  }

  void _onStatusChanged(
    TableOrderStatusChanged event,
    Emitter<TableOrderState> emit,
  ) {
    final current = state.table;
    emit(
      state.copyWith(
        table:
            current?.copyWith(status: event.status) ??
            TableEntity(
              name: state.tableName ?? 'Table',
              status: event.status,
              capacity: current?.capacity ?? 0,
              category: current?.category ?? 'General',
              tableTypeId: current?.tableTypeId ?? 0,
              notes: current?.notes ?? '',
              activeItems: current?.activeItems ?? const [],
              pastOrders: current?.pastOrders ?? const [],
              reservationName: current?.reservationName,
              id: state.tableId,
            ),
        lastMessage: event.message,
      ),
    );
  }

  void _onTableUpdated(
    TableOrderTableUpdated event,
    Emitter<TableOrderState> emit,
  ) {
    emit(
      state.copyWith(
        table: event.table,
        tableId: event.table.id ?? state.tableId,
      ),
    );
  }
}
