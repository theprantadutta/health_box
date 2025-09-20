import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/database/app_database.dart';
import 'l10n/app_localizations.dart';
import 'shared/navigation/app_router.dart';
import 'shared/providers/app_providers.dart';
import 'shared/providers/onboarding_providers.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/design_system.dart';

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

// Clean, consistent theme system - Using our comprehensive design system
const Color _seedColor = HealthBoxDesignSystem.primaryBlue;

// Enhanced Material 3 theme with our design system
ThemeData _buildLightTheme() {
  // Create dynamic color scheme using our primary blue
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ).copyWith(
        // Enhanced surface colors for better hierarchy
        surface: HealthBoxDesignSystem.surfacePrimary,
        surfaceContainerLowest: HealthBoxDesignSystem.surfaceTertiary,
        surfaceContainerLow: HealthBoxDesignSystem.neutral100,
        surfaceContainer: HealthBoxDesignSystem.neutral200,
        surfaceContainerHigh: HealthBoxDesignSystem.neutral300,
        surfaceContainerHighest: Colors.white,

        // Refined on-surface colors
        onSurface: HealthBoxDesignSystem.textPrimary,
        onSurfaceVariant: HealthBoxDesignSystem.textSecondary,

        // Enhanced primary colors
        primary: HealthBoxDesignSystem.primaryBlue,
        primaryContainer: HealthBoxDesignSystem.primaryBlueLight,
        onPrimary: Colors.white,
        onPrimaryContainer: Colors.white,

        // Secondary color scheme
        secondary: HealthBoxDesignSystem.accentPurple,
        secondaryContainer: HealthBoxDesignSystem.accentPurple.withValues(alpha: 0.1),
        onSecondary: Colors.white,
        onSecondaryContainer: HealthBoxDesignSystem.textPrimary,

        // Tertiary colors for accents
        tertiary: HealthBoxDesignSystem.accentCyan,
        tertiaryContainer: HealthBoxDesignSystem.accentCyan.withValues(alpha: 0.1),
        onTertiary: Colors.white,
        onTertiaryContainer: HealthBoxDesignSystem.textPrimary,

        // Error colors
        error: HealthBoxDesignSystem.errorColor,
        onError: Colors.white,
        errorContainer: HealthBoxDesignSystem.errorColor.withValues(alpha: 0.1),
        onErrorContainer: HealthBoxDesignSystem.textPrimary,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,

    // Enhanced typography with design system
    textTheme: _buildTextTheme(colorScheme),

    // Refined app bar theme
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.surfaceTint,
      shadowColor: colorScheme.shadow,
      titleTextStyle: _buildTextTheme(colorScheme).titleLarge?.copyWith(
        fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 24),
    ),

    // Enhanced card theme with design system
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusLg),
      ),
      surfaceTintColor: colorScheme.surfaceTint,
      shadowColor: colorScheme.shadow,
      margin: EdgeInsets.zero,
    ),

    // Floating action button with design system
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusXl),
      ),
      sizeConstraints: const BoxConstraints(minWidth: 56, minHeight: 56),
    ),

    // Enhanced button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 1,
        shadowColor: colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        ),
        minimumSize: const Size(0, HealthBoxDesignSystem.buttonHeightBase),
        padding: const EdgeInsets.symmetric(
          horizontal: HealthBoxDesignSystem.spacing4,
          vertical: HealthBoxDesignSystem.spacing3,
        ),
        textStyle: _buildTextTheme(colorScheme).labelLarge?.copyWith(
          fontWeight: HealthBoxDesignSystem.fontWeightMedium,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.outline, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        ),
        minimumSize: const Size(0, HealthBoxDesignSystem.buttonHeightBase),
        padding: const EdgeInsets.symmetric(
          horizontal: HealthBoxDesignSystem.spacing4,
          vertical: HealthBoxDesignSystem.spacing3,
        ),
        textStyle: _buildTextTheme(colorScheme).labelLarge?.copyWith(
          fontWeight: HealthBoxDesignSystem.fontWeightMedium,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        ),
        minimumSize: const Size(0, HealthBoxDesignSystem.buttonHeightBase),
        padding: const EdgeInsets.symmetric(
          horizontal: HealthBoxDesignSystem.spacing4,
          vertical: HealthBoxDesignSystem.spacing3,
        ),
        textStyle: _buildTextTheme(colorScheme).labelLarge?.copyWith(
          fontWeight: HealthBoxDesignSystem.fontWeightMedium,
        ),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: HealthBoxDesignSystem.spacing4,
        vertical: HealthBoxDesignSystem.spacing3,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        borderSide: BorderSide(color: colorScheme.outline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        borderSide: BorderSide(color: colorScheme.error, width: 1),
      ),
      labelStyle: _buildTextTheme(
        colorScheme,
      ).bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
      hintStyle: _buildTextTheme(colorScheme).bodyLarge?.copyWith(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
    ),

    // Enhanced scaffold background
    scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,

    // Bottom navigation bar theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      selectedLabelStyle: _buildTextTheme(colorScheme).labelSmall?.copyWith(
        fontWeight: HealthBoxDesignSystem.fontWeightMedium,
      ),
      unselectedLabelStyle: _buildTextTheme(colorScheme).labelSmall,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),

    // Tab bar theme
    tabBarTheme: TabBarThemeData(
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: colorScheme.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: _buildTextTheme(colorScheme).titleSmall?.copyWith(
        fontWeight: HealthBoxDesignSystem.fontWeightMedium,
      ),
      unselectedLabelStyle: _buildTextTheme(colorScheme).titleSmall,
    ),

    // Enhanced dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusXl),
      ),
      elevation: 24,
      shadowColor: colorScheme.shadow,
    ),
  );
}

// Enhanced dark theme with refined contrast
ThemeData _buildDarkTheme() {
  // Create dynamic color scheme for dark mode
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ).copyWith(
        // Enhanced surface colors for dark mode
        surface: const Color(0xFF0F172A), // Slate-900
        surfaceContainerLowest: const Color(0xFF1E293B), // Slate-800
        surfaceContainerLow: const Color(0xFF334155), // Slate-700
        surfaceContainer: const Color(0xFF475569), // Slate-600
        surfaceContainerHigh: const Color(0xFF64748B), // Slate-500
        surfaceContainerHighest: const Color(0xFF94A3B8), // Slate-400
        // Refined on-surface colors for dark mode
        onSurface: HealthBoxDesignSystem.neutral50,
        onSurfaceVariant: HealthBoxDesignSystem.neutral300,

        // Enhanced primary colors for dark mode
        primary: HealthBoxDesignSystem.primaryBlueLight,
        primaryContainer: HealthBoxDesignSystem.primaryBlue,
        onPrimary: HealthBoxDesignSystem.neutral900,
        onPrimaryContainer: Colors.white,

        // Secondary color scheme for dark mode
        secondary: HealthBoxDesignSystem.accentPurple,
        secondaryContainer: HealthBoxDesignSystem.accentPurple.withValues(alpha: 0.2),
        onSecondary: Colors.white,
        onSecondaryContainer: HealthBoxDesignSystem.neutral50,

        // Tertiary colors for dark mode
        tertiary: HealthBoxDesignSystem.accentCyan,
        tertiaryContainer: HealthBoxDesignSystem.accentCyan.withValues(alpha: 0.2),
        onTertiary: Colors.white,
        onTertiaryContainer: HealthBoxDesignSystem.neutral50,

        // Error colors for dark mode
        error: const Color(0xFFEF4444), // Red-500
        onError: Colors.white,
        errorContainer: const Color(0xFF7F1D1D).withValues(alpha: 0.2),
        onErrorContainer: HealthBoxDesignSystem.neutral50,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,

    // Enhanced typography for dark mode
    textTheme: _buildTextTheme(colorScheme),

    // Refined app bar theme for dark mode
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.surfaceTint,
      shadowColor: colorScheme.shadow,
      titleTextStyle: _buildTextTheme(colorScheme).titleLarge?.copyWith(
        fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 24),
    ),

    // Enhanced card theme for dark mode
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusLg),
      ),
      surfaceTintColor: colorScheme.surfaceTint,
      shadowColor: colorScheme.shadow,
      margin: EdgeInsets.zero,
    ),

    // Floating action button for dark mode
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusXl),
      ),
      sizeConstraints: const BoxConstraints(minWidth: 56, minHeight: 56),
    ),

    // Enhanced button themes for dark mode
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shadowColor: colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        ),
        minimumSize: const Size(0, HealthBoxDesignSystem.buttonHeightBase),
        padding: const EdgeInsets.symmetric(
          horizontal: HealthBoxDesignSystem.spacing4,
          vertical: HealthBoxDesignSystem.spacing3,
        ),
        textStyle: _buildTextTheme(colorScheme).labelLarge?.copyWith(
          fontWeight: HealthBoxDesignSystem.fontWeightMedium,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.outline, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        ),
        minimumSize: const Size(0, HealthBoxDesignSystem.buttonHeightBase),
        padding: const EdgeInsets.symmetric(
          horizontal: HealthBoxDesignSystem.spacing4,
          vertical: HealthBoxDesignSystem.spacing3,
        ),
        textStyle: _buildTextTheme(colorScheme).labelLarge?.copyWith(
          fontWeight: HealthBoxDesignSystem.fontWeightMedium,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        ),
        minimumSize: const Size(0, HealthBoxDesignSystem.buttonHeightBase),
        padding: const EdgeInsets.symmetric(
          horizontal: HealthBoxDesignSystem.spacing4,
          vertical: HealthBoxDesignSystem.spacing3,
        ),
        textStyle: _buildTextTheme(colorScheme).labelLarge?.copyWith(
          fontWeight: HealthBoxDesignSystem.fontWeightMedium,
        ),
      ),
    ),

    // Input decoration theme for dark mode
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: HealthBoxDesignSystem.spacing4,
        vertical: HealthBoxDesignSystem.spacing3,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        borderSide: BorderSide(color: colorScheme.error, width: 1),
      ),
      labelStyle: _buildTextTheme(
        colorScheme,
      ).bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
      hintStyle: _buildTextTheme(colorScheme).bodyLarge?.copyWith(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
    ),

    // Enhanced scaffold background for dark mode
    scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,

    // Bottom navigation bar theme for dark mode
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      selectedLabelStyle: _buildTextTheme(colorScheme).labelSmall?.copyWith(
        fontWeight: HealthBoxDesignSystem.fontWeightMedium,
      ),
      unselectedLabelStyle: _buildTextTheme(colorScheme).labelSmall,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),

    // Tab bar theme for dark mode
    tabBarTheme: TabBarThemeData(
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: colorScheme.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: _buildTextTheme(colorScheme).titleSmall?.copyWith(
        fontWeight: HealthBoxDesignSystem.fontWeightMedium,
      ),
      unselectedLabelStyle: _buildTextTheme(colorScheme).titleSmall,
    ),

    // Enhanced dialog theme for dark mode
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusXl),
      ),
      elevation: 24,
      shadowColor: colorScheme.shadow,
    ),
  );
}

// Enhanced text theme using design system
TextTheme _buildTextTheme(ColorScheme colorScheme) {
  return TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontSize: HealthBoxDesignSystem.textSize4xl,
      fontWeight: HealthBoxDesignSystem.fontWeightBold,
      color: colorScheme.onSurface,
      height: HealthBoxDesignSystem.lineHeightTight,
      letterSpacing: -0.025,
    ),
    displayMedium: TextStyle(
      fontSize: HealthBoxDesignSystem.textSize3xl,
      fontWeight: HealthBoxDesignSystem.fontWeightBold,
      color: colorScheme.onSurface,
      height: HealthBoxDesignSystem.lineHeightTight,
      letterSpacing: -0.025,
    ),
    displaySmall: TextStyle(
      fontSize: HealthBoxDesignSystem.textSize2xl,
      fontWeight: HealthBoxDesignSystem.fontWeightBold,
      color: colorScheme.onSurface,
      height: HealthBoxDesignSystem.lineHeightSnug,
      letterSpacing: 0,
    ),

    // Headline styles
    headlineLarge: TextStyle(
      fontSize: HealthBoxDesignSystem.textSize2xl,
      fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
      color: colorScheme.onSurface,
      height: HealthBoxDesignSystem.lineHeightSnug,
      letterSpacing: -0.025,
    ),
    headlineMedium: TextStyle(
      fontSize: HealthBoxDesignSystem.textSizeXl,
      fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
      color: colorScheme.onSurface,
      height: HealthBoxDesignSystem.lineHeightSnug,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: HealthBoxDesignSystem.textSizeLg,
      fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
      color: colorScheme.onSurface,
      height: HealthBoxDesignSystem.lineHeightNormal,
      letterSpacing: 0,
    ),

    // Title styles
    titleLarge: TextStyle(
      fontSize: HealthBoxDesignSystem.textSizeLg,
      fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
      color: colorScheme.onSurface,
      height: HealthBoxDesignSystem.lineHeightSnug,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: HealthBoxDesignSystem.textSizeBase,
      fontWeight: HealthBoxDesignSystem.fontWeightMedium,
      color: colorScheme.onSurface,
      height: HealthBoxDesignSystem.lineHeightNormal,
      letterSpacing: 0.015,
    ),
    titleSmall: TextStyle(
      fontSize: HealthBoxDesignSystem.textSizeSm,
      fontWeight: HealthBoxDesignSystem.fontWeightMedium,
      color: colorScheme.onSurface,
      height: HealthBoxDesignSystem.lineHeightNormal,
      letterSpacing: 0.01,
    ),

    // Body styles
    bodyLarge: TextStyle(
      fontSize: HealthBoxDesignSystem.textSizeBase,
      fontWeight: HealthBoxDesignSystem.fontWeightNormal,
      color: colorScheme.onSurface,
      height: HealthBoxDesignSystem.lineHeightRelaxed,
      letterSpacing: 0.025,
    ),
    bodyMedium: TextStyle(
      fontSize: HealthBoxDesignSystem.textSizeSm,
      fontWeight: HealthBoxDesignSystem.fontWeightNormal,
      color: colorScheme.onSurface,
      height: HealthBoxDesignSystem.lineHeightRelaxed,
      letterSpacing: 0.025,
    ),
    bodySmall: TextStyle(
      fontSize: HealthBoxDesignSystem.textSizeXs,
      fontWeight: HealthBoxDesignSystem.fontWeightNormal,
      color: colorScheme.onSurface,
      height: HealthBoxDesignSystem.lineHeightNormal,
      letterSpacing: 0.04,
    ),

    // Label styles
    labelLarge: TextStyle(
      fontSize: HealthBoxDesignSystem.textSizeSm,
      fontWeight: HealthBoxDesignSystem.fontWeightMedium,
      color: colorScheme.onSurface,
      height: HealthBoxDesignSystem.lineHeightNormal,
      letterSpacing: 0.025,
    ),
    labelMedium: TextStyle(
      fontSize: HealthBoxDesignSystem.textSizeXs,
      fontWeight: HealthBoxDesignSystem.fontWeightMedium,
      color: colorScheme.onSurface,
      height: HealthBoxDesignSystem.lineHeightNormal,
      letterSpacing: 0.05,
    ),
    labelSmall: TextStyle(
      fontSize: HealthBoxDesignSystem.textSizeXs - 1,
      fontWeight: HealthBoxDesignSystem.fontWeightMedium,
      color: colorScheme.onSurface,
      height: HealthBoxDesignSystem.lineHeightNormal,
      letterSpacing: 0.05,
    ),
  );
}
