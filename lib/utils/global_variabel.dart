import '../data/local/db/recipe_dao.dart';
import '../data/remote/api/api_service.dart';
import 'mapper.dart';

final mapper = Mapper();

final recipeDao = RecipeDao();
final apiService = ApiService(
    baseUrl: 'https://myfoods-backend-dot-warm-tome-428215-f7.et.r.appspot.com');
