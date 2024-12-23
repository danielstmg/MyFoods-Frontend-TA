import 'package:flutter/material.dart';

@immutable
class RecipeDBEntity {
  const RecipeDBEntity({
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

  RecipeDBEntity.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        isFavorite = map['isFavorite'],
        title = map['title'],
        description = map['description'],
        photoUrl = map['photoUrl'],
        ingredients = map['ingredients']?.split("<"),
        steps = map['steps']?.split("<"),
        healthyIngredients = map['healthyIngredients']?.split("<"),
        healthySteps = map['healthySteps']?.split("<"),
        calories = map['calories'],
        healthyCalories = map['healthyCalories'];

  Map<String, dynamic> toMap() => {
        'id': id,
        'isFavorite': isFavorite,
        'title': title,
        'description': description,
        'photoUrl': photoUrl,
        'ingredients': ingredients?.join("<"),
        'steps': steps?.join("<"),
        'healthyIngredients': healthyIngredients?.join("<"),
        'healthySteps': healthySteps?.join("<"),
        'calories': calories,
        'healthyCalories': healthyCalories,
      };
}
