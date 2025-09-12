import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'material3_theme.dart';

class AppTheme {
  static const Color _seedColor = Color(0xFF2196F3);
  
  // Modern gradient colors for HealthBox
  static const List<Color> primaryGradientLight = [
    Color(0xFF2196F3), // Primary blue
    Color(0xFF1976D2), // Darker blue
  ];
  
  static const List<Color> primaryGradientDark = [
    Color(0xFF42A5F5), // Lighter blue for dark mode
    Color(0xFF1E88E5), // Medium blue
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF4CAF50), // Green
    Color(0xFF388E3C), // Darker green
  ];
  
  static const List<Color> warningGradient = [
    Color(0xFFFF9800), // Orange
    Color(0xFFF57C00), // Darker orange
  ];
  
  static const List<Color> errorGradient = [
    Color(0xFFF44336), // Red
    Color(0xFFD32F2F), // Darker red
  ];
  
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
  
  // Gradient decorations
  static LinearGradient getPrimaryGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark ? primaryGradientDark : primaryGradientLight,
    );
  }
  
  static LinearGradient getSuccessGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: successGradient,
    );
  }
  
  static LinearGradient getWarningGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: warningGradient,
    );
  }
  
  static LinearGradient getErrorGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: errorGradient,
    );
  }

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
  
  // Utility method to get shadows based on theme
  static List<BoxShadow> getCardShadow(bool isDarkMode) {
    return isDarkMode ? cardShadowDark : cardShadowLight;
  }
  
  static List<BoxShadow> getElevatedShadow(bool isDarkMode) {
    return isDarkMode ? elevatedShadowDark : elevatedShadowLight;
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