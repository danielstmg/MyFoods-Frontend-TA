import 'package:recepku/data/domain/daily_calories.dart';
import 'package:recepku/data/domain/result.dart';
import 'package:recepku/data/domain/target_calories.dart';
import 'package:recepku/data/local/entity/recipe_db_entity.dart';
import 'package:recepku/data/remote/response/daily_calories_response.dart';
import 'package:recepku/data/remote/response/recipe_response.dart';
import 'package:recepku/data/remote/response/target_calories_response.dart';
import '../data/domain/recipe.dart';
import '../data/domain/search_history.dart';
import '../data/domain/user.dart';
import '../data/remote/response/history_response.dart';
import '../data/remote/response/result_response.dart';
import '../data/remote/response/user_repsonse.dart';

class MapperException<From, To> implements Exception {
  final String message;

  const MapperException(this.message);

  @override
  String toString() {
    return 'Error when mapping class $From to $To: $message';
  }
}

class Mapper {
  Recipe toAsset(RecipeEntity entity) {
    try {
      return Recipe(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        photoUrl: entity.photoUrl,
        ingredients: entity.ingredients,
        steps: entity.steps,
        healthyIngredients: entity.healthyIngredients,
        healthySteps: entity.healthySteps,
        calories: entity.calories,
        healthyCalories: entity.healthyCalories,
      );
    } catch (e) {
      throw MapperException<RecipeEntity, Recipe>(e.toString());
    }
  }

  List<Recipe> toAssets(List<RecipeEntity> entities) {
    final List<Recipe> assets = [];
    for (final entity in entities) {
      assets.add(toAsset(entity));
    }
    return assets;
  }

  Recipe toAssetFromDb(RecipeDBEntity entity) {
    try {
      return Recipe(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        photoUrl: entity.photoUrl,
        ingredients: entity.ingredients,
        steps: entity.steps,
        healthyIngredients: entity.healthyIngredients,
        healthySteps: entity.healthySteps,
        calories: entity.calories,
        healthyCalories: entity.healthyCalories,
      );
    } catch (e) {
      throw MapperException<RecipeDBEntity, Recipe>(e.toString());
    }
  }

  List<Recipe> toAssetsFromDb(List<RecipeDBEntity> entities) {
    final List<Recipe> assets = [];
    for (final entity in entities) {
      assets.add(toAssetFromDb(entity));
    }
    return assets;
  }

  RecipeDBEntity toAssetDbEntity(Recipe asset) {
    try {
      return RecipeDBEntity(
        id: asset.id,
        isFavorite: 0,
        title: asset.title,
        description: asset.description,
        photoUrl: asset.photoUrl,
        ingredients: asset.ingredients,
        steps: asset.steps,
        healthyIngredients: asset.healthyIngredients,
        healthySteps: asset.healthySteps,
        calories: asset.calories,
        healthyCalories: asset.healthyCalories,
      );
    } catch (e) {
      throw MapperException<Recipe, RecipeDBEntity>(e.toString());
    }
  }

  List<RecipeDBEntity> toAssetsDbEntity(List<Recipe> assets) {
    final List<RecipeDBEntity> list = [];
    for (final asset in assets) {
      list.add(toAssetDbEntity(asset));
    }
    return list;
  }

  UserData toUserData(UserResponse response) {
    try {
      return UserData(
        uid: response.data.uid,
        username: response.data.username,
        email: response.data.email,
        imageUrl: response.data.imageUrl,
        token: response.token,
        error: response.result.error,
        message: response.result.message,
      );
    } catch (e) {
      throw MapperException<UserResponse, UserData>(e.toString());
    }
  }

  Recipe toRecipe(RecipeEntity entity) {
    try {
      return Recipe(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        photoUrl: entity.photoUrl,
        ingredients: entity.ingredients,
        steps: entity.steps,
        healthyIngredients: entity.healthyIngredients,
        healthySteps: entity.healthySteps,
        calories: entity.calories,
        healthyCalories: entity.healthyCalories,
      );
    } catch (e) {
      throw MapperException<RecipeEntity, Recipe>(e.toString());
    }
  }

  List<Recipe> toRecipes(List<RecipeEntity> entities) {
    return entities.map((entity) => toRecipe(entity)).toList();
  }

  DailyCalories toDailyCalories(DailyCaloriesEntity entity) {
    try {
      return DailyCalories(
        hari: entity.hari,
        ishealthy: entity.ishealthy,
        idMakanan: entity.idMakanan,
        jumlahPorsi: entity.jumlahPorsi,
        id: entity.id,
        idUser: entity.idUser,
        calories: entity.calories,
        healthyCalories: entity.healthyCalories,
        jenisAsupan: entity.jenisAsupan,
      );
    } catch (e) {
      throw MapperException<DailyCaloriesEntity, DailyCalories>(e.toString());
    }
  }

  List<DailyCalories> toDailyCaloriess(List<DailyCaloriesEntity> entities) {
    return entities.map((entity) => toDailyCalories(entity)).toList();
  }


  TargetCalories toTargetCalories(TargetCaloriesEntity entity){
    try{
      return TargetCalories(
        hari: entity.hari,
        idUser: entity.idUser,
        targetCalories: entity.target_kalori,
      );
    }catch(e){
      throw MapperException<TargetCaloriesEntity, TargetCalories>(e.toString());
    }
  }

  SearchHistory toSearchHistory(HistoryResponse response) {
    try {
      return SearchHistory(
        idMakanan: response.idMakanan,
        idUser: response.idUser,
        timestamp: response.timestamp,
      );
    } catch (e) {
      throw MapperException<HistoryResponse, SearchHistory>(e.toString());
    }
  }

  List<SearchHistory> toSearchHistories(List<HistoryResponse> responses) {
    return responses.map((response) => toSearchHistory(response)).toList();
  }

  Result toResult(ResultEntity entity) {
    try {
      return Result(
        error: entity.error,
        message: entity.message,
      );
    } catch (e) {
      throw MapperException<ResultEntity, Result>(e.toString());
    }
  }
}
