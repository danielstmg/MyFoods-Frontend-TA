import 'package:recepku/data/remote/api/api_service.dart';
import '../../utils/mapper.dart';
import '../domain/daily_calories.dart';
import '../domain/recipe.dart';
import '../domain/result.dart';
import '../remote/response/daily_calories_response.dart';

class CaloriesRepository {
  final ApiService apiService;
  final Mapper mapper;

  CaloriesRepository({
    required this.apiService,
    required this.mapper,
  });

  Future<int> getTargetCalories(String token, String day) async {
    try {
      final response = await apiService.getTargetCaloriesByDay(token, day);
      if (response.result.error) {
        return 0;
      }
      final targetData = mapper.toTargetCalories(response.data);
      return targetData.targetCalories ?? 0;
    } catch (e) {
      print("Exception occurred: $e");
      return 0;
    }
  }

  Future<int> getCurrentCalories(String token, String day) async {
    try {
      final response = await apiService.getAsupanHarianByDay(token, day);
      final dailyCaloriesResponse = response.totalCalories;

      if (response.result.error) {
        print("Error in response: ${response.result.message}");
        return 0;
      }

      final dailyCalories = dailyCaloriesResponse ?? 0;
      print("Parsed dailyCalories: $dailyCalories");
      return dailyCalories;
    } catch (e) {
      print("Exception occurred: $e");
      return 0;
    }
  }

  Future<void> setTargetCalories(String token, String day, int targetCalories) async {
    try {
      await apiService.setTargetCalories(token, day, targetCalories);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<DailyCalories>> getDailyCaloriesData(String token, String day) async {
    try{
      final response = await apiService.getAsupanHarianByDay(token, day);
      final dailyCalories = mapper.toDailyCaloriess(response.data);
      return dailyCalories;
    } catch (e) {
      print("Exception occurred: $e");
      throw Exception(e);
    }
  }

  Future<Recipe> getRecipeById(String token, String id) async {
    final response = await apiService.getRecipeById(token, id);
    final recipe = mapper.toRecipe(response);
    return recipe;
  }

  Future<void> addAsupanHarianByDay(
      String token,
      String day,
      String idMakanan,
      int jumlahPorsi,
      String mealType,
      int isHealthy
      ) async {
    try{
      await apiService.addAsupanHarianByDay(token, day, idMakanan, jumlahPorsi, mealType, isHealthy);
    } catch (e) {
      print("Exception occurred: $e");
      throw Exception(e);
    }
  }

  Future<Result> deleteAsupanHarianByDay(String token, String id) async {
    try {
      final response = await apiService.deleteAsupanHarianByDay(token, id);
      final result = mapper.toResult(response.data);
      return result;
    } catch (e) {
      print("Exception occurred: $e");
      throw Exception(e);
    }
  }
}
