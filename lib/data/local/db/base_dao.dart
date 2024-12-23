import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class BaseDao {
  static const databaseName = 'recipe.db';

  static const recipeTableName = 'recipe';

  @protected
  Future<Database> getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), databaseName),
      onCreate: (db, version) async {
        final batch = db.batch();
        _createAssetTable(batch);
        await batch.commit();
      },
      version: 1,
    );
  }

  void _createAssetTable(Batch batch) {
    batch.execute(
      '''
      CREATE TABLE $recipeTableName(
        id INTEGER PRIMARY KEY,
        isFavorite INTEGER,
        title TEXT,
        description TEXT,
        photoUrl TEXT,
        ingredients TEXT,
        steps TEXT,
        healthyIngredients TEXT,
        healthySteps TEXT,
        calories INTEGER,
        healthyCalories INTEGER
      );
      ''',
    );
  }
}
