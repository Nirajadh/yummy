import 'package:equatable/equatable.dart';

class GroupPersonEntity extends Equatable {
  final String name;
  final String? phone;
  final String? email;

  const GroupPersonEntity({
    required this.name,
    this.phone,
    this.email,
  });

  @override
  List<Object?> get props => [name, phone, email];
}
