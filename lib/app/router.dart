import 'package:flutter/material.dart';

// Auth screens
import '../features/auth/screen/login_screen.dart';
import '../features/auth/screen/register_screen.dart';
import '../features/auth/screen/onboarding_screen.dart';

// Home screen
import '../features/home/screen/home_screen.dart';

// Profile screens
import '../features/profile/screen/profile_screen.dart';
import '../features/profile/screen/edit_profile_screen.dart';
import '../features/profile/screen/change_password_screen.dart';
import '../features/profile/screen/settings_screen.dart';

// Fitur baru (3 features yang baru dibuat)
import '../features/manajemen_dompet/screen/wallet_screen.dart';
import '../features/anggaran/screen/budgets_screen.dart';
import '../features/hutang_piutang/screen/debts_screen.dart';
import '../features/manajemen_kategori/screen/category_screen.dart';
import '../features/transaksi_harian/screen/transactions_screen.dart';
import '../features/transfer_dompet/screen/transfer_screen.dart';
import '../features/investasi/screen/investment_screen.dart';

/// App Router untuk mengelola navigasi
class AppRouter {
  /// Route names constants
  static const String initial = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';

  // Main screens
  static const String home = '/home';
  static const String wallets = '/wallets';
  static const String reports = '/reports';
  static const String profile = '/profile';

  // Wallet routes
  static const String walletForm = '/wallet/form';
  static const String walletDetail = '/wallet/detail';

  // Transaction routes
  static const String transactions = '/transactions';
  static const String transactionForm = '/transaction/form';
  static const String transactionDetail = '/transaction/detail';

  // Category routes
  static const String categories = '/categories';
  static const String categoryForm = '/category/form';

  // Budget routes
  static const String budgets = '/budgets';
  static const String budgetForm = '/budget/form';
  static const String budgetDetail = '/budget/detail';

  // Bill routes
  static const String bills = '/bills';
  static const String billForm = '/bill/form';
  static const String billDetail = '/bill/detail';

  // Savings goal routes
  static const String savingsGoals = '/savings-goals';
  static const String savingsGoalForm = '/savings-goal/form';
  static const String savingsGoalDetail = '/savings-goal/detail';

  // Investment routes
  static const String investments = '/investments';
  static const String investmentForm = '/investment/form';
  static const String investmentDetail = '/investment/detail';

  // Debt routes
  static const String debts = '/debts';
  static const String debtForm = '/debt/form';
  static const String debtDetail = '/debt/detail';
  static const String debtPaymentForm = '/debt/payment';

  // Wallet transfer routes
  static const String walletTransferForm = '/wallet-transfer/form';
  static const String walletTransfers = '/wallet-transfers';

  // Report routes
  static const String incomeExpenseReport = '/reports/income-expense';
  static const String cashFlowReport = '/reports/cash-flow';
  static const String categoryReport = '/reports/category';

  // Profile routes
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String settings = '/settings';

  /// Generate route
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ===== ROUTE YANG SUDAH DIBUAT =====

      // Auth routes
      case AppRouter.initial:
      case AppRouter.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );

      case AppRouter.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRouter.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      // Main screens
      case AppRouter.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      // Profile routes
      case AppRouter.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      case AppRouter.editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
          settings: settings,
        );

      case AppRouter.changePassword:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordScreen(),
          settings: settings,
        );

      case AppRouter.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      // ===== 3 FITUR BARU YANG SUDAH DIBUAT =====
      case AppRouter.wallets:
        return MaterialPageRoute(
          builder: (_) => const WalletScreen(userId: 1),
          settings: settings,
        );

      case AppRouter.budgets:
        return MaterialPageRoute(
          builder: (_) => const BudgetsScreen(userId: 1),
          settings: settings,
        );

      case AppRouter.debts:
        return MaterialPageRoute(
          builder: (_) => const DebtsScreen(userId: 1),
          settings: settings,
        );

      // Category routes
      case AppRouter.categories:
        return MaterialPageRoute(
          builder: (_) => const CategoryScreen(),
          settings: settings,
        );

      // Transaction routes
      case AppRouter.transactions:
        return MaterialPageRoute(
          builder: (_) => const TransactionsScreen(),
          settings: settings,
        );

      // Transfer routes
      case AppRouter.walletTransferForm:
      case AppRouter.walletTransfers:
        return MaterialPageRoute(
          builder: (_) => const TransferScreen(),
          settings: settings,
        );

      // Investment routes
      case AppRouter.investments:
      case AppRouter.investmentForm:
      case AppRouter.investmentDetail:
        return MaterialPageRoute(
          builder: (_) => const InvestmentScreen(),
          settings: settings,
        );

      // ===== ROUTE YANG BELUM DIBUAT - COMING SOON =====
      case AppRouter.walletForm:
      case AppRouter.walletDetail:
      case AppRouter.transactionForm:
      case AppRouter.transactionDetail:
      case AppRouter.categoryForm:
      case AppRouter.budgetForm:
      case AppRouter.budgetDetail:
      case AppRouter.bills:
      case AppRouter.billForm:
      case AppRouter.billDetail:
      case AppRouter.savingsGoals:
      case AppRouter.savingsGoalForm:
      case AppRouter.savingsGoalDetail:
      case AppRouter.debtForm:
      case AppRouter.debtDetail:
      case AppRouter.debtPaymentForm:
      case AppRouter.reports:
      case AppRouter.incomeExpenseReport:
      case AppRouter.cashFlowReport:
      case AppRouter.categoryReport:
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Coming Soon'),
                  centerTitle: true,
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.construction_rounded,
                        size: 80,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Fitur Dalam Pengembangan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Route: ${settings.name}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Kembali'),
                      ),
                    ],
                  ),
                ),
              ),
          settings: settings,
        );

      // Default route (404)
      default:
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                appBar: AppBar(title: const Text('Error'), centerTitle: true),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 80,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Halaman Tidak Ditemukan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Route: ${settings.name}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed:
                            () => Navigator.of(
                              context,
                            ).pushReplacementNamed(home),
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('Kembali ke Beranda'),
                      ),
                    ],
                  ),
                ),
              ),
        );
    }
  }

  /// Navigate to route with arguments
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Navigate and replace current route
  static Future<T?> navigateReplaceTo<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(
      context,
    ).pushReplacementNamed<T, T>(routeName, arguments: arguments);
  }

  /// Navigate and clear all previous routes
  static Future<T?> navigateClearTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current route
  static void pop(BuildContext context, [Object? result]) {
    Navigator.of(context).pop(result);
  }

  /// Pop until specific route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }

  /// Check if can pop
  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }
}

/// Extension untuk memudahkan navigasi dari BuildContext
extension NavigationExtension on BuildContext {
  /// Navigate to route
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return AppRouter.navigateTo<T>(this, routeName, arguments: arguments);
  }

  /// Navigate and replace
  Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) {
    return AppRouter.navigateReplaceTo<T>(
      this,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and clear stack
  Future<T?> pushNamedAndRemoveUntil<T>(String routeName, {Object? arguments}) {
    return AppRouter.navigateClearTo<T>(this, routeName, arguments: arguments);
  }

  /// Pop current route
  void pop<T>([T? result]) {
    AppRouter.pop(this, result);
  }

  /// Pop until route
  void popUntil(String routeName) {
    AppRouter.popUntil(this, routeName);
  }

  /// Check if can pop
  bool get canPop => AppRouter.canPop(this);
}
