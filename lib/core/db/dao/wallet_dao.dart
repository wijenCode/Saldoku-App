import '../app_database.dart';
import '../../models/wallet.dart';

class WalletDao {
  final AppDatabase _db = AppDatabase();

  // Create
  Future<int> insert(Wallet wallet) async {
    final db = await _db.database;
    return await db.insert('wallets', wallet.toMap());
  }

  // Read
  Future<Wallet?> getById(int id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wallets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Wallet.fromMap(maps.first);
  }

  Future<List<Wallet>> getByUserId(int userId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wallets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Wallet.fromMap(maps[i]));
  }

  Future<List<Wallet>> getActiveByUserId(int userId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wallets',
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Wallet.fromMap(maps[i]));
  }

  Future<List<Wallet>> getByType(int userId, String type) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wallets',
      where: 'user_id = ? AND type = ?',
      whereArgs: [userId, type],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Wallet.fromMap(maps[i]));
  }

  // Update
  Future<int> update(Wallet wallet) async {
    final db = await _db.database;
    return await db.update(
      'wallets',
      wallet.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }

  Future<int> updateBalance(int id, double newBalance) async {
    final db = await _db.database;
    return await db.update(
      'wallets',
      {
        'balance': newBalance,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> addToBalance(int id, double amount) async {
    final wallet = await getById(id);
    if (wallet == null) return 0;
    return await updateBalance(id, wallet.balance + amount);
  }

  Future<int> subtractFromBalance(int id, double amount) async {
    final wallet = await getById(id);
    if (wallet == null) return 0;
    return await updateBalance(id, wallet.balance - amount);
  }

  // Delete
  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      'wallets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get total balance
  Future<double> getTotalBalance(int userId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT SUM(balance) as total FROM wallets WHERE user_id = ? AND is_active = 1',
      [userId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
