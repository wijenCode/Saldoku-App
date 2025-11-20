import '../../../core/models/bill.dart';
import '../data/bills_repository.dart';

/// Provider untuk mengelola state tagihan
class BillsProvider {
  final _repo = BillsRepository();

  List<Bill> _bills = [];
  List<Bill> _dueSoon = [];
  List<Bill> _overdue = [];
  double _totalPending = 0.0;
  bool _isLoading = false;
  String? _error;

  List<Bill> get bills => _bills;
  List<Bill> get dueSoon => _dueSoon;
  List<Bill> get overdue => _overdue;
  double get totalPending => _totalPending;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBills(int userId) async {
    try {
      _isLoading = true;
      _error = null;

      _bills = await _repo.getAllBills(userId);
      _dueSoon = await _repo.getDueSoonBills(userId);
      _overdue = await _repo.getOverdueBills(userId);
      _totalPending = await _repo.getTotalPendingAmount(userId);

      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      rethrow;
    }
  }

  Future<Bill?> getBillById(int billId) async {
    try {
      _error = null;
      return await _repo.getBillById(billId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<int> createBill(Bill bill, int userId) async {
    try {
      _error = null;
      final id = await _repo.createBill(bill);
      await loadBills(userId);
      return id;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<bool> updateBill(Bill bill, int userId) async {
    try {
      _error = null;
      final result = await _repo.updateBill(bill);
      if (result) await loadBills(userId);
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<bool> deleteBill(int billId, int userId) async {
    try {
      _error = null;
      final result = await _repo.deleteBill(billId);
      if (result) await loadBills(userId);
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  void clear() {
    _bills = [];
    _dueSoon = [];
    _overdue = [];
    _totalPending = 0.0;
    _isLoading = false;
    _error = null;
  }
}
