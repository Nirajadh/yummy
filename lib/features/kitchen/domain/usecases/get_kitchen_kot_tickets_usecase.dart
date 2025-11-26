import 'package:yummy/features/kitchen/domain/repositories/kitchen_repository.dart';
import 'package:yummy/features/kot/domain/entities/kot_ticket_entity.dart';

class GetKitchenKotTicketsUseCase {
  final KitchenRepository repository;

  const GetKitchenKotTicketsUseCase(this.repository);

  Future<List<KotTicketEntity>> call() {
    return repository.getKotTickets();
  }
}
