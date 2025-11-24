import 'package:yummy/features/common/data/dummy_data.dart' as dummy;

class GroupPersonModel {
  String? name;
  String? phone;
  String? email;

  GroupPersonModel({this.name, this.phone, this.email});

  factory GroupPersonModel.fromJson(Map<String, dynamic> json) {
    return GroupPersonModel(
      name: (json['name'] as String?)?.trim(),
      phone: (json['phone'] as String?)?.trim(),
      email: (json['email'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
    };
  }
}

class GroupModel {
  String? name;
  int? peopleCount;
  String? contactName;
  String? contactPhone;
  String? type;
  String? notes;
  bool? isActive;
  List<GroupPersonModel>? people;

  GroupModel({
    this.name,
    this.peopleCount,
    this.contactName,
    this.contactPhone,
    this.type,
    this.notes,
    this.isActive,
    this.people,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final peopleJson = json['people'];
    final people = peopleJson is List
        ? peopleJson
            .whereType<Map<String, dynamic>>()
            .map(GroupPersonModel.fromJson)
            .toList()
        : null;

    return GroupModel(
      name: (json['name'] as String?)?.trim(),
      peopleCount: _parseInt(json['peopleCount']),
      contactName: (json['contactName'] as String?)?.trim(),
      contactPhone: (json['contactPhone'] as String?)?.trim(),
      type: (json['type'] as String?)?.trim(),
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool?,
      people: people,
    );
  }

  factory GroupModel.fromDummy(dummy.GroupInfo group) {
    return GroupModel(
      name: group.name,
      peopleCount: group.peopleCount,
      contactName: group.contactName,
      contactPhone: group.contactPhone,
      type: group.type,
      notes: group.notes,
      isActive: group.isActive,
      people: group.people
          .map(
            (person) => GroupPersonModel(
              name: person.name,
              phone: person.phone,
              email: person.email,
            ),
          )
          .toList(),
    );
  }

  GroupModel copyWith({
    String? name,
    int? peopleCount,
    String? contactName,
    String? contactPhone,
    String? type,
    String? notes,
    bool? isActive,
    List<GroupPersonModel>? people,
  }) {
    return GroupModel(
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'peopleCount': peopleCount,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'type': type,
      'notes': notes,
      'isActive': isActive,
      'people': people?.map((p) => p.toJson()).toList(),
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
