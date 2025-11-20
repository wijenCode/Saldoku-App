import 'package:flutter/material.dart';
import '../../../core/models/bill.dart';
import '../providers/bills_provider.dart';

/// Screen untuk Tagihan (Bills)
class BillsScreen extends StatefulWidget {
  final int userId;

  const BillsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  late BillsProvider _provider;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _provider = BillsProvider();
    _load();
  }

  void _load() {
    _provider.loadBills(widget.userId).then((_) => setState(() {})).catchError((
      e,
    ) {
      _showError('Gagal memuat tagihan: $e');
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tagihan'), centerTitle: true),
      body:
          _provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSummaryCard(),
                    _buildTabBar(),
                    if (_selectedTab == 0)
                      _buildList(_provider.bills)
                    else if (_selectedTab == 1)
                      _buildList(_provider.dueSoon)
                    else
                      _buildList(_provider.overdue),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Tagihan Tertunda',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp ${_provider.totalPending.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Icon(Icons.receipt_long, color: Colors.white, size: 36),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _tabButton('Semua', 0),
          _tabButton('Jatuh Tempo', 1),
          _tabButton('Terlambat', 2),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final sel = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? Colors.blueAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: sel ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Bill> items) {
    if (items.isEmpty) return _emptyState();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, i) => _buildCard(items[i]),
    );
  }

  Widget _buildCard(Bill bill) {
    final isOverdue =
        bill.status == 'overdue' || bill.dueDate.isBefore(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          title: Text(bill.name),
          subtitle: Text(
            'Rp ${bill.amount.toStringAsFixed(0)} • ${bill.dueDate.toLocal().toString().split(' ')[0]}',
          ),
          trailing: PopupMenuButton(
            itemBuilder:
                (_) => [
                  PopupMenuItem(
                    child: const Text('Detail'),
                    onTap: () => _showDetail(bill),
                  ),
                  PopupMenuItem(
                    child: const Text('Edit'),
                    onTap: () => _showEdit(bill),
                  ),
                  PopupMenuItem(
                    child: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () => _delete(bill.id!),
                  ),
                ],
          ),
          leading: CircleAvatar(
            backgroundColor: isOverdue ? Colors.redAccent : Colors.green,
            child: Icon(
              isOverdue ? Icons.warning : Icons.schedule,
              color: Colors.white,
            ),
          ),
          onTap: () => _showDetail(bill),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Belum ada tagihan', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Tambahkan tagihan supaya kamu dapat mengelolanya.'),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder:
          (_) => _BillFormDialog(
            onSave: (bill) async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _provider.createBill(bill, widget.userId);
                if (!mounted) return;
                setState(() {});
                navigator.pop();
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Gagal menambah tagihan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
    );
  }

  void _showEdit(Bill bill) {
    showDialog(
      context: context,
      builder:
          (_) => _BillFormDialog(
            initial: bill,
            onSave: (updated) async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _provider.updateBill(updated, widget.userId);
                if (!mounted) return;
                setState(() {});
                navigator.pop();
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Gagal mengupdate tagihan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
    );
  }

  void _showDetail(Bill bill) {
    // Use a small delay because PopupMenuItem onTap runs before menu closes
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(bill.name),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jumlah: Rp ${bill.amount.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  Text(
                    'Jatuh tempo: ${bill.dueDate.toLocal().toString().split(' ')[0]}',
                  ),
                  const SizedBox(height: 8),
                  Text('Status: ${bill.status}'),
                  const SizedBox(height: 8),
                  Text('Pengulangan: ${bill.recurrence}'),
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
    });
  }

  void _delete(int billId) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Hapus Tagihan?'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus tagihan ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await _provider.deleteBill(billId, widget.userId);
                    if (!mounted) return;
                    setState(() {});
                    navigator.pop();
                  } catch (e) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus tagihan: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}

/// Form dialog untuk tambah / edit tagihan
class _BillFormDialog extends StatefulWidget {
  final Bill? initial;
  final Future<void> Function(Bill bill) onSave;

  const _BillFormDialog({Key? key, required this.onSave, this.initial})
    : super(key: key);

  @override
  State<_BillFormDialog> createState() => _BillFormDialogState();
}

class _BillFormDialogState extends State<_BillFormDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  DateTime _dueDate = DateTime.now();
  String _recurrence = 'once';
  bool _reminder = true;

  @override
  void initState() {
    super.initState();
    final ini = widget.initial;
    _nameCtrl = TextEditingController(text: ini?.name ?? '');
    _amountCtrl = TextEditingController(
      text: ini?.amount.toStringAsFixed(0) ?? '',
    );
    _dueDate = ini?.dueDate ?? DateTime.now();
    _recurrence = ini?.recurrence ?? 'once';
    _reminder = ini?.reminderEnabled ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Tambah Tagihan' : 'Edit Tagihan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _dueDate = picked);
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
                    const SizedBox(width: 8),
                    Text(
                      'Jatuh tempo: ${_dueDate.toLocal().toString().split(' ')[0]}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _recurrence,
              items: const [
                DropdownMenuItem(value: 'once', child: Text('Sekali')),
                DropdownMenuItem(value: 'monthly', child: Text('Bulanan')),
                DropdownMenuItem(value: 'yearly', child: Text('Tahunan')),
              ],
              onChanged: (v) => setState(() => _recurrence = v ?? 'once'),
              decoration: const InputDecoration(labelText: 'Pengulangan'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _reminder,
              onChanged: (v) => setState(() => _reminder = v),
              title: const Text('Ingatkan'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }

  void _save() {
    if (_nameCtrl.text.isEmpty || _amountCtrl.text.isEmpty) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Nama dan jumlah harus diisi')),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0.0;
    final existing = widget.initial;

    final bill = Bill(
      id: existing?.id,
      userId: existing?.userId ?? 1,
      walletId: existing?.walletId ?? 0,
      categoryId: existing?.categoryId ?? 0,
      name: _nameCtrl.text,
      amount: amount,
      dueDate: _dueDate,
      recurrence: _recurrence,
      status: existing?.status ?? 'pending',
      reminderEnabled: _reminder,
      reminderDays: existing?.reminderDays,
      autoPay: existing?.autoPay ?? false,
    );

    widget.onSave(bill);
  }
}
