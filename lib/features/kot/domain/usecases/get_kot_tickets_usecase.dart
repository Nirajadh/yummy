import 'package:yummy/features/common/domain/repositories/restaurant_repository.dart';
import 'package:yummy/features/kot/domain/entities/kot_ticket_entity.dart';

class GetKotTicketsUseCase {
  final RestaurantRepository repository;

  const GetKotTicketsUseCase(this.repository);

  Future<List<KotTicketEntity>> call() {
    return repository.getKotTickets();
  }
}
