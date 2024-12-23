import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:recepku/data/remote/response/daily_calories_response.dart';
import 'package:recepku/data/remote/response/recipe_response.dart';
import 'package:recepku/data/remote/response/result_response.dart';
import 'package:recepku/data/remote/response/token_response.dart';

import '../response/history_response.dart';
import '../response/target_calories_response.dart';
import '../response/user_repsonse.dart';
import 'base_service.dart';

class ApiService extends BaseService {
  final String baseUrl;

  ApiService({
    required this.baseUrl,
  });

  Future<RecipeResponse> fetchData() async {
    final response = await get('${baseUrl}/makanan');

    return RecipeResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<RecipeResponse> searchData(String query) async {
    final response =
        await get('${baseUrl}/makanan', queryParameters: {'slug': query});

    return RecipeResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<ResultResponse> register(
      String email, String password, String username) async {
    final uri = Uri.parse("$baseUrl/register");
    final response = await http.post(uri,
        body: {'username': username, 'email': email, 'password': password});

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ResultResponse.fromJson(responseBody);
  }

  Future<UserResponse> login(String username, String password) async {
    final uri = Uri.parse("$baseUrl/login");
    final response = await http
        .post(uri, body: {'username': username, 'password': password});
    print(jsonDecode(response.body));

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (responseBody.containsKey('error') && responseBody['error'] == true) {
      print('Login Error: ${responseBody['message']}');
      return UserResponse(
        data: UserEntity(uid: '', username: '', email: '', imageUrl: ''),
        token: '',
        result: ResultEntity(error: true, message: responseBody['message']),
      );
    }

    Future.delayed(
      const Duration(seconds: 2),
          () => print('Login Success'),
    );

    final TokenResponse authResponse = TokenResponse.fromJson(responseBody);
    return await getProfile(authResponse.data.token);
  }

  Future<ResultResponse> deleteUser(String token) async {
    final uri = Uri.parse("$baseUrl/profile");
    final response = await http.delete(uri,
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ResultResponse.fromJson(responseBody);
  }

  Future<UserResponse> changeUsername(
      String token, String newUsername, String password) async {
    final uri = Uri.parse("$baseUrl/profile/username");
    final response = await http.put(uri,
        body: {'username': newUsername, 'password': password},
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    print(responseBody);
    return UserResponse.fromJson(responseBody);
  }

  Future<UserResponse> changeEmail(
      String token, String newEmail, String password) async {
    final uri = Uri.parse("$baseUrl/profile/email");
    final response = await http.put(uri,
        body: {'email': newEmail, 'password': password},
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return UserResponse.fromJson(responseBody);
  }

  Future<ResultResponse> changePassword(String token,
      {required String oldPassword,
      required String newPassword,
      required String confirmPassword}) async {
    final uri = Uri.parse("$baseUrl/profile/password");
    final response = await http.put(uri, body: {
      'password': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword
    }, headers: {
      HttpHeaders.authorizationHeader: "Bearer $token"
    });

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ResultResponse.fromJson(responseBody);
  }

  Future<ResultResponse> changePhotoProfile(String token, File image) async {
    final uri = Uri.parse("$baseUrl/profile/photo");

    var request = http.MultipartRequest('PUT', uri)
      ..headers[HttpHeaders.authorizationHeader] = "Bearer $token"
      ..files.add(await http.MultipartFile.fromPath('photo', image.path))
      ..headers['Content-Type'] = 'multipart/form-data';

    var response = await request.send();

    var responseString = await response.stream.bytesToString();
    final responseBody = jsonDecode(responseString) as Map<String, dynamic>;
    print(responseBody);

    return ResultResponse.fromJson(responseBody);
  }

  Future<UserResponse> getProfile(String token) async {
    final uri = Uri.parse("$baseUrl/profile");
    final response = await http
        .get(uri, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return UserResponse.fromJson(responseBody);
  }

  Future<void> addSearchHistory(String token, String idMakanan) async{
    final uri = Uri.parse("$baseUrl/riwayat_pencarian");
    final response = await http.post(uri, body: {'id_makanan': idMakanan}, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    print(response.body);
  }


  Future<List<HistoryResponse>> getSearchHistory(String token) async {
    final uri = Uri.parse("$baseUrl/riwayat_pencarian");
    final response = await http.get(uri, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final data = responseBody['data'] as List<dynamic>;
      return data.map((json) => HistoryResponse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load search history');
    }
  }

  Future<RecipeEntity> getRecipeById(String token, String id) async {
    final uri = Uri.parse("$baseUrl/makanan/id/$id");
    final response = await http.get(uri, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      return RecipeEntity.fromJson(responseBody['data']);
    } else {
      throw Exception('Failed to load recipe');
    }
  }


  Future<TargetCaloriesResponse> getTargetCaloriesByDay(String token, String day) async {
    final uri = Uri.parse("$baseUrl/target_kalori/$day");
    final response = await http.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return TargetCaloriesResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load target calories');
    }
  }

  Future<DailyCaloriesResponse> getAsupanHarianByDay(String token, String day) async {
    final uri = Uri.parse("$baseUrl/asupan_harian/$day");
    final response = await http.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return DailyCaloriesResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load target calories');
    }
  }

  Future<TargetCaloriesResponse> setTargetCalories(String token, String day, int targetCalories) async {
    final uri = Uri.parse("$baseUrl/target_kalori");
    final response = await http.post(
      uri,
      body: {'hari': day, 'target_kalori': targetCalories.toString()},
      headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to set target calories');
    } else {
      return TargetCaloriesResponse.fromJson(jsonDecode(response.body));
    }
  }

  Future<DailyCaloriesResponse> getDailyCalories(String token, String day) async {
    final uri = Uri.parse("$baseUrl/asupan_harian/$day");
    final response = await http.get(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return DailyCaloriesResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load daily calories');
    }
  }

  Future<DailyCaloriesResponse> addAsupanHarianByDay(
      String token,
      String day,
      String idMakanan,
      int jumlahPorsi,
      String mealType,
      int isHealthy
      ) async {
    try {
      final uri = Uri.parse("$baseUrl/asupan_harian/$day");
      final response = await http.post(
        uri,
        body: {
          'is_healthy': isHealthy.toString(),
          'id_makanan': idMakanan,
          'jumlah_porsi': jumlahPorsi.toString(),
          'jenis_asupan': mealType,
        },
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return DailyCaloriesResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add daily calories');
      }
    } catch (e) {
      print('Exception occurred 12321321312: $e');
      rethrow;
    }
  }

  Future<ResultResponse> deleteAsupanHarianByDay(String token, String id) async {
    final uri = Uri.parse("$baseUrl/asupan_harian/id/$id");
    final response = await http.delete(
      uri,
      headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete daily calories');
    }else{
      return ResultResponse.fromJson(jsonDecode(response.body));
    }
  }
}
