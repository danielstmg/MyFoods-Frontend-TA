import 'package:recepku/data/local/entity/recipe_db_entity.dart';
import 'package:sqflite/sqflite.dart';
import 'base_dao.dart';

class RecipeDao extends BaseDao {
  Future<List<RecipeDBEntity>> selectAll() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps =
    await db.query(BaseDao.recipeTableName);
    return List.generate(maps.length, (i) => RecipeDBEntity.fromMap(maps[i]));
  }

  Future<void> insertAll(List<RecipeDBEntity> assets) async {
    final db = await getDatabase();
    final batch = db.batch();

    for (final asset in assets) {
      batch.insert(
        BaseDao.recipeTableName,
        asset.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<void> toggleFavorite(int id) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db
        .query(BaseDao.recipeTableName, where: 'id = ?', whereArgs: [id]);
    final isFavorite = maps[0]['isFavorite'] == 1;
    await db.update(BaseDao.recipeTableName, {'isFavorite': isFavorite ? 0 : 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isFavorite(int id) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db
        .query(BaseDao.recipeTableName, where: 'id = ?', whereArgs: [id]);
    return maps[0]['isFavorite'] == 1;
  }

  Future<List<RecipeDBEntity>> selectFavorite() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
        BaseDao.recipeTableName,
        where: 'isFavorite = ?',
        whereArgs: [1]);
    return List.generate(maps.length, (i) => RecipeDBEntity.fromMap(maps[i]));
  }

  Future<int> getIdByName(String name) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT id FROM ${BaseDao.recipeTableName} WHERE title = ? COLLATE NOCASE',
      [name],
    );
    print(maps.isNotEmpty ? maps[0]['id'] : "why");
    return maps.isNotEmpty ? maps[0]['id'] : null;
  }

  Future<RecipeDBEntity> selectById(int id) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db
        .query(BaseDao.recipeTableName, where: 'id = ?', whereArgs: [id]);
    return RecipeDBEntity.fromMap(maps[0]);
  }
}