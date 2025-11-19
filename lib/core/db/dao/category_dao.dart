import '../app_database.dart';
import '../../models/category.dart';

class CategoryDao {
  final AppDatabase _db = AppDatabase();

  // Create
  Future<int> insert(Category category) async {
    final db = await _db.database;
    return await db.insert('categories', category.toMap());
  }

  // Read
  Future<Category?> getById(int id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  Future<List<Category>> getByUserId(int userId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'user_id = ? OR user_id = 0',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<List<Category>> getActiveByUserId(int userId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: '(user_id = ? OR user_id = 0) AND is_active = 1',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<List<Category>> getByType(int userId, String type) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: '(user_id = ? OR user_id = 0) AND type = ? AND is_active = 1',
      whereArgs: [userId, type],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  // Update
  Future<int> update(Category category) async {
    final db = await _db.database;
    return await db.update(
      'categories',
      category.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // Delete
  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      'categories',
      where: 'id = ? AND user_id != 0',
      whereArgs: [id],
    );
  }

  // Soft delete (deactivate)
  Future<int> deactivate(int id) async {
    final db = await _db.database;
    return await db.update(
      'categories',
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> activate(int id) async {
    final db = await _db.database;
    return await db.update(
      'categories',
      {
        'is_active': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
