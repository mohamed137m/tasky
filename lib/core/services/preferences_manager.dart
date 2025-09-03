import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static final PreferencesManager _instance = PreferencesManager._internal();

  factory PreferencesManager() {
    return _instance;
  }
  
  PreferencesManager._internal();

  late final SharedPreferences _preferences;

  init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // set Method
  setString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  setInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  setDouble(String key, double value) async {
    await _preferences.setDouble(key, value);
  }

  setBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  setStringList(String key, List<String> value) async {
    await _preferences.setStringList(key, value);
  }

  // get Method
  String? getString(String key) {
    return _preferences.getString(key);
  }

  int? getInt(String key, int value) {
    return _preferences.getInt(key);
  }

  double? getDouble(String key) {
    return _preferences.getDouble(key);
  }

  bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  List<String>? getStringList(String key) {
    return _preferences.getStringList(key);
  }


  //delete
  remove(String key) async {
    await _preferences.remove(key);
  }

  clear() async {
    await _preferences.clear();
  }
}
