import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yummy/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:yummy/features/dashboard/domain/usecases/get_dashboard_snapshot_usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSnapshotUseCase _getDashboardSnapshot;

  DashboardBloc({required GetDashboardSnapshotUseCase getDashboardSnapshot})
      : _getDashboardSnapshot = getDashboardSnapshot,
        super(const DashboardState()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardRefreshed>(_onStarted);
  }

  Future<void> _onStarted(
    DashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final snapshot = await _getDashboardSnapshot();
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          snapshot: snapshot,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
