import 'package:flutter/material.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/theme/widgets/theme_extensions.dart';
import '../../../app/widgets/widgets.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/category.dart';
import '../data/category_repository.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _repository = CategoryRepository();

  late TabController _tabController;
  List<Category> _incomeCategories = [];
  List<Category> _expenseCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    final user = _authService.currentUser;
    if (user != null) {
      final income = await _repository.getCategoriesByType(user.id!, 'income');
      final expense = await _repository.getCategoriesByType(
        user.id!,
        'expense',
      );

      setState(() {
        _incomeCategories = income;
        _expenseCategories = expense;
        _isLoading = false;
      });
    }
  }

  void _showAddCategoryDialog(String type) {
    final nameController = TextEditingController();
    String? selectedIcon;
    String? selectedColor;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(
                    'Tambah Kategori ${type == 'income' ? 'Pemasukan' : 'Pengeluaran'}',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTextField(
                          controller: nameController,
                          label: 'Nama Kategori',
                          hint:
                              'Contoh: ${type == 'income' ? 'Gaji' : 'Makan'}',
                          prefixIcon: Icon(Icons.label_outline),
                        ),
                        const SizedBox(height: 16),

                        // Icon picker
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _categoryIcons.map((icon) {
                                final isSelected = selectedIcon == icon;
                                return GestureDetector(
                                  onTap:
                                      () => setDialogState(
                                        () => selectedIcon = icon,
                                      ),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? AppColors.primary.withAlpha(
                                                (0.2 * 255).round(),
                                              )
                                              : context.surfaceColor,
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? AppColors.primary
                                                : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getIconData(icon),
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : context.textColor,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),

                        const SizedBox(height: 16),

                        // Color picker
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _categoryColors.map((color) {
                                final isSelected = selectedColor == color;
                                return GestureDetector(
                                  onTap:
                                      () => setDialogState(
                                        () => selectedColor = color,
                                      ),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _getColorFromHex(color),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? Colors.black
                                                : Colors.transparent,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child:
                                        isSelected
                                            ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            )
                                            : null,
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nama kategori harus diisi'),
                            ),
                          );
                          return;
                        }

                        final user = _authService.currentUser;
                        if (user != null) {
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final result = await _repository.createCategory(
                            userId: user.id!,
                            name: nameController.text.trim(),
                            type: type,
                            icon: selectedIcon ?? 'label',
                            color: selectedColor ?? '4CAF50',
                          );

                          if (!mounted) return;
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(content: Text(result['message'])),
                          );

                          if (result['success']) {
                            _loadCategories();
                          }
                        }
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showEditCategoryDialog(Category category) {
    final nameController = TextEditingController(text: category.name);
    String? selectedIcon = category.icon;
    String? selectedColor = category.color;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Edit Kategori'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (category.userId == 0)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Kategori sistem tidak dapat diedit',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          CustomTextField(
                            controller: nameController,
                            label: 'Nama Kategori',
                            prefixIcon: Icon(Icons.label_outline),
                          ),
                          const SizedBox(height: 16),

                          // Icon picker
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                _categoryIcons.map((icon) {
                                  final isSelected = selectedIcon == icon;
                                  return GestureDetector(
                                    onTap:
                                        () => setDialogState(
                                          () => selectedIcon = icon,
                                        ),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? AppColors.primary.withAlpha(
                                                  (0.2 * 255).round(),
                                                )
                                                : context.surfaceColor,
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? AppColors.primary
                                                  : Colors.grey.shade300,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getIconData(icon),
                                        color:
                                            isSelected
                                                ? AppColors.primary
                                                : context.textColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),

                          const SizedBox(height: 16),

                          // Color picker
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                _categoryColors.map((color) {
                                  final isSelected = selectedColor == color;
                                  return GestureDetector(
                                    onTap:
                                        () => setDialogState(
                                          () => selectedColor = color,
                                        ),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _getColorFromHex(color),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? Colors.black
                                                  : Colors.transparent,
                                          width: 3,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child:
                                          isSelected
                                              ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                              )
                                              : null,
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    if (category.userId != 0)
                      ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nama kategori harus diisi'),
                              ),
                            );
                            return;
                          }

                          final updated = category.copyWith(
                            name: nameController.text.trim(),
                            icon: selectedIcon,
                            color: selectedColor,
                          );

                          final user = _authService.currentUser;
                          if (user != null) {
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            final result = await _repository.updateCategory(
                              updated,
                            );

                            if (!mounted) return;
                            navigator.pop();
                            messenger.showSnackBar(
                              SnackBar(content: Text(result['message'])),
                            );

                            if (result['success']) {
                              _loadCategories();
                            }
                          }
                        },
                        child: const Text('Simpan'),
                      ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteConfirmation(Category category) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Kategori'),
            content: Text(
              category.userId == 0
                  ? 'Kategori sistem tidak dapat dihapus'
                  : 'Yakin ingin menghapus kategori "${category.name}"?\n\nTransaksi yang menggunakan kategori ini tidak akan terhapus.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              if (category.userId != 0)
                ElevatedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final result = await _repository.deleteCategory(
                      category.id!,
                    );

                    if (!mounted) return;
                    navigator.pop();
                    messenger.showSnackBar(
                      SnackBar(content: Text(result['message'])),
                    );

                    if (result['success']) {
                      _loadCategories();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Hapus'),
                ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kategori'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Pemasukan'), Tab(text: 'Pengeluaran')],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildCategoryList(_incomeCategories, 'income'),
                  _buildCategoryList(_expenseCategories, 'expense'),
                ],
              ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, String type) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada kategori ${type == 'income' ? 'pemasukan' : 'pengeluaran'}',
              style: context.bodyStyle.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddCategoryDialog(type),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Kategori'),
            ),
          ],
        ),
      );
    }

    // Separate system and custom categories
    final systemCategories = categories.where((c) => c.userId == 0).toList();
    final customCategories = categories.where((c) => c.userId != 0).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (systemCategories.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.verified, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Kategori Sistem',
                style: context.labelStyle.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...systemCategories.map((category) => _buildCategoryItem(category)),
          const SizedBox(height: 24),
        ],

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.person, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Kategori Kustom',
                  style: context.labelStyle.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => _showAddCategoryDialog(type),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (customCategories.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                'Belum ada kategori kustom',
                style: context.bodyStyle.copyWith(color: Colors.grey.shade600),
              ),
            ),
          )
        else
          ...customCategories.map((category) => _buildCategoryItem(category)),
      ],
    );
  }

  Widget _buildCategoryItem(Category category) {
    final color = _getColorFromHex(category.color ?? '4CAF50');
    final icon = _getIconData(category.icon ?? 'label');
    final isSystem = category.userId == 0;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          category.name,
          style: context.bodyStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isSystem ? 'Kategori sistem' : 'Kategori kustom',
          style: context.labelStyle.copyWith(color: Colors.grey.shade600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!category.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Nonaktif',
                  style: context.labelStyle.copyWith(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditCategoryDialog(category);
                    break;
                  case 'toggle':
                    _toggleCategoryStatus(category);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(category);
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (!isSystem)
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              category.isActive
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              category.isActive ? 'Nonaktifkan' : 'Aktifkan',
                            ),
                          ],
                        ),
                      ),
                    if (!isSystem)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 12),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleCategoryStatus(Category category) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await _repository.toggleCategoryStatus(category);

    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(result['message'])));

    if (result['success']) {
      _loadCategories();
    }
  }

  // Category icons
  static const List<String> _categoryIcons = [
    'label',
    'shopping_cart',
    'restaurant',
    'local_gas_station',
    'home',
    'school',
    'local_hospital',
    'emoji_transportation',
    'phone_android',
    'checkroom',
    'sports_esports',
    'movie',
    'flight',
    'hotel',
    'fitness_center',
    'pets',
    'account_balance_wallet',
    'savings',
    'business_center',
    'card_giftcard',
  ];

  // Category colors
  static const List<String> _categoryColors = [
    '4CAF50', // Green
    '2196F3', // Blue
    'F44336', // Red
    'FF9800', // Orange
    '9C27B0', // Purple
    'E91E63', // Pink
    '00BCD4', // Cyan
    'FFC107', // Amber
    '795548', // Brown
    '607D8B', // Blue Grey
  ];

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_gas_station':
        return Icons.local_gas_station;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'emoji_transportation':
        return Icons.emoji_transportation;
      case 'phone_android':
        return Icons.phone_android;
      case 'checkroom':
        return Icons.checkroom;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'movie':
        return Icons.movie;
      case 'flight':
        return Icons.flight;
      case 'hotel':
        return Icons.hotel;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'pets':
        return Icons.pets;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'savings':
        return Icons.savings;
      case 'business_center':
        return Icons.business_center;
      case 'card_giftcard':
        return Icons.card_giftcard;
      default:
        return Icons.label;
    }
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
