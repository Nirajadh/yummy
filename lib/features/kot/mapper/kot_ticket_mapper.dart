import 'package:yummy/features/kot/data/models/kot_ticket_model.dart';
import 'package:yummy/features/kot/domain/entities/kot_ticket_entity.dart';

class KotTicketMapper {
  static KotTicketEntity toEntity(KotTicketModel model) {
    return KotTicketEntity(
      id: model.id ?? '',
      type: model.type ?? '',
      reference: model.reference ?? '',
      items: model.items ?? const [],
      time: model.time ?? '',
      status: model.status ?? 'Pending',
    );
  }

  static KotTicketModel fromEntity(KotTicketEntity entity) {
    return KotTicketModel(
      id: entity.id,
      type: entity.type,
      reference: entity.reference,
      items: entity.items,
      time: entity.time,
      status: entity.status,
    );
  }
}
