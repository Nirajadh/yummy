import 'package:yummy/features/common/data/dummy_data.dart' as dummy;

class StaffMemberModel {
  String? name;
  String? role;
  double? salary;
  String? phone;
  String? email;
  String? joinedDate;
  String? status;
  String? shift;
  String? loginId;
  String? tempPin;
  String? notes;

  StaffMemberModel({
    this.name,
    this.role,
    this.salary,
    this.phone,
    this.email,
    this.joinedDate,
    this.status,
    this.shift,
    this.loginId,
    this.tempPin,
    this.notes,
  });

  factory StaffMemberModel.fromJson(Map<String, dynamic> json) {
    final rawSalary = json['salary'];
    final salary = rawSalary is num
        ? rawSalary.toDouble()
        : double.tryParse(rawSalary?.toString() ?? '');

    return StaffMemberModel(
      name: (json['name'] as String?)?.trim(),
      role: (json['role'] as String?)?.trim(),
      salary: salary,
      phone: (json['phone'] as String?)?.trim(),
      email: (json['email'] as String?)?.trim(),
      joinedDate: (json['joinedDate'] as String?)?.trim(),
      status: (json['status'] as String?)?.trim(),
      shift: (json['shift'] as String?)?.trim(),
      loginId: (json['loginId'] as String?)?.trim(),
      tempPin: (json['tempPin'] as String?)?.trim(),
      notes: (json['notes'] as String?)?.trim(),
    );
  }

  factory StaffMemberModel.fromDummy(dummy.StaffMember member) {
    return StaffMemberModel(
      name: member.name,
      role: member.role,
      salary: member.salary,
      phone: member.phone,
      email: member.email,
      joinedDate: member.joinedDate,
      status: member.status,
      shift: member.shift,
      notes: member.notes,
      loginId: member.loginId,
      tempPin: member.tempPin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'salary': salary,
      'phone': phone,
      'email': email,
      'joinedDate': joinedDate,
      'status': status,
      'shift': shift,
      'loginId': loginId,
      'tempPin': tempPin,
      'notes': notes,
    };
  }
}
