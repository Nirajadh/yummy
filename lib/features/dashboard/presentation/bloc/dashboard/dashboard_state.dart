part of 'dashboard_bloc.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardSnapshot? snapshot;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.snapshot,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardSnapshot? snapshot,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, snapshot, errorMessage];
}
