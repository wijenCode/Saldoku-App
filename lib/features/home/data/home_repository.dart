import '../../../core/db/dao/wallet_dao.dart';
import '../../../core/db/dao/transaction_dao.dart';
import '../../../core/models/transaction.dart';

/// Repository untuk mengelola data home dashboard
class HomeRepository {
  late final WalletDao _walletDao;
  late final TransactionDao _transactionDao;

  HomeRepository() {
    _walletDao = WalletDao();
    _transactionDao = TransactionDao();
  }

  /// Get total balance dari semua wallet user
  Future<double> getTotalBalance(int userId) async {
    try {
      final wallets = await _walletDao.getActiveByUserId(userId);
      double total = 0.0;
      for (var wallet in wallets) {
        total += wallet.balance;
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get monthly income & expense statistics
  Future<Map<String, double>> getMonthlyStats(int userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final transactions = await _transactionDao.getByDateRange(
        userId,
        startOfMonth,
        endOfMonth,
      );

      double income = 0.0;
      double expense = 0.0;

      for (var transaction in transactions) {
        if (transaction.type.toLowerCase() == 'income') {
          income += transaction.amount;
        } else if (transaction.type.toLowerCase() == 'expense') {
          expense += transaction.amount;
        }
      }

      return {
        'income': income,
        'expense': expense,
        'net': income - expense,
      };
    } catch (e) {
      return {
        'income': 0.0,
        'expense': 0.0,
        'net': 0.0,
      };
    }
  }

  /// Get recent transactions (latest 5)
  Future<List<Transaction>> getRecentTransactions(int userId) async {
    try {
      return await _transactionDao.getByUserId(userId, limit: 5);
    } catch (e) {
      return [];
    }
  }

  /// Get pending notifications count (bills due, budget exceeded, etc)
  Future<int> getNotificationCount(int userId) async {
    try {
      // TODO: Implement actual notification count logic
      // For now return 0, nanti bisa ambil dari:
      // - Bills yang jatuh tempo dalam 3 hari
      // - Budget yang sudah exceeded
      // - Savings goal yang hampir tercapai
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Refresh all dashboard data
  Future<Map<String, dynamic>> refreshDashboard(int userId) async {
    try {
      final balance = await getTotalBalance(userId);
      final stats = await getMonthlyStats(userId);
      final transactions = await getRecentTransactions(userId);
      final notificationCount = await getNotificationCount(userId);

      return {
        'balance': balance,
        'monthlyIncome': stats['income'],
        'monthlyExpense': stats['expense'],
        'monthlyNet': stats['net'],
        'recentTransactions': transactions,
        'notificationCount': notificationCount,
      };
    } catch (e) {
      return {
        'balance': 0.0,
        'monthlyIncome': 0.0,
        'monthlyExpense': 0.0,
        'monthlyNet': 0.0,
        'recentTransactions': <Transaction>[],
        'notificationCount': 0,
      };
    }
  }
}

