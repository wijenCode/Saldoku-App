import '../app_database.dart';
import '../../models/investment.dart';

class InvestmentDao {
  final AppDatabase _db = AppDatabase();

  // Create
  Future<int> insert(Investment investment) async {
    final db = await _db.database;
    return await db.insert('investments', investment.toMap());
  }

  // Read
  Future<Investment?> getById(int id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'investments',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Investment.fromMap(maps.first);
  }

  Future<List<Investment>> getByUserId(int userId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'investments',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'purchase_date DESC',
    );
    return List.generate(maps.length, (i) => Investment.fromMap(maps[i]));
  }

  Future<List<Investment>> getActiveByUserId(int userId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'investments',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'active'],
      orderBy: 'purchase_date DESC',
    );
    return List.generate(maps.length, (i) => Investment.fromMap(maps[i]));
  }

  Future<List<Investment>> getByType(int userId, String type) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'investments',
      where: 'user_id = ? AND type = ?',
      whereArgs: [userId, type],
      orderBy: 'purchase_date DESC',
    );
    return List.generate(maps.length, (i) => Investment.fromMap(maps[i]));
  }

  Future<List<Investment>> getByStatus(int userId, String status) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'investments',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, status],
      orderBy: 'purchase_date DESC',
    );
    return List.generate(maps.length, (i) => Investment.fromMap(maps[i]));
  }

  // Update
  Future<int> update(Investment investment) async {
    final db = await _db.database;
    return await db.update(
      'investments',
      investment.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [investment.id],
    );
  }

  Future<int> updateCurrentAmount(int id, double amount) async {
    final db = await _db.database;
    return await db.update(
      'investments',
      {
        'current_amount': amount,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateStatus(int id, String status) async {
    final db = await _db.database;
    return await db.update(
      'investments',
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
      'investments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistics
  Future<double> getTotalInvestment(int userId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(initial_amount) as total FROM investments WHERE user_id = ? AND status = ?',
      [userId, 'active'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalCurrentValue(int userId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(current_amount) as total FROM investments WHERE user_id = ? AND status = ?',
      [userId, 'active'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalProfit(int userId) async {
    final totalCurrent = await getTotalCurrentValue(userId);
    final totalInitial = await getTotalInvestment(userId);
    return totalCurrent - totalInitial;
  }
}
