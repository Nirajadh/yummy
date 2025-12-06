import 'package:shared_preferences/shared_preferences.dart';

/// Singleton wrapper over SharedPreferences with a tiny in-memory cache to
/// avoid repeated disk reads.
class SecureStorageService {
  SecureStorageService._internal();
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  static final Future<SharedPreferences> _prefsFuture =
      SharedPreferences.getInstance();
  final Map<String, String?> _memoryCache = {};

  Future<SharedPreferences> get _prefs async => _prefsFuture;

  Future<String?> getValue({required String key}) async {
    if (_memoryCache.containsKey(key)) return _memoryCache[key];
    final prefs = await _prefs;
    final value = prefs.getString(key);
    _memoryCache[key] = value;
    return value;
  }

  Future<void> setValue({required String key, required String value}) async {
    _memoryCache[key] = value;
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  Future<void> delete({bool shouldDeleteAll = false, String? key}) async {
    final prefs = await _prefs;
    if (shouldDeleteAll) {
      _memoryCache.clear();
      await prefs.clear();
    } else if (key != null) {
      _memoryCache.remove(key);
      await prefs.remove(key);
    }
  }
}
