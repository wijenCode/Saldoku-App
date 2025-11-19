import '../../../core/db/dao/wallet_transfer_dao.dart';
import '../../../core/db/dao/wallet_dao.dart';
import '../../../core/models/wallet_transfer.dart';
import '../../../core/models/wallet.dart';

/// Repository untuk mengelola transfer antar dompet
class TransferRepository {
  late final WalletTransferDao _transferDao;
  late final WalletDao _walletDao;

  TransferRepository() {
    _transferDao = WalletTransferDao();
    _walletDao = WalletDao();
  }

  /// Get all transfers by user
  Future<List<WalletTransfer>> getTransfers(int userId) async {
    try {
      return await _transferDao.getByUserId(userId);
    } catch (e) {
      return [];
    }
  }

  /// Get transfer by id
  Future<WalletTransfer?> getTransferById(int id) async {
    try {
      return await _transferDao.getById(id);
    } catch (e) {
      return null;
    }
  }

  /// Get active wallets
  Future<List<Wallet>> getActiveWallets(int userId) async {
    try {
      return await _walletDao.getActiveByUserId(userId);
    } catch (e) {
      return [];
    }
  }

  /// Get wallet by id
  Future<Wallet?> getWalletById(int id) async {
    try {
      return await _walletDao.getById(id);
    } catch (e) {
      return null;
    }
  }

  /// Create transfer between wallets
  Future<Map<String, dynamic>> createTransfer({
    required int userId,
    required int fromWalletId,
    required int toWalletId,
    required double amount,
    double fee = 0,
    DateTime? date,
    String? description,
  }) async {
    try {
      // Validation: Can't transfer to same wallet
      if (fromWalletId == toWalletId) {
        return {
          'success': false,
          'message': 'Tidak dapat transfer ke dompet yang sama',
        };
      }

      // Get source wallet
      final fromWallet = await _walletDao.getById(fromWalletId);
      if (fromWallet == null) {
        return {
          'success': false,
          'message': 'Dompet sumber tidak ditemukan',
        };
      }

      // Get destination wallet
      final toWallet = await _walletDao.getById(toWalletId);
      if (toWallet == null) {
        return {
          'success': false,
          'message': 'Dompet tujuan tidak ditemukan',
        };
      }

      // Check if wallets are active
      if (!fromWallet.isActive) {
        return {
          'success': false,
          'message': 'Dompet sumber tidak aktif',
        };
      }

      if (!toWallet.isActive) {
        return {
          'success': false,
          'message': 'Dompet tujuan tidak aktif',
        };
      }

      // Check sufficient balance (amount + fee)
      final totalDeduct = amount + fee;
      if (fromWallet.balance < totalDeduct) {
        return {
          'success': false,
          'message': 'Saldo dompet sumber tidak mencukupi',
        };
      }

      // Create transfer record
      final transfer = WalletTransfer(
        userId: userId,
        fromWalletId: fromWalletId,
        toWalletId: toWalletId,
        amount: amount,
        fee: fee,
        date: date ?? DateTime.now(),
        description: description,
      );

      final transferId = await _transferDao.insert(transfer);

      // Update balances
      final newFromBalance = fromWallet.balance - totalDeduct;
      final newToBalance = toWallet.balance + amount;

      await _walletDao.updateBalance(fromWalletId, newFromBalance);
      await _walletDao.updateBalance(toWalletId, newToBalance);

      return {
        'success': true,
        'message': 'Transfer berhasil',
        'transferId': transferId,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal melakukan transfer: $e',
      };
    }
  }

  /// Delete transfer (rollback balances)
  Future<Map<String, dynamic>> deleteTransfer(int transferId) async {
    try {
      // Get transfer
      final transfer = await _transferDao.getById(transferId);
      if (transfer == null) {
        return {
          'success': false,
          'message': 'Transfer tidak ditemukan',
        };
      }

      // Get wallets
      final fromWallet = await _walletDao.getById(transfer.fromWalletId);
      final toWallet = await _walletDao.getById(transfer.toWalletId);

      if (fromWallet == null || toWallet == null) {
        return {
          'success': false,
          'message': 'Dompet tidak ditemukan',
        };
      }

      // Rollback balances
      final newFromBalance = fromWallet.balance + transfer.amount + transfer.fee;
      final newToBalance = toWallet.balance - transfer.amount;

      // Check if destination wallet has enough balance to rollback
      if (newToBalance < 0) {
        return {
          'success': false,
          'message': 'Tidak dapat membatalkan transfer. Saldo dompet tujuan tidak mencukupi.',
        };
      }

      await _walletDao.updateBalance(transfer.fromWalletId, newFromBalance);
      await _walletDao.updateBalance(transfer.toWalletId, newToBalance);

      // Delete transfer
      await _transferDao.delete(transferId);

      return {
        'success': true,
        'message': 'Transfer berhasil dibatalkan',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal membatalkan transfer: $e',
      };
    }
  }
}
