import '../../../core/models/savings_goal.dart';
import '../data/goals_repository.dart';

/// Provider untuk mengelola state target tabungan
class GoalsProvider {
  final _repo = GoalsRepository();

  List<SavingsGoal> _goals = [];
  double _totalSaved = 0.0;
  bool _isLoading = false;
  String? _error;

  List<SavingsGoal> get goals => _goals;
  double get totalSaved => _totalSaved;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGoals(int userId) async {
    try {
      _isLoading = true;
      _error = null;

      _goals = await _repo.getAllGoals(userId);
      _totalSaved = await _repo.getTotalSaved(userId);

      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      rethrow;
    }
  }

  Future<SavingsGoal?> getGoalById(int id) async {
    try {
      _error = null;
      return await _repo.getGoalById(id);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<int> createGoal(SavingsGoal goal, int userId) async {
    try {
      _error = null;
      final id = await _repo.createGoal(goal);
      await loadGoals(userId);
      return id;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<bool> updateGoal(SavingsGoal goal, int userId) async {
    try {
      _error = null;
      final result = await _repo.updateGoal(goal);
      if (result) await loadGoals(userId);
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<bool> deleteGoal(int goalId, int userId) async {
    try {
      _error = null;
      final result = await _repo.deleteGoal(goalId);
      if (result) await loadGoals(userId);
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<bool> deposit(int goalId, double amount, int userId) async {
    try {
      _error = null;
      final result = await _repo.depositToGoal(goalId, amount);
      if (result) await loadGoals(userId);
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  void clear() {
    _goals = [];
    _totalSaved = 0.0;
    _isLoading = false;
    _error = null;
  }
}
