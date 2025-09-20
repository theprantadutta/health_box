import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared/navigation/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'shared/providers/app_providers.dart';
import 'shared/providers/onboarding_providers.dart';
import 'data/database/app_database.dart';
import 'l10n/app_localizations.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize and test database connection
  await _initializeDatabase();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const HealthBoxApp(),
    ),
  );
}

Future<void> _initializeDatabase() async {
  try {
    // Test database connection
    final database = AppDatabase.instance;

    // First check if we can even get the database instance
    debugPrint('Got database instance successfully');

    final canConnect = await database.testConnection();

    debugPrint(
      'Database connection test: ${canConnect ? "SUCCESS" : "FAILED"}',
    );

    if (canConnect) {
      debugPrint('HealthBox database is ready!');

      // Test a simple table creation/query to make sure everything works
      try {
        await database.customStatement(
          'CREATE TABLE IF NOT EXISTS test_table (id INTEGER PRIMARY KEY)',
        );
        await database.customStatement('DROP TABLE IF EXISTS test_table');
        debugPrint('Database table operations test: SUCCESS');
      } catch (tableError) {
        debugPrint('Database table operations test: FAILED - $tableError');
      }
    } else {
      debugPrint('Warning: Database connection failed, app will use fallback');
    }
  } catch (e) {
    debugPrint('Database initialization error: $e');
    debugPrint('Error type: ${e.runtimeType}');
    debugPrint('Stack trace: ${StackTrace.current}');
    // Don't block app startup, the database will handle fallbacks
  }
}

class HealthBoxApp extends ConsumerWidget {
  const HealthBoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'HealthBox',
      debugShowCheckedModeBanner: false,

      // Clean Material 3 Theme System - Single Blue Color Scheme
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeMode,
      themeAnimationDuration: AppTheme.themeTransitionDuration,

      // Routing
      routerConfig: router,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],

      // Builder for responsive and accessibility support
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

// Clean, consistent theme system - Using our seed color as primary
const Color _primaryBlue = Color(0xFF2196F3);

ThemeData _buildLightTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: _primaryBlue,
        brightness: Brightness.light,
      ).copyWith(
        primary: _primaryBlue, // Use our exact seed color as primary
        primaryContainer: const Color(0xFF1976D2), // Darker variant
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      surfaceTintColor: colorScheme.surfaceTint,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

ThemeData _buildDarkTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: _primaryBlue,
        brightness: Brightness.dark,
      ).copyWith(
        primary: _primaryBlue, // Use our exact seed color as primary
        primaryContainer: const Color(0xFF1565C0), // Even darker for dark theme
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      surfaceTintColor: colorScheme.surfaceTint,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
