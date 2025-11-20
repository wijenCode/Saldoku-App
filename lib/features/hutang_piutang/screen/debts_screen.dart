import 'package:flutter/material.dart';
import '../../../core/models/debt.dart';
import '../../../core/models/debt_payment.dart';
import '../providers/debts_provider.dart';

/// Screen untuk Hutang/Piutang
/// Menampilkan list hutang dan piutang dengan filter dan tracking status
class DebtsScreen extends StatefulWidget {
  final int userId;

  const DebtsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  late DebtsProvider _provider;
  int _selectedTabIndex = 0; // 0: Hutang, 1: Piutang, 2: Jatuh Tempo

  @override
  void initState() {
    super.initState();
    _provider = DebtsProvider();
    _loadDebts();
  }

  void _loadDebts() {
    _provider
        .loadDebts(widget.userId)
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
        title: const Text('Hutang & Piutang'),
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
                    // Summary cards
                    _buildSummaryCards(),

                    // Tab untuk switching view
                    _buildTabBar(),

                    // Content berdasarkan tab
                    if (_selectedTabIndex == 0)
                      _buildDebtsView()
                    else if (_selectedTabIndex == 1)
                      _buildReceivablesView()
                    else
                      _buildOverdueView(),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtDialog(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Widget untuk menampilkan summary cards
  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Card Hutang
          Expanded(
            child: _buildSummaryCard(
              title: 'Hutang',
              amount: _provider.totalUnpaidDebt,
              icon: Icons.trending_down,
              color: Colors.redAccent,
              count: _provider.unpaidDebts.length,
            ),
          ),
          const SizedBox(width: 12),
          // Card Piutang
          Expanded(
            child: _buildSummaryCard(
              title: 'Piutang',
              amount: _provider.totalUnpaidReceivable,
              icon: Icons.trending_up,
              color: Colors.greenAccent,
              count: _provider.unpaidReceivables.length,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk individual summary card
  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha((0.8 * 255).round()), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha((0.3 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count transaksi',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
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
          _buildTabButton('Hutang', 0),
          _buildTabButton('Piutang', 1),
          _buildTabButton('Jatuh Tempo (${_provider.overdueCount})', 2),
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
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  /// Widget untuk view hutang
  Widget _buildDebtsView() {
    if (_provider.unpaidDebts.isEmpty) {
      return _buildEmptyState(
        'Tidak ada hutang',
        'Anda tidak memiliki hutang saat ini',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _provider.unpaidDebts.length,
      itemBuilder: (context, index) {
        final debt = _provider.unpaidDebts[index];
        return _buildDebtCard(debt);
      },
    );
  }

  /// Widget untuk view piutang
  Widget _buildReceivablesView() {
    if (_provider.unpaidReceivables.isEmpty) {
      return _buildEmptyState(
        'Tidak ada piutang',
        'Anda tidak memiliki piutang saat ini',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _provider.unpaidReceivables.length,
      itemBuilder: (context, index) {
        final debt = _provider.unpaidReceivables[index];
        return _buildDebtCard(debt);
      },
    );
  }

  /// Widget untuk view hutang yang jatuh tempo
  Widget _buildOverdueView() {
    if (_provider.overdueDebts.isEmpty) {
      return _buildEmptyState(
        'Tidak ada yang jatuh tempo',
        'Semua hutang/piutang masih dalam batas waktu',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _provider.overdueDebts.length,
      itemBuilder: (context, index) {
        final debt = _provider.overdueDebts[index];
        return _buildDebtCard(debt, isOverdue: true);
      },
    );
  }

  /// Widget untuk card hutang/piutang individual
  Widget _buildDebtCard(Debt debt, {bool isOverdue = false}) {
    final isDebt = debt.type == 'debt';
    final statusColor =
        debt.status == 'paid'
            ? Colors.greenAccent
            : debt.status == 'partially_paid'
            ? Colors.orangeAccent
            : isOverdue
            ? Colors.redAccent
            : Colors.blueAccent;

    final statusLabel =
        debt.status == 'paid'
            ? 'Lunas'
            : debt.status == 'partially_paid'
            ? 'Sebagian'
            : 'Belum Bayar';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _showDebtDetailDialog(debt),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan nama dan status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            debt.personName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isDebt
                                          ? Colors.redAccent.withAlpha(
                                            (0.1 * 255).round(),
                                          )
                                          : Colors.greenAccent.withAlpha(
                                            (0.1 * 255).round(),
                                          ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isDebt ? 'Hutang' : 'Piutang',
                                  style: TextStyle(
                                    color: isDebt ? Colors.red : Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withAlpha(
                                    (0.1 * 255).round(),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder:
                          (context) => [
                            if (debt.status != 'paid')
                              PopupMenuItem(
                                onTap: () => _showPaymentDialog(debt),
                                child: const Row(
                                  children: [
                                    Icon(Icons.payment, size: 18),
                                    SizedBox(width: 8),
                                    Text('Bayar'),
                                  ],
                                ),
                              ),
                            PopupMenuItem(
                              onTap: () => _showEditDebtDialog(debt),
                              child: const Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () => _deleteDebt(debt.id!),
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
                const SizedBox(height: 12),

                // Amount info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Hutang',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${debt.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Sisa Hutang',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${debt.remainingAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                debt.remainingAmount > 0
                                    ? Colors.red
                                    : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (debt.percentage / 100).clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      debt.isPaid ? Colors.green : Colors.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Due date info
                if (debt.dueDate != null)
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Jatuh Tempo: ${debt.dueDate!.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isOverdue ? Colors.redAccent : Colors.grey[600],
                          fontWeight:
                              isOverdue ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                // Progress percentage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${debt.percentage.toStringAsFixed(1)}% Lunas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
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
  Widget _buildEmptyState(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.done_all_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Dialog untuk menambah hutang/piutang baru
  void _showAddDebtDialog() {
    showDialog(
      context: context,
      builder:
          (context) => _DebtFormDialog(
            onSave: (personName, type, amount, dueDate, description) async {
              final debt = Debt(
                userId: widget.userId,
                type: type,
                personName: personName,
                amount: amount,
                dueDate: dueDate,
                description: description,
              );

              try {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                await _provider.createDebt(debt, widget.userId);
                if (!mounted) return;
                setState(() {});
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Hutang/piutang berhasil ditambahkan'),
                  ),
                );
              } catch (e) {
                _showErrorSnackBar('Gagal menambahkan: $e');
              }
            },
          ),
    );
  }

  /// Dialog untuk edit hutang/piutang
  void _showEditDebtDialog(Debt debt) {
    showDialog(
      context: context,
      builder:
          (context) => _DebtFormDialog(
            initialPersonName: debt.personName,
            initialType: debt.type,
            initialAmount: debt.amount,
            initialDueDate: debt.dueDate,
            initialDescription: debt.description,
            onSave: (personName, type, amount, dueDate, description) async {
              final updatedDebt = debt.copyWith(
                personName: personName,
                type: type,
                amount: amount,
                dueDate: dueDate,
                description: description,
              );

              try {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                await _provider.updateDebt(updatedDebt, widget.userId);
                if (!mounted) return;
                setState(() {});
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Hutang/piutang berhasil diupdate'),
                  ),
                );
              } catch (e) {
                _showErrorSnackBar('Gagal mengupdate: $e');
              }
            },
          ),
    );
  }

  /// Dialog untuk detail hutang/piutang
  void _showDebtDetailDialog(Debt debt) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(debt.personName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipe: ${debt.type == 'debt' ? 'Hutang' : 'Piutang'}'),
                const SizedBox(height: 8),
                Text('Total: Rp ${debt.amount.toStringAsFixed(0)}'),
                const SizedBox(height: 8),
                Text('Sisa: Rp ${debt.remainingAmount.toStringAsFixed(0)}'),
                const SizedBox(height: 8),
                Text('Status: ${debt.status}'),
                if (debt.dueDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Jatuh Tempo: ${debt.dueDate!.toLocal().toString().split(' ')[0]}',
                  ),
                ],
                if (debt.description != null &&
                    debt.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Keterangan: ${debt.description}'),
                ],
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

  /// Dialog untuk pembayaran hutang
  void _showPaymentDialog(Debt debt) {
    showDialog(
      context: context,
      builder:
          (context) => _PaymentDialog(
            debt: debt,
            onSave: (amount, notes) async {
              final payment = DebtPayment(
                debtId: debt.id!,
                walletId:
                    1, // Placeholder, sesuaikan dengan wallet yang dipilih
                amount: amount,
                paymentDate: DateTime.now(),
                notes: notes,
              );

              try {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                await _provider.createDebtPayment(payment, widget.userId);
                if (!mounted) return;
                setState(() {});
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Pembayaran berhasil dicatat')),
                );
              } catch (e) {
                _showErrorSnackBar('Gagal mencatat pembayaran: $e');
              }
            },
          ),
    );
  }

  /// Fungsi untuk menghapus hutang/piutang
  void _deleteDebt(int debtId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Hutang/Piutang?'),
            content: const Text('Apakah Anda yakin ingin menghapus?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    await _provider.deleteDebt(debtId, widget.userId);
                    if (!mounted) return;
                    setState(() {});
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Hutang/piutang berhasil dihapus'),
                      ),
                    );
                  } catch (e) {
                    _showErrorSnackBar('Gagal menghapus: $e');
                  }
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}

/// Dialog form untuk tambah/edit hutang/piutang
class _DebtFormDialog extends StatefulWidget {
  final Function(
    String personName,
    String type,
    double amount,
    DateTime? dueDate,
    String? description,
  )
  onSave;
  final String? initialPersonName;
  final String? initialType;
  final double? initialAmount;
  final DateTime? initialDueDate;
  final String? initialDescription;

  const _DebtFormDialog({
    required this.onSave,
    this.initialPersonName,
    this.initialType,
    this.initialAmount,
    this.initialDueDate,
    this.initialDescription,
  });

  @override
  State<_DebtFormDialog> createState() => _DebtFormDialogState();
}

class _DebtFormDialogState extends State<_DebtFormDialog> {
  late TextEditingController _personNameController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late String _selectedType;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _personNameController = TextEditingController(
      text: widget.initialPersonName ?? '',
    );
    _amountController = TextEditingController(
      text: widget.initialAmount?.toStringAsFixed(0) ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    _selectedType = widget.initialType ?? 'debt';
    _dueDate = widget.initialDueDate;
  }

  @override
  void dispose() {
    _personNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialPersonName == null
            ? 'Tambah Hutang/Piutang'
            : 'Edit Hutang/Piutang',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: 'Tipe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                const DropdownMenuItem(value: 'debt', child: Text('Hutang')),
                const DropdownMenuItem(
                  value: 'receivable',
                  child: Text('Piutang'),
                ),
              ],
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _personNameController,
              decoration: InputDecoration(
                labelText: 'Nama Orang',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah (Rp)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() => _dueDate = picked);
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
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      _dueDate?.toString().split(' ')[0] ??
                          'Pilih Tanggal Jatuh Tempo',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Keterangan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
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
            if (_personNameController.text.isEmpty ||
                _amountController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Semua field harus diisi')),
              );
              return;
            }
            widget.onSave(
              _personNameController.text,
              _selectedType,
              double.parse(_amountController.text),
              _dueDate,
              _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

/// Dialog untuk mencatat pembayaran
class _PaymentDialog extends StatefulWidget {
  final Debt debt;
  final Function(double amount, String? notes) onSave;

  const _PaymentDialog({required this.debt, required this.onSave});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Catat Pembayaran'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sisa Hutang: Rp ${widget.debt.remainingAmount.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah Pembayaran (Rp)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Catatan',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_amountController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Jumlah pembayaran harus diisi')),
              );
              return;
            }
            final amount = double.parse(_amountController.text);
            if (amount > widget.debt.remainingAmount) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Jumlah melebihi sisa hutang')),
              );
              return;
            }
            widget.onSave(
              amount,
              _notesController.text.isEmpty ? null : _notesController.text,
            );
          },
          child: const Text('Bayar'),
        ),
      ],
    );
  }
}
