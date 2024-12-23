import 'package:recepku/data/remote/api/api_service.dart';

import '../../utils/mapper.dart';
import '../domain/recipe.dart';
import '../domain/search_history.dart';
import '../local/db/recipe_dao.dart';
import '../remote/response/history_response.dart';

class RecipeRepository {
  final ApiService apiService;
  final Mapper mapper;
  final RecipeDao recipeDao;

  RecipeRepository({
    required this.apiService,
    required this.mapper,
    required this.recipeDao,
  });

  Future<List<Recipe>> getRecipes() async {
    final dbEntities = await recipeDao.selectAll();

    if (dbEntities.isNotEmpty) {
      return mapper.toAssetsFromDb(dbEntities);
    }

    final response = await apiService.fetchData();
    final recipes = mapper.toAssets(response.data);
    await recipeDao.insertAll(mapper.toAssetsDbEntity(recipes));
    return recipes;
  }

  Future<bool> toggleFavorite(int id) async {
    await recipeDao.toggleFavorite(id);
    return await recipeDao.isFavorite(id);
  }

  Future<bool> isFavorite(int id) async {
    return await recipeDao.isFavorite(id);
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final response = await apiService.searchData(query);
    final recipes = mapper.toAssets(response.data);
    print(recipes);
    return recipes;
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    final dbEntities = await recipeDao.selectFavorite();
    return mapper.toAssetsFromDb(dbEntities);
  }

  Future<Recipe> getScanRecipe(String name) async {
    final id = await recipeDao.getIdByName(name);
    final dbEntity = await recipeDao.selectById(id);
    return mapper.toAssetFromDb(dbEntity);
  }

  Future<void> addSearchHistory(String token, String idMakanan) async {
    await apiService.addSearchHistory(token, idMakanan);
  }



  // Future<List<Recipe>> getSearchHistoryRecipes(String token) async {
  //   final List<HistoryResponse> historyResponses = await apiService
  //       .getSearchHistory(token);
  //   final List<Recipe> recipes = [];
  //   try {
  //     for (final history in historyResponses) {
  //       final recipeEntity = await apiService.getRecipeById(
  //           token, history.idMakanan);
  //       recipes.add(mapper.toRecipe(recipeEntity));
  //     }
  //     return recipes;
  //   } catch (e) {
  //     print(e);
  //     throw Exception('Failed to load search history');
  //   }
  // }

  Future<List<Recipe>> getSearchHistoryRecipes(String token) async {
    final List<HistoryResponse> historyResponses = await apiService.getSearchHistory(token);
    final Map<String, HistoryResponse> latestHistoryMap = {};

    for (final history in historyResponses) {
      if (!latestHistoryMap.containsKey(history.idMakanan) ||
          latestHistoryMap[history.idMakanan]!.timestamp.toDate().isBefore(history.timestamp.toDate())) {
        latestHistoryMap[history.idMakanan] = history;
      }
    }

    final List<HistoryResponse> latestHistories = latestHistoryMap.values.toList()
      ..sort((a, b) => b.timestamp.toDate().compareTo(a.timestamp.toDate()));

    final List<Recipe> recipes = [];
    try {
      for (final history in latestHistories) {
        final recipeEntity = await apiService.getRecipeById(token, history.idMakanan);
        recipes.add(mapper.toRecipe(recipeEntity));
      }
      return recipes;
    } catch (e) {
      print(e);
      throw Exception('Failed to load search history');
    }
  }

}
