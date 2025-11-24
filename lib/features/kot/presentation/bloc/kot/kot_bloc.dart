import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yummy/features/kot/domain/entities/kot_ticket_entity.dart';
import 'package:yummy/features/kot/domain/usecases/get_kot_tickets_usecase.dart';

part 'kot_event.dart';
part 'kot_state.dart';

class KotBloc extends Bloc<KotEvent, KotState> {
  final GetKotTicketsUseCase _getKotTicketsUseCase;

  KotBloc({required GetKotTicketsUseCase getKotTicketsUseCase})
      : _getKotTicketsUseCase = getKotTicketsUseCase,
        super(const KotState()) {
    on<KotRequested>(_onRequested);
  }

  Future<void> _onRequested(
    KotRequested event,
    Emitter<KotState> emit,
  ) async {
    emit(state.copyWith(status: KotStatus.loading));
    try {
      final tickets = await _getKotTicketsUseCase();
      emit(
        state.copyWith(
          status: KotStatus.success,
          tickets: tickets,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: KotStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
