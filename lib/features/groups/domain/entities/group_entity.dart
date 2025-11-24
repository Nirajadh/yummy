import 'package:equatable/equatable.dart';

import 'group_person_entity.dart';

class GroupEntity extends Equatable {
  final String name;
  final int peopleCount;
  final String contactName;
  final String contactPhone;
  final String type;
  final String notes;
  final bool isActive;
  final List<GroupPersonEntity> people;

  const GroupEntity({
    required this.name,
    required this.peopleCount,
    required this.contactName,
    required this.contactPhone,
    required this.type,
    this.notes = '',
    this.isActive = true,
    this.people = const [],
  });

  GroupEntity copyWith({
    String? name,
    int? peopleCount,
    String? contactName,
    String? contactPhone,
    String? type,
    String? notes,
    bool? isActive,
    List<GroupPersonEntity>? people,
  }) {
    return GroupEntity(
      name: name ?? this.name,
      peopleCount: peopleCount ?? this.peopleCount,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      people: people ?? this.people,
    );
  }

  @override
  List<Object?> get props => [
        name,
        peopleCount,
        contactName,
        contactPhone,
        type,
        notes,
        isActive,
        people,
      ];
}
