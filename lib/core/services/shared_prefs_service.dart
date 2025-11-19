import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola SharedPreferences
class SharedPrefsService {
  static const String _keyUserId = 'user_id';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyCurrency = 'currency';
  static const String _keyLanguage = 'language';
  static const String _keyNotificationEnabled = 'notification_enabled';
  static const String _keyBiometricEnabled = 'biometric_enabled';

  /// Save user ID
  static Future<bool> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(_keyUserId, userId);
  }

  /// Get user ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Clear user ID (logout)
  static Future<bool> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_keyUserId);
  }

  /// Save theme mode (light/dark/system)
  static Future<bool> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyThemeMode, mode);
  }

  /// Get theme mode
  static Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode);
  }

  /// Mark onboarding as complete
  static Future<bool> setOnboardingComplete(bool complete) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyOnboardingComplete, complete);
  }

  /// Check if onboarding is complete
  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  /// Save currency preference
  static Future<bool> saveCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyCurrency, currency);
  }

  /// Get currency preference (default: IDR)
  static Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrency) ?? 'IDR';
  }

  /// Save language preference
  static Future<bool> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyLanguage, language);
  }

  /// Get language preference (default: id)
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'id';
  }

  /// Enable/disable notifications
  static Future<bool> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyNotificationEnabled, enabled);
  }

  /// Check if notifications are enabled
  static Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationEnabled) ?? true;
  }

  /// Enable/disable biometric authentication
  static Future<bool> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_keyBiometricEnabled, enabled);
  }

  /// Check if biometric is enabled
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  /// Clear all preferences (reset app)
  static Future<bool> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }
}
