part of 'staff_dashboard_bloc.dart';

abstract class StaffDashboardEvent extends Equatable {
  const StaffDashboardEvent();

  @override
  List<Object?> get props => [];
}

class StaffDashboardStarted extends StaffDashboardEvent {
  const StaffDashboardStarted();
}

class StaffDashboardRefreshed extends StaffDashboardEvent {
  const StaffDashboardRefreshed();
}
