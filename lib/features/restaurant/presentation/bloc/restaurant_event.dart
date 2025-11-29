part of 'restaurant_bloc.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => [];
}

class RestaurantSubmitted extends RestaurantEvent {
  final String name;
  final String address;
  final String phone;
  final String? description;

  const RestaurantSubmitted({
    required this.name,
    required this.address,
    required this.phone,
    this.description,
  });

  @override
  List<Object?> get props => [name, address, phone, description];
}

class RestaurantUpdated extends RestaurantEvent {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String? description;

  const RestaurantUpdated({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, address, phone, description];
}
