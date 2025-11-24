part of 'kot_bloc.dart';

enum KotStatus { initial, loading, success, failure }

class KotState extends Equatable {
  final KotStatus status;
  final List<KotTicketEntity> tickets;
  final String? errorMessage;

  const KotState({
    this.status = KotStatus.initial,
    this.tickets = const [],
    this.errorMessage,
  });

  KotState copyWith({
    KotStatus? status,
    List<KotTicketEntity>? tickets,
    String? errorMessage,
  }) {
    return KotState(
      status: status ?? this.status,
      tickets: tickets ?? this.tickets,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tickets, errorMessage];
}
