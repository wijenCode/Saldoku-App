import '../../../core/db/dao/category_dao.dart';
import '../../../core/models/category.dart';

/// Repository untuk mengelola data kategori
class CategoryRepository {
  late final CategoryDao _categoryDao;

  CategoryRepository() {
    _categoryDao = CategoryDao();
  }

  /// Get all categories by user
  Future<List<Category>> getCategories(int userId) async {
    try {
      return await _categoryDao.getByUserId(userId);
    } catch (e) {
      return [];
    }
  }

  /// Get active categories only
  Future<List<Category>> getActiveCategories(int userId) async {
    try {
      return await _categoryDao.getActiveByUserId(userId);
    } catch (e) {
      return [];
    }
  }

  /// Get categories by type (income/expense)
  Future<List<Category>> getCategoriesByType(int userId, String type) async {
    try {
      return await _categoryDao.getByType(userId, type);
    } catch (e) {
      return [];
    }
  }

  /// Get category by id
  Future<Category?> getCategoryById(int id) async {
    try {
      return await _categoryDao.getById(id);
    } catch (e) {
      return null;
    }
  }

  /// Create new category
  Future<Map<String, dynamic>> createCategory({
    required int userId,
    required String name,
    required String type,
    String? icon,
    String? color,
  }) async {
    try {
      // Check if name already exists
      final existingCategories = await _categoryDao.getByUserId(userId);
      final isDuplicate = existingCategories.any(
        (cat) => cat.name.toLowerCase() == name.toLowerCase() && cat.type == type,
      );

      if (isDuplicate) {
        return {
          'success': false,
          'message': 'Kategori dengan nama "$name" sudah ada',
        };
      }

      final category = Category(
        userId: userId,
        name: name,
        type: type,
        icon: icon,
        color: color,
      );

      final id = await _categoryDao.insert(category);

      return {
        'success': true,
        'message': 'Kategori berhasil ditambahkan',
        'categoryId': id,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menambahkan kategori: $e',
      };
    }
  }

  /// Update category
  Future<Map<String, dynamic>> updateCategory(Category category) async {
    try {
      // Check if category belongs to user (can't edit system categories)
      if (category.userId == 0) {
        return {
          'success': false,
          'message': 'Tidak dapat mengedit kategori sistem',
        };
      }

      await _categoryDao.update(category);

      return {
        'success': true,
        'message': 'Kategori berhasil diperbarui',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui kategori: $e',
      };
    }
  }

  /// Delete category (hard delete)
  Future<Map<String, dynamic>> deleteCategory(int categoryId) async {
    try {
      final category = await _categoryDao.getById(categoryId);
      
      if (category == null) {
        return {
          'success': false,
          'message': 'Kategori tidak ditemukan',
        };
      }

      if (category.userId == 0) {
        return {
          'success': false,
          'message': 'Tidak dapat menghapus kategori sistem',
        };
      }

      await _categoryDao.delete(categoryId);

      return {
        'success': true,
        'message': 'Kategori berhasil dihapus',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal menghapus kategori: $e',
      };
    }
  }

  /// Toggle category active status
  Future<Map<String, dynamic>> toggleCategoryStatus(Category category) async {
    try {
      if (category.userId == 0) {
        return {
          'success': false,
          'message': 'Tidak dapat mengubah status kategori sistem',
        };
      }

      final updated = category.copyWith(isActive: !category.isActive);
      await _categoryDao.update(updated);

      return {
        'success': true,
        'message': updated.isActive 
          ? 'Kategori diaktifkan' 
          : 'Kategori dinonaktifkan',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengubah status: $e',
      };
    }
  }
}
