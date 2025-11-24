import 'package:yummy/features/groups/data/models/group_model.dart';
import 'package:yummy/features/groups/domain/entities/group_entity.dart';
import 'package:yummy/features/groups/domain/entities/group_person_entity.dart';

class GroupMapper {
  static GroupEntity toEntity(GroupModel model) {
    final people = model.people ?? const [];
    return GroupEntity(
      name: model.name ?? '',
      peopleCount: model.peopleCount ?? 0,
      contactName: model.contactName ?? '',
      contactPhone: model.contactPhone ?? '',
      type: model.type ?? '',
      notes: model.notes ?? '',
      isActive: model.isActive ?? true,
      people: people
          .map(
            (p) => GroupPersonEntity(
              name: p.name ?? '',
              phone: p.phone,
              email: p.email,
            ),
          )
          .toList(),
    );
  }

  static GroupModel fromEntity(GroupEntity entity) {
    return GroupModel(
      name: entity.name,
      peopleCount: entity.peopleCount,
      contactName: entity.contactName,
      contactPhone: entity.contactPhone,
      type: entity.type,
      notes: entity.notes,
      isActive: entity.isActive,
      people: entity.people
          .map(
            (p) => GroupPersonModel(
              name: p.name,
              phone: p.phone,
              email: p.email,
            ),
          )
          .toList(),
    );
  }
}
