import 'package:flutter/material.dart';
import '../../../core/models/budget.dart';
import '../providers/budgets_provider.dart';

/// Screen untuk Anggaran Bulanan
/// Menampilkan list anggaran, progress bar, dan statistik
class BudgetsScreen extends StatefulWidget {
  final int userId;

  const BudgetsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  late BudgetsProvider _provider;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _provider = BudgetsProvider();
    _loadBudgets();
  }

  void _loadBudgets() {
    _provider
        .loadBudgets(widget.userId)
        .then((_) {
          setState(() {});
        })
        .catchError((e) {
          _showErrorSnackBar('Gagal memuat data: $e');
        });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggaran Bulanan'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body:
          _provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Statistik keseluruhan
                    _buildOverallStatsCard(),

                    // Tab untuk switching view
                    _buildTabBar(),

                    // Content berdasarkan tab
                    if (_selectedTabIndex == 0)
                      _buildAllBudgetsView()
                    else if (_selectedTabIndex == 1)
                      _buildCurrentMonthView()
                    else
                      _buildWarningBudgetsView(),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Widget untuk menampilkan statistik keseluruhan
  Widget _buildOverallStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row untuk Total Budget dan Sisa
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Total Budget
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Anggaran',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${_calculateTotalBudget().toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Sisa Budget
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Sisa Anggaran',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${_provider.totalRemaining.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress bar keseluruhan
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Penggunaan',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${_provider.overallPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _provider.overallPercentage / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _provider.overallPercentage > 100
                        ? Colors.redAccent
                        : _provider.overallPercentage > 80
                        ? Colors.orangeAccent
                        : Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget untuk tab bar
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTabButton('Semua', 0),
          _buildTabButton('Bulan Ini', 1),
          _buildTabButton('Peringatan', 2),
        ],
      ),
    );
  }

  /// Widget untuk tombol tab individual
  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// Widget untuk view semua budget
  Widget _buildAllBudgetsView() {
    if (_provider.budgets.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _provider.budgets.length,
      itemBuilder: (context, index) {
        final budget = _provider.budgets[index];
        return _buildBudgetCard(budget);
      },
    );
  }

  /// Widget untuk view budget bulan ini
  Widget _buildCurrentMonthView() {
    if (_provider.currentMonthBudgets.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _provider.currentMonthBudgets.length,
      itemBuilder: (context, index) {
        final budget = _provider.currentMonthBudgets[index];
        return _buildBudgetCard(budget);
      },
    );
  }

  /// Widget untuk view budget yang melebihi limit
  Widget _buildWarningBudgetsView() {
    if (_provider.overBudgets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada anggaran yang melebihi',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _provider.overBudgets.length,
      itemBuilder: (context, index) {
        final budget = _provider.overBudgets[index];
        return _buildBudgetCard(budget, showWarning: true);
      },
    );
  }

  /// Widget untuk card budget individual
  Widget _buildBudgetCard(Budget budget, {bool showWarning = false}) {
    final percentage = budget.percentage;
    final progressColor =
        budget.isOverBudget
            ? Colors.redAccent
            : percentage > 80
            ? Colors.orangeAccent
            : Colors.greenAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _showBudgetDetailDialog(budget),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${budget.periodStart.toLocal().toString().split(' ')[0]} - ${budget.periodEnd.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showWarning)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Melebihi',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Amount info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${budget.spent.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                      ),
                    ),
                    Text(
                      'Rp ${budget.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (percentage / 100).clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: 8),

                // Percentage and remaining
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Sisa: Rp ${budget.remaining.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: budget.remaining < 0 ? Colors.red : Colors.green,
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              onTap: () => _showEditBudgetDialog(budget),
                              child: const Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () => _deleteBudget(budget.id!),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.grey[500],
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget untuk empty state
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada anggaran',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat anggaran untuk mengontrol pengeluaran',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Dialog untuk menambah budget baru
  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder:
          (context) => _BudgetFormDialog(
            onSave: (name, amount, periodStart, periodEnd, categoryId) async {
              final budget = Budget(
                userId: widget.userId,
                categoryId: categoryId,
                name: name,
                amount: amount,
                periodStart: periodStart,
                periodEnd: periodEnd,
              );

              try {
                await _provider.createBudget(budget, widget.userId);
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Anggaran berhasil ditambahkan'),
                  ),
                );
              } catch (e) {
                _showErrorSnackBar('Gagal menambahkan anggaran: $e');
              }
            },
          ),
    );
  }

  /// Dialog untuk edit budget
  void _showEditBudgetDialog(Budget budget) {
    showDialog(
      context: context,
      builder:
          (context) => _BudgetFormDialog(
            initialName: budget.name,
            initialAmount: budget.amount,
            initialPeriodStart: budget.periodStart,
            initialPeriodEnd: budget.periodEnd,
            onSave: (name, amount, periodStart, periodEnd, categoryId) async {
              final updatedBudget = budget.copyWith(
                name: name,
                amount: amount,
                periodStart: periodStart,
                periodEnd: periodEnd,
                categoryId: categoryId,
              );

              try {
                await _provider.updateBudget(updatedBudget, widget.userId);
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Anggaran berhasil diupdate')),
                );
              } catch (e) {
                _showErrorSnackBar('Gagal mengupdate anggaran: $e');
              }
            },
          ),
    );
  }

  /// Dialog untuk menampilkan detail budget
  void _showBudgetDetailDialog(Budget budget) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(budget.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Anggaran: Rp ${budget.amount.toStringAsFixed(0)}'),
                const SizedBox(height: 8),
                Text('Pengeluaran: Rp ${budget.spent.toStringAsFixed(0)}'),
                const SizedBox(height: 8),
                Text('Sisa: Rp ${budget.remaining.toStringAsFixed(0)}'),
                const SizedBox(height: 8),
                Text('Penggunaan: ${budget.percentage.toStringAsFixed(1)}%'),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (budget.percentage / 100).clamp(0, 1),
                    minHeight: 10,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  /// Fungsi untuk menghapus budget
  void _deleteBudget(int budgetId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Anggaran?'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus anggaran ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _provider.deleteBudget(budgetId, widget.userId);
                    setState(() {});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Anggaran berhasil dihapus'),
                      ),
                    );
                  } catch (e) {
                    _showErrorSnackBar('Gagal menghapus anggaran: $e');
                  }
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  /// Hitung total budget
  double _calculateTotalBudget() {
    return _provider.budgets.fold(0.0, (sum, budget) => sum + budget.amount);
  }
}

/// Dialog form untuk tambah/edit budget
class _BudgetFormDialog extends StatefulWidget {
  final Function(
    String name,
    double amount,
    DateTime periodStart,
    DateTime periodEnd,
    int categoryId,
  )
  onSave;
  final String? initialName;
  final double? initialAmount;
  final DateTime? initialPeriodStart;
  final DateTime? initialPeriodEnd;

  const _BudgetFormDialog({
    required this.onSave,
    this.initialName,
    this.initialAmount,
    this.initialPeriodStart,
    this.initialPeriodEnd,
  });

  @override
  State<_BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends State<_BudgetFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late DateTime _periodStart;
  late DateTime _periodEnd;
  int _selectedCategoryId = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _amountController = TextEditingController(
      text: widget.initialAmount?.toStringAsFixed(0) ?? '',
    );
    _periodStart = widget.initialPeriodStart ?? DateTime.now();
    _periodEnd =
        widget.initialPeriodEnd ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialName == null ? 'Tambah Anggaran' : 'Edit Anggaran',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Anggaran',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.trending_up),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Anggaran (Rp)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.money),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _periodStart,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() => _periodStart = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Mulai: ${_periodStart.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _periodEnd,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() => _periodEnd = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Akhir: ${_periodEnd.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
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
          onPressed: () {
            if (_nameController.text.isEmpty ||
                _amountController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Semua field harus diisi')),
              );
              return;
            }
            widget.onSave(
              _nameController.text,
              double.parse(_amountController.text),
              _periodStart,
              _periodEnd,
              _selectedCategoryId,
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
