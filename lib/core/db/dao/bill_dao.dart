import '../app_database.dart';
import '../../models/bill.dart';

class BillDao {
  final AppDatabase _db = AppDatabase();

  // Create
  Future<int> insert(Bill bill) async {
    final db = await _db.database;
    return await db.insert('bills', bill.toMap());
  }

  // Read
  Future<Bill?> getById(int id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Bill.fromMap(maps.first);
  }

  Future<List<Bill>> getByUserId(int userId) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'due_date ASC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  Future<List<Bill>> getByStatus(int userId, String status) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, status],
      orderBy: 'due_date ASC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  Future<List<Bill>> getUpcoming(int userId, int days) async {
    final db = await _db.database;
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'user_id = ? AND status = ? AND due_date >= ? AND due_date <= ?',
      whereArgs: [
        userId,
        'pending',
        now.toIso8601String(),
        futureDate.toIso8601String(),
      ],
      orderBy: 'due_date ASC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  Future<List<Bill>> getOverdue(int userId) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'user_id = ? AND status = ? AND due_date < ?',
      whereArgs: [userId, 'pending', now],
      orderBy: 'due_date ASC',
    );
    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  // Update
  Future<int> update(Bill bill) async {
    final db = await _db.database;
    return await db.update(
      'bills',
      bill.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<int> updateStatus(int id, String status) async {
    final db = await _db.database;
    return await db.update(
      'bills',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete
  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get total upcoming bills amount
  Future<double> getTotalUpcoming(int userId, int days) async {
    final bills = await getUpcoming(userId, days);
    double total = 0.0;
    for (var bill in bills) {
      total += bill.amount;
    }
    return total;
  }
}
