import 'package:flutter/foundation.dart' hide Category;
import '../../../core/models/transaction.dart';
import '../../../core/models/wallet.dart';
import '../../../core/models/category.dart';
import '../data/transactions_repository.dart';

/// Provider untuk state management transaksi
class TransactionsProvider extends ChangeNotifier {
  final TransactionsRepository _repository = TransactionsRepository();

  List<Transaction> _transactions = [];
  List<Wallet> _wallets = [];
  List<Category> _incomeCategories = [];
  List<Category> _expenseCategories = [];
  bool _isLoading = false;
  String? _error;
  String _filterType = 'all'; // all, income, expense
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  List<Transaction> get transactions {
    if (_filterType == 'income') {
      return _transactions.where((t) => t.type == 'income').toList();
    } else if (_filterType == 'expense') {
      return _transactions.where((t) => t.type == 'expense').toList();
    }
    return _transactions;
  }

  List<Wallet> get wallets => _wallets;
  List<Category> get incomeCategories => _incomeCategories;
  List<Category> get expenseCategories => _expenseCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterType => _filterType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  /// Load transactions
  Future<void> loadTransactions(int userId, {int? limit}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_startDate != null && _endDate != null) {
        _transactions = await _repository.getTransactionsByDateRange(
          userId,
          _startDate!,
          _endDate!,
        );
      } else {
        _transactions = await _repository.getTransactions(userId, limit: limit);
      }
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat transaksi: $e';
      _transactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load wallets and categories
  Future<void> loadFormData(int userId) async {
    try {
      _wallets = await _repository.getActiveWallets(userId);
      _incomeCategories = await _repository.getActiveCategories(userId, 'income');
      _expenseCategories = await _repository.getActiveCategories(userId, 'expense');
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat data: $e';
      notifyListeners();
    }
  }

  /// Set filter type
  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  /// Set date range filter
  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  /// Clear date filter
  void clearDateFilter() {
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  /// Create transaction
  Future<Map<String, dynamic>> createTransaction({
    required int userId,
    required int walletId,
    required int categoryId,
    required String type,
    required double amount,
    DateTime? date,
    String? description,
  }) async {
    final result = await _repository.createTransaction(
      userId: userId,
      walletId: walletId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      date: date,
      description: description,
    );

    if (result['success']) {
      await loadTransactions(userId);
    }

    return result;
  }

  /// Update transaction
  Future<Map<String, dynamic>> updateTransaction(
    int userId,
    Transaction oldTransaction,
    Transaction newTransaction,
  ) async {
    final result = await _repository.updateTransaction(
      oldTransaction,
      newTransaction,
    );

    if (result['success']) {
      await loadTransactions(userId);
    }

    return result;
  }

  /// Delete transaction
  Future<Map<String, dynamic>> deleteTransaction(
    int userId,
    int transactionId,
  ) async {
    final result = await _repository.deleteTransaction(transactionId);

    if (result['success']) {
      await loadTransactions(userId);
    }

    return result;
  }

  /// Get statistics
  Future<Map<String, double>> getStatistics(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _repository.getStatistics(userId, startDate, endDate);
  }
}
