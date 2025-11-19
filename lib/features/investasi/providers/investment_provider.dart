import 'package:flutter/material.dart';
import '../../../core/models/investment.dart';
import '../../../core/services/auth_service.dart';
import '../data/investment_repository.dart';

class InvestmentProvider with ChangeNotifier {
  final InvestmentRepository _repository = InvestmentRepository();
  final AuthService _authService = AuthService();

  List<Investment> _investments = [];
  Map<String, double> _statistics = {};
  Map<String, double> _typeDistribution = {};
  bool _isLoading = false;
  String? _error;
  String _filterStatus = 'all'; // all, active, sold, matured

  List<Investment> get investments => _investments;
  Map<String, double> get statistics => _statistics;
  Map<String, double> get typeDistribution => _typeDistribution;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterStatus => _filterStatus;

  // Get filtered investments
  List<Investment> get filteredInvestments {
    if (_filterStatus == 'all') {
      return _investments;
    }
    return _investments.where((inv) => inv.status == _filterStatus).toList();
  }

  // Load investments
  Future<void> loadInvestments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }

      _investments = await _repository.getInvestments(user.id!);
      await _loadStatistics(user.id!);
      await _loadTypeDistribution(user.id!);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load statistics
  Future<void> _loadStatistics(int userId) async {
    _statistics = await _repository.getPortfolioStatistics(userId);
  }

  // Load type distribution
  Future<void> _loadTypeDistribution(int userId) async {
    _typeDistribution = await _repository.getTypeDistribution(userId);
  }

  // Set filter status
  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  // Create investment
  Future<bool> createInvestment({
    required String name,
    required String type,
    required double initialAmount,
    required double currentAmount,
    required DateTime purchaseDate,
    DateTime? maturityDate,
    String? notes,
  }) async {
    try {
      final user = await _authService.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }

      final investment = Investment(
        userId: user.id!,
        name: name,
        type: type,
        initialAmount: initialAmount,
        currentAmount: currentAmount,
        purchaseDate: purchaseDate,
        maturityDate: maturityDate,
        status: 'active',
        notes: notes,
      );

      await _repository.createInvestment(investment);
      await loadInvestments();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update investment
  Future<bool> updateInvestment(Investment investment) async {
    try {
      await _repository.updateInvestment(investment);
      await loadInvestments();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update current amount
  Future<bool> updateCurrentAmount(int id, double amount) async {
    try {
      await _repository.updateCurrentAmount(id, amount);
      await loadInvestments();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sell/close investment
  Future<bool> closeInvestment(int id, String status) async {
    try {
      await _repository.updateStatus(id, status);
      await loadInvestments();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete investment
  Future<bool> deleteInvestment(int id) async {
    try {
      await _repository.deleteInvestment(id);
      await loadInvestments();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
