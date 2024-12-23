class Recipe {
  final int id;
  final int isFavorite;
  final String title;
  final String description;
  final String photoUrl;
  final List<String>? ingredients;
  final List<String>? steps;
  final List<String>? healthyIngredients;
  final List<String>? healthySteps;
  final int calories;
  final int healthyCalories;

  Recipe({
    required this.id,
    this.isFavorite = 0,
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
}
