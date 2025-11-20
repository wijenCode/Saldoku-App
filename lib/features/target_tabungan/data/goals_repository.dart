import '../../../core/models/savings_goal.dart';
import '../../../core/db/app_database.dart';

/// Repository untuk mengelola data target tabungan (savings goals)
class GoalsRepository {
  final _db = AppDatabase();

  Future<List<SavingsGoal>> getAllGoals(int userId) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'savings_goals',
        where: 'user_id = ? AND status != ?',
        whereArgs: [userId, 'cancelled'],
        orderBy: 'created_at DESC',
      );
      return maps.map((m) => SavingsGoal.fromMap(m)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil goals: $e');
    }
  }

  Future<SavingsGoal?> getGoalById(int goalId) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'savings_goals',
        where: 'id = ?',
        whereArgs: [goalId],
        limit: 1,
      );
      return maps.isEmpty ? null : SavingsGoal.fromMap(maps.first);
    } catch (e) {
      throw Exception('Gagal mengambil detail goal: $e');
    }
  }

  Future<int> createGoal(SavingsGoal goal) async {
    try {
      final database = await _db.database;
      final id = await database.insert('savings_goals', goal.toMap());
      return id;
    } catch (e) {
      throw Exception('Gagal membuat goal: $e');
    }
  }

  Future<bool> updateGoal(SavingsGoal goal) async {
    try {
      final database = await _db.database;
      final updated = await database.update(
        'savings_goals',
        goal.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [goal.id],
      );
      return updated > 0;
    } catch (e) {
      throw Exception('Gagal memperbarui goal: $e');
    }
  }

  Future<bool> deleteGoal(int goalId) async {
    try {
      final database = await _db.database;
      final deleted = await database.update(
        'savings_goals',
        {'status': 'cancelled', 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [goalId],
      );
      return deleted > 0;
    } catch (e) {
      throw Exception('Gagal menghapus goal: $e');
    }
  }

  Future<bool> depositToGoal(int goalId, double amount) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'savings_goals',
        where: 'id = ?',
        whereArgs: [goalId],
        limit: 1,
      );
      if (maps.isEmpty) return false;
      final goal = SavingsGoal.fromMap(maps.first);
      final newAmount = (goal.currentAmount + amount).clamp(
        0,
        goal.targetAmount,
      );
      final updated = await database.update(
        'savings_goals',
        {
          'current_amount': newAmount,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [goalId],
      );
      return updated > 0;
    } catch (e) {
      throw Exception('Gagal menambahkan dana ke goal: $e');
    }
  }

  Future<double> getTotalSaved(int userId) async {
    try {
      final database = await _db.database;
      final result = await database.rawQuery(
        'SELECT SUM(current_amount) as total FROM savings_goals WHERE user_id = ? AND status = ?',
        [userId, 'active'],
      );
      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('Gagal menghitung total tabungan tujuan: $e');
    }
  }
}
