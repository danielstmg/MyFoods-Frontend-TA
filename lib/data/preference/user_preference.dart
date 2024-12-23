import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/user.dart';

class UserPreference {
  static const String userDataKey = 'user_data';

  static Future<void> saveUserData(UserData userData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonData = jsonEncode(userData.toJson());
    print(jsonData);
    await prefs.setString(userDataKey, jsonData);
  }

  static Future<UserData?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonData = prefs.getString(userDataKey);

    if (jsonData != null) {
      final Map<String, dynamic> dataMap = jsonDecode(jsonData);
      return UserData.fromJson(dataMap);
    } else {
      return null;
    }
  }

  static Future<void> removeUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(userDataKey);
  }

  static Future<void> saveToken(String newToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', newToken);
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
