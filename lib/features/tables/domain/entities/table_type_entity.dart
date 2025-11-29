import 'package:equatable/equatable.dart';

class TableTypeEntity extends Equatable {
  final int id;
  final String name;
  final int restaurantId;

  const TableTypeEntity({
    required this.id,
    required this.name,
    required this.restaurantId,
  });

  @override
  List<Object?> get props => [id, name, restaurantId];
}
