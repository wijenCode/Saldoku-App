import '../app_database.dart';
import '../../models/transaction.dart';

class TransactionDao {
  final AppDatabase _db = AppDatabase();

  // Create
  Future<int> insert(Transaction transaction) async {
    final db = await _db.database;
    return await db.insert('transactions', transaction.toMap());
  }

  // Read
  Future<Transaction?> getById(int id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Transaction.fromMap(maps.first);
  }

  Future<List<Transaction>> getByUserId(int userId, {int? limit}) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, created_at DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<List<Transaction>> getByWalletId(int walletId, {int? limit}) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'wallet_id = ?',
      whereArgs: [walletId],
      orderBy: 'date DESC, created_at DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<List<Transaction>> getByDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<List<Transaction>> getByType(int userId, String type) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'user_id = ? AND type = ?',
      whereArgs: [userId, type],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<List<Transaction>> getByCategoryId(int categoryId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  // Update
  Future<int> update(Transaction transaction) async {
    final db = await _db.database;
    return await db.update(
      'transactions',
      transaction.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Delete
  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistics
  Future<double> getTotalIncome(int userId, DateTime startDate, DateTime endDate) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE user_id = ? AND type = ? AND date >= ? AND date <= ?',
      [userId, 'income', startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalExpense(int userId, DateTime startDate, DateTime endDate) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE user_id = ? AND type = ? AND date >= ? AND date <= ?',
      [userId, 'expense', startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalByCategoryId(int categoryId, DateTime startDate, DateTime endDate) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE category_id = ? AND date >= ? AND date <= ?',
      [categoryId, startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getIncomeExpenseSummary(int userId, DateTime startDate, DateTime endDate) async {
    final income = await getTotalIncome(userId, startDate, endDate);
    final expense = await getTotalExpense(userId, startDate, endDate);
    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }
}
