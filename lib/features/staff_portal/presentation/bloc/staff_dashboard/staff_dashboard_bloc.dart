import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:yummy/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/staff_portal/domain/usecases/get_staff_active_orders_usecase.dart';
import 'package:yummy/features/staff_portal/domain/usecases/get_staff_dashboard_snapshot_usecase.dart';

part 'staff_dashboard_event.dart';
part 'staff_dashboard_state.dart';

class StaffDashboardBloc
    extends Bloc<StaffDashboardEvent, StaffDashboardState> {
  final GetStaffDashboardSnapshotUseCase _getSnapshot;
  final GetStaffActiveOrdersUseCase _getActiveOrders;

  StaffDashboardBloc({
    required GetStaffDashboardSnapshotUseCase getSnapshot,
    required GetStaffActiveOrdersUseCase getActiveOrders,
  })  : _getSnapshot = getSnapshot,
        _getActiveOrders = getActiveOrders,
        super(const StaffDashboardState()) {
    on<StaffDashboardStarted>(_onStarted);
    on<StaffDashboardRefreshed>(_onStarted);
  }

  Future<void> _onStarted(
    StaffDashboardEvent event,
    Emitter<StaffDashboardState> emit,
  ) async {
    emit(state.copyWith(status: StaffDashboardStatus.loading));
    try {
      final snapshot = await _getSnapshot();
      final activeOrders = await _getActiveOrders();
      emit(
        state.copyWith(
          status: StaffDashboardStatus.success,
          snapshot: snapshot,
          activeOrders: activeOrders,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: StaffDashboardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
