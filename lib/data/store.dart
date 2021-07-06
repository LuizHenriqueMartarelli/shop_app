import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<void> saveMap(String key, Map<String, dynamic> value) async {
    saveString(key, json.encode(value));
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<Map<String, dynamic>?> getMap(String key) async {
    String? ret = await getString(key);
    if (ret != null) {
      try {
        Map<String, dynamic> map = json.decode(ret);
        return map;
      } catch (_) {
        return Future.value();
      }
    }
    return Future.value();
  }

  static Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
