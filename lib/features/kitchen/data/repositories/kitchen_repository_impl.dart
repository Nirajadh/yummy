import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/kitchen/domain/repositories/kitchen_repository.dart';
import 'package:yummy/features/kot/domain/entities/kot_ticket_entity.dart';

class KitchenRepositoryImpl implements KitchenRepository {
  final RestaurantRepository base;

  KitchenRepositoryImpl({required this.base});

  @override
  Future<List<KotTicketEntity>> getKotTickets() {
    return base.getKotTickets();
  }
}
