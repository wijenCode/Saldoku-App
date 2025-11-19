import '../../../core/db/dao/transaction_dao.dart';
import '../../../core/db/dao/wallet_dao.dart';
import '../../../core/db/dao/category_dao.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/wallet.dart';
import '../../../core/models/category.dart';

/// Repository untuk mengelola transaksi harian
class TransactionsRepository {
  late final TransactionDao _transactionDao;
  late final WalletDao _walletDao;
  late final CategoryDao _categoryDao;

  TransactionsRepository() {
    _transactionDao = TransactionDao();
    _walletDao = WalletDao();
    _categoryDao = CategoryDao();
  }

  /// Get all transactions by user
  Future<List<Transaction>> getTransactions(int userId, {int? limit}) async {
    try {
      return await _transactionDao.getByUserId(userId, limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Get transactions by date range
  Future<List<Transaction>> getTransactionsByDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _transactionDao.getByDateRange(userId, startDate, endDate);
    } catch (e) {
      return [];
    }
  }

  /// Get transactions by type (income/expense)
  Future<List<Transaction>> getTransactionsByType(
    int userId,
    String type,
  ) async {
    try {
      return await _transactionDao.getByType(userId, type);
    } catch (e) {
      return [];
    }
  }

  /// Get transactions by wallet
  Future<List<Transaction>> getTransactionsByWallet(
    int walletId, {
    int? limit,
  }) async {
    try {
      return await _transactionDao.getByWalletId(walletId, limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Get transaction by id
  Future<Transaction?> getTransactionById(int id) async {
    try {
      return await _transactionDao.getById(id);
    } catch (e) {
      return null;
    }
  }

  /// Get wallet by id
  Future<Wallet?> getWalletById(int id) async {
    try {
      return await _walletDao.getById(id);
    } catch (e) {
      return null;
    }
  }

  /// Get category by id
  Future<Category?> getCategoryById(int id) async {
    try {
      return await _categoryDao.getById(id);
    } catch (e) {
      return null;
    }
  }

  /// Get active wallets
  Future<List<Wallet>> getActiveWallets(int userId) async {
    try {
      return await _walletDao.getActiveByUserId(userId);
    } catch (e) {
      return [];
    }
  }

  /// Get active categories by type
  Future<List<Category>> getActiveCategories(int userId, String type) async {
    try {
      return await _categoryDao.getByType(userId, type);
    } catch (e) {
      return [];
    }
  }

  /// Create new transaction (with wallet balance update)
  Future<Map<String, dynamic>> createTransaction({
    required int userId,
    required int walletId,
    required int categoryId,
    required String type,
    required double amount,
    DateTime? date,
    String? description,
  }) async {
    try {
      // Get wallet
      final wallet = await _walletDao.getById(walletId);
      if (wallet == null) {
        return {
          'success': false,
          'message': 'Dompet tidak ditemukan',
        };
      }

      // Check if wallet is active
      if (!wallet.isActive) {
        return {
          'success': false,
          'message': 'Dompet tidak aktif',
        };
      }

      // Check sufficient balance for expense
      if (type == 'expense' && wallet.balance < amount) {
        return {
          'success': false,
          'message': 'Saldo dompet tidak mencukupi',
        };
      }

      // Create transaction
      final transaction = Transaction(
        userId: userId,
        walletId: walletId,
        categoryId: categoryId,
        type: type,
        amount: amount,
        date: date ?? DateTime.now(),
        description: description,
      );

      final transactionId = await _transactionDao.insert(transaction);

      // Update wallet balance
      double newBalance = wallet.balance;
      if (type == 'income') {
        newBalance += amount;
      } else if (type == 'expense') {
        newBalance -= amount;
      }

      await _walletDao.updateBalance(walletId, newBalance);

      return {
        'success': true,
        'message': 'Transaksi berhasil ditambahkan',
        'transactionId': transactionId,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menambahkan transaksi: $e',
      };
    }
  }

  /// Update transaction (with wallet balance adjustment)
  Future<Map<String, dynamic>> updateTransaction(
    Transaction oldTransaction,
    Transaction newTransaction,
  ) async {
    try {
      // Get wallet
      final wallet = await _walletDao.getById(newTransaction.walletId);
      if (wallet == null) {
        return {
          'success': false,
          'message': 'Dompet tidak ditemukan',
        };
      }

      // Rollback old transaction from balance
      double adjustedBalance = wallet.balance;
      if (oldTransaction.type == 'income') {
        adjustedBalance -= oldTransaction.amount;
      } else if (oldTransaction.type == 'expense') {
        adjustedBalance += oldTransaction.amount;
      }

      // Apply new transaction to balance
      if (newTransaction.type == 'income') {
        adjustedBalance += newTransaction.amount;
      } else if (newTransaction.type == 'expense') {
        // Check sufficient balance
        if (adjustedBalance < newTransaction.amount) {
          return {
            'success': false,
            'message': 'Saldo dompet tidak mencukupi',
          };
        }
        adjustedBalance -= newTransaction.amount;
      }

      // Update transaction
      await _transactionDao.update(newTransaction);

      // Update wallet balance
      await _walletDao.updateBalance(newTransaction.walletId, adjustedBalance);

      return {
        'success': true,
        'message': 'Transaksi berhasil diperbarui',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui transaksi: $e',
      };
    }
  }

  /// Delete transaction (with wallet balance rollback)
  Future<Map<String, dynamic>> deleteTransaction(int transactionId) async {
    try {
      // Get transaction
      final transaction = await _transactionDao.getById(transactionId);
      if (transaction == null) {
        return {
          'success': false,
          'message': 'Transaksi tidak ditemukan',
        };
      }

      // Get wallet
      final wallet = await _walletDao.getById(transaction.walletId);
      if (wallet == null) {
        return {
          'success': false,
          'message': 'Dompet tidak ditemukan',
        };
      }

      // Rollback balance
      double newBalance = wallet.balance;
      if (transaction.type == 'income') {
        newBalance -= transaction.amount;
      } else if (transaction.type == 'expense') {
        newBalance += transaction.amount;
      }

      // Delete transaction
      await _transactionDao.delete(transactionId);

      // Update wallet balance
      await _walletDao.updateBalance(transaction.walletId, newBalance);

      return {
        'success': true,
        'message': 'Transaksi berhasil dihapus',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menghapus transaksi: $e',
      };
    }
  }

  /// Get statistics for date range
  Future<Map<String, double>> getStatistics(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final transactions = await _transactionDao.getByDateRange(
        userId,
        startDate,
        endDate,
      );

      double income = 0;
      double expense = 0;

      for (var transaction in transactions) {
        if (transaction.type == 'income') {
          income += transaction.amount;
        } else if (transaction.type == 'expense') {
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
        'income': 0,
        'expense': 0,
        'net': 0,
      };
    }
  }
}
