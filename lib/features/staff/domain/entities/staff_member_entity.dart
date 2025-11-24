import 'package:equatable/equatable.dart';

class StaffMemberEntity extends Equatable {
  final String name;
  final String role;
  final double salary;
  final String phone;
  final String email;
  final String joinedDate;
  final String status;
  final String shift;
  final String? notes;
  final String loginId;
  final String tempPin;

  const StaffMemberEntity({
    required this.name,
    required this.role,
    required this.salary,
    required this.phone,
    required this.email,
    required this.joinedDate,
    required this.status,
    required this.shift,
    required this.loginId,
    required this.tempPin,
    this.notes,
  });

  @override
  List<Object?> get props => [
        name,
        role,
        salary,
        phone,
        email,
        joinedDate,
        status,
        shift,
        loginId,
        tempPin,
        notes,
      ];
}
