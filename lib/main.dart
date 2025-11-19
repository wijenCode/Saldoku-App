import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'core/db/app_database.dart';
import 'core/services/auth_service.dart';
import 'core/services/shared_prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await AppDatabase().database;
  
  // Initialize auth service
  await AuthService().init();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const SaldokuApp());
}

class SaldokuApp extends StatefulWidget {
  const SaldokuApp({super.key});

  @override
  State<SaldokuApp> createState() => _SaldokuAppState();
}

class _SaldokuAppState extends State<SaldokuApp> {
  ThemeMode _themeMode = ThemeMode.system;
  
  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    final themeMode = await SharedPrefsService.getThemeMode() ?? 'system';
    setState(() {
      _themeMode = _getThemeMode(themeMode);
    });
  }
  
  ThemeMode _getThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saldoku - Kelola Keuangan',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeMode,
      
      // Routing
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: _getInitialRoute(),
    );
  }
  
  String _getInitialRoute() {
    // Use FutureBuilder pattern in production
    // For now, always start with onboarding
    return AppRouter.onboarding;
  }
}

