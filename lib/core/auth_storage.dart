/// Lightweight auth storage placeholder for future secure storage wiring.
class AuthStorage {
  String? _token;

  Future<void> saveToken(String token) async {
    _token = token;
  }

  Future<String?> getToken() async => _token;

  Future<void> clear() async {
    _token = null;
  }
}
