import 'package:shared_preferences/shared_preferences.dart';

class Cache {
  static late SharedPreferences sharedPreferences;

  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<void> setBool({required String key, required bool value}) async {
    await sharedPreferences.setBool(key, value);
  }

  static bool? getBool(String key) {
    return sharedPreferences.getBool(key);
  }

  static Future<void> setStringList({required String key, required List<String> value}) async {
    await sharedPreferences.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return sharedPreferences.getStringList(key);
  }
}
