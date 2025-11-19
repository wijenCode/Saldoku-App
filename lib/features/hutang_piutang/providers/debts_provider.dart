import '../../../core/models/debt.dart';
import '../../../core/models/debt_payment.dart';
import '../data/debts_repository.dart';

/// Provider untuk mengelola state hutang/piutang
class DebtsProvider {
  final _repository = DebtsRepository();

  /// State untuk list hutang/piutang
  List<Debt> _debts = [];
  List<Debt> _unpaidDebts = [];
  List<Debt> _unpaidReceivables = [];
  List<Debt> _overdueDebts = [];
  double _totalUnpaidDebt = 0;
  double _totalUnpaidReceivable = 0;
  int _overdueCount = 0;
  bool _isLoading = false;
  String? _error;

  /// Getter untuk mengakses state
  List<Debt> get debts => _debts;
  List<Debt> get unpaidDebts => _unpaidDebts;
  List<Debt> get unpaidReceivables => _unpaidReceivables;
  List<Debt> get overdueDebts => _overdueDebts;
  double get totalUnpaidDebt => _totalUnpaidDebt;
  double get totalUnpaidReceivable => _totalUnpaidReceivable;
  int get overdueCount => _overdueCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load semua hutang/piutang untuk user
  Future<void> loadDebts(int userId) async {
    try {
      _isLoading = true;
      _error = null;

      _debts = await _repository.getAllDebts(userId);
      _unpaidDebts = await _repository.getDebtsByType(userId, 'debt');
      _unpaidReceivables = await _repository.getDebtsByType(
        userId,
        'receivable',
      );
      _overdueDebts = await _repository.getOverdueDebts(userId);
      _totalUnpaidDebt = await _repository.getTotalUnpaidDebt(userId);
      _totalUnpaidReceivable = await _repository.getTotalUnpaidReceivable(
        userId,
      );
      _overdueCount = await _repository.getOverdueCount(userId);

      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      rethrow;
    }
  }

  /// Ambil hutang berdasarkan tipe
  Future<List<Debt>> getDebtsByType(int userId, String type) async {
    try {
      _error = null;
      return await _repository.getDebtsByType(userId, type);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Ambil hutang berdasarkan ID
  Future<Debt?> getDebtById(int debtId) async {
    try {
      _error = null;
      return await _repository.getDebtById(debtId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Buat hutang/piutang baru
  Future<int> createDebt(Debt debt, int userId) async {
    try {
      _error = null;
      final id = await _repository.createDebt(debt);

      // Reload data
      await loadDebts(userId);

      return id;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Update hutang/piutang
  Future<bool> updateDebt(Debt debt, int userId) async {
    try {
      _error = null;
      final result = await _repository.updateDebt(debt);

      if (result) {
        // Reload data
        await loadDebts(userId);
      }

      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Hapus hutang/piutang
  Future<bool> deleteDebt(int debtId, int userId) async {
    try {
      _error = null;
      final result = await _repository.deleteDebt(debtId);

      if (result) {
        // Reload data
        await loadDebts(userId);
      }

      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Buat pembayaran hutang
  Future<int> createDebtPayment(DebtPayment payment, int userId) async {
    try {
      _error = null;
      final id = await _repository.createDebtPayment(payment);

      // Reload data
      await loadDebts(userId);

      return id;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Ambil pembayaran hutang
  Future<List<DebtPayment>> getDebtPayments(int debtId) async {
    try {
      _error = null;
      return await _repository.getDebtPayments(debtId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Tandai hutang sebagai dibayar
  Future<bool> markAsPaid(int debtId, int userId) async {
    try {
      _error = null;
      final result = await _repository.markAsPaid(debtId);

      if (result) {
        // Reload data
        await loadDebts(userId);
      }

      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Clear semua data
  void clear() {
    _debts = [];
    _unpaidDebts = [];
    _unpaidReceivables = [];
    _overdueDebts = [];
    _totalUnpaidDebt = 0;
    _totalUnpaidReceivable = 0;
    _overdueCount = 0;
    _isLoading = false;
    _error = null;
  }
}
