import '../db/dao/user_dao.dart';
import '../models/user.dart';
import 'shared_prefs_service.dart';

/// Service untuk mengelola autentikasi user
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final UserDao _userDao = UserDao();
  User? _currentUser;

  /// Get current logged in user
  User? get currentUser => _currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  /// Initialize auth service - check saved session
  Future<void> init() async {
    final userId = await SharedPrefsService.getUserId();
    if (userId != null) {
      _currentUser = await _userDao.getById(userId);
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Check if email already exists
      final existingUser = await _userDao.getByEmail(email);
      if (existingUser != null) {
        return {
          'success': false,
          'message': 'Email sudah terdaftar',
        };
      }

      // Create new user
      final user = User(
        name: name,
        email: email,
        password: password, // In production, hash this password!
        createdAt: DateTime.now(),
      );

      final userId = await _userDao.insert(user);
      final newUser = user.copyWith(id: userId);

      // Save session
      await SharedPrefsService.saveUserId(userId);
      _currentUser = newUser;

      return {
        'success': true,
        'message': 'Registrasi berhasil',
        'user': newUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _userDao.authenticate(email, password);

      if (user == null) {
        return {
          'success': false,
          'message': 'Email atau password salah',
        };
      }

      // Update last login time using updatedAt
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await _userDao.update(updatedUser);

      // Save session
      await SharedPrefsService.saveUserId(user.id!);
      _currentUser = updatedUser;

      return {
        'success': true,
        'message': 'Login berhasil',
        'user': updatedUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Logout user
  Future<void> logout() async {
    await SharedPrefsService.clearUserId();
    _currentUser = null;
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    if (_currentUser == null) {
      return {
        'success': false,
        'message': 'User tidak ditemukan',
      };
    }

    try {
      // Check if new email already exists
      if (email != null && email != _currentUser!.email) {
        final existingUser = await _userDao.getByEmail(email);
        if (existingUser != null) {
          return {
            'success': false,
            'message': 'Email sudah digunakan',
          };
        }
      }

      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        phone: phone ?? _currentUser!.phone,
        avatar: avatar ?? _currentUser!.avatar,
      );

      await _userDao.update(updatedUser);
      _currentUser = updatedUser;

      return {
        'success': true,
        'message': 'Profil berhasil diperbarui',
        'user': updatedUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Change password
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      return {
        'success': false,
        'message': 'User tidak ditemukan',
      };
    }

    try {
      // Verify old password
      if (_currentUser!.password != oldPassword) {
        return {
          'success': false,
          'message': 'Password lama salah',
        };
      }

      final updatedUser = _currentUser!.copyWith(password: newPassword);
      await _userDao.update(updatedUser);
      _currentUser = updatedUser;

      return {
        'success': true,
        'message': 'Password berhasil diubah',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    if (_currentUser == null) {
      return {
        'success': false,
        'message': 'User tidak ditemukan',
      };
    }

    try {
      await _userDao.delete(_currentUser!.id!);
      await logout();

      return {
        'success': true,
        'message': 'Akun berhasil dihapus',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
}
