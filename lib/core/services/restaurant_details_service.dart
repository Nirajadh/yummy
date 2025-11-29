import 'package:yummy/core/services/shared_prefrences.dart';

class RestaurantDetails {
  final int? id;
  final String name;
  final String address;
  final String phone;
  final String description;

  const RestaurantDetails({
    this.id,
    this.name = '',
    this.address = '',
    this.phone = '',
    this.description = '',
  });

  bool get isComplete =>
      name.trim().isNotEmpty &&
      address.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      description.trim().isNotEmpty;

  bool get hasAnyData =>
      name.trim().isNotEmpty ||
      address.trim().isNotEmpty ||
      phone.trim().isNotEmpty ||
      description.trim().isNotEmpty;

  RestaurantDetails copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    String? description,
  }) {
    return RestaurantDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      description: description ?? this.description,
    );
  }
}

/// Simple local storage wrapper for the restaurant profile.
class RestaurantDetailsService {
  static const _idKey = 'restaurant_id';
  static const _nameKey = 'restaurant_name';
  static const _addressKey = 'restaurant_address';
  static const _phoneKey = 'restaurant_phone';
  static const _descriptionKey = 'restaurant_description';

  final SecureStorageService _storage = SecureStorageService();

  Future<RestaurantDetails> getDetails() async {
    final idRaw = await _storage.getValue(key: _idKey);
    final id = int.tryParse(idRaw ?? '');
    final name = await _storage.getValue(key: _nameKey) ?? '';
    final address = await _storage.getValue(key: _addressKey) ?? '';
    final phone = await _storage.getValue(key: _phoneKey) ?? '';
    final description = await _storage.getValue(key: _descriptionKey) ?? '';
    return RestaurantDetails(
      id: id,
      name: name,
      address: address,
      phone: phone,
      description: description,
    );
  }

  Future<void> saveDetails(RestaurantDetails details) async {
    if (details.id != null) {
      await _storage.setValue(key: _idKey, value: details.id.toString());
    }
    await _storage.setValue(key: _nameKey, value: details.name.trim());
    await _storage.setValue(key: _addressKey, value: details.address.trim());
    await _storage.setValue(key: _phoneKey, value: details.phone.trim());
    await _storage.setValue(
      key: _descriptionKey,
      value: details.description.trim(),
    );
  }

  Future<void> clear() async {
    await _storage.setValue(key: _idKey, value: '');
    await _storage.setValue(key: _nameKey, value: '');
    await _storage.setValue(key: _addressKey, value: '');
    await _storage.setValue(key: _phoneKey, value: '');
    await _storage.setValue(key: _descriptionKey, value: '');
  }
}
