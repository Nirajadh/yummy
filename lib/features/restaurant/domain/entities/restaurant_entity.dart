import 'package:equatable/equatable.dart';

class RestaurantEntity extends Equatable {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String? description;

  const RestaurantEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, address, phone, description];
}
