import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'shared/navigation/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'shared/providers/app_providers.dart';
import 'data/database/app_database.dart';
import 'l10n/app_localizations.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize and test database connection
  await _initializeDatabase();
  
  runApp(ProviderScope(child: const HealthBoxApp()));
}

Future<void> _initializeDatabase() async {
  try {
    // Test database connection
    final database = AppDatabase.instance;
    
    // First check if we can even get the database instance
    debugPrint('Got database instance successfully');
    
    final canConnect = await database.testConnection();
    
    debugPrint('Database connection test: ${canConnect ? "SUCCESS" : "FAILED"}');
    
    if (canConnect) {
      debugPrint('HealthBox database is ready!');
      
      // Test a simple table creation/query to make sure everything works
      try {
        await database.customStatement('CREATE TABLE IF NOT EXISTS test_table (id INTEGER PRIMARY KEY)');
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
      
      // Theme Configuration - Using fallback themes for now, async loading in providers
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
      ),
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
      supportedLocales: const [
        Locale('en'),
      ],
      
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