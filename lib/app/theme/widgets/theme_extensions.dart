import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

/// Extension untuk BuildContext agar mudah akses theme
extension ThemeExtension on BuildContext {
  /// Mendapatkan ThemeData saat ini
  ThemeData get theme => Theme.of(this);

  /// Mendapatkan TextTheme saat ini
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Mendapatkan ColorScheme saat ini
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Cek apakah sedang dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ===================================================================
  // QUICK ACCESS - COLORS
  // ===================================================================

  /// Primary color
  Color get primaryColor => colorScheme.primary;

  /// Background color berdasarkan tema
  Color get backgroundColor => isDarkMode 
      ? AppColors.backgroundDark 
      : AppColors.backgroundLight;

  /// Surface color berdasarkan tema
  Color get surfaceColor => isDarkMode 
      ? AppColors.surfaceDark 
      : AppColors.surfaceLight;

  /// Card color berdasarkan tema
  Color get cardColor => isDarkMode 
      ? AppColors.cardDark 
      : AppColors.cardLight;

  /// Text color berdasarkan tema
  Color get textColor => isDarkMode 
      ? AppColors.onBackgroundDark 
      : AppColors.onBackgroundLight;

  /// Success color (untuk income)
  Color get successColor => AppColors.success;

  /// Expense color (untuk pengeluaran)
  Color get expenseColor => AppColors.expense;

  /// Warning color
  Color get warningColor => AppColors.warning;

  /// Info color
  Color get infoColor => AppColors.info;

  /// Text secondary color (muted text)
  Color get textSecondary => isDarkMode 
      ? Colors.grey.shade400 
      : Colors.grey.shade600;

  /// Border color
  Color get borderColor => isDarkMode 
      ? Colors.grey.shade700 
      : Colors.grey.shade300;

  /// Income color (alias for success)
  Color get incomeColor => AppColors.success;

  // ===================================================================
  // QUICK ACCESS - TEXT STYLES
  // ===================================================================

  /// Display text style
  TextStyle get displayStyle => isDarkMode 
      ? AppTextStyles.darkDisplay 
      : AppTextStyles.lightDisplay;

  /// Headline text style
  TextStyle get headlineStyle => isDarkMode 
      ? AppTextStyles.darkHeadline 
      : AppTextStyles.lightHeadline;

  /// Title text style
  TextStyle get titleStyle => isDarkMode 
      ? AppTextStyles.darkTitle 
      : AppTextStyles.lightTitle;

  /// Body text style
  TextStyle get bodyStyle => isDarkMode 
      ? AppTextStyles.darkBody 
      : AppTextStyles.lightBody;

  /// Body bold text style
  TextStyle get bodyBoldStyle => isDarkMode 
      ? AppTextStyles.darkBodyBold 
      : AppTextStyles.lightBodyBold;

  /// Label text style
  TextStyle get labelStyle => isDarkMode 
      ? AppTextStyles.darkLabel 
      : AppTextStyles.lightLabel;

  /// Label small text style
  TextStyle get labelSmallStyle => isDarkMode 
      ? AppTextStyles.darkLabelSmall 
      : AppTextStyles.lightLabelSmall;

  /// Title small text style
  TextStyle get titleSmallStyle => isDarkMode 
      ? AppTextStyles.darkTitle 
      : AppTextStyles.lightTitle;

  /// Headline large text style
  TextStyle get headlineLargeStyle => isDarkMode 
      ? AppTextStyles.darkDisplay 
      : AppTextStyles.lightDisplay;

  // ===================================================================
  // COLORED TEXT STYLES (tidak terpengaruh theme)
  // ===================================================================

  /// Primary colored text
  TextStyle get primaryText => AppTextStyles.primaryText;

  /// Primary colored label
  TextStyle get primaryLabel => AppTextStyles.primaryLabel;

  /// Success text (untuk income)
  TextStyle get successText => AppTextStyles.successText;

  /// Danger/Expense text
  TextStyle get dangerText => AppTextStyles.dangerText;

  /// Info text
  TextStyle get infoText => AppTextStyles.infoText;

  // ===================================================================
  // RESPONSIVE HELPERS
  // ===================================================================

  /// Lebar layar
  double get width => MediaQuery.of(this).size.width;

  /// Tinggi layar
  double get height => MediaQuery.of(this).size.height;

  /// Padding atas (untuk notch/status bar)
  double get topPadding => MediaQuery.of(this).padding.top;

  /// Padding bawah (untuk navigation bar)
  double get bottomPadding => MediaQuery.of(this).padding.bottom;

  /// Cek apakah layar kecil (mobile)
  bool get isMobile => width < 600;

  /// Cek apakah layar tablet
  bool get isTablet => width >= 600 && width < 1200;

  /// Cek apakah layar desktop
  bool get isDesktop => width >= 1200;

  // ===================================================================
  // NAVIGATION HELPERS
  // ===================================================================

  /// Push ke halaman baru
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Push replacement
  Future<T?> pushReplacement<T extends Object?>(Widget page, {Object? result}) {
    return Navigator.of(this).pushReplacement<T?, Object?>(
      MaterialPageRoute(builder: (_) => page),
      result: result,
    );
  }

  /// Pop halaman
  void pop<T>([T? result]) {
    return Navigator.of(this).pop(result);
  }

  /// Push dan hapus semua halaman sebelumnya
  Future<T?> pushAndRemoveUntil<T>(Widget page) {
    return Navigator.of(this).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  // ===================================================================
  // SNACKBAR HELPERS
  // ===================================================================

  /// Tampilkan snackbar sukses
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Tampilkan snackbar error
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.expense,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Tampilkan snackbar info
  void showInfoSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Tampilkan snackbar warning
  void showWarningSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
