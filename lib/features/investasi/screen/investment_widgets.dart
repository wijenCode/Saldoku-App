import 'package:flutter/material.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/theme/widgets/theme_extensions.dart';
import '../../../app/widgets/widgets.dart';
import '../../../core/models/investment.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/date_utils.dart';
import '../data/investment_repository.dart';

// Portfolio Summary Card
class PortfolioSummaryCard extends StatelessWidget {
  final Map<String, double> statistics;

  const PortfolioSummaryCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final totalInvestment = statistics['totalInvestment'] ?? 0;
    final totalCurrentValue = statistics['totalCurrentValue'] ?? 0;
    final totalProfit = statistics['totalProfit'] ?? 0;
    final profitPercentage = statistics['profitPercentage'] ?? 0;
    final isProfit = totalProfit >= 0;

    return CustomCard(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Portfolio Saya',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Total Nilai Investasi',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormat.format(totalCurrentValue),
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modal',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormat.format(totalInvestment),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keuntungan',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            CurrencyFormat.format(totalProfit),
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  isProfit
                                      ? context.incomeColor
                                      : context.expenseColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isProfit
                                    ? context.incomeColor.withAlpha(
                                      (0.1 * 255).round(),
                                    )
                                    : context.expenseColor.withAlpha(
                                      (0.1 * 255).round(),
                                    ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${isProfit ? '+' : ''}${profitPercentage.toStringAsFixed(1)}%',
                            style: context.textTheme.bodySmall?.copyWith(
                              color:
                                  isProfit
                                      ? context.incomeColor
                                      : context.expenseColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Type Distribution Card
class TypeDistributionCard extends StatelessWidget {
  final Map<String, double> typeDistribution;

  const TypeDistributionCard({super.key, required this.typeDistribution});

  @override
  Widget build(BuildContext context) {
    if (typeDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = typeDistribution.values.fold(0.0, (a, b) => a + b);

    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribusi Investasi',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...typeDistribution.entries.map((entry) {
            final percentage = (entry.value / total * 100);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        InvestmentHelper.getTypeLabel(entry.key),
                        style: context.textTheme.bodyMedium,
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: context.borderColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      InvestmentHelper.getTypeColor(context, entry.key),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// Investment Card
class InvestmentCard extends StatelessWidget {
  final Investment investment;
  final VoidCallback onTap;

  const InvestmentCard({
    super.key,
    required this.investment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = investment.isProfit;
    final profitColor = isProfit ? context.incomeColor : context.expenseColor;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: InvestmentHelper.getTypeColor(
                    context,
                    investment.type,
                  ).withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  InvestmentHelper.getTypeIcon(investment.type),
                  color: InvestmentHelper.getTypeColor(
                    context,
                    investment.type,
                  ),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      investment.name,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      InvestmentHelper.getTypeLabel(investment.type),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              InvestmentStatusBadge(status: investment.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modal',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormat.format(investment.initialAmount),
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nilai Saat Ini',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormat.format(investment.currentAmount),
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isProfit ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: profitColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        CurrencyFormat.format(investment.profit),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: profitColor,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${isProfit ? '+' : ''}${investment.profitPercentage.toStringAsFixed(1)}%)',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: profitColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                AppDateUtils.format(
                  investment.purchaseDate,
                  pattern: 'dd MMM yy',
                ),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Status Badge
class InvestmentStatusBadge extends StatelessWidget {
  final String status;

  const InvestmentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'active':
        color = context.incomeColor;
        label = 'Aktif';
        break;
      case 'sold':
        color = AppColors.warning;
        label = 'Terjual';
        break;
      case 'matured':
        color = AppColors.info;
        label = 'Jatuh Tempo';
        break;
      default:
        color = context.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Helper Class
class InvestmentHelper {
  static String getTypeLabel(String type) {
    switch (type) {
      case 'stocks':
        return 'Saham';
      case 'mutual_funds':
        return 'Reksa Dana';
      case 'crypto':
        return 'Cryptocurrency';
      case 'gold':
        return 'Emas';
      case 'bonds':
        return 'Obligasi';
      case 'property':
        return 'Properti';
      default:
        return type;
    }
  }

  static IconData getTypeIcon(String type) {
    switch (type) {
      case 'stocks':
        return Icons.show_chart;
      case 'mutual_funds':
        return Icons.pie_chart;
      case 'crypto':
        return Icons.currency_bitcoin;
      case 'gold':
        return Icons.diamond;
      case 'bonds':
        return Icons.receipt_long;
      case 'property':
        return Icons.home;
      default:
        return Icons.trending_up;
    }
  }

  static Color getTypeColor(BuildContext context, String type) {
    switch (type) {
      case 'stocks':
        return AppColors.primary;
      case 'mutual_funds':
        return AppColors.info;
      case 'crypto':
        return AppColors.warning;
      case 'gold':
        return const Color(0xFFFFD700);
      case 'bonds':
        return context.incomeColor;
      case 'property':
        return const Color(0xFF8B4513);
      default:
        return context.textSecondary;
    }
  }
}

// Investment Form Sheet
class InvestmentFormSheet extends StatefulWidget {
  final Investment? investment;
  final VoidCallback onSaved;

  const InvestmentFormSheet({
    super.key,
    this.investment,
    required this.onSaved,
  });

  @override
  State<InvestmentFormSheet> createState() => _InvestmentFormSheetState();
}

class _InvestmentFormSheetState extends State<InvestmentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _repository = InvestmentRepository();

  late TextEditingController _nameController;
  late TextEditingController _initialAmountController;
  late TextEditingController _currentAmountController;
  late TextEditingController _notesController;

  String _selectedType = 'stocks';
  DateTime _purchaseDate = DateTime.now();
  DateTime? _maturityDate;
  bool _isLoading = false;

  final List<Map<String, String>> _investmentTypes = [
    {'value': 'stocks', 'label': 'Saham'},
    {'value': 'mutual_funds', 'label': 'Reksa Dana'},
    {'value': 'crypto', 'label': 'Cryptocurrency'},
    {'value': 'gold', 'label': 'Emas'},
    {'value': 'bonds', 'label': 'Obligasi'},
    {'value': 'property', 'label': 'Properti'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.investment?.name);
    _initialAmountController = TextEditingController(
      text: widget.investment?.initialAmount.toString(),
    );
    _currentAmountController = TextEditingController(
      text: widget.investment?.currentAmount.toString(),
    );
    _notesController = TextEditingController(text: widget.investment?.notes);

    if (widget.investment != null) {
      _selectedType = widget.investment!.type;
      _purchaseDate = widget.investment!.purchaseDate;
      _maturityDate = widget.investment!.maturityDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialAmountController.dispose();
    _currentAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
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
                      widget.investment == null
                          ? 'Tambah Investasi'
                          : 'Edit Investasi',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _nameController,
                  label: 'Nama Investasi',
                  hint: 'Contoh: Saham BBCA',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama investasi harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Investasi',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      _investmentTypes.map((type) {
                        return DropdownMenuItem(
                          value: type['value'],
                          child: Text(type['label']!),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _initialAmountController,
                  label: 'Modal Awal',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  prefixText: 'Rp ',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Modal awal harus diisi';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Masukkan jumlah yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _currentAmountController,
                  label: 'Nilai Saat Ini',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  prefixText: 'Rp ',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nilai saat ini harus diisi';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Masukkan jumlah yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectPurchaseDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Pembelian',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      AppDateUtils.format(
                        _purchaseDate,
                        pattern: 'dd MMMM yyyy',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectMaturityDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Jatuh Tempo (Opsional)',
                      border: const OutlineInputBorder(),
                      suffixIcon:
                          _maturityDate != null
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed:
                                    () => setState(() => _maturityDate = null),
                              )
                              : const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _maturityDate != null
                          ? AppDateUtils.format(
                            _maturityDate!,
                            pattern: 'dd MMMM yyyy',
                          )
                          : 'Pilih tanggal',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _notesController,
                  label: 'Catatan (Opsional)',
                  hint: 'Tambahkan catatan...',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    isLoading: _isLoading,
                    child: Text(
                      widget.investment == null
                          ? 'Tambah Investasi'
                          : 'Simpan Perubahan',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectPurchaseDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _purchaseDate = date);
    }
  }

  Future<void> _selectMaturityDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _maturityDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _maturityDate = date);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not found');

      if (widget.investment == null) {
        final investment = Investment(
          userId: user.id!,
          name: _nameController.text,
          type: _selectedType,
          initialAmount: double.parse(_initialAmountController.text),
          currentAmount: double.parse(_currentAmountController.text),
          purchaseDate: _purchaseDate,
          maturityDate: _maturityDate,
          status: 'active',
          notes:
              _notesController.text.isNotEmpty ? _notesController.text : null,
        );
        await _repository.createInvestment(investment);
      } else {
        final updated = widget.investment!.copyWith(
          name: _nameController.text,
          type: _selectedType,
          initialAmount: double.parse(_initialAmountController.text),
          currentAmount: double.parse(_currentAmountController.text),
          purchaseDate: _purchaseDate,
          maturityDate: _maturityDate,
          notes:
              _notesController.text.isNotEmpty ? _notesController.text : null,
        );
        await _repository.updateInvestment(updated);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.investment == null
                  ? 'Investasi berhasil ditambahkan'
                  : 'Investasi berhasil diperbarui',
            ),
            backgroundColor: context.incomeColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Investment Detail Sheet
class InvestmentDetailSheet extends StatelessWidget {
  final Investment investment;
  final VoidCallback onUpdate;
  final VoidCallback onEdit;

  const InvestmentDetailSheet({
    super.key,
    required this.investment,
    required this.onUpdate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = investment.isProfit;
    final profitColor = isProfit ? context.incomeColor : context.expenseColor;
    final repository = InvestmentRepository();

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      investment.name,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InvestmentStatusBadge(status: investment.status),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                'Nilai Saat Ini',
                CurrencyFormat.format(investment.currentAmount),
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                'Keuntungan',
                '${CurrencyFormat.format(investment.profit)} (${isProfit ? '+' : ''}${investment.profitPercentage.toStringAsFixed(2)}%)',
                valueColor: profitColor,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: profitColor,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                'Modal Awal',
                CurrencyFormat.format(investment.initialAmount),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                'Jenis Investasi',
                InvestmentHelper.getTypeLabel(investment.type),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                'Tanggal Pembelian',
                AppDateUtils.format(
                  investment.purchaseDate,
                  pattern: 'dd MMMM yyyy',
                ),
              ),
              if (investment.maturityDate != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  'Jatuh Tempo',
                  AppDateUtils.format(
                    investment.maturityDate!,
                    pattern: 'dd MMMM yyyy',
                  ),
                ),
              ],
              if (investment.notes != null && investment.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Catatan',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(investment.notes!, style: context.textTheme.bodyMedium),
              ],
              const SizedBox(height: 24),
              if (investment.status == 'active') ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlineButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showUpdateValueDialog(context, repository);
                        },
                        child: const Text('Update Nilai'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlineButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showCloseDialog(context, repository);
                        },
                        child: const Text('Tutup/Jual'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onEdit();
                      },
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DangerButton(
                      onPressed: () => _showDeleteDialog(context, repository),
                      child: const Text('Hapus'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    TextStyle? style,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style:
                style ??
                context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _showUpdateValueDialog(
    BuildContext context,
    InvestmentRepository repository,
  ) {
    final controller = TextEditingController(
      text: investment.currentAmount.toString(),
    );

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Update Nilai Investasi'),
            content: CustomTextField(
              controller: controller,
              label: 'Nilai Saat Ini',
              keyboardType: TextInputType.number,
              prefixText: 'Rp ',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () async {
                  final value = double.tryParse(controller.text);
                  if (value != null) {
                    await repository.updateCurrentAmount(investment.id!, value);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      onUpdate();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Nilai investasi berhasil diperbarui',
                          ),
                          backgroundColor: context.incomeColor,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _showCloseDialog(BuildContext context, InvestmentRepository repository) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Tutup Investasi'),
            content: const Text(
              'Apakah investasi ini sudah terjual atau jatuh tempo?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  await repository.updateStatus(investment.id!, 'sold');
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    onUpdate();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Investasi ditandai sebagai terjual',
                        ),
                        backgroundColor: context.incomeColor,
                      ),
                    );
                  }
                },
                child: const Text('Terjual'),
              ),
              FilledButton(
                onPressed: () async {
                  await repository.updateStatus(investment.id!, 'matured');
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    onUpdate();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Investasi ditandai sebagai jatuh tempo',
                        ),
                        backgroundColor: context.incomeColor,
                      ),
                    );
                  }
                },
                child: const Text('Jatuh Tempo'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    InvestmentRepository repository,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Hapus Investasi'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus investasi ini? '
              'Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () async {
                  await repository.deleteInvestment(investment.id!);
                  if (ctx.mounted) {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Close detail sheet
                    onUpdate();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Investasi berhasil dihapus'),
                        backgroundColor: context.incomeColor,
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.expense,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }
}
