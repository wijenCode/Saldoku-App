import '../app_database.dart';
import '../../models/wallet_transfer.dart';

class WalletTransferDao {
  final AppDatabase _db = AppDatabase();

  // Create
  Future<int> insert(WalletTransfer transfer) async {
    final db = await _db.database;
    return await db.insert('wallet_transfers', transfer.toMap());
  }

  // Read
  Future<WalletTransfer?> getById(int id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wallet_transfers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return WalletTransfer.fromMap(maps.first);
  }

  Future<List<WalletTransfer>> getByUserId(int userId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wallet_transfers',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => WalletTransfer.fromMap(maps[i]));
  }

  Future<List<WalletTransfer>> getByWalletId(int walletId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wallet_transfers',
      where: 'from_wallet_id = ? OR to_wallet_id = ?',
      whereArgs: [walletId, walletId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => WalletTransfer.fromMap(maps[i]));
  }

  Future<List<WalletTransfer>> getByDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wallet_transfers',
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => WalletTransfer.fromMap(maps[i]));
  }

  // Delete
  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      'wallet_transfers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistics
  Future<double> getTotalTransferred(int userId, DateTime startDate, DateTime endDate) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM wallet_transfers WHERE user_id = ? AND date >= ? AND date <= ?',
      [userId, startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalFees(int userId, DateTime startDate, DateTime endDate) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(fee) as total FROM wallet_transfers WHERE user_id = ? AND date >= ? AND date <= ?',
      [userId, startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
