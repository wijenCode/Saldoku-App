import '../../../core/models/bill.dart';
import '../../../core/db/app_database.dart';

/// Repository untuk mengelola data tagihan (bills)
class BillsRepository {
  final _db = AppDatabase();

  Future<List<Bill>> getAllBills(int userId) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'bills',
        where: 'user_id = ? AND status != ? ',
        whereArgs: [userId, 'deleted'],
        orderBy: 'due_date ASC',
      );
      return maps.map((m) => Bill.fromMap(m)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data tagihan: $e');
    }
  }

  Future<Bill?> getBillById(int billId) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'bills',
        where: 'id = ?',
        whereArgs: [billId],
        limit: 1,
      );
      return maps.isEmpty ? null : Bill.fromMap(maps.first);
    } catch (e) {
      throw Exception('Gagal mengambil detail tagihan: $e');
    }
  }

  Future<List<Bill>> getDueSoonBills(int userId, {int days = 7}) async {
    try {
      final now = DateTime.now();
      final until = now.add(Duration(days: days));
      final database = await _db.database;
      final maps = await database.rawQuery(
        'SELECT * FROM bills WHERE user_id = ? AND status = ? AND due_date BETWEEN ? AND ? ORDER BY due_date ASC',
        [userId, 'pending', now.toIso8601String(), until.toIso8601String()],
      );
      return maps.map((m) => Bill.fromMap(m)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil tagihan mendekati jatuh tempo: $e');
    }
  }

  Future<List<Bill>> getOverdueBills(int userId) async {
    try {
      final now = DateTime.now();
      final database = await _db.database;
      final maps = await database.query(
        'bills',
        where: 'user_id = ? AND status = ? AND due_date < ?',
        whereArgs: [userId, 'pending', now.toIso8601String()],
        orderBy: 'due_date ASC',
      );
      return maps.map((m) => Bill.fromMap(m)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil tagihan terlambat: $e');
    }
  }

  Future<int> createBill(Bill bill) async {
    try {
      final database = await _db.database;
      final id = await database.insert('bills', bill.toMap());
      return id;
    } catch (e) {
      throw Exception('Gagal membuat tagihan: $e');
    }
  }

  Future<bool> updateBill(Bill bill) async {
    try {
      final database = await _db.database;
      final updated = await database.update(
        'bills',
        bill.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [bill.id],
      );
      return updated > 0;
    } catch (e) {
      throw Exception('Gagal memperbarui tagihan: $e');
    }
  }

  Future<bool> deleteBill(int billId) async {
    try {
      final database = await _db.database;
      final deleted = await database.update(
        'bills',
        {'status': 'deleted', 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [billId],
      );
      return deleted > 0;
    } catch (e) {
      throw Exception('Gagal menghapus tagihan: $e');
    }
  }

  Future<double> getTotalPendingAmount(int userId) async {
    try {
      final database = await _db.database;
      final result = await database.rawQuery(
        'SELECT SUM(amount) as total FROM bills WHERE user_id = ? AND status = ?',
        [userId, 'pending'],
      );
      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('Gagal menghitung total tagihan: $e');
    }
  }
}
