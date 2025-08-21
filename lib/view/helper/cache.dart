import 'package:shared_preferences/shared_preferences.dart';

class Cache {
  static late SharedPreferences _sharedPreferences;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  /// Save data (supports String, int, bool, double, List<String>)
  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) return await _sharedPreferences.setString(key, value);
    if (value is int) return await _sharedPreferences.setInt(key, value);
    if (value is bool) return await _sharedPreferences.setBool(key, value);
    if (value is double) return await _sharedPreferences.setDouble(key, value);
    if (value is List<String>) return await _sharedPreferences.setStringList(key, value);

    throw Exception("Unsupported value type: ${value.runtimeType}");
  }


  /// Get data by key
  static dynamic getData(String key) {
    return _sharedPreferences.get(key);
  }

  /// Remove data by key
  static Future<bool> removeData(String key) async {
    return await _sharedPreferences.remove(key);
  }

  /// Clear all cache
  static Future<bool> clear() async {
    return await _sharedPreferences.clear();
  }
}
