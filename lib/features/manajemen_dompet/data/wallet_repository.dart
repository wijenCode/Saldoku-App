import '../../../core/models/wallet.dart';
import '../../../core/db/app_database.dart';

/// Repository untuk mengelola data wallet/dompet
/// Menangani semua operasi CRUD dan query ke database
class WalletRepository {
  final _db = AppDatabase();

  /// Ambil semua wallet user
  /// Returns: List<Wallet> - daftar semua dompet aktif
  Future<List<Wallet>> getAllWallets(int userId) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'wallets',
        where: 'user_id = ? AND is_active = 1',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => Wallet.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data dompet: $e');
    }
  }

  /// Ambil detail wallet berdasarkan ID
  /// Returns: Wallet - detail dompet
  Future<Wallet?> getWalletById(int walletId) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'wallets',
        where: 'id = ?',
        whereArgs: [walletId],
        limit: 1,
      );
      return maps.isEmpty ? null : Wallet.fromMap(maps.first);
    } catch (e) {
      throw Exception('Gagal mengambil detail dompet: $e');
    }
  }

  /// Buat dompet baru
  /// Returns: int - ID dompet yang baru dibuat
  Future<int> createWallet(Wallet wallet) async {
    try {
      final database = await _db.database;
      final id = await database.insert('wallets', wallet.toMap());
      return id;
    } catch (e) {
      throw Exception('Gagal membuat dompet: $e');
    }
  }

  /// Perbarui data dompet
  /// Returns: bool - status keberhasilan update
  Future<bool> updateWallet(Wallet wallet) async {
    try {
      final database = await _db.database;
      final updated = await database.update(
        'wallets',
        wallet.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [wallet.id],
      );
      return updated > 0;
    } catch (e) {
      throw Exception('Gagal memperbarui dompet: $e');
    }
  }

  /// Hapus dompet (soft delete)
  /// Returns: bool - status keberhasilan delete
  Future<bool> deleteWallet(int walletId) async {
    try {
      final database = await _db.database;
      final deleted = await database.update(
        'wallets',
        {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [walletId],
      );
      return deleted > 0;
    } catch (e) {
      throw Exception('Gagal menghapus dompet: $e');
    }
  }

  /// Hitung total saldo semua wallet
  /// Returns: double - total saldo
  Future<double> getTotalBalance(int userId) async {
    try {
      final database = await _db.database;
      final result = await database.rawQuery(
        'SELECT SUM(balance) as total FROM wallets WHERE user_id = ? AND is_active = 1',
        [userId],
      );
      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('Gagal menghitung total saldo: $e');
    }
  }

  /// Update saldo wallet (untuk transaksi)
  /// Returns: bool - status keberhasilan update
  Future<bool> updateBalance(int walletId, double newBalance) async {
    try {
      final database = await _db.database;
      final updated = await database.update(
        'wallets',
        {'balance': newBalance, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [walletId],
      );
      return updated > 0;
    } catch (e) {
      throw Exception('Gagal mengupdate saldo: $e');
    }
  }

  /// Cari wallet berdasarkan tipe
  /// Returns: List<Wallet> - daftar wallet sesuai tipe
  Future<List<Wallet>> getWalletsByType(int userId, String type) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'wallets',
        where: 'user_id = ? AND type = ? AND is_active = 1',
        whereArgs: [userId, type],
        orderBy: 'name ASC',
      );
      return maps.map((map) => Wallet.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Gagal mencari wallet berdasarkan tipe: $e');
    }
  }
}
