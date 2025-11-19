import '../app_database.dart';
import '../../models/budget.dart';

class BudgetDao {
  final AppDatabase _db = AppDatabase();

  // Create
  Future<int> insert(Budget budget) async {
    final db = await _db.database;
    return await db.insert('budgets', budget.toMap());
  }

  // Read
  Future<Budget?> getById(int id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Budget.fromMap(maps.first);
  }

  Future<List<Budget>> getByUserId(int userId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'period_start DESC',
    );
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  Future<List<Budget>> getActiveByUserId(int userId) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'user_id = ? AND is_active = 1 AND period_end >= ?',
      whereArgs: [userId, now],
      orderBy: 'period_start DESC',
    );
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  Future<List<Budget>> getByPeriod(int userId, DateTime startDate, DateTime endDate) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'user_id = ? AND period_start >= ? AND period_end <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'period_start DESC',
    );
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  // Update
  Future<int> update(Budget budget) async {
    final db = await _db.database;
    return await db.update(
      'budgets',
      budget.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> updateSpent(int id, double spent) async {
    final db = await _db.database;
    return await db.update(
      'budgets',
      {
        'spent': spent,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> addToSpent(int id, double amount) async {
    final budget = await getById(id);
    if (budget == null) return 0;
    return await updateSpent(id, budget.spent + amount);
  }

  // Delete
  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get over-budget items
  Future<List<Budget>> getOverBudget(int userId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM budgets WHERE user_id = ? AND spent > amount AND is_active = 1',
      [userId],
    );
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }
}
