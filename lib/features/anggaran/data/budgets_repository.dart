import '../../../core/models/budget.dart';
import '../../../core/db/app_database.dart';

/// Repository untuk mengelola data budget/anggaran bulanan
/// Menangani semua operasi CRUD dan query ke database
class BudgetsRepository {
  final _db = AppDatabase();

  /// Ambil semua budget aktif untuk user
  /// Returns: List<Budget> - daftar anggaran
  Future<List<Budget>> getAllBudgets(int userId) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'budgets',
        where: 'user_id = ? AND is_active = 1',
        whereArgs: [userId],
        orderBy: 'period_start DESC',
      );
      return maps.map((map) => Budget.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data budget: $e');
    }
  }

  /// Ambil budget berdasarkan ID
  /// Returns: Budget - detail anggaran
  Future<Budget?> getBudgetById(int budgetId) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'budgets',
        where: 'id = ?',
        whereArgs: [budgetId],
        limit: 1,
      );
      return maps.isEmpty ? null : Budget.fromMap(maps.first);
    } catch (e) {
      throw Exception('Gagal mengambil detail budget: $e');
    }
  }

  /// Ambil budget bulan ini
  /// Returns: List<Budget> - anggaran bulan ini
  Future<List<Budget>> getCurrentMonthBudgets(int userId) async {
    try {
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(
        now.year,
        now.month + 1,
        1,
      ).subtract(const Duration(days: 1));

      final database = await _db.database;
      final maps = await database.query(
        'budgets',
        where: '''user_id = ? AND is_active = 1 AND 
                  period_start <= ? AND period_end >= ?''',
        whereArgs: [
          userId,
          lastDay.toIso8601String(),
          firstDay.toIso8601String(),
        ],
        orderBy: 'name ASC',
      );
      return maps.map((map) => Budget.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil budget bulan ini: $e');
    }
  }

  /// Buat budget baru
  /// Returns: int - ID budget yang baru dibuat
  Future<int> createBudget(Budget budget) async {
    try {
      final database = await _db.database;
      final id = await database.insert('budgets', budget.toMap());
      return id;
    } catch (e) {
      throw Exception('Gagal membuat budget: $e');
    }
  }

  /// Perbarui budget
  /// Returns: bool - status keberhasilan update
  Future<bool> updateBudget(Budget budget) async {
    try {
      final database = await _db.database;
      final updated = await database.update(
        'budgets',
        budget.copyWith(updatedAt: DateTime.now()).toMap(),
        where: 'id = ?',
        whereArgs: [budget.id],
      );
      return updated > 0;
    } catch (e) {
      throw Exception('Gagal memperbarui budget: $e');
    }
  }

  /// Hapus budget (soft delete)
  /// Returns: bool - status keberhasilan delete
  Future<bool> deleteBudget(int budgetId) async {
    try {
      final database = await _db.database;
      final deleted = await database.update(
        'budgets',
        {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [budgetId],
      );
      return deleted > 0;
    } catch (e) {
      throw Exception('Gagal menghapus budget: $e');
    }
  }

  /// Update jumlah pengeluaran budget
  /// Returns: bool - status keberhasilan update
  Future<bool> updateSpent(int budgetId, double newSpent) async {
    try {
      final database = await _db.database;
      final updated = await database.update(
        'budgets',
        {'spent': newSpent, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [budgetId],
      );
      return updated > 0;
    } catch (e) {
      throw Exception('Gagal mengupdate pengeluaran budget: $e');
    }
  }

  /// Hitung total sisa budget
  /// Returns: double - total sisa budget
  Future<double> getTotalRemaining(int userId) async {
    try {
      final database = await _db.database;
      final result = await database.rawQuery(
        'SELECT SUM(amount - spent) as total FROM budgets WHERE user_id = ? AND is_active = 1',
        [userId],
      );
      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('Gagal menghitung total sisa: $e');
    }
  }

  /// Hitung persentase pengeluaran keseluruhan
  /// Returns: double - persentase (0-100)
  Future<double> getOverallPercentage(int userId) async {
    try {
      final database = await _db.database;
      final result = await database.rawQuery(
        '''SELECT 
            SUM(spent) as total_spent,
            SUM(amount) as total_amount
           FROM budgets 
           WHERE user_id = ? AND is_active = 1''',
        [userId],
      );

      final totalSpent =
          (result.first['total_spent'] as num?)?.toDouble() ?? 0.0;
      final totalAmount =
          (result.first['total_amount'] as num?)?.toDouble() ?? 0.0;

      if (totalAmount == 0) return 0.0;
      return (totalSpent / totalAmount * 100).clamp(0, 100);
    } catch (e) {
      throw Exception('Gagal menghitung persentase: $e');
    }
  }

  /// Ambil budget yang sudah melampaui limit
  /// Returns: List<Budget> - budget yang over budget
  Future<List<Budget>> getOverBudgets(int userId) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'budgets',
        where: 'user_id = ? AND is_active = 1 AND spent > amount',
        whereArgs: [userId],
        orderBy: 'spent DESC',
      );
      return maps.map((map) => Budget.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil budget over: $e');
    }
  }

  /// Cari budget berdasarkan kategori
  /// Returns: List<Budget> - budget dengan kategori tertentu
  Future<List<Budget>> getBudgetsByCategory(int userId, int categoryId) async {
    try {
      final database = await _db.database;
      final maps = await database.query(
        'budgets',
        where: 'user_id = ? AND category_id = ? AND is_active = 1',
        whereArgs: [userId, categoryId],
        orderBy: 'period_start DESC',
      );
      return maps.map((map) => Budget.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Gagal mencari budget berdasarkan kategori: $e');
    }
  }
}
