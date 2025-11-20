import 'package:flutter/material.dart';
import '../providers/reports_provider.dart';

class LaporanKeuanganScreen extends StatefulWidget {
  final int userId;

  const LaporanKeuanganScreen({super.key, required this.userId});

  @override
  State<LaporanKeuanganScreen> createState() => _LaporanKeuanganScreenState();
}

class _LaporanKeuanganScreenState extends State<LaporanKeuanganScreen> {
  late LaporanProvider _provider;
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _provider = LaporanProvider();
    _load();
  }

  Future<void> _load() async {
    await _provider.loadReport(widget.userId, _range.start, _range.end);
    if (mounted) setState(() {});
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _range,
    );
    if (picked != null) {
      _range = picked;
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _provider;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _pickRange, icon: const Icon(Icons.date_range)),
        ],
      ),
      body:
          p.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kpiRow(p),
                    const SizedBox(height: 16),
                    const Text(
                      'Saldo Dompet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _walletsList(p),
                    const SizedBox(height: 16),
                    const Text(
                      'Pengeluaran per Kategori',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _categoriesList(p),
                  ],
                ),
              ),
    );
  }

  Widget _kpiRow(LaporanProvider p) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _kpiCard('Pendapatan', p.totalIncome),
        _kpiCard('Pengeluaran', p.totalExpense),
        _kpiCard('Nett', p.balance),
      ],
    );
  }

  Widget _kpiCard(String title, double value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp ${value.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _walletsList(LaporanProvider p) {
    if (p.wallets.isEmpty) return const Text('Tidak ada dompet');
    return Column(
      children:
          p.wallets
              .map(
                (w) => ListTile(
                  title: Text(w['name'] ?? 'Unknown'),
                  trailing: Text(
                    'Rp ${((w['balance'] as num?) ?? 0).toStringAsFixed(0)}',
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _categoriesList(LaporanProvider p) {
    if (p.topCategories.isEmpty) {
      return const Text('Tidak ada pengeluaran pada periode ini');
    }
    return Column(
      children:
          p.topCategories
              .map(
                (c) => ListTile(
                  title: Text(c['name'] ?? 'Unknown'),
                  trailing: Text(
                    'Rp ${((c['total'] as num?) ?? 0).toStringAsFixed(0)}',
                  ),
                ),
              )
              .toList(),
    );
  }
}
