import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yummy/features/admin/domain/usecases/get_admin_dashboard_snapshot_usecase.dart';
import 'package:yummy/features/dashboard/domain/entities/dashboard_snapshot.dart';

part 'admin_dashboard_event.dart';
part 'admin_dashboard_state.dart';

class AdminDashboardBloc
    extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final GetAdminDashboardSnapshotUseCase _getSnapshot;

  AdminDashboardBloc({required GetAdminDashboardSnapshotUseCase getSnapshot})
      : _getSnapshot = getSnapshot,
        super(const AdminDashboardState()) {
    on<AdminDashboardStarted>(_onStarted);
    on<AdminDashboardRefreshed>(_onStarted);
  }

  Future<void> _onStarted(
    AdminDashboardEvent event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(state.copyWith(status: AdminDashboardStatus.loading));
    try {
      final snapshot = await _getSnapshot();
      emit(
        state.copyWith(
          status: AdminDashboardStatus.success,
          snapshot: snapshot,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminDashboardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
