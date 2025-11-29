import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yummy/features/restaurant/domain/entities/restaurant_entity.dart';
import 'package:yummy/features/restaurant/domain/usecases/create_restaurant_usecase.dart';
import 'package:yummy/features/restaurant/domain/usecases/update_restaurant_usecase.dart';

part 'restaurant_event.dart';
part 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  RestaurantBloc({
    required CreateRestaurantUseCase createRestaurant,
    required UpdateRestaurantUseCase updateRestaurant,
  }) : _createRestaurant = createRestaurant,
       _updateRestaurant = updateRestaurant,
       super(const RestaurantState()) {
    on<RestaurantSubmitted>(_onSubmitted);
    on<RestaurantUpdated>(_onUpdated);
  }

  final CreateRestaurantUseCase _createRestaurant;
  final UpdateRestaurantUseCase _updateRestaurant;

  Future<void> _onSubmitted(
    RestaurantSubmitted event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(state.copyWith(status: RestaurantStatus.loading, errorMessage: null));
    final result = await _createRestaurant(
      name: event.name,
      address: event.address,
      phone: event.phone,
      description: event.description,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: RestaurantStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (restaurant) => emit(
        state.copyWith(
          status: RestaurantStatus.success,
          restaurant: restaurant,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onUpdated(
    RestaurantUpdated event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(state.copyWith(status: RestaurantStatus.loading, errorMessage: null));
    final result = await _updateRestaurant(
      id: event.id,
      name: event.name,
      address: event.address,
      phone: event.phone,
      description: event.description,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: RestaurantStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (restaurant) => emit(
        state.copyWith(
          status: RestaurantStatus.success,
          restaurant: restaurant,
          errorMessage: null,
        ),
      ),
    );
  }
}
