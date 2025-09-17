import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'material3_theme.dart';

/// 6-Level Elevation System for Premium Medical UI
enum ElevationLevel { flat, subtle, low, medium, high, floating }

class AppTheme {
  static const Color _seedColor = Color(0xFF2196F3);

  // ============ SIMPLIFIED LIGHT COLOR PALETTE ============

  // Primary Colors - Very Light and Readable
  static const Color primaryColorLight = Color(0xFF64B5F6); // Light medical blue
  static const Color primaryColorDark = Color(0xFF90CAF9); // Even lighter blue for dark theme

  // Success Color - Light and Calming
  static const Color successColor = Color(0xFF81C784); // Light green

  // Warning Color - Soft and Noticeable
  static const Color warningColor = Color(0xFFFFB74D); // Light orange

  // Error Color - Light but Still Visible
  static const Color errorColor = Color(0xFFE57373); // Light red

  // Neutral Colors - Very Light
  static const Color neutralColorLight = Color(0xFFF8F9FA); // Almost white
  static const Color neutralColorDark = Color(0xFF455A64); // Medium gray for dark theme

  // ============ ELEVATION & SHADOW SYSTEM ============

  // Elevation shadows for light theme
  static const Map<ElevationLevel, List<BoxShadow>> elevationShadowsLight = {
    ElevationLevel.flat: [],
    ElevationLevel.subtle: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.04),
        offset: Offset(0, 1),
        blurRadius: 2,
        spreadRadius: 0,
      ),
    ],
    ElevationLevel.low: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.08),
        offset: Offset(0, 2),
        blurRadius: 8,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.04),
        offset: Offset(0, 1),
        blurRadius: 3,
        spreadRadius: 0,
      ),
    ],
    ElevationLevel.medium: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.12),
        offset: Offset(0, 4),
        blurRadius: 16,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.06),
        offset: Offset(0, 2),
        blurRadius: 6,
        spreadRadius: 0,
      ),
    ],
    ElevationLevel.high: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.16),
        offset: Offset(0, 8),
        blurRadius: 24,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.08),
        offset: Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ],
    ElevationLevel.floating: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.20),
        offset: Offset(0, 12),
        blurRadius: 32,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.12),
        offset: Offset(0, 6),
        blurRadius: 16,
        spreadRadius: 0,
      ),
    ],
  };

  // Elevation shadows for dark theme
  static const Map<ElevationLevel, List<BoxShadow>> elevationShadowsDark = {
    ElevationLevel.flat: [],
    ElevationLevel.subtle: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.12),
        offset: Offset(0, 1),
        blurRadius: 3,
        spreadRadius: 0,
      ),
    ],
    ElevationLevel.low: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.24),
        offset: Offset(0, 2),
        blurRadius: 8,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.12),
        offset: Offset(0, 1),
        blurRadius: 4,
        spreadRadius: 0,
      ),
    ],
    ElevationLevel.medium: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.32),
        offset: Offset(0, 4),
        blurRadius: 16,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.16),
        offset: Offset(0, 2),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
    ElevationLevel.high: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.40),
        offset: Offset(0, 8),
        blurRadius: 24,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.20),
        offset: Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ],
    ElevationLevel.floating: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.48),
        offset: Offset(0, 12),
        blurRadius: 32,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.24),
        offset: Offset(0, 6),
        blurRadius: 16,
        spreadRadius: 0,
      ),
    ],
  };

  // ============ ANIMATION SYSTEM ============

  // Animation Durations (Medical UI Standards)
  static const Duration microDuration = Duration(
    milliseconds: 150,
  ); // Quick feedback
  static const Duration standardDuration = Duration(
    milliseconds: 300,
  ); // Default
  static const Duration dramaticDuration = Duration(
    milliseconds: 500,
  ); // Hero transitions
  static const Duration slowDuration = Duration(
    milliseconds: 800,
  ); // Page transitions

  // Animation Curves (Carefully chosen for medical app feel)
  static const Curve easeOutCubic = Curves.easeOutCubic; // Most interactions
  static const Curve easeInOutCubic =
      Curves.easeInOutCubic; // Smooth transitions
  static const Curve bounceOut = Curves.bounceOut; // Success feedback
  static const Curve elasticOut = Curves.elasticOut; // Playful interactions

  // Spring Animation Settings
  static const SpringDescription springDescription = SpringDescription(
    mass: 1.0,
    stiffness: 500.0,
    damping: 30.0,
  );

  // Stagger Animation Delays
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration staggerDelayLong = Duration(milliseconds: 100);

  // Responsive breakpoints
  static const double mobileMaxWidth = 480;
  static const double tabletMaxWidth = 1024;
  static const double desktopMinWidth = 1025;

  // Enhanced shadows
  static const List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.3),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevatedShadowLight = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.12),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevatedShadowDark = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.4),
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.2),
      offset: Offset(0, 3),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // ============ SOLID COLOR UTILITIES ============

  // Primary color methods
  static Color getPrimaryColor(bool isDark) {
    return isDark ? primaryColorDark : primaryColorLight;
  }

  static Color getSuccessColor() {
    return successColor;
  }

  static Color getWarningColor() {
    return warningColor;
  }

  static Color getErrorColor() {
    return errorColor;
  }

  // Simplified color utilities
  static Color getNeutralColor(bool isDark) {
    return isDark ? neutralColorDark : neutralColorLight;
  }

  // ============ ELEVATION UTILITIES ============

  // Get elevation shadows based on theme and level
  static List<BoxShadow> getElevationShadow(
    bool isDarkMode,
    ElevationLevel level,
  ) {
    final shadows = isDarkMode ? elevationShadowsDark : elevationShadowsLight;
    return shadows[level] ?? [];
  }

  // Convenience methods for specific elevation levels
  static List<BoxShadow> getFlatShadow(bool isDarkMode) =>
      getElevationShadow(isDarkMode, ElevationLevel.flat);

  static List<BoxShadow> getSubtleShadow(bool isDarkMode) =>
      getElevationShadow(isDarkMode, ElevationLevel.subtle);

  static List<BoxShadow> getLowShadow(bool isDarkMode) =>
      getElevationShadow(isDarkMode, ElevationLevel.low);

  static List<BoxShadow> getMediumShadow(bool isDarkMode) =>
      getElevationShadow(isDarkMode, ElevationLevel.medium);

  static List<BoxShadow> getHighShadow(bool isDarkMode) =>
      getElevationShadow(isDarkMode, ElevationLevel.high);

  static List<BoxShadow> getFloatingShadow(bool isDarkMode) =>
      getElevationShadow(isDarkMode, ElevationLevel.floating);

  static Future<ThemeData> lightTheme() async {
    final colorScheme = await Material3Theme.generateDynamicColorScheme(
      brightness: Brightness.light,
      seedColor: _seedColor,
    );

    final theme = Material3Theme.createMaterial3Theme(colorScheme: colorScheme);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      Material3Theme.getSystemUiOverlayStyle(colorScheme),
    );

    return theme.copyWith(
      // Enhanced card theme with custom shadows
      cardTheme: theme.cardTheme.copyWith(
        elevation: 0, // We'll use custom shadows instead
        shadowColor: Colors.transparent,
      ),
    );
  }

  static Future<ThemeData> darkTheme() async {
    final colorScheme = await Material3Theme.generateDynamicColorScheme(
      brightness: Brightness.dark,
      seedColor: _seedColor,
    );

    final theme = Material3Theme.createMaterial3Theme(colorScheme: colorScheme);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      Material3Theme.getSystemUiOverlayStyle(colorScheme),
    );

    return theme.copyWith(
      // Enhanced card theme with custom shadows
      cardTheme: theme.cardTheme.copyWith(
        elevation: 0, // We'll use custom shadows instead
        shadowColor: Colors.transparent,
      ),
    );
  }

  // Legacy shadow methods (maintained for backward compatibility)
  static List<BoxShadow> getCardShadow(bool isDarkMode) {
    return getLowShadow(isDarkMode); // Maps to new elevation system
  }

  static List<BoxShadow> getElevatedShadow(bool isDarkMode) {
    return getMediumShadow(isDarkMode); // Maps to new elevation system
  }

  // Responsive utility methods
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= mobileMaxWidth;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > mobileMaxWidth && width <= tabletMaxWidth;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMinWidth;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  static double getResponsiveCardRadius(BuildContext context) {
    if (isMobile(context)) {
      return 12;
    } else if (isTablet(context)) {
      return 16;
    } else {
      return 20;
    }
  }

  static const Duration themeTransitionDuration = Duration(milliseconds: 300);
}
