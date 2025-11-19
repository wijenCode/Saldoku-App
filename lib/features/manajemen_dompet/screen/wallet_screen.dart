import 'package:flutter/material.dart';
import '../../../core/models/wallet.dart';
import '../providers/wallet_provider.dart';

/// Screen untuk Manajemen Dompet
/// Menampilkan list dompet, detail, dan form tambah/edit
class WalletScreen extends StatefulWidget {
  final int userId;

  const WalletScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late WalletProvider _provider;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _provider = WalletProvider();
    _loadWallets();
  }

  void _loadWallets() {
    _provider
        .loadWallets(widget.userId)
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
        title: const Text('Manajemen Dompet'),
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
                    // Header dengan total saldo
                    _buildTotalBalanceCard(),

                    // Tab untuk switching view
                    _buildTabBar(),

                    // Content berdasarkan tab
                    if (_selectedTabIndex == 0)
                      _buildWalletListView()
                    else
                      _buildWalletsByTypeView(),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWalletDialog(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Widget untuk menampilkan total saldo
  Widget _buildTotalBalanceCard() {
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
          const Text(
            'Total Saldo',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Rp ${_provider.totalBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_provider.wallets.length} Dompet',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Aktif',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
        children: [_buildTabButton('Semua', 0), _buildTabButton('Tipe', 1)],
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
          padding: const EdgeInsets.symmetric(vertical: 12),
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
            ),
          ),
        ),
      ),
    );
  }

  /// Widget untuk list view dompet
  Widget _buildWalletListView() {
    if (_provider.wallets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wallet_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Belum ada dompet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan dompet baru untuk mulai',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _provider.wallets.length,
      itemBuilder: (context, index) {
        final wallet = _provider.wallets[index];
        return _buildWalletCard(wallet);
      },
    );
  }

  /// Widget untuk card dompet individual
  Widget _buildWalletCard(Wallet wallet) {
    final walletTypeIcons = {
      'cash': Icons.money_rounded,
      'bank': Icons.account_balance_rounded,
      'e-wallet': Icons.account_balance_wallet_rounded,
      'credit_card': Icons.credit_card_rounded,
    };

    final walletTypeLabels = {
      'cash': 'Tunai',
      'bank': 'Bank',
      'e-wallet': 'E-Wallet',
      'credit_card': 'Kartu Kredit',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _showWalletDetailDialog(wallet),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon dengan background warna
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    walletTypeIcons[wallet.type] ?? Icons.wallet_outlined,
                    color: Colors.blueAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Informasi dompet
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        walletTypeLabels[wallet.type] ?? wallet.type,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Saldo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${wallet.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    PopupMenuButton(
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              onTap: () => _showEditWalletDialog(wallet),
                              child: const Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () => _deleteWallet(wallet.id!),
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

  /// Widget untuk view berdasarkan tipe wallet
  Widget _buildWalletsByTypeView() {
    final types = ['cash', 'bank', 'e-wallet', 'credit_card'];
    final typeLabels = {
      'cash': 'Tunai',
      'bank': 'Bank',
      'e-wallet': 'E-Wallet',
      'credit_card': 'Kartu Kredit',
    };

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final walletsOfType =
            _provider.wallets.where((w) => w.type == type).toList();

        if (walletsOfType.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
              child: Text(
                typeLabels[type] ?? type,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ...walletsOfType.map((wallet) => _buildWalletCard(wallet)),
          ],
        );
      },
    );
  }

  /// Dialog untuk menambah dompet baru
  void _showAddWalletDialog() {
    showDialog(
      context: context,
      builder:
          (context) => _WalletFormDialog(
            onSave: (name, type) async {
              final wallet = Wallet(
                userId: widget.userId,
                name: name,
                type: type,
                balance: 0,
              );

              try {
                await _provider.createWallet(wallet, widget.userId);
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dompet berhasil ditambahkan')),
                );
              } catch (e) {
                _showErrorSnackBar('Gagal menambahkan dompet: $e');
              }
            },
          ),
    );
  }

  /// Dialog untuk edit dompet
  void _showEditWalletDialog(Wallet wallet) {
    showDialog(
      context: context,
      builder:
          (context) => _WalletFormDialog(
            initialName: wallet.name,
            initialType: wallet.type,
            onSave: (name, type) async {
              final updatedWallet = wallet.copyWith(name: name, type: type);

              try {
                await _provider.updateWallet(updatedWallet, widget.userId);
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dompet berhasil diupdate')),
                );
              } catch (e) {
                _showErrorSnackBar('Gagal mengupdate dompet: $e');
              }
            },
          ),
    );
  }

  /// Dialog untuk menampilkan detail dompet
  void _showWalletDetailDialog(Wallet wallet) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(wallet.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipe: ${wallet.type}'),
                const SizedBox(height: 8),
                Text(
                  'Saldo: Rp ${wallet.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Mata Uang: ${wallet.currency}'),
                const SizedBox(height: 8),
                Text(
                  'Dibuat: ${wallet.createdAt.toLocal().toString().split('.')[0]}',
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

  /// Fungsi untuk menghapus dompet
  void _deleteWallet(int walletId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Dompet?'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus dompet ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _provider.deleteWallet(walletId, widget.userId);
                    setState(() {});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dompet berhasil dihapus')),
                    );
                  } catch (e) {
                    _showErrorSnackBar('Gagal menghapus dompet: $e');
                  }
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}

/// Dialog form untuk tambah/edit dompet
class _WalletFormDialog extends StatefulWidget {
  final Function(String name, String type) onSave;
  final String? initialName;
  final String? initialType;

  const _WalletFormDialog({
    required this.onSave,
    this.initialName,
    this.initialType,
  });

  @override
  State<_WalletFormDialog> createState() => _WalletFormDialogState();
}

class _WalletFormDialogState extends State<_WalletFormDialog> {
  late TextEditingController _nameController;
  late String _selectedType;

  final _walletTypes = [
    {'value': 'cash', 'label': 'Tunai'},
    {'value': 'bank', 'label': 'Bank'},
    {'value': 'e-wallet', 'label': 'E-Wallet'},
    {'value': 'credit_card', 'label': 'Kartu Kredit'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _selectedType = widget.initialType ?? 'cash';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? 'Tambah Dompet' : 'Edit Dompet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nama Dompet',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.wallet),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Tipe Dompet',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.category),
            ),
            items:
                _walletTypes.map((type) {
                  return DropdownMenuItem(
                    value: type['value'],
                    child: Text(type['label']!),
                  );
                }).toList(),
            onChanged: (value) => setState(() => _selectedType = value!),
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
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nama dompet tidak boleh kosong')),
              );
              return;
            }
            widget.onSave(_nameController.text, _selectedType);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
