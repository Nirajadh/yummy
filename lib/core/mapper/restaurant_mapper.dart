import 'package:yummy/features/restaurant/data/models/restaurant_model.dart';
import 'package:yummy/features/restaurant/domain/entities/restaurant_entity.dart';

class RestaurantMapper {
  static RestaurantEntity toEntity(RestaurantModel model) {
    return RestaurantEntity(
      id: model.id,
      name: model.name,
      address: model.address,
      phone: model.phone,
      description: model.description,
    );
  }
}
