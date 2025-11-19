import 'package:flutter/foundation.dart' hide Category;
import '../../../core/models/category.dart';
import '../data/category_repository.dart';

/// Provider untuk state management kategori
class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();

  List<Category> _categories = [];
  List<Category> _incomeCategories = [];
  List<Category> _expenseCategories = [];
  bool _isLoading = false;
  String? _error;
  String _selectedType = 'all'; // all, income, expense

  // Getters
  List<Category> get categories {
    if (_selectedType == 'income') return _incomeCategories;
    if (_selectedType == 'expense') return _expenseCategories;
    return _categories;
  }

  List<Category> get incomeCategories => _incomeCategories;
  List<Category> get expenseCategories => _expenseCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedType => _selectedType;

  /// Load categories
  Future<void> loadCategories(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _repository.getCategories(userId);
      _incomeCategories = _categories.where((c) => c.type == 'income').toList();
      _expenseCategories = _categories.where((c) => c.type == 'expense').toList();
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat kategori: $e';
      _categories = [];
      _incomeCategories = [];
      _expenseCategories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set filter type
  void setFilterType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  /// Create category
  Future<Map<String, dynamic>> createCategory({
    required int userId,
    required String name,
    required String type,
    String? icon,
    String? color,
  }) async {
    final result = await _repository.createCategory(
      userId: userId,
      name: name,
      type: type,
      icon: icon,
      color: color,
    );

    if (result['success']) {
      await loadCategories(userId);
    }

    return result;
  }

  /// Update category
  Future<Map<String, dynamic>> updateCategory(
    int userId,
    Category category,
  ) async {
    final result = await _repository.updateCategory(category);

    if (result['success']) {
      await loadCategories(userId);
    }

    return result;
  }

  /// Delete category
  Future<Map<String, dynamic>> deleteCategory(int userId, int categoryId) async {
    final result = await _repository.deleteCategory(categoryId);

    if (result['success']) {
      await loadCategories(userId);
    }

    return result;
  }

  /// Toggle category status
  Future<Map<String, dynamic>> toggleStatus(int userId, Category category) async {
    final result = await _repository.toggleCategoryStatus(category);

    if (result['success']) {
      await loadCategories(userId);
    }

    return result;
  }
}
