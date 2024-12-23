class RecipeResponse {
  final List<RecipeEntity> data;

  RecipeResponse({required this.data});

  factory RecipeResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>;

    final List<RecipeEntity> entities = [];
    for (final element in data) {
      entities.add(RecipeEntity.fromJson(element));
    }

    return RecipeResponse(data: entities);
  }
}

class RecipeEntity {
  final int id;
  final String title;
  final String description;
  final String photoUrl;
  final List<String>? ingredients;
  final List<String>? steps;
  final List<String>? healthyIngredients;
  final List<String>? healthySteps;
  final int calories;
  final int healthyCalories;

  const RecipeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.photoUrl,
    this.ingredients,
    this.steps,
    this.healthyIngredients,
    this.healthySteps,
    required this.calories,
    required this.healthyCalories,
  });

  RecipeEntity.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int? ?? 0,
        title = json['title'] as String,
        description = json['description'] as String,
        photoUrl = json['photoUrl'] as String,
        ingredients = json['ingredients'] != null
            ? List<String>.from(json['ingredients'])
            : null,
        steps = json['steps'] != null ? List<String>.from(json['steps']) : null,
        healthyIngredients =json['healthyIngredients'] != null
            ? List<String>.from(json['healthyIngredients'])
            : null,
        healthySteps = json['healthySteps'] != null
            ? List<String>.from(json['healthySteps'])
            : null,
        calories = json['calories'] as int? ?? 0,
        healthyCalories = json['healthyCalories'] as int? ?? 0;
  }
