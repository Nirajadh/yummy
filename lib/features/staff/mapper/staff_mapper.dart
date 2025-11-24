import 'package:yummy/features/staff/data/models/staff_member_model.dart';
import 'package:yummy/features/staff/data/models/staff_record_model.dart';
import 'package:yummy/features/staff/domain/entities/staff_member_entity.dart';
import 'package:yummy/features/staff/domain/entities/staff_record_entity.dart';

class StaffMapper {
  static StaffMemberEntity toMemberEntity(StaffMemberModel model) {
    return StaffMemberEntity(
      name: model.name ?? '',
      role: model.role ?? '',
      salary: model.salary ?? 0,
      phone: model.phone ?? '',
      email: model.email ?? '',
      joinedDate: model.joinedDate ?? '',
      status: model.status ?? '',
      shift: model.shift ?? '',
      notes: model.notes,
      loginId: model.loginId ?? '',
      tempPin: model.tempPin ?? '',
    );
  }

  static StaffMemberModel fromMemberEntity(StaffMemberEntity entity) {
    return StaffMemberModel(
      name: entity.name,
      role: entity.role,
      salary: entity.salary,
      phone: entity.phone,
      email: entity.email,
      joinedDate: entity.joinedDate,
      status: entity.status,
      shift: entity.shift,
      notes: entity.notes,
      loginId: entity.loginId,
      tempPin: entity.tempPin,
    );
  }

  static StaffRecordEntity toRecordEntity(StaffRecordModel model) {
    return StaffRecordEntity(
      staffName: model.staffName ?? '',
      type: model.type ?? '',
      amount: model.amount ?? 0,
      date: model.date ?? '',
      note: model.note ?? '',
    );
  }

  static StaffRecordModel fromRecordEntity(StaffRecordEntity entity) {
    return StaffRecordModel(
      staffName: entity.staffName,
      type: entity.type,
      amount: entity.amount,
      date: entity.date,
      note: entity.note,
    );
  }
}
