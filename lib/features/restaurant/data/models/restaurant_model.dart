class RestaurantModel {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String? description;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.description,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      description: json['description']?.toString(),
    );
  }
}
