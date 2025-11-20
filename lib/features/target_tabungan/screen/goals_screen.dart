import 'package:flutter/material.dart';
import '../../../core/models/savings_goal.dart';
import '../providers/goals_provider.dart';

/// Screen untuk Target Tabungan
class GoalsScreen extends StatefulWidget {
  final int userId;

  const GoalsScreen({super.key, required this.userId});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late GoalsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = GoalsProvider();
    _load();
  }

  void _load() {
    _provider.loadGoals(widget.userId).then((_) => setState(() {})).catchError((
      e,
    ) {
      _showError('Gagal memuat data: $e');
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
      appBar: AppBar(title: const Text('Target Tabungan'), centerTitle: true),
      body:
          _provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 8),
                    _buildGoalsList(),
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
                'Total Terkumpul',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp ${_provider.totalSaved.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Icon(Icons.savings, color: Colors.white, size: 36),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    if (_provider.goals.isEmpty) return _emptyState();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _provider.goals.length,
      itemBuilder: (context, i) => _buildGoalCard(_provider.goals[i]),
    );
  }

  Widget _buildGoalCard(SavingsGoal goal) {
    final color = Colors.blue;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          title: Text(goal.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (goal.percentage / 100).clamp(0, 1),
                minHeight: 8,
                valueColor: AlwaysStoppedAnimation(color),
              ),
              const SizedBox(height: 8),
              Text(
                'Terkumpul: Rp ${goal.currentAmount.toStringAsFixed(0)} • Target: Rp ${goal.targetAmount.toStringAsFixed(0)}',
              ),
            ],
          ),
          trailing: PopupMenuButton(
            itemBuilder:
                (_) => [
                  PopupMenuItem(
                    child: const Text('Detail'),
                    onTap: () => _showDetail(goal),
                  ),
                  PopupMenuItem(
                    child: const Text('Setor'),
                    onTap: () => _showDeposit(goal),
                  ),
                  PopupMenuItem(
                    child: const Text('Edit'),
                    onTap: () => _showEdit(goal),
                  ),
                  PopupMenuItem(
                    child: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () => _delete(goal.id!),
                  ),
                ],
          ),
          onTap: () => _showDetail(goal),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(Icons.flag_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Belum ada target tabungan',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text('Buat target tabungan untuk mulai menabung.'),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder:
          (_) => _GoalFormDialog(
            onSave: (goal) async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _provider.createGoal(goal, widget.userId);
                if (!mounted) return;
                setState(() {});
                navigator.pop();
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Gagal membuat target: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
    );
  }

  void _showEdit(SavingsGoal goal) {
    showDialog(
      context: context,
      builder:
          (_) => _GoalFormDialog(
            initial: goal,
            onSave: (updated) async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _provider.updateGoal(updated, widget.userId);
                if (!mounted) return;
                setState(() {});
                navigator.pop();
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Gagal mengupdate target: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
    );
  }

  void _showDeposit(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (_) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Setor ke target'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final v = double.tryParse(ctrl.text.replaceAll(',', '')) ?? 0.0;
                if (v <= 0) {
                  if (mounted) _showError('Jumlah tidak valid');
                  return;
                }
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await _provider.deposit(goal.id!, v, widget.userId);
                  if (!mounted) return;
                  setState(() {});
                  navigator.pop();
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Gagal setor: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Setor'),
            ),
          ],
        );
      },
    );
  }

  void _showDetail(SavingsGoal goal) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(goal.name),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target: Rp ${goal.targetAmount.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  Text(
                    'Terkumpul: Rp ${goal.currentAmount.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 8),
                  Text('Sisa: Rp ${goal.remaining.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  Text('Persentase: ${goal.percentage.toStringAsFixed(1)}%'),
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

  void _delete(int id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Hapus target?'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus target ini?',
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
                    await _provider.deleteGoal(id, widget.userId);
                    if (!mounted) return;
                    setState(() {});
                    navigator.pop();
                  } catch (e) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus: $e'),
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

class _GoalFormDialog extends StatefulWidget {
  final SavingsGoal? initial;
  final Future<void> Function(SavingsGoal) onSave;

  const _GoalFormDialog({Key? key, required this.onSave, this.initial})
    : super(key: key);

  @override
  State<_GoalFormDialog> createState() => _GoalFormDialogState();
}

class _GoalFormDialogState extends State<_GoalFormDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _targetCtrl;
  DateTime? _deadline;
  int _walletId = 0;

  @override
  void initState() {
    super.initState();
    final ini = widget.initial;
    _nameCtrl = TextEditingController(text: ini?.name ?? '');
    _targetCtrl = TextEditingController(
      text: ini?.targetAmount.toStringAsFixed(0) ?? '',
    );
    _deadline = ini?.deadline;
    _walletId = ini?.walletId ?? 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Tambah Target' : 'Edit Target'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Target'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Target (Rp)',
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _deadline ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _deadline = picked);
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
                      _deadline == null
                          ? 'Pilih deadline (opsional)'
                          : 'Deadline: ${_deadline!.toLocal().toString().split(' ')[0]}',
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
        ElevatedButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }

  void _save() {
    if (_nameCtrl.text.isEmpty || _targetCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan target harus diisi')),
      );
      return;
    }
    final target = double.tryParse(_targetCtrl.text.replaceAll(',', '')) ?? 0.0;
    final existing = widget.initial;
    final goal = SavingsGoal(
      id: existing?.id,
      userId: existing?.userId ?? 1,
      walletId: _walletId,
      name: _nameCtrl.text,
      targetAmount: target,
      currentAmount: existing?.currentAmount ?? 0,
      deadline: _deadline,
      status: existing?.status ?? 'active',
    );

    widget.onSave(goal);
  }
}
