import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> saveData({
    required String key,
    required String value,
  }) async {
    return await _prefs!.setString(key, value);
  }

  static String? getData({required String key}) {
    return _prefs?.getString(key);
  }

  static Future<bool> removeData({required String key}) async {
    return _prefs!.remove(key);
  }

  static Future<bool> setBool({
    required String key,
    required bool value,
  }) async {
    return await _prefs!.setBool(key, value);
  }

  static bool? getBool({required String key}) {
    return _prefs?.getBool(key);
  }
}
