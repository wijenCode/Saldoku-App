import '../app_database.dart';
import '../../models/debt.dart';
import '../../models/debt_payment.dart';

class DebtDao {
  final AppDatabase _db = AppDatabase();

  // Create
  Future<int> insert(Debt debt) async {
    final db = await _db.database;
    return await db.insert('debts', debt.toMap());
  }

  // Read
  Future<Debt?> getById(int id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'debts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Debt.fromMap(maps.first);
  }

  Future<List<Debt>> getByUserId(int userId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'debts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Debt.fromMap(maps[i]));
  }

  Future<List<Debt>> getByType(int userId, String type) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'debts',
      where: 'user_id = ? AND type = ?',
      whereArgs: [userId, type],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Debt.fromMap(maps[i]));
  }

  Future<List<Debt>> getByStatus(int userId, String status) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'debts',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, status],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Debt.fromMap(maps[i]));
  }

  Future<List<Debt>> getUnpaid(int userId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'debts',
      where: 'user_id = ? AND status != ?',
      whereArgs: [userId, 'paid'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Debt.fromMap(maps[i]));
  }

  // Update
  Future<int> update(Debt debt) async {
    final db = await _db.database;
    return await db.update(
      'debts',
      debt.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [debt.id],
    );
  }

  Future<int> updateRemainingAmount(int id, double amount) async {
    final db = await _db.database;
    final status = amount <= 0 ? 'paid' : (amount < (await getById(id))!.amount ? 'partially_paid' : 'unpaid');
    
    return await db.update(
      'debts',
      {
        'remaining_amount': amount,
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
      'debts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistics
  Future<double> getTotalDebt(int userId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(remaining_amount) as total FROM debts WHERE user_id = ? AND type = ? AND status != ?',
      [userId, 'debt', 'paid'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalReceivable(int userId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(remaining_amount) as total FROM debts WHERE user_id = ? AND type = ? AND status != ?',
      [userId, 'receivable', 'paid'],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Debt Payment operations
  Future<int> insertPayment(DebtPayment payment) async {
    final db = await _db.database;
    final debtId = payment.debtId;
    
    // Insert payment
    final paymentId = await db.insert('debt_payments', payment.toMap());
    
    // Update debt remaining amount
    final debt = await getById(debtId);
    if (debt != null) {
      final newRemaining = ((debt.remainingAmount - payment.amount).clamp(0, debt.amount)).toDouble();
      await updateRemainingAmount(debtId, newRemaining);
    }
    
    return paymentId;
  }

  Future<List<DebtPayment>> getPaymentsByDebtId(int debtId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'debt_payments',
      where: 'debt_id = ?',
      whereArgs: [debtId],
      orderBy: 'payment_date DESC',
    );
    return List.generate(maps.length, (i) => DebtPayment.fromMap(maps[i]));
  }

  Future<int> deletePayment(int paymentId) async {
    final db = await _db.database;
    return await db.delete(
      'debt_payments',
      where: 'id = ?',
      whereArgs: [paymentId],
    );
  }
}
