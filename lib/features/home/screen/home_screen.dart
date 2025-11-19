import 'package:flutter/material.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/theme/widgets/theme_extensions.dart';
import '../../../app/widgets/widgets.dart';
import '../../../app/router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/date_utils.dart';
import '../../profile/screen/profile_screen.dart';
import '../data/home_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  final _notificationService = NotificationService();
  final _homeRepository = HomeRepository();
  
  // Data dari repository
  double _totalBalance = 0.0;
  double _monthlyIncome = 0.0;
  double _monthlyExpense = 0.0;
  int _notificationCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        final dashboardData = await _homeRepository.refreshDashboard(user.id!);
        final notifCount = await _notificationService.getNotificationCount(user.id!);
        
        setState(() {
          _totalBalance = dashboardData['balance'] as double;
          _monthlyIncome = dashboardData['monthlyIncome'] as double;
          _monthlyExpense = dashboardData['monthlyExpense'] as double;
          _notificationCount = notifCount;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onAddPressed() {
    AddTransactionBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildWalletsTab(),
          _buildReportsTab(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        onAddPressed: _onAddPressed,
      ),
    );
  }

  // Home Tab - Dashboard
  Widget _buildHomeTab() {
    final user = _authService.currentUser;
    
    // Show loading indicator
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: context.titleStyle.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Greeting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat ${_getGreeting()}',
                            style: context.labelStyle.copyWith(
                              color: context.textColor.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            user?.name ?? 'User',
                            style: context.titleStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Notification icon
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {
                            // TODO: Navigate to notifications
                          },
                        ),
                        if (_notificationCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.expense,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                _notificationCount > 9 ? '9+' : '$_notificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Total Balance Card
                  _buildBalanceCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Income & Expense Summary
                  _buildIncomeExpenseSummary(),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Akses Cepat',
                        style: context.titleStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildQuickActions(),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaksi Terakhir',
                        style: context.titleStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.pushNamed(AppRouter.transactions);
                        },
                        child: Text(
                          'Lihat Semua',
                          style: context.labelStyle.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildRecentTransactions(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return CustomCard(
      padding: const EdgeInsets.all(20),
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Saldo',
                style: context.labelStyle.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            CurrencyFormat.format(_totalBalance, currency: 'IDR'),
            style: context.headlineStyle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 32,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            'Update ${AppDateUtils.formatRelative(DateTime.now())}',
            style: context.labelSmallStyle.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseSummary() {
    return Row(
      children: [
        // Income
        Expanded(
          child: CustomCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: AppColors.success,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Pemasukan',
                        style: context.labelStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  CurrencyFormat.format(_monthlyIncome, currency: 'IDR'),
                  style: context.titleStyle.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 4),
        
        // Expense
        Expanded(
          child: CustomCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.expense.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: AppColors.expense,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Pengeluaran',
                        style: context.labelStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  CurrencyFormat.format(_monthlyExpense, currency: 'IDR'),
                  style: context.titleStyle.copyWith(
                    color: AppColors.expense,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildQuickActionItem(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Dompet',
          color: AppColors.primary,
          onTap: () => context.pushNamed(AppRouter.wallets),
        ),
        _buildQuickActionItem(
          icon: Icons.receipt_long_rounded,
          label: 'Tagihan',
          color: AppColors.warning,
          onTap: () => context.pushNamed(AppRouter.bills),
        ),
        _buildQuickActionItem(
          icon: Icons.savings_rounded,
          label: 'Tabungan',
          color: AppColors.success,
          onTap: () => context.pushNamed(AppRouter.savingsGoals),
        ),
        _buildQuickActionItem(
          icon: Icons.trending_up_rounded,
          label: 'Investasi',
          color: AppColors.info,
          onTap: () => context.pushNamed(AppRouter.investments),
        ),
        _buildQuickActionItem(
          icon: Icons.pie_chart_rounded,
          label: 'Anggaran',
          color: AppColors.primaryLight,
          onTap: () => context.pushNamed(AppRouter.budgets),
        ),
        _buildQuickActionItem(
          icon: Icons.account_balance_rounded,
          label: 'Hutang',
          color: AppColors.expense,
          onTap: () => context.pushNamed(AppRouter.debts),
        ),
        _buildQuickActionItem(
          icon: Icons.category_rounded,
          label: 'Kategori',
          color: AppColors.primaryDark,
          onTap: () => context.pushNamed(AppRouter.categories),
        ),
        _buildQuickActionItem(
          icon: Icons.swap_horiz_rounded,
          label: 'Transfer',
          color: AppColors.info,
          onTap: () => context.pushNamed(AppRouter.walletTransferForm),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: context.labelSmallStyle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    // Sample data
    final transactions = [
      {
        'category': 'Gaji',
        'amount': 8500000.0,
        'type': 'income',
        'date': DateTime.now().subtract(const Duration(hours: 2)),
        'icon': Icons.work_rounded,
      },
      {
        'category': 'Makan',
        'amount': 45000.0,
        'type': 'expense',
        'date': DateTime.now().subtract(const Duration(hours: 5)),
        'icon': Icons.restaurant_rounded,
      },
      {
        'category': 'Transport',
        'amount': 30000.0,
        'type': 'expense',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'icon': Icons.directions_car_rounded,
      },
    ];

    if (transactions.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Tidak Ada Transaksi',
        message: 'Belum ada transaksi',
      );
    }

    return Column(
      children: transactions.map((tx) {
        final isIncome = tx['type'] == 'income';
        final color = isIncome ? AppColors.success : AppColors.expense;
        
        return CustomCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  tx['icon'] as IconData,
                  color: color,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['category'] as String,
                      style: context.bodyBoldStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppDateUtils.formatRelativeWithTime(tx['date'] as DateTime),
                      style: context.labelSmallStyle.copyWith(
                        color: context.textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              Text(
                CurrencyFormat.formatWithSign(
                  tx['amount'] as double,
                  tx['type'] as String,
                  currency: 'IDR',
                ),
                style: context.titleSmallStyle.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Wallets Tab
  Widget _buildWalletsTab() {
    return const Center(
      child: Text('Dompet Screen - Coming Soon'),
    );
  }

  // Reports Tab
  Widget _buildReportsTab() {
    return const Center(
      child: Text('Laporan Screen - Coming Soon'),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Pagi';
    if (hour < 15) return 'Siang';
    if (hour < 18) return 'Sore';
    return 'Malam';
  }
}
