import 'package:intl/intl.dart';
import '../services/shared_prefs_service.dart';

/// Utility untuk format mata uang
class CurrencyFormat {
  /// Format number ke format mata uang
  static String format(
    double amount, {
    String? currency,
    bool showSymbol = true,
    int decimalDigits = 0,
  }) {
    // Default currency dari shared preferences
    currency ??= 'IDR';

    final formatter = NumberFormat.currency(
      locale: _getLocale(currency),
      symbol: showSymbol ? _getSymbol(currency) : '',
      decimalDigits: decimalDigits,
    );

    return formatter.format(amount);
  }

  /// Format dengan async (get currency dari SharedPreferences)
  static Future<String> formatAsync(
    double amount, {
    bool showSymbol = true,
    int decimalDigits = 0,
  }) async {
    final currency = await SharedPrefsService.getCurrency();
    return format(
      amount,
      currency: currency,
      showSymbol: showSymbol,
      decimalDigits: decimalDigits,
    );
  }

  /// Format compact (1000 -> 1K, 1000000 -> 1M)
  static String formatCompact(
    double amount, {
    String? currency,
    bool showSymbol = true,
  }) {
    currency ??= 'IDR';
    final symbol = showSymbol ? _getSymbol(currency) : '';

    if (amount >= 1000000000) {
      return '$symbol${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return format(amount, currency: currency, showSymbol: showSymbol);
    }
  }

  /// Format dengan tanda + atau - untuk income/expense
  static String formatWithSign(
    double amount,
    String type, {
    String? currency,
    bool showSymbol = true,
    int decimalDigits = 0,
  }) {
    final formatted = format(
      amount.abs(),
      currency: currency,
      showSymbol: showSymbol,
      decimalDigits: decimalDigits,
    );

    if (type.toLowerCase() == 'income') {
      return '+ $formatted';
    } else if (type.toLowerCase() == 'expense') {
      return '- $formatted';
    } else {
      return formatted;
    }
  }

  /// Parse string currency ke double
  static double parse(String text) {
    // Remove currency symbols and non-numeric characters except . and ,
    final cleaned = text
        .replaceAll(RegExp(r'[^0-9.,]'), '')
        .replaceAll(',', '.');

    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Get locale berdasarkan currency
  static String _getLocale(String currency) {
    switch (currency.toUpperCase()) {
      case 'IDR':
        return 'id_ID';
      case 'USD':
        return 'en_US';
      case 'EUR':
        return 'de_DE';
      case 'GBP':
        return 'en_GB';
      case 'JPY':
        return 'ja_JP';
      case 'SGD':
        return 'en_SG';
      case 'MYR':
        return 'ms_MY';
      default:
        return 'id_ID';
    }
  }

  /// Get currency symbol
  static String _getSymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'IDR':
        return 'Rp';
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'SGD':
        return r'S$';
      case 'MYR':
        return 'RM';
      default:
        return 'Rp';
    }
  }

  /// Get list of supported currencies
  static List<Map<String, String>> getSupportedCurrencies() {
    return [
      {'code': 'IDR', 'name': 'Rupiah Indonesia', 'symbol': 'Rp'},
      {'code': 'USD', 'name': 'US Dollar', 'symbol': r'$'},
      {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
      {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
      {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
      {'code': 'SGD', 'name': 'Singapore Dollar', 'symbol': r'S$'},
      {'code': 'MYR', 'name': 'Malaysian Ringgit', 'symbol': 'RM'},
    ];
  }

  /// Format percentage
  static String formatPercentage(double value, {int decimalDigits = 1}) {
    return '${value.toStringAsFixed(decimalDigits)}%';
  }

  /// Format decimal number
  static String formatDecimal(double value, {int decimalDigits = 2}) {
    final formatter = NumberFormat.decimalPattern('id_ID');
    return formatter.format(value);
  }
}
