part of 'kot_bloc.dart';

sealed class KotEvent extends Equatable {
  const KotEvent();

  @override
  List<Object?> get props => [];
}

class KotRequested extends KotEvent {
  const KotRequested();
}
