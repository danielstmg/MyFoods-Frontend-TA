import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:recepku/data/domain/recipe.dart';
import 'package:recepku/data/local/db/recipe_dao.dart';
import 'package:recepku/data/repository/calories_repository.dart';
import '../../data/local/entity/recipe_db_entity.dart';

Future<bool?> showAddDialog(BuildContext context, String token, String day) async {
  final TextEditingController portionController = TextEditingController();
  int isHealthy = 0;
  String? selectedFoodId;
  Recipe? selectedFood;
  Map<String, Recipe>? foodOptions;
  String? selectedMealType;

  try {
    foodOptions = await fetchFoodOptions();
  } catch (e) {
    print("Error fetching food options: $e");
    foodOptions = {};
  }

  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text("Add New Food"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: selectedFoodId,
                  hint: const Text("Select Food Name"),
                  isExpanded: true,
                  items: foodOptions?.values.map((food) {
                    return DropdownMenuItem<String>(
                      value: food.id.toString(),
                      child: Text(
                        food.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFoodId = newValue;
                      selectedFood = foodOptions?[newValue!];
                    });
                  },
                ),
                if (selectedFood != null) ...[
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Calories: ${selectedFood!.calories}",
                          style: TextStyle(
                            fontWeight: isHealthy == 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Healthy Calories: ${selectedFood!.healthyCalories}",
                          style: TextStyle(
                            fontWeight: isHealthy == 1 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: Text("Is Healthy"),
                    ),
                    Switch(
                      value: isHealthy == 1,
                      onChanged: (value) {
                        setState(() {
                          isHealthy = value ? 1 : 0;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: portionController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Portion",
                  ),
                ),
                SizedBox(height: 16.0),
                DropdownButton<String>(
                  value: selectedMealType,
                  hint: const Text("Select Meal Type"),
                  isExpanded: true,
                  items: ['breakfast', 'lunch', 'dinner'].map((mealType) {
                    return DropdownMenuItem<String>(
                      value: mealType,
                      child: Text(mealType),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMealType = newValue;
                    });
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Close the dialog and return false
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  final portion = int.tryParse(portionController.text) ?? 0;

                  if (selectedFoodId == null || selectedMealType == null || portion == 0) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Validation Error"),
                          content: const Text("Fill the form"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                    return; // Exit the method early if validation fails
                  }

                  try {
                    final apiProvider = Provider.of<CaloriesRepository>(context, listen: false);
                    await apiProvider.addAsupanHarianByDay(
                      token,
                      day,
                      selectedFoodId.toString(),
                      portion,
                      selectedMealType!,
                      isHealthy,
                    );

                    Navigator.of(context).pop(true); // Return true to indicate success
                  } catch (e) {
                    print('Error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add daily calories')),
                    );
                    Navigator.of(context).pop(false); // Close the dialog and return false
                  }
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      );
    },
  ) ?? Future.value(false); // Ensure the return type is Future<bool>
}


Future<Map<String, Recipe>> fetchFoodOptions() async {
  final dao = RecipeDao();
  final List<RecipeDBEntity> recipes = await dao.selectAll();

  return {
    for (var recipe in recipes)
      recipe.id.toString(): Recipe(
        id: recipe.id,
        title: recipe.title,
        calories: recipe.calories,
        healthyCalories: recipe.healthyCalories,
        description: recipe.description,
        photoUrl: recipe.photoUrl,
      ),
  };
}
