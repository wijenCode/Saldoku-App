import 'package:flutter/material.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/theme/widgets/theme_extensions.dart';
import '../../../app/widgets/widgets.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/transaction.dart' as model;
import '../../../core/models/wallet.dart';
import '../../../core/models/category.dart' as cat;
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/date_utils.dart';
import '../data/transactions_repository.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _repository = TransactionsRepository();

  late TabController _tabController;
  List<model.Transaction> _allTransactions = [];
  List<model.Transaction> _incomeTransactions = [];
  List<model.Transaction> _expenseTransactions = [];
  bool _isLoading = true;

  // Cache for wallets and categories
  final Map<int, Wallet> _walletsCache = {};
  final Map<int, cat.Category> _categoriesCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final user = _authService.currentUser;
    if (user != null) {
      final transactions = await _repository.getTransactions(user.id!);

      // Load wallets and categories for caching
      final wallets = await _repository.getActiveWallets(user.id!);
      final incomeCategories = await _repository.getActiveCategories(
        user.id!,
        'income',
      );
      final expenseCategories = await _repository.getActiveCategories(
        user.id!,
        'expense',
      );

      _walletsCache.clear();
      _categoriesCache.clear();

      for (var wallet in wallets) {
        _walletsCache[wallet.id!] = wallet;
      }
      for (var category in incomeCategories) {
        _categoriesCache[category.id!] = category;
      }
      for (var category in expenseCategories) {
        _categoriesCache[category.id!] = category;
      }

      setState(() {
        _allTransactions = transactions;
        _incomeTransactions =
            transactions.where((t) => t.type == 'income').toList();
        _expenseTransactions =
            transactions.where((t) => t.type == 'expense').toList();
        _isLoading = false;
      });
    }
  }

  void _showTransactionForm({model.Transaction? transaction}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _TransactionFormSheet(
            transaction: transaction,
            repository: _repository,
          ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _showDeleteConfirmation(model.Transaction transaction) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Transaksi'),
            content: const Text(
              'Yakin ingin menghapus transaksi ini?\n\nSaldo dompet akan disesuaikan kembali.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  final result = await _repository.deleteTransaction(
                    transaction.id!,
                  );

                  if (!mounted) return;
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(content: Text(result['message'])),
                  );

                  if (result['success']) {
                    _loadData();
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
        title: const Text('Transaksi Harian'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Pemasukan'),
            Tab(text: 'Pengeluaran'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildTransactionList(_allTransactions),
                  _buildTransactionList(_incomeTransactions),
                  _buildTransactionList(_expenseTransactions),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTransactionForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Transaksi'),
      ),
    );
  }

  Widget _buildTransactionList(List<model.Transaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada transaksi',
              style: context.bodyStyle.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // Group by date
    final groupedTransactions = <String, List<model.Transaction>>{};
    for (var transaction in transactions) {
      final dateKey = AppDateUtils.format(
        transaction.date,
        pattern: 'dd MMM yyyy',
      );
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final dateKey = groupedTransactions.keys.elementAt(index);
        final dayTransactions = groupedTransactions[dateKey]!;

        // Calculate day total
        double dayIncome = 0;
        double dayExpense = 0;
        for (var t in dayTransactions) {
          if (t.type == 'income') {
            dayIncome += t.amount;
          } else {
            dayExpense += t.amount;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header with summary
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateKey,
                    style: context.bodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      if (dayIncome > 0) ...[
                        Text(
                          '+${CurrencyFormat.format(dayIncome)}',
                          style: context.labelStyle.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (dayExpense > 0)
                        Text(
                          '-${CurrencyFormat.format(dayExpense)}',
                          style: context.labelStyle.copyWith(
                            color: AppColors.expense,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Transactions for this day
            ...dayTransactions.map(
              (transaction) => _buildTransactionItem(transaction),
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(model.Transaction transaction) {
    final wallet = _walletsCache[transaction.walletId];
    final category = _categoriesCache[transaction.categoryId];
    final isIncome = transaction.type == 'income';

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isIncome ? AppColors.success : AppColors.expense).withAlpha(
              (0.1 * 255).round(),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? AppColors.success : AppColors.expense,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                category?.name ?? 'Kategori tidak diketahui',
                style: context.bodyStyle.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${CurrencyFormat.format(transaction.amount)}',
              style: context.bodyStyle.copyWith(
                color: isIncome ? AppColors.success : AppColors.expense,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  wallet?.name ?? 'Dompet tidak diketahui',
                  style: context.labelStyle.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (transaction.description != null &&
                transaction.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                transaction.description!,
                style: context.labelStyle.copyWith(color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showTransactionForm(transaction: transaction);
                break;
              case 'delete':
                _showDeleteConfirmation(transaction);
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
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Hapus', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
      ),
    );
  }
}

// Transaction Form Sheet
class _TransactionFormSheet extends StatefulWidget {
  final model.Transaction? transaction;
  final TransactionsRepository repository;

  const _TransactionFormSheet({this.transaction, required this.repository});

  @override
  State<_TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<_TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authService = AuthService();

  String _selectedType = 'expense';
  Wallet? _selectedWallet;
  cat.Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  List<Wallet> _wallets = [];
  List<cat.Category> _incomeCategories = [];
  List<cat.Category> _expenseCategories = [];

  @override
  void initState() {
    super.initState();
    _loadFormData();

    if (widget.transaction != null) {
      final t = widget.transaction!;
      _selectedType = t.type;
      _amountController.text = t.amount.toString();
      _descriptionController.text = t.description ?? '';
      _selectedDate = t.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final wallets = await widget.repository.getActiveWallets(user.id!);
      final incomeCategories = await widget.repository.getActiveCategories(
        user.id!,
        'income',
      );
      final expenseCategories = await widget.repository.getActiveCategories(
        user.id!,
        'expense',
      );

      setState(() {
        _wallets = wallets;
        _incomeCategories = incomeCategories;
        _expenseCategories = expenseCategories;

        // Set defaults
        if (widget.transaction != null) {
          _selectedWallet = wallets.firstWhere(
            (w) => w.id == widget.transaction!.walletId,
          );
          final categories =
              _selectedType == 'income' ? incomeCategories : expenseCategories;
          _selectedCategory = categories.firstWhere(
            (c) => c.id == widget.transaction!.categoryId,
          );
        } else {
          if (wallets.isNotEmpty) _selectedWallet = wallets.first;
          if (expenseCategories.isNotEmpty) {
            _selectedCategory = expenseCategories.first;
          }
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWallet == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih dompet dan kategori')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = _authService.currentUser!;
    final amount = double.parse(_amountController.text);

    Map<String, dynamic> result;

    if (widget.transaction == null) {
      // Create new
      result = await widget.repository.createTransaction(
        userId: user.id!,
        walletId: _selectedWallet!.id!,
        categoryId: _selectedCategory!.id!,
        type: _selectedType,
        amount: amount,
        date: _selectedDate,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
      );
    } else {
      // Update existing
      final updated = widget.transaction!.copyWith(
        walletId: _selectedWallet!.id!,
        categoryId: _selectedCategory!.id!,
        type: _selectedType,
        amount: amount,
        date: _selectedDate,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
      );

      result = await widget.repository.updateTransaction(
        widget.transaction!,
        updated,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pop(context, result['success']);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result['message'])));
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        _selectedType == 'income' ? _incomeCategories : _expenseCategories;

    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.transaction == null
                        ? 'Tambah Transaksi'
                        : 'Edit Transaksi',
                    style: context.headlineStyle,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Type selector
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'income', label: Text('Pemasukan')),
                  ButtonSegment(value: 'expense', label: Text('Pengeluaran')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _selectedType = selection.first;
                    // Reset category when type changes
                    final newCategories =
                        _selectedType == 'income'
                            ? _incomeCategories
                            : _expenseCategories;
                    if (newCategories.isNotEmpty) {
                      _selectedCategory = newCategories.first;
                    }
                  });
                },
              ),

              const SizedBox(height: 20),

              // Amount
              CustomTextField(
                controller: _amountController,
                label: 'Jumlah',
                hint: '0',
                prefixIcon: const Icon(Icons.attach_money),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah harus diisi';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Jumlah tidak valid';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Wallet dropdown
              DropdownButtonFormField<Wallet>(
                initialValue: _selectedWallet,
                decoration: InputDecoration(
                  labelText: 'Dompet',
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    _wallets.map((wallet) {
                      return DropdownMenuItem(
                        value: wallet,
                        child: Text(wallet.name),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() => _selectedWallet = value);
                },
                validator: (value) => value == null ? 'Pilih dompet' : null,
              ),

              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<cat.Category>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),

              const SizedBox(height: 16),

              // Date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Tanggal'),
                subtitle: Text(
                  AppDateUtils.format(_selectedDate, pattern: 'dd MMMM yyyy'),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),

              const Divider(),

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Catatan (Opsional)',
                hint: 'Tambahkan catatan...',
                prefixIcon: const Icon(Icons.note_outlined),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            widget.transaction == null ? 'Simpan' : 'Perbarui',
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
