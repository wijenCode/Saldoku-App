import '../app_database.dart';
import '../../models/savings_goal.dart';

class SavingsGoalDao {
  final AppDatabase _db = AppDatabase();

  // Create
  Future<int> insert(SavingsGoal goal) async {
    final db = await _db.database;
    return await db.insert('savings_goals', goal.toMap());
  }

  // Read
  Future<SavingsGoal?> getById(int id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return SavingsGoal.fromMap(maps.first);
  }

  Future<List<SavingsGoal>> getByUserId(int userId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => SavingsGoal.fromMap(maps[i]));
  }

  Future<List<SavingsGoal>> getActiveByUserId(int userId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'active'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => SavingsGoal.fromMap(maps[i]));
  }

  Future<List<SavingsGoal>> getByStatus(int userId, String status) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, status],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => SavingsGoal.fromMap(maps[i]));
  }

  // Update
  Future<int> update(SavingsGoal goal) async {
    final db = await _db.database;
    return await db.update(
      'savings_goals',
      goal.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> updateCurrentAmount(int id, double amount) async {
    final db = await _db.database;
    return await db.update(
      'savings_goals',
      {
        'current_amount': amount,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> addToCurrentAmount(int id, double amount) async {
    final goal = await getById(id);
    if (goal == null) return 0;
    
    final newAmount = goal.currentAmount + amount;
    final newStatus = newAmount >= goal.targetAmount ? 'completed' : 'active';
    
    final db = await _db.database;
    return await db.update(
      'savings_goals',
      {
        'current_amount': newAmount,
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateStatus(int id, String status) async {
    final db = await _db.database;
    return await db.update(
      'savings_goals',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete
  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistics
  Future<double> getTotalTarget(int userId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(target_amount) as total FROM savings_goals WHERE user_id = ? AND status = ?',
      [userId, 'active'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalSaved(int userId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(current_amount) as total FROM savings_goals WHERE user_id = ? AND status = ?',
      [userId, 'active'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
