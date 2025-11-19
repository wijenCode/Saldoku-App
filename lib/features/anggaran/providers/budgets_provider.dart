import '../../../core/models/budget.dart';
import '../data/budgets_repository.dart';

/// Provider untuk mengelola state budget/anggaran bulanan
class BudgetsProvider {
  final _repository = BudgetsRepository();

  /// State untuk list budget
  List<Budget> _budgets = [];
  List<Budget> _currentMonthBudgets = [];
  List<Budget> _overBudgets = [];
  double _totalRemaining = 0;
  double _overallPercentage = 0;
  bool _isLoading = false;
  String? _error;

  /// Getter untuk mengakses state
  List<Budget> get budgets => _budgets;
  List<Budget> get currentMonthBudgets => _currentMonthBudgets;
  List<Budget> get overBudgets => _overBudgets;
  double get totalRemaining => _totalRemaining;
  double get overallPercentage => _overallPercentage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load semua budget untuk user
  Future<void> loadBudgets(int userId) async {
    try {
      _isLoading = true;
      _error = null;

      _budgets = await _repository.getAllBudgets(userId);
      _currentMonthBudgets = await _repository.getCurrentMonthBudgets(userId);
      _overBudgets = await _repository.getOverBudgets(userId);
      _totalRemaining = await _repository.getTotalRemaining(userId);
      _overallPercentage = await _repository.getOverallPercentage(userId);

      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      rethrow;
    }
  }

  /// Ambil budget berdasarkan ID
  Future<Budget?> getBudgetById(int budgetId) async {
    try {
      _error = null;
      return await _repository.getBudgetById(budgetId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Buat budget baru
  Future<int> createBudget(Budget budget, int userId) async {
    try {
      _error = null;
      final id = await _repository.createBudget(budget);

      // Reload data
      await loadBudgets(userId);

      return id;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Update budget
  Future<bool> updateBudget(Budget budget, int userId) async {
    try {
      _error = null;
      final result = await _repository.updateBudget(budget);

      if (result) {
        // Reload data
        await loadBudgets(userId);
      }

      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Hapus budget
  Future<bool> deleteBudget(int budgetId, int userId) async {
    try {
      _error = null;
      final result = await _repository.deleteBudget(budgetId);

      if (result) {
        // Reload data
        await loadBudgets(userId);
      }

      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Update pengeluaran budget
  Future<bool> updateSpent(int budgetId, double newSpent, int userId) async {
    try {
      _error = null;
      final result = await _repository.updateSpent(budgetId, newSpent);

      if (result) {
        // Reload data
        await loadBudgets(userId);
      }

      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Dapatkan budget berdasarkan kategori
  Future<List<Budget>> getBudgetsByCategory(int userId, int categoryId) async {
    try {
      _error = null;
      return await _repository.getBudgetsByCategory(userId, categoryId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Clear semua data
  void clear() {
    _budgets = [];
    _currentMonthBudgets = [];
    _overBudgets = [];
    _totalRemaining = 0;
    _overallPercentage = 0;
    _isLoading = false;
    _error = null;
  }
}
