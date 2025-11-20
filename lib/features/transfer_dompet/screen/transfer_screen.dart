import 'package:flutter/material.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/theme/widgets/theme_extensions.dart';
import '../../../app/widgets/widgets.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/wallet_transfer.dart';
import '../../../core/models/wallet.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/date_utils.dart';
import '../data/transfer_repository.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _authService = AuthService();
  final _repository = TransferRepository();

  List<WalletTransfer> _transfers = [];
  bool _isLoading = true;

  // Cache for wallets
  final Map<int, Wallet> _walletsCache = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final user = _authService.currentUser;
    if (user != null) {
      final transfers = await _repository.getTransfers(user.id!);
      final wallets = await _repository.getActiveWallets(user.id!);

      _walletsCache.clear();
      for (var wallet in wallets) {
        _walletsCache[wallet.id!] = wallet;
      }

      setState(() {
        _transfers = transfers;
        _isLoading = false;
      });
    }
  }

  void _showTransferForm() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransferFormSheet(repository: _repository),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _showDeleteConfirmation(WalletTransfer transfer) {
    final fromWallet = _walletsCache[transfer.fromWalletId];
    final toWallet = _walletsCache[transfer.toWalletId];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Batalkan Transfer'),
            content: Text(
              'Yakin ingin membatalkan transfer ini?\n\n'
              'Dari: ${fromWallet?.name ?? 'Unknown'}\n'
              'Ke: ${toWallet?.name ?? 'Unknown'}\n'
              'Jumlah: ${CurrencyFormat.format(transfer.amount)}\n\n'
              'Saldo kedua dompet akan dikembalikan.',
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
                  final result = await _repository.deleteTransfer(transfer.id!);

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
                child: const Text('Batalkan'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Dompet')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildTransferList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTransferForm,
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Transfer'),
      ),
    );
  }

  Widget _buildTransferList() {
    if (_transfers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz_rounded,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada riwayat transfer',
              style: context.bodyStyle.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // Group by date
    final groupedTransfers = <String, List<WalletTransfer>>{};
    for (var transfer in _transfers) {
      final dateKey = AppDateUtils.format(
        transfer.date,
        pattern: 'dd MMM yyyy',
      );
      if (!groupedTransfers.containsKey(dateKey)) {
        groupedTransfers[dateKey] = [];
      }
      groupedTransfers[dateKey]!.add(transfer);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedTransfers.length,
      itemBuilder: (context, index) {
        final dateKey = groupedTransfers.keys.elementAt(index);
        final dayTransfers = groupedTransfers[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dateKey,
                style: context.bodyStyle.copyWith(fontWeight: FontWeight.w600),
              ),
            ),

            // Transfers for this day
            ...dayTransfers.map((transfer) => _buildTransferItem(transfer)),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildTransferItem(WalletTransfer transfer) {
    final fromWallet = _walletsCache[transfer.fromWalletId];
    final toWallet = _walletsCache[transfer.toWalletId];

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.info.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.swap_horiz, color: AppColors.info),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          fromWallet?.name ?? 'Unknown',
                          style: context.labelStyle.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          toWallet?.name ?? 'Unknown',
                          style: context.labelStyle.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              CurrencyFormat.format(transfer.amount),
              style: context.bodyStyle.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (transfer.fee > 0)
              Text(
                'Biaya: ${CurrencyFormat.format(transfer.fee)}',
                style: context.labelStyle.copyWith(color: Colors.grey.shade600),
              ),
            if (transfer.description != null &&
                transfer.description!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                transfer.description!,
                style: context.labelStyle.copyWith(color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _showDeleteConfirmation(transfer),
        ),
      ),
    );
  }
}

// Transfer Form Sheet
class _TransferFormSheet extends StatefulWidget {
  final TransferRepository repository;

  const _TransferFormSheet({required this.repository});

  @override
  State<_TransferFormSheet> createState() => _TransferFormSheetState();
}

class _TransferFormSheetState extends State<_TransferFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _feeController = TextEditingController(text: '0');
  final _descriptionController = TextEditingController();
  final _authService = AuthService();

  Wallet? _fromWallet;
  Wallet? _toWallet;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  List<Wallet> _wallets = [];

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadWallets() async {
    final user = _authService.currentUser;
    if (user != null) {
      final wallets = await widget.repository.getActiveWallets(user.id!);
      setState(() {
        _wallets = wallets;
        if (wallets.length >= 2) {
          _fromWallet = wallets[0];
          _toWallet = wallets[1];
        }
      });
    }
  }

  List<Wallet> _getAvailableToWallets() {
    if (_fromWallet == null) return _wallets;
    return _wallets.where((w) => w.id != _fromWallet!.id).toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromWallet == null || _toWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih dompet sumber dan tujuan')),
      );
      return;
    }

    if (_fromWallet!.id == _toWallet!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dompet sumber dan tujuan tidak boleh sama'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = _authService.currentUser!;
    final amount = double.parse(_amountController.text);
    final fee = double.parse(_feeController.text);

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await widget.repository.createTransfer(
      userId: user.id!,
      fromWalletId: _fromWallet!.id!,
      toWalletId: _toWallet!.id!,
      amount: amount,
      fee: fee,
      date: _selectedDate,
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    navigator.pop(result['success']);
    messenger.showSnackBar(SnackBar(content: Text(result['message'])));
  }

  @override
  Widget build(BuildContext context) {
    final availableToWallets = _getAvailableToWallets();

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
                  Text('Transfer Dompet', style: context.headlineStyle),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // From Wallet
              DropdownButtonFormField<Wallet>(
                initialValue: _fromWallet,
                decoration: InputDecoration(
                  labelText: 'Dari Dompet',
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    _wallets.map((wallet) {
                      return DropdownMenuItem(
                        value: wallet,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(wallet.name),
                            Text(
                              CurrencyFormat.format(wallet.balance),
                              style: context.labelStyle.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _fromWallet = value;
                    // Reset to wallet if same as from wallet
                    if (_toWallet?.id == value?.id) {
                      final available = _getAvailableToWallets();
                      _toWallet = available.isNotEmpty ? available.first : null;
                    }
                  });
                },
                validator:
                    (value) => value == null ? 'Pilih dompet sumber' : null,
              ),

              const SizedBox(height: 16),

              // To Wallet
              DropdownButtonFormField<Wallet>(
                initialValue: _toWallet,
                decoration: InputDecoration(
                  labelText: 'Ke Dompet',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    availableToWallets.map((wallet) {
                      return DropdownMenuItem(
                        value: wallet,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(wallet.name),
                            Text(
                              CurrencyFormat.format(wallet.balance),
                              style: context.labelStyle.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() => _toWallet = value);
                },
                validator:
                    (value) => value == null ? 'Pilih dompet tujuan' : null,
              ),

              const SizedBox(height: 16),

              // Amount
              CustomTextField(
                controller: _amountController,
                label: 'Jumlah Transfer',
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
                  final amount = double.parse(value);
                  if (amount <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  if (_fromWallet != null) {
                    final fee = double.tryParse(_feeController.text) ?? 0;
                    if (_fromWallet!.balance < (amount + fee)) {
                      return 'Saldo tidak mencukupi';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Fee
              CustomTextField(
                controller: _feeController,
                label: 'Biaya Transfer (Opsional)',
                hint: '0',
                prefixIcon: const Icon(Icons.money_off),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (double.tryParse(value) == null) {
                    return 'Biaya tidak valid';
                  }
                  if (double.parse(value) < 0) {
                    return 'Biaya tidak boleh negatif';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Balance info
              if (_fromWallet != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Saldo ${_fromWallet!.name}: ${CurrencyFormat.format(_fromWallet!.balance)}',
                          style: context.labelStyle.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

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
                          : const Text('Transfer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
