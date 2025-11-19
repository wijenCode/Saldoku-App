import 'package:flutter/material.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/widgets/widgets.dart';
import '../../../core/models/investment.dart';
import '../../../core/services/auth_service.dart';
import '../data/investment_repository.dart';
import 'investment_widgets.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  final _authService = AuthService();
  final _repository = InvestmentRepository();

  List<Investment> _investments = [];
  Map<String, double> _statistics = {};
  Map<String, double> _typeDistribution = {};
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.currentUser;
      if (user == null) throw Exception('User not found');

      final investments = await _repository.getInvestments(user.id!);
      final statistics = await _repository.getPortfolioStatistics(user.id!);
      final typeDistribution = await _repository.getTypeDistribution(user.id!);

      setState(() {
        _investments = investments;
        _statistics = statistics;
        _typeDistribution = typeDistribution;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  List<Investment> get _filteredInvestments {
    if (_filterStatus == 'all') {
      return _investments;
    }
    return _investments.where((inv) => inv.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Investasi',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showInvestmentForm(context),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingState()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: PortfolioSummaryCard(statistics: _statistics),
                  ),
                  SliverToBoxAdapter(
                    child: TypeDistributionCard(typeDistribution: _typeDistribution),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'all', label: Text('Semua')),
                          ButtonSegment(value: 'active', label: Text('Aktif')),
                          ButtonSegment(value: 'sold', label: Text('Terjual')),
                          ButtonSegment(value: 'matured', label: Text('Jatuh Tempo')),
                        ],
                        selected: {_filterStatus},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() => _filterStatus = newSelection.first);
                        },
                      ),
                    ),
                  ),
                  _filteredInvestments.isEmpty
                      ? SliverFillRemaining(
                          child: EmptyState(
                            icon: Icons.trending_up,
                            title: 'Belum Ada Investasi',
                            message: 'Mulai catat investasi Anda',
                            action: PrimaryButton(
                              onPressed: () => _showInvestmentForm(context),
                              child: const Text('Tambah Investasi'),
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final investment = _filteredInvestments[index];
                                return InvestmentCard(
                                  investment: investment,
                                  onTap: () => _showInvestmentDetail(context, investment),
                                );
                              },
                              childCount: _filteredInvestments.length,
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  void _showInvestmentForm(BuildContext context, [Investment? investment]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InvestmentFormSheet(
        investment: investment,
        onSaved: _loadData,
      ),
    );
  }

  void _showInvestmentDetail(BuildContext context, Investment investment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InvestmentDetailSheet(
        investment: investment,
        onUpdate: _loadData,
        onEdit: () => _showInvestmentForm(context, investment),
      ),
    );
  }
}
