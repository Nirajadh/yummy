part of 'staff_dashboard_bloc.dart';

enum StaffDashboardStatus { initial, loading, success, failure }

class StaffDashboardState extends Equatable {
  final StaffDashboardStatus status;
  final DashboardSnapshot? snapshot;
  final List<ActiveOrderEntity> activeOrders;
  final String? errorMessage;

  const StaffDashboardState({
    this.status = StaffDashboardStatus.initial,
    this.snapshot,
    this.activeOrders = const [],
    this.errorMessage,
  });

  StaffDashboardState copyWith({
    StaffDashboardStatus? status,
    DashboardSnapshot? snapshot,
    List<ActiveOrderEntity>? activeOrders,
    String? errorMessage,
  }) {
    return StaffDashboardState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      activeOrders: activeOrders ?? this.activeOrders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, snapshot, activeOrders, errorMessage];
}
