import '../../../core/db/dao/investment_dao.dart';
import '../../../core/models/investment.dart';

class InvestmentRepository {
  final InvestmentDao _investmentDao = InvestmentDao();

  // Get all investments
  Future<List<Investment>> getInvestments(int userId) async {
    return await _investmentDao.getByUserId(userId);
  }

  // Get investments by status
  Future<List<Investment>> getInvestmentsByStatus(int userId, String status) async {
    return await _investmentDao.getByStatus(userId, status);
  }

  // Get investments by type
  Future<List<Investment>> getInvestmentsByType(int userId, String type) async {
    return await _investmentDao.getByType(userId, type);
  }

  // Get single investment
  Future<Investment?> getInvestmentById(int id) async {
    return await _investmentDao.getById(id);
  }

  // Create investment
  Future<int> createInvestment(Investment investment) async {
    return await _investmentDao.insert(investment);
  }

  // Update investment
  Future<int> updateInvestment(Investment investment) async {
    return await _investmentDao.update(investment);
  }

  // Update current amount
  Future<int> updateCurrentAmount(int id, double amount) async {
    return await _investmentDao.updateCurrentAmount(id, amount);
  }

  // Update status (sell/close investment)
  Future<int> updateStatus(int id, String status) async {
    return await _investmentDao.updateStatus(id, status);
  }

  // Delete investment
  Future<int> deleteInvestment(int id) async {
    return await _investmentDao.delete(id);
  }

  // Get portfolio statistics
  Future<Map<String, double>> getPortfolioStatistics(int userId) async {
    final totalInvestment = await _investmentDao.getTotalInvestment(userId);
    final totalCurrentValue = await _investmentDao.getTotalCurrentValue(userId);
    final totalProfit = await _investmentDao.getTotalProfit(userId);
    
    final profitPercentage = totalInvestment > 0 
        ? ((totalCurrentValue - totalInvestment) / totalInvestment * 100) 
        : 0.0;

    return {
      'totalInvestment': totalInvestment,
      'totalCurrentValue': totalCurrentValue,
      'totalProfit': totalProfit,
      'profitPercentage': profitPercentage,
    };
  }

  // Get investment types distribution
  Future<Map<String, double>> getTypeDistribution(int userId) async {
    final investments = await _investmentDao.getActiveByUserId(userId);
    final Map<String, double> distribution = {};

    for (var investment in investments) {
      distribution[investment.type] = 
          (distribution[investment.type] ?? 0) + investment.currentAmount;
    }

    return distribution;
  }
}
