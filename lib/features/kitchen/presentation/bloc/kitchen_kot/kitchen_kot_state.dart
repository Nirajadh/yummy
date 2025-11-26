part of 'kitchen_kot_bloc.dart';

enum KitchenKotStatus { initial, loading, success, failure }

class KitchenKotState extends Equatable {
  final KitchenKotStatus status;
  final List<KotTicketEntity> tickets;
  final String? errorMessage;

  const KitchenKotState({
    this.status = KitchenKotStatus.initial,
    this.tickets = const [],
    this.errorMessage,
  });

  KitchenKotState copyWith({
    KitchenKotStatus? status,
    List<KotTicketEntity>? tickets,
    String? errorMessage,
  }) {
    return KitchenKotState(
      status: status ?? this.status,
      tickets: tickets ?? this.tickets,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tickets, errorMessage];
}
