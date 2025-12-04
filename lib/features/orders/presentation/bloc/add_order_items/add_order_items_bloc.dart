import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/orders/domain/entities/order_entity.dart';
import 'package:yummy/features/orders/domain/entities/order_inputs.dart';
import 'package:yummy/features/orders/domain/usecases/add_order_items_usecase.dart';

part 'add_order_items_event.dart';
part 'add_order_items_state.dart';

class AddOrderItemsBloc
    extends Bloc<AddOrderItemsEvent, AddOrderItemsState> {
  AddOrderItemsBloc({required AddOrderItemsUseCase addItems})
      : _addItems = addItems,
        super(const AddOrderItemsState()) {
    on<AddOrderItemsSubmitted>(_onSubmitted);
  }

  final AddOrderItemsUseCase _addItems;

  Future<void> _onSubmitted(
    AddOrderItemsSubmitted event,
    Emitter<AddOrderItemsState> emit,
  ) async {
    emit(state.copyWith(status: AddOrderItemsStatus.submitting, message: null));

    if (event.items.isEmpty) {
      emit(
        state.copyWith(
          status: AddOrderItemsStatus.failure,
          message: 'Add at least one item.',
        ),
      );
      return;
    }

    final result = await _addItems(orderId: event.orderId, items: event.items);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AddOrderItemsStatus.failure,
          message: failure.message,
        ),
      ),
      (order) => emit(
        state.copyWith(
          status: AddOrderItemsStatus.success,
          order: order,
          message: 'Items added to order',
        ),
      ),
    );
  }
}
