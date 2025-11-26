part of 'kitchen_kot_bloc.dart';

abstract class KitchenKotEvent extends Equatable {
  const KitchenKotEvent();

  @override
  List<Object?> get props => [];
}

class KitchenKotRequested extends KitchenKotEvent {
  const KitchenKotRequested();
}
