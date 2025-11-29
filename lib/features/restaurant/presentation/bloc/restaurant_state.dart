part of 'restaurant_bloc.dart';

enum RestaurantStatus { initial, loading, success, failure }

class RestaurantState extends Equatable {
  final RestaurantStatus status;
  final RestaurantEntity? restaurant;
  final String? errorMessage;

  const RestaurantState({
    this.status = RestaurantStatus.initial,
    this.restaurant,
    this.errorMessage,
  });

  RestaurantState copyWith({
    RestaurantStatus? status,
    RestaurantEntity? restaurant,
    String? errorMessage,
  }) {
    return RestaurantState(
      status: status ?? this.status,
      restaurant: restaurant ?? this.restaurant,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, restaurant, errorMessage];
}
