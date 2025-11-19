import 'package:flutter/foundation.dart';
import '../../../core/models/wallet_transfer.dart';
import '../../../core/models/wallet.dart';
import '../data/transfer_repository.dart';

/// Provider untuk state management transfer
class TransferProvider extends ChangeNotifier {
  final TransferRepository _repository = TransferRepository();

  List<WalletTransfer> _transfers = [];
  List<Wallet> _wallets = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<WalletTransfer> get transfers => _transfers;
  List<Wallet> get wallets => _wallets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load transfers
  Future<void> loadTransfers(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transfers = await _repository.getTransfers(userId);
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat riwayat transfer: $e';
      _transfers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load wallets
  Future<void> loadWallets(int userId) async {
    try {
      _wallets = await _repository.getActiveWallets(userId);
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat dompet: $e';
      notifyListeners();
    }
  }

  /// Create transfer
  Future<Map<String, dynamic>> createTransfer({
    required int userId,
    required int fromWalletId,
    required int toWalletId,
    required double amount,
    double fee = 0,
    DateTime? date,
    String? description,
  }) async {
    final result = await _repository.createTransfer(
      userId: userId,
      fromWalletId: fromWalletId,
      toWalletId: toWalletId,
      amount: amount,
      fee: fee,
      date: date,
      description: description,
    );

    if (result['success']) {
      await loadTransfers(userId);
      await loadWallets(userId);
    }

    return result;
  }

  /// Delete transfer
  Future<Map<String, dynamic>> deleteTransfer(
    int userId,
    int transferId,
  ) async {
    final result = await _repository.deleteTransfer(transferId);

    if (result['success']) {
      await loadTransfers(userId);
      await loadWallets(userId);
    }

    return result;
  }
}
