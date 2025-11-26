import 'package:yummy/features/orders/domain/entities/active_order_entity.dart';
import 'package:yummy/features/staff_portal/domain/repositories/staff_portal_repository.dart';

class GetStaffActiveOrdersUseCase {
  final StaffPortalRepository repository;

  const GetStaffActiveOrdersUseCase(this.repository);

  Future<List<ActiveOrderEntity>> call() {
    return repository.getActiveOrders();
  }
}
