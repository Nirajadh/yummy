import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yummy/features/kitchen/domain/usecases/get_kitchen_kot_tickets_usecase.dart';
import 'package:yummy/features/kot/domain/entities/kot_ticket_entity.dart';

part 'kitchen_kot_event.dart';
part 'kitchen_kot_state.dart';

class KitchenKotBloc extends Bloc<KitchenKotEvent, KitchenKotState> {
  final GetKitchenKotTicketsUseCase _getTickets;

  KitchenKotBloc({required GetKitchenKotTicketsUseCase getTickets})
      : _getTickets = getTickets,
        super(const KitchenKotState()) {
    on<KitchenKotRequested>(_onRequested);
  }

  Future<void> _onRequested(
    KitchenKotEvent event,
    Emitter<KitchenKotState> emit,
  ) async {
    emit(state.copyWith(status: KitchenKotStatus.loading));
    try {
      final tickets = await _getTickets();
      emit(
        state.copyWith(
          status: KitchenKotStatus.success,
          tickets: tickets,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: KitchenKotStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
