import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/achievement_manager.dart';
import 'screens/home_screen.dart';
import 'services/settings_service.dart';
import 'models/game_settings.dart';
import 'l10n/app_localizations.dart';
import 'theme/steampunk_theme.dart';

import 'theme/fortune_theme.dart';
import 'theme/ghibli_theme.dart';



final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _settingsService = SettingsService();
  late final ValueNotifier<GameSettings> _settingsNotifier;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _settingsNotifier = ValueNotifier(GameSettings());
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.loadSettings();
    _settingsNotifier.value = settings;
    setState(() {
      _isLoading = false;
    });
  }

  void _updateSettings(GameSettings newSettings) {
    _settingsNotifier.value = newSettings;
    _settingsService.saveSettings(newSettings);
  }

  @override
  void dispose() {
    _settingsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black, // Dark background as requested "steampunk dark"
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo V2
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.3), blurRadius: 20),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/images/logo_v2.jpg'),
                  ),
                ),
                const SizedBox(height: 24),
                // Custom Loader
                const CircularProgressIndicator(
                  color: Color(0xFFC0C0C0), // Silver/Metal
                  backgroundColor: Colors.black,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ValueListenableBuilder<GameSettings>(
      valueListenable: _settingsNotifier,
      builder: (context, settings, _) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AchievementManager()),
            Provider<GameSettings>.value(value: settings),
            Provider<Function(GameSettings)>.value(value: _updateSettings),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey, // CRITIAL: Key for overlays
            title: '14.1 Fortune',
            debugShowCheckedModeBanner: false,
            
            // Localization
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale(settings.languageCode),
            
            
            // Theme
            theme: _getTheme(settings.themeId),
            darkTheme: _getTheme(settings.themeId),
            themeMode: settings.themeId == 'ghibli' ? ThemeMode.light : ThemeMode.dark,
            
            home: const HomeScreen(),
          ),
        );
      },
    );
  }
  ThemeData _getTheme(String themeId) {
    switch (themeId) {
      case 'cyberpunk':
        return CyberpunkTheme.themeData;
      case 'ghibli':
        return GhibliTheme.themeData;
      case 'steampunk':
      default:
        return SteampunkTheme.themeData;
    }
  }
}
