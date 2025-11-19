import '../../../core/models/debt.dart';
import '../../../core/models/debt_payment.dart';
import '../../../core/db/app_database.dart';

/// Repository untuk mengelola data hutang/piutang
/// Menangani semua operasi CRUD dan query ke database
class DebtsRepository {
  final _db = AppDatabase();

  /// Ambil semua hutang/piutang untuk user
  /// Returns: List<Debt> - daftar hutang/piutang
  Future<List<Debt>> getAllDebts(int userId) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'debts',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'due_date ASC, created_at DESC',
      );
      return maps.map((map) => Debt.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data hutang/piutang: $e');
    }
  }

  /// Ambil hutang berdasarkan tipe (hutang atau piutang)
  /// Returns: List<Debt> - daftar hutang atau piutang
  Future<List<Debt>> getDebtsByType(int userId, String type) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'debts',
        where: 'user_id = ? AND type = ?',
        whereArgs: [userId, type],
        orderBy: 'due_date ASC, created_at DESC',
      );
      return maps.map((map) => Debt.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data berdasarkan tipe: $e');
    }
  }

  /// Ambil hutang berdasarkan status
  /// Returns: List<Debt> - daftar hutang dengan status tertentu
  Future<List<Debt>> getDebtsByStatus(int userId, String status) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'debts',
        where: 'user_id = ? AND status = ?',
        whereArgs: [userId, status],
        orderBy: 'due_date ASC',
      );
      return maps.map((map) => Debt.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data berdasarkan status: $e');
    }
  }

  /// Ambil detail hutang berdasarkan ID
  /// Returns: Debt - detail hutang/piutang
  Future<Debt?> getDebtById(int debtId) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'debts',
        where: 'id = ?',
        whereArgs: [debtId],
        limit: 1,
      );
      return maps.isEmpty ? null : Debt.fromMap(maps.first);
    } catch (e) {
      throw Exception('Gagal mengambil detail hutang: $e');
    }
  }

  /// Buat hutang/piutang baru
  /// Returns: int - ID hutang yang baru dibuat
  Future<int> createDebt(Debt debt) async {
    try {
      final database = await _db.database;
      final id = await database.insert('debts', debt.toMap());
      return id;
    } catch (e) {
      throw Exception('Gagal membuat hutang/piutang: $e');
    }
  }

  /// Perbarui hutang/piutang
  /// Returns: bool - status keberhasilan update
  Future<bool> updateDebt(Debt debt) async {
    try {
      final database = await _db.database;
      final updated = await database.update(
        'debts',
        debt.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [debt.id],
      );
      return updated > 0;
    } catch (e) {
      throw Exception('Gagal memperbarui hutang/piutang: $e');
    }
  }

  /// Hapus hutang/piutang
  /// Returns: bool - status keberhasilan delete
  Future<bool> deleteDebt(int debtId) async {
    try {
      final database = await _db.database;
      final deleted = await database.delete(
        'debts',
        where: 'id = ?',
        whereArgs: [debtId],
      );
      return deleted > 0;
    } catch (e) {
      throw Exception('Gagal menghapus hutang/piutang: $e');
    }
  }

  /// Buat pembayaran hutang
  /// Returns: int - ID pembayaran yang baru dibuat
  Future<int> createDebtPayment(DebtPayment payment) async {
    try {
      final database = await _db.database;

      // Simpan pembayaran
      final id = await database.insert('debt_payments', payment.toMap());

      // Update remaining amount pada hutang
      final debt = await getDebtById(payment.debtId);
      if (debt != null) {
        final newRemaining = debt.remainingAmount - payment.amount;
        final newStatus = newRemaining <= 0 ? 'paid' : 'partially_paid';

        final updatedDebt = debt.copyWith(
          remainingAmount: newRemaining < 0 ? 0 : newRemaining,
          status: newStatus,
        );
        await updateDebt(updatedDebt);
      }

      return id;
    } catch (e) {
      throw Exception('Gagal membuat pembayaran: $e');
    }
  }

  /// Ambil semua pembayaran hutang
  /// Returns: List<DebtPayment> - daftar pembayaran
  Future<List<DebtPayment>> getDebtPayments(int debtId) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'debt_payments',
        where: 'debt_id = ?',
        whereArgs: [debtId],
        orderBy: 'payment_date DESC',
      );
      return maps.map((map) => DebtPayment.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil pembayaran: $e');
    }
  }

  /// Hitung total hutang yang belum dibayar
  /// Returns: double - total hutang
  Future<double> getTotalUnpaidDebt(int userId) async {
    try {
      final database = await _db.database;
      final result = await database.rawQuery(
        'SELECT SUM(remaining_amount) as total FROM debts WHERE user_id = ? AND type = ? AND status != ?',
        [userId, 'debt', 'paid'],
      );
      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('Gagal menghitung total hutang: $e');
    }
  }

  /// Hitung total piutang yang belum diterima
  /// Returns: double - total piutang
  Future<double> getTotalUnpaidReceivable(int userId) async {
    try {
      final database = await _db.database;
      final result = await database.rawQuery(
        'SELECT SUM(remaining_amount) as total FROM debts WHERE user_id = ? AND type = ? AND status != ?',
        [userId, 'receivable', 'paid'],
      );
      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('Gagal menghitung total piutang: $e');
    }
  }

  /// Hitung jumlah hutang/piutang yang sudah jatuh tempo
  /// Returns: int - jumlah hutang/piutang yang sudah jatuh tempo
  Future<int> getOverdueCount(int userId) async {
    try {
      final database = await _db.database;
      final now = DateTime.now().toIso8601String();
      final result = await database.rawQuery(
        'SELECT COUNT(*) as count FROM debts WHERE user_id = ? AND status != ? AND due_date < ?',
        [userId, 'paid', now],
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      throw Exception('Gagal menghitung hutang yang jatuh tempo: $e');
    }
  }

  /// Ambil hutang/piutang yang jatuh tempo
  /// Returns: List<Debt> - daftar hutang/piutang yang sudah jatuh tempo
  Future<List<Debt>> getOverdueDebts(int userId) async {
    try {
      final database = await _db.database;
      final now = DateTime.now().toIso8601String();
      final maps = await database.query(
        'debts',
        where: 'user_id = ? AND status != ? AND due_date < ?',
        whereArgs: [userId, 'paid', now],
        orderBy: 'due_date ASC',
      );
      return maps.map((map) => Debt.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil hutang yang jatuh tempo: $e');
    }
  }

  /// Update status hutang menjadi paid
  /// Returns: bool - status keberhasilan update
  Future<bool> markAsPaid(int debtId) async {
    try {
      final database = await _db.database;
      final debt = await getDebtById(debtId);

      if (debt == null) return false;

      final updated = await database.update(
        'debts',
        {
          'status': 'paid',
          'remaining_amount': 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [debtId],
      );
      return updated > 0;
    } catch (e) {
      throw Exception('Gagal menandai sebagai dibayar: $e');
    }
  }
}
