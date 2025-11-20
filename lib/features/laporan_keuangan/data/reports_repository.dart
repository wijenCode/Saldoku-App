import '../../../core/db/dao/transaction_dao.dart';
import '../../../core/db/dao/wallet_dao.dart';
import '../../../core/db/app_database.dart';

class LaporanRepository {
  final TransactionDao _txDao = TransactionDao();
  final WalletDao _walletDao = WalletDao();
  final AppDatabase _db = AppDatabase();

  Future<Map<String, double>> incomeExpenseSummary(
    int userId,
    DateTime start,
    DateTime end,
  ) async {
    return await _txDao.getIncomeExpenseSummary(userId, start, end);
  }

  Future<double> totalBalance(int userId) async {
    return await _walletDao.getTotalBalance(userId);
  }

  Future<List<Map<String, dynamic>>> topExpenseCategories(
    int userId,
    DateTime start,
    DateTime end, {
    int limit = 5,
  }) async {
    final db = await _db.database;
    final results = await db.rawQuery(
      '''
      SELECT c.id, c.name, IFNULL(SUM(t.amount),0) as total
      FROM categories c
      LEFT JOIN transactions t ON t.category_id = c.id AND t.user_id = ? AND t.type = 'expense' AND t.date >= ? AND t.date <= ?
      WHERE c.user_id = 0 OR c.user_id = ?
      GROUP BY c.id
      HAVING total > 0
      ORDER BY total DESC
      LIMIT ?
    ''',
      [userId, start.toIso8601String(), end.toIso8601String(), userId, limit],
    );

    return results.map((r) => r.cast<String, dynamic>()).toList();
  }

  Future<List<Map<String, dynamic>>> walletsSummary(int userId) async {
    final wallets = await _walletDao.getByUserId(userId);
    return wallets
        .map((w) => {'id': w.id, 'name': w.name, 'balance': w.balance})
        .toList();
  }
}
