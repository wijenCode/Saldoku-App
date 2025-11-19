import '../../../core/models/wallet.dart';
import '../data/wallet_repository.dart';

/// Provider untuk mengelola state wallet menggunakan simple state management
/// Alternatif dari Riverpod untuk kesederhanaan
class WalletProvider {
  final _repository = WalletRepository();

  /// State untuk list wallet
  List<Wallet> _wallets = [];
  double _totalBalance = 0;
  bool _isLoading = false;
  String? _error;

  /// Getter untuk mengakses state
  List<Wallet> get wallets => _wallets;
  double get totalBalance => _totalBalance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load semua wallet untuk user tertentu
  Future<void> loadWallets(int userId) async {
    try {
      _isLoading = true;
      _error = null;

      _wallets = await _repository.getAllWallets(userId);
      _totalBalance = await _repository.getTotalBalance(userId);

      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      rethrow;
    }
  }

  /// Ambil wallet berdasarkan ID
  Future<Wallet?> getWalletById(int walletId) async {
    try {
      _error = null;
      return await _repository.getWalletById(walletId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Buat wallet baru
  Future<int> createWallet(Wallet wallet, int userId) async {
    try {
      _error = null;
      final id = await _repository.createWallet(wallet);

      // Reload data
      await loadWallets(userId);

      return id;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Update wallet
  Future<bool> updateWallet(Wallet wallet, int userId) async {
    try {
      _error = null;
      final result = await _repository.updateWallet(wallet);

      if (result) {
        // Reload data
        await loadWallets(userId);
      }

      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Hapus wallet
  Future<bool> deleteWallet(int walletId, int userId) async {
    try {
      _error = null;
      final result = await _repository.deleteWallet(walletId);

      if (result) {
        // Reload data
        await loadWallets(userId);
      }

      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Update balance wallet (untuk transaksi)
  Future<bool> updateBalance(
    int walletId,
    double newBalance,
    int userId,
  ) async {
    try {
      _error = null;
      final result = await _repository.updateBalance(walletId, newBalance);

      if (result) {
        // Reload data
        await loadWallets(userId);
      }

      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Dapatkan wallet berdasarkan tipe
  Future<List<Wallet>> getWalletsByType(int userId, String type) async {
    try {
      _error = null;
      return await _repository.getWalletsByType(userId, type);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Clear semua data
  void clear() {
    _wallets = [];
    _totalBalance = 0;
    _isLoading = false;
    _error = null;
  }
}
