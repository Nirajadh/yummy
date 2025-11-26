import 'package:yummy/features/kot/domain/entities/kot_ticket_entity.dart';

abstract interface class KitchenRepository {
  Future<List<KotTicketEntity>> getKotTickets();
}
