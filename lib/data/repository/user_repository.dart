import 'dart:io';

import 'package:recepku/data/domain/result.dart';
import 'package:recepku/data/domain/search_history.dart';
import 'package:recepku/data/domain/user.dart';
import 'package:recepku/data/preference/user_preference.dart';
import 'package:recepku/data/remote/api/api_service.dart';
import 'package:recepku/utils/global_variabel.dart';

class UserRepository {
  final ApiService apiService;

  UserRepository({
    required this.apiService,
  });

  Future<Result> register(
      String email, String password, String username) async {
    final result = await apiService.register(email, password, username);
    final data = Result(error: result.data.error, message: result.data.message);
    return data;
  }

  Future<UserData> login(String username, String password) async {
    try {
      final result = await apiService.login(username, password);
      final data = mapper.toUserData(result);
      return data;
    } on FormatException catch (e) {
      return UserData(
          uid: '',
          username: '',
          email: '',
          imageUrl: '',
          token: '',
          error: true,
          message: 'No Credential Found');
    }
  }

  Future<Result> deleteUser(String token) async {
    final result = await apiService.deleteUser(token);
    final data = Result(error: result.data.error, message: result.data.message);
    print(data.error);
    print(data.message);
    return data;
  }

  Future<Result> changeEmail(
      String token, String newEmail, String password) async {
    final result = await apiService.changeEmail(token, newEmail, password);
    return Result(error: result.result.error, message: result.result.message, token: result.token);
  }

  Future<Result> changeUsername(
      String token, String newUsername, String password) async {
    final result =
        await apiService.changeUsername(token, newUsername, password);
    return Result(error: result.result.error, message: result.result.message, token: result.token);
  }

  Future<Result> changePassword(String token,
      {required String oldPassword,
      required String newPassword,
      required String confirmPassword}) async {
    final result = await apiService.changePassword(token,
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword);
    return Result(error: result.data.error, message: result.data.message);
  }

  Future<Result> changePhotoProfile(String token, File image) async {
    final result = await apiService.changePhotoProfile(token, image);
    print(result);
    return Result(error: result.data.error, message: result.data.message, token: result.token);
  }

  Future<UserData> getProfile(String token) async {
    final result = await apiService.getProfile(token);
    final data = mapper.toUserData(result);
    return data;
  }

  Future<void> saveUserDataToPreferences(String token) async {
    try {
      final userData = await getProfile(token);
      await UserPreference.saveUserData(userData);
    } catch (e) {
      print('Error getting user data: $e');
    }
  }

  Future<void> saveNewToken(String token) async {
    try {
      await UserPreference.saveToken(token);
    } catch (e) {
      print('Error getting token: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await UserPreference.getToken();
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }
}
