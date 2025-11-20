import 'package:flutter/material.dart';
import '../data/reports_repository.dart';

class LaporanProvider extends ChangeNotifier {
  final LaporanRepository _repo = LaporanRepository();

  bool isLoading = false;
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  double balance = 0.0;
  double totalWallets = 0.0;
  List<Map<String, dynamic>> topCategories = [];
  List<Map<String, dynamic>> wallets = [];

  Future<void> loadReport(int userId, DateTime start, DateTime end) async {
    isLoading = true;
    notifyListeners();
    try {
      final summary = await _repo.incomeExpenseSummary(userId, start, end);
      totalIncome = summary['income'] ?? 0.0;
      totalExpense = summary['expense'] ?? 0.0;
      balance = summary['balance'] ?? (totalIncome - totalExpense);

      totalWallets = await _repo.totalBalance(userId);
      topCategories = await _repo.topExpenseCategories(userId, start, end);
      wallets = await _repo.walletsSummary(userId);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
