import 'package:flutter/material.dart';
import '../../../app/constants/app_colors.dart';
import '../../../app/theme/widgets/theme_extensions.dart';
import '../../../app/widgets/widgets.dart';
import '../../../core/services/shared_prefs_service.dart';
import '../../../core/utils/currency_format.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTheme = 'system';
  String _selectedCurrency = 'IDR';
  String _selectedLanguage = 'id';
  bool _notificationEnabled = true;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeMode = await SharedPrefsService.getThemeMode() ?? 'system';
    final currency = await SharedPrefsService.getCurrency();
    final language = await SharedPrefsService.getLanguage();
    final notificationEnabled = await SharedPrefsService.isNotificationEnabled();
    final biometricEnabled = await SharedPrefsService.isBiometricEnabled();

    setState(() {
      _selectedTheme = themeMode;
      _selectedCurrency = currency;
      _selectedLanguage = language;
      _notificationEnabled = notificationEnabled;
      _biometricEnabled = biometricEnabled;
    });
  }

  Future<void> _changeTheme(String? theme) async {
    if (theme == null) return;
    
    await SharedPrefsService.saveThemeMode(theme);
    setState(() {
      _selectedTheme = theme;
    });
    
    if (mounted) {
      context.showSuccessSnackBar('Tema berhasil diubah. Restart aplikasi untuk melihat perubahan.');
    }
  }

  Future<void> _changeCurrency(String? currency) async {
    if (currency == null) return;
    
    await SharedPrefsService.saveCurrency(currency);
    setState(() {
      _selectedCurrency = currency;
    });
    
    if (mounted) {
      context.showSuccessSnackBar('Mata uang berhasil diubah');
    }
  }

  Future<void> _changeLanguage(String? language) async {
    if (language == null) return;
    
    await SharedPrefsService.saveLanguage(language);
    setState(() {
      _selectedLanguage = language;
    });
    
    if (mounted) {
      context.showSuccessSnackBar('Bahasa berhasil diubah');
    }
  }

  Future<void> _toggleNotification(bool value) async {
    await SharedPrefsService.setNotificationEnabled(value);
    setState(() {
      _notificationEnabled = value;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    await SharedPrefsService.setBiometricEnabled(value);
    setState(() {
      _biometricEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pengaturan',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              
              // Appearance Section
              _buildSectionHeader('Tampilan'),
              CustomCard(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.palette_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Tema',
                        style: context.bodyBoldStyle,
                      ),
                      subtitle: Text(
                        _getThemeName(_selectedTheme),
                        style: context.labelSmallStyle.copyWith(
                          color: context.textColor.withOpacity(0.6),
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                      onTap: () => _showThemeDialog(),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Regional Section
              _buildSectionHeader('Regional'),
              CustomCard(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.attach_money_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Mata Uang',
                        style: context.bodyBoldStyle,
                      ),
                      subtitle: Text(
                        _getCurrencyName(_selectedCurrency),
                        style: context.labelSmallStyle.copyWith(
                          color: context.textColor.withOpacity(0.6),
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                      onTap: () => _showCurrencyDialog(),
                    ),
                    Divider(
                      height: 1,
                      indent: 68,
                      color: context.textColor.withOpacity(0.1),
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: AppColors.info,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Bahasa',
                        style: context.bodyBoldStyle,
                      ),
                      subtitle: Text(
                        _getLanguageName(_selectedLanguage),
                        style: context.labelSmallStyle.copyWith(
                          color: context.textColor.withOpacity(0.6),
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                      onTap: () => _showLanguageDialog(),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Security Section
              _buildSectionHeader('Keamanan & Privasi'),
              CustomCard(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.warning,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Notifikasi',
                        style: context.bodyBoldStyle,
                      ),
                      subtitle: Text(
                        'Aktifkan pengingat tagihan & anggaran',
                        style: context.labelSmallStyle.copyWith(
                          color: context.textColor.withOpacity(0.6),
                        ),
                      ),
                      value: _notificationEnabled,
                      onChanged: _toggleNotification,
                      activeColor: AppColors.primary,
                    ),
                    Divider(
                      height: 1,
                      indent: 68,
                      color: context.textColor.withOpacity(0.1),
                    ),
                    SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.expense.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.fingerprint_rounded,
                          color: AppColors.expense,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Biometrik',
                        style: context.bodyBoldStyle,
                      ),
                      subtitle: Text(
                        'Login dengan sidik jari',
                        style: context.labelSmallStyle.copyWith(
                          color: context.textColor.withOpacity(0.6),
                        ),
                      ),
                      value: _biometricEnabled,
                      onChanged: _toggleBiometric,
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Text(
        title,
        style: context.labelStyle.copyWith(
          color: context.textColor.withOpacity(0.6),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('Terang', 'light'),
            _buildThemeOption('Gelap', 'dark'),
            _buildThemeOption('Sistem', 'system'),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _selectedTheme,
      onChanged: (value) {
        Navigator.pop(context);
        _changeTheme(value);
      },
      activeColor: AppColors.primary,
    );
  }

  void _showCurrencyDialog() {
    final currencies = CurrencyFormat.getSupportedCurrencies();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Mata Uang'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: currencies.map((currency) {
              return RadioListTile<String>(
                title: Text(currency['name']!),
                subtitle: Text(currency['symbol']!),
                value: currency['code']!,
                groupValue: _selectedCurrency,
                onChanged: (value) {
                  Navigator.pop(context);
                  _changeCurrency(value);
                },
                activeColor: AppColors.primary,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Bahasa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('Bahasa Indonesia', 'id'),
            _buildLanguageOption('English', 'en'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _selectedLanguage,
      onChanged: (value) {
        Navigator.pop(context);
        _changeLanguage(value);
      },
      activeColor: AppColors.primary,
    );
  }

  String _getThemeName(String theme) {
    switch (theme) {
      case 'light':
        return 'Terang';
      case 'dark':
        return 'Gelap';
      case 'system':
        return 'Mengikuti Sistem';
      default:
        return 'Mengikuti Sistem';
    }
  }

  String _getCurrencyName(String code) {
    final currencies = CurrencyFormat.getSupportedCurrencies();
    final currency = currencies.firstWhere(
      (c) => c['code'] == code,
      orElse: () => {'code': 'IDR', 'name': 'Rupiah Indonesia'},
    );
    return currency['name']!;
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'id':
        return 'Bahasa Indonesia';
      case 'en':
        return 'English';
      default:
        return 'Bahasa Indonesia';
    }
  }
}
