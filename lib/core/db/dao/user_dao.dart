import '../app_database.dart';
import '../../models/user.dart';

class UserDao {
  final AppDatabase _db = AppDatabase();

  // Create
  Future<int> insert(User user) async {
    final db = await _db.database;
    return await db.insert('users', user.toMap());
  }

  // Read
  Future<User?> getById(int id) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getByEmail(String email) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<List<User>> getAll() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // Update
  Future<int> update(User user) async {
    final db = await _db.database;
    return await db.update(
      'users',
      user.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete
  Future<int> delete(int id) async {
    final db = await _db.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    final user = await getByEmail(email);
    return user != null;
  }

  // Authenticate user
  Future<User?> authenticate(String email, String password) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }
}
