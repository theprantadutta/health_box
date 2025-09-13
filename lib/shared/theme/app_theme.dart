import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'material3_theme.dart';

class AppTheme {
  static const Color _seedColor = Color(0xFF00BCD4); // Vibrant teal for health/wellness
  
  // Premium Health-Focused Color Palettes
  // Primary - Vibrant Teal to Deep Ocean Blue (Trust, Health, Vitality)
  static const List<Color> primaryGradientLight = [
    Color(0xFF00E5FF), // Bright cyan
    Color(0xFF00BCD4), // Primary teal  
    Color(0xFF0097A7), // Deep teal
  ];
  
  static const List<Color> primaryGradientDark = [
    Color(0xFF4FC3F7), // Light blue
    Color(0xFF29B6F6), // Sky blue
    Color(0xFF0288D1), // Ocean blue
  ];
  
  // Success - Vibrant Life Green (Growth, Healing, Wellness)
  static const List<Color> successGradient = [
    Color(0xFF69F0AE), // Bright mint
    Color(0xFF00E676), // Vibrant green
    Color(0xFF00C853), // Deep emerald
  ];
  
  // Warning - Warm Sunset Orange (Energy, Alertness, Care)
  static const List<Color> warningGradient = [
    Color(0xFFFFB74D), // Warm orange
    Color(0xFFFF9800), // Primary orange
    Color(0xFFE65100), // Deep amber
  ];
  
  // Error - Soft Coral Red (Gentle Alert, Not Harsh)
  static const List<Color> errorGradient = [
    Color(0xFFFF8A80), // Soft coral
    Color(0xFFFF5722), // Warm red
    Color(0xFFD84315), // Deep red-orange
  ];

  // NEW: Additional Health-Themed Color Palettes
  
  // Wellness Purple (Mental Health, Calm, Meditation)
  static const List<Color> wellnessGradient = [
    Color(0xFFB39DDB), // Light purple
    Color(0xFF9C27B0), // Medium purple
    Color(0xFF6A1B9A), // Deep purple
  ];
  
  // Vitality Gold (Energy, Nutrition, Supplements)
  static const List<Color> vitalityGradient = [
    Color(0xFFFFD54F), // Light gold
    Color(0xFFFFC107), // Primary amber
    Color(0xFFFF8F00), // Deep orange
  ];
  
  // Heart Red (Cardio, Love, Care)
  static const List<Color> heartGradient = [
    Color(0xFFFF8A80), // Soft pink-red
    Color(0xFFE91E63), // Vibrant pink
    Color(0xFFC2185B), // Deep rose
  ];
  
  // Nature Green (Organic, Natural, Fresh)
  static const List<Color> natureGradient = [
    Color(0xFFA5D6A7), // Light green
    Color(0xFF66BB6A), // Fresh green
    Color(0xFF2E7D32), // Forest green
  ];
  
  // Sky Blue (Freedom, Breath, Oxygen)
  static const List<Color> skyGradient = [
    Color(0xFF81D4FA), // Light sky
    Color(0xFF03A9F4), // Sky blue
    Color(0xFF0277BD), // Deep sky
  ];
  
  // Sunset Pink (Warmth, Comfort, Care)
  static const List<Color> sunsetGradient = [
    Color(0xFFFFCDD2), // Soft pink
    Color(0xFFFF7043), // Sunset orange
    Color(0xFFD84315), // Deep sunset
  ];
  
  // Responsive breakpoints
  static const double mobileMaxWidth = 480;
  static const double tabletMaxWidth = 1024;
  static const double desktopMinWidth = 1025;
  
  // PREMIUM: Advanced Colored Shadow System
  
  // Subtle card shadows with health-themed color tints
  static const List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: Color.fromRGBO(0, 188, 212, 0.15), // Teal tint
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Color.fromRGBO(0, 188, 212, 0.25), // Stronger teal tint for dark mode
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.3),
      offset: Offset(0, 3),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  // Premium elevated shadows with gradient-like color transitions
  static const List<BoxShadow> elevatedShadowLight = [
    BoxShadow(
      color: Color.fromRGBO(0, 188, 212, 0.2), // Primary teal
      offset: Offset(0, 8),
      blurRadius: 20,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 150, 136, 0.1), // Secondary teal
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.06),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> elevatedShadowDark = [
    BoxShadow(
      color: Color.fromRGBO(41, 182, 246, 0.3), // Brighter blue for dark mode
      offset: Offset(0, 12),
      blurRadius: 24,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 188, 212, 0.2),
      offset: Offset(0, 6),
      blurRadius: 16,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.4),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // NEW: Context-Specific Colored Shadows
  
  // Success shadows (Green tints)
  static const List<BoxShadow> successShadowLight = [
    BoxShadow(
      color: Color.fromRGBO(76, 175, 80, 0.2),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(46, 125, 50, 0.1),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> successShadowDark = [
    BoxShadow(
      color: Color.fromRGBO(105, 240, 174, 0.25),
      offset: Offset(0, 6),
      blurRadius: 20,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 230, 118, 0.15),
      offset: Offset(0, 3),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // Warning shadows (Orange tints)
  static const List<BoxShadow> warningShadowLight = [
    BoxShadow(
      color: Color.fromRGBO(255, 152, 0, 0.2),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(230, 81, 0, 0.1),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> warningShadowDark = [
    BoxShadow(
      color: Color.fromRGBO(255, 183, 77, 0.25),
      offset: Offset(0, 6),
      blurRadius: 20,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color.fromRGBO(255, 152, 0, 0.15),
      offset: Offset(0, 3),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // Error shadows (Coral/Red tints)
  static const List<BoxShadow> errorShadowLight = [
    BoxShadow(
      color: Color.fromRGBO(255, 87, 34, 0.2),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(216, 67, 21, 0.1),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> errorShadowDark = [
    BoxShadow(
      color: Color.fromRGBO(255, 138, 128, 0.25),
      offset: Offset(0, 6),
      blurRadius: 20,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color.fromRGBO(255, 87, 34, 0.15),
      offset: Offset(0, 3),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // Heart/Cardio shadows (Pink tints)
  static const List<BoxShadow> heartShadowLight = [
    BoxShadow(
      color: Color.fromRGBO(233, 30, 99, 0.2),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(194, 24, 91, 0.1),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> heartShadowDark = [
    BoxShadow(
      color: Color.fromRGBO(255, 138, 128, 0.25),
      offset: Offset(0, 6),
      blurRadius: 20,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color.fromRGBO(233, 30, 99, 0.15),
      offset: Offset(0, 3),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // Wellness/Purple shadows
  static const List<BoxShadow> wellnessShadowLight = [
    BoxShadow(
      color: Color.fromRGBO(156, 39, 176, 0.2),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color.fromRGBO(106, 27, 154, 0.1),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> wellnessShadowDark = [
    BoxShadow(
      color: Color.fromRGBO(179, 157, 219, 0.25),
      offset: Offset(0, 6),
      blurRadius: 20,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color.fromRGBO(156, 39, 176, 0.15),
      offset: Offset(0, 3),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  // Enhanced Gradient Decorations with Premium Effects
  static LinearGradient getPrimaryGradient(bool isDark, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: isDark ? primaryGradientDark : primaryGradientLight,
    );
  }
  
  static LinearGradient getSuccessGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: successGradient,
    );
  }
  
  static LinearGradient getWarningGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: warningGradient,
    );
  }
  
  static LinearGradient getErrorGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: errorGradient,
    );
  }

  // NEW: Health-Themed Gradient Getters
  static LinearGradient getWellnessGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: wellnessGradient,
    );
  }
  
  static LinearGradient getVitalityGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: vitalityGradient,
    );
  }
  
  static LinearGradient getHeartGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: heartGradient,
    );
  }
  
  static LinearGradient getNatureGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: natureGradient,
    );
  }
  
  static LinearGradient getSkyGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: skyGradient,
    );
  }
  
  static LinearGradient getSunsetGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: sunsetGradient,
    );
  }

  // Dynamic Health Context-Based Gradients
  static LinearGradient getHealthContextGradient(String context, {bool isDark = false}) {
    switch (context.toLowerCase()) {
      case 'medication':
      case 'pharmacy':
        return getVitalityGradient();
      case 'cardio':
      case 'heart':
      case 'blood_pressure':
        return getHeartGradient();
      case 'mental_health':
      case 'therapy':
      case 'meditation':
        return getWellnessGradient();
      case 'nutrition':
      case 'diet':
      case 'organic':
        return getNatureGradient();
      case 'exercise':
      case 'fitness':
      case 'yoga':
        return getSkyGradient();
      case 'appointment':
      case 'reminder':
        return getSunsetGradient();
      case 'emergency':
      case 'urgent':
        return getErrorGradient();
      case 'success':
      case 'completed':
      case 'healthy':
        return getSuccessGradient();
      case 'warning':
      case 'overdue':
        return getWarningGradient();
      default:
        return getPrimaryGradient(isDark);
    }
  }

  // PREMIUM: Advanced Multi-Stop Gradients with Depth Effects
  
  // Depth-Enhanced Primary Gradient (5-stop)
  static LinearGradient getPremiumPrimaryGradient(bool isDark, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      colors: isDark 
        ? [
            const Color(0xFF6DD5FA), // Bright cyan
            const Color(0xFF4FC3F7), // Light blue
            const Color(0xFF29B6F6), // Sky blue
            const Color(0xFF1E88E5), // Medium blue
            const Color(0xFF0288D1), // Deep ocean
          ]
        : [
            const Color(0xFF00E5FF), // Electric cyan
            const Color(0xFF00D4FF), // Bright cyan
            const Color(0xFF00BCD4), // Primary teal
            const Color(0xFF00ACC1), // Medium teal
            const Color(0xFF0097A7), // Deep teal
          ],
    );
  }

  // Aurora Success Gradient (Magical Green)
  static LinearGradient getAuroraSuccessGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      stops: const [0.0, 0.3, 0.6, 1.0],
      colors: const [
        Color(0xFF69F0AE), // Bright mint
        Color(0xFF00E676), // Vibrant green
        Color(0xFF00E676), // Vibrant green (emphasis)
        Color(0xFF00C853), // Deep emerald
      ],
    );
  }

  // Sunset Fire Gradient (Warm Energy)
  static LinearGradient getSunsetFireGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      stops: const [0.0, 0.35, 0.7, 1.0],
      colors: const [
        Color(0xFFFFD54F), // Light gold
        Color(0xFFFFB74D), // Warm orange
        Color(0xFFFF9800), // Primary orange
        Color(0xFFE65100), // Deep amber
      ],
    );
  }

  // Ocean Depth Gradient (Deep Blue Mystery)
  static LinearGradient getOceanDepthGradient({
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      stops: const [0.0, 0.4, 0.8, 1.0],
      colors: const [
        Color(0xFF81D4FA), // Surface blue
        Color(0xFF03A9F4), // Sky blue
        Color(0xFF0277BD), // Deep sky
        Color(0xFF01579B), // Ocean depths
      ],
    );
  }

  // Rose Dawn Gradient (Gentle Pink to Coral)
  static LinearGradient getRoseDawnGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      stops: const [0.0, 0.4, 0.8, 1.0],
      colors: const [
        Color(0xFFFFCDD2), // Soft pink
        Color(0xFFFF8A80), // Light coral
        Color(0xFFFF7043), // Warm coral
        Color(0xFFD84315), // Deep sunset
      ],
    );
  }

  // Purple Mystique Gradient (Wellness & Calm)
  static LinearGradient getPurpleMystiqueGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      stops: const [0.0, 0.3, 0.7, 1.0],
      colors: const [
        Color(0xFFE1BEE7), // Very light purple
        Color(0xFFB39DDB), // Light purple
        Color(0xFF9C27B0), // Medium purple
        Color(0xFF6A1B9A), // Deep purple
      ],
    );
  }

  // Shimmer Effect Gradients (For loading states)
  static LinearGradient getShimmerGradient({
    Color baseColor = const Color(0xFFE0E0E0),
    Color highlightColor = const Color(0xFFF5F5F5),
  }) {
    return LinearGradient(
      begin: const Alignment(-1.0, -0.3),
      end: const Alignment(1.0, 0.3),
      stops: const [0.0, 0.4, 0.6, 1.0],
      colors: [
        baseColor,
        baseColor,
        highlightColor,
        baseColor,
      ],
    );
  }

  // Glassmorphism Background Gradient
  static LinearGradient getGlassmorphismGradient({
    Color primaryColor = const Color(0xFF00BCD4),
    double opacity = 0.1,
  }) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0.0, 0.5, 1.0],
      colors: [
        primaryColor.withValues(alpha: opacity),
        primaryColor.withValues(alpha: opacity * 0.6),
        primaryColor.withValues(alpha: opacity * 0.3),
      ],
    );
  }

  // Animated Gradient Helper (for dynamic effects)
  static LinearGradient getAnimatedGradient(double animationValue, List<Color> colors) {
    final rotatedColors = List<Color>.from(colors);
    final shift = (animationValue * colors.length).floor();
    for (int i = 0; i < shift; i++) {
      rotatedColors.add(rotatedColors.removeAt(0));
    }
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: rotatedColors,
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
  
  // PREMIUM: Advanced Shadow Utility Methods
  static List<BoxShadow> getCardShadow(bool isDarkMode) {
    return isDarkMode ? cardShadowDark : cardShadowLight;
  }
  
  static List<BoxShadow> getElevatedShadow(bool isDarkMode) {
    return isDarkMode ? elevatedShadowDark : elevatedShadowLight;
  }
  
  // Context-specific shadow getters
  static List<BoxShadow> getSuccessShadow(bool isDarkMode) {
    return isDarkMode ? successShadowDark : successShadowLight;
  }
  
  static List<BoxShadow> getWarningShadow(bool isDarkMode) {
    return isDarkMode ? warningShadowDark : warningShadowLight;
  }
  
  static List<BoxShadow> getErrorShadow(bool isDarkMode) {
    return isDarkMode ? errorShadowDark : errorShadowLight;
  }
  
  static List<BoxShadow> getHeartShadow(bool isDarkMode) {
    return isDarkMode ? heartShadowDark : heartShadowLight;
  }
  
  static List<BoxShadow> getWellnessShadow(bool isDarkMode) {
    return isDarkMode ? wellnessShadowDark : wellnessShadowLight;
  }

  // Dynamic Health Context-Based Shadows
  static List<BoxShadow> getHealthContextShadow(String context, bool isDarkMode) {
    switch (context.toLowerCase()) {
      case 'medication':
      case 'pharmacy':
      case 'vitality':
        return getWarningShadow(isDarkMode); // Golden/amber shadows
      case 'cardio':
      case 'heart':
      case 'blood_pressure':
        return getHeartShadow(isDarkMode);
      case 'mental_health':
      case 'therapy':
      case 'meditation':
      case 'wellness':
        return getWellnessShadow(isDarkMode);
      case 'success':
      case 'completed':
      case 'healthy':
      case 'nutrition':
        return getSuccessShadow(isDarkMode);
      case 'warning':
      case 'overdue':
      case 'reminder':
        return getWarningShadow(isDarkMode);
      case 'error':
      case 'emergency':
      case 'urgent':
        return getErrorShadow(isDarkMode);
      default:
        return getCardShadow(isDarkMode);
    }
  }

  // Custom shadow builder for specific colors
  static List<BoxShadow> createColoredShadow(Color primaryColor, bool isDarkMode, {
    double intensity = 0.2,
    double blur = 16.0,
    Offset offset = const Offset(0, 4),
  }) {
    return [
      BoxShadow(
        color: primaryColor.withValues(alpha: intensity),
        offset: offset,
        blurRadius: blur,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: isDarkMode 
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.08),
        offset: Offset(offset.dx, offset.dy / 2),
        blurRadius: blur / 2,
        spreadRadius: 0,
      ),
    ];
  }

  // Floating/Levitation shadows for premium cards
  static List<BoxShadow> getFloatingShadow(bool isDarkMode, {double elevation = 16.0}) {
    final intensity = isDarkMode ? 0.4 : 0.25;
    return [
      BoxShadow(
        color: const Color(0xFF00BCD4).withValues(alpha: intensity), // Primary teal glow
        offset: Offset(0, elevation),
        blurRadius: elevation * 2,
        spreadRadius: -elevation / 4,
      ),
      BoxShadow(
        color: isDarkMode 
            ? Colors.black.withValues(alpha: 0.6)
            : Colors.black.withValues(alpha: 0.15),
        offset: Offset(0, elevation / 2),
        blurRadius: elevation,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: isDarkMode 
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.08),
        offset: const Offset(0, 2),
        blurRadius: 6,
        spreadRadius: 0,
      ),
    ];
  }

  // Inner glow effect (inset-like shadow simulation)
  static List<BoxShadow> getInnerGlow(Color glowColor, {double intensity = 0.1}) {
    return [
      BoxShadow(
        color: glowColor.withValues(alpha: intensity),
        offset: const Offset(0, 1),
        blurRadius: 3,
        spreadRadius: -1,
      ),
      BoxShadow(
        color: glowColor.withValues(alpha: intensity * 0.5),
        offset: const Offset(0, -1),
        blurRadius: 2,
        spreadRadius: -1,
      ),
    ];
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

  // PREMIUM: Advanced Typography System
  
  // Responsive font scale multipliers
  static double getFontScaleMultiplier(BuildContext context) {
    if (isMobile(context)) {
      return 1.0;
    } else if (isTablet(context)) {
      return 1.1;
    } else {
      return 1.2;
    }
  }

  // Golden ratio-based font sizes for better hierarchy
  static const double _goldenRatio = 1.618;
  static const double _baseFontSize = 16.0;

  // Premium font size scale (based on golden ratio)
  static double get fontSizeXXS => _baseFontSize * 0.618; // ~10px
  static double get fontSizeXS => _baseFontSize * 0.764; // ~12px
  static double get fontSizeSM => _baseFontSize * 0.875; // ~14px
  static double get fontSizeBase => _baseFontSize; // 16px
  static double get fontSizeLG => _baseFontSize * _goldenRatio * 0.618; // ~18px
  static double get fontSizeXL => _baseFontSize * _goldenRatio; // ~26px
  static double get fontSize2XL => _baseFontSize * _goldenRatio * 1.382; // ~36px
  static double get fontSize3XL => _baseFontSize * _goldenRatio * _goldenRatio; // ~42px
  static double get fontSize4XL => _baseFontSize * _goldenRatio * _goldenRatio * 1.236; // ~52px

  // Responsive font size getter
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    return baseFontSize * getFontScaleMultiplier(context);
  }

  // Premium Typography Styles
  static TextStyle getDisplayLarge(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize4XL),
      fontWeight: FontWeight.w800,
      height: 1.1,
      letterSpacing: -0.5,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle getDisplayMedium(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize3XL),
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.25,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle getDisplaySmall(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize2XL),
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: 0,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle getHeadlineLarge(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize2XL),
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: -0.25,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle getHeadlineMedium(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSizeXL),
      fontWeight: FontWeight.w600,
      height: 1.35,
      letterSpacing: 0,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle getHeadlineSmall(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSizeLG * 1.2),
      fontWeight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle getTitleLarge(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSizeLG),
      fontWeight: FontWeight.w500,
      height: 1.45,
      letterSpacing: 0,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle getTitleMedium(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSizeBase),
      fontWeight: FontWeight.w500,
      height: 1.5,
      letterSpacing: 0.15,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle getTitleSmall(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSizeSM),
      fontWeight: FontWeight.w500,
      height: 1.5,
      letterSpacing: 0.1,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle getBodyLarge(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSizeBase),
      fontWeight: FontWeight.w400,
      height: 1.6,
      letterSpacing: 0.5,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle getBodyMedium(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSizeSM),
      fontWeight: FontWeight.w400,
      height: 1.6,
      letterSpacing: 0.25,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle getBodySmall(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSizeXS),
      fontWeight: FontWeight.w400,
      height: 1.65,
      letterSpacing: 0.4,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  static TextStyle getLabelLarge(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSizeSM),
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.1,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle getLabelMedium(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSizeXS),
      fontWeight: FontWeight.w500,
      height: 1.35,
      letterSpacing: 0.5,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle getLabelSmall(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSizeXXS),
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0.5,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  // Health Context-Specific Typography
  static TextStyle getHealthMetricText(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize2XL),
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.5,
      fontFeatures: const [FontFeature.tabularFigures()], // Monospaced numbers
      color: theme.colorScheme.primary,
    );
  }

  static TextStyle getMedicationDosageText(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSizeLG),
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: theme.colorScheme.secondary,
    );
  }

  static TextStyle getEmergencyText(BuildContext context, ThemeData theme) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSizeLG),
      fontWeight: FontWeight.w700,
      height: 1.3,
      letterSpacing: 0.5,
      color: theme.colorScheme.error,
    );
  }

  // Gradient text support (for premium headers)
  static TextStyle getGradientTextStyle(BuildContext context, ThemeData theme, {
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? getResponsiveFontSize(context, fontSizeXL),
      fontWeight: fontWeight ?? FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.25,
      foreground: Paint()
        ..shader = AppTheme.getPrimaryGradient(theme.brightness == Brightness.dark)
          .createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
    );
  }

  // Animated text glow effect
  static TextStyle getGlowTextStyle(BuildContext context, ThemeData theme, {
    Color? glowColor,
    double glowRadius = 10.0,
  }) {
    final effectiveGlowColor = glowColor ?? theme.colorScheme.primary;
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSizeXL),
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: theme.colorScheme.onSurface,
      shadows: [
        Shadow(
          color: effectiveGlowColor.withValues(alpha: 0.5),
          offset: const Offset(0, 0),
          blurRadius: glowRadius,
        ),
        Shadow(
          color: effectiveGlowColor.withValues(alpha: 0.3),
          offset: const Offset(0, 0),
          blurRadius: glowRadius * 2,
        ),
      ],
    );
  }

  // Health category text colors
  static Color getHealthCategoryTextColor(String category, ThemeData theme) {
    switch (category.toLowerCase()) {
      case 'medication':
        return const Color(0xFFFFC107); // Amber
      case 'cardio':
      case 'heart':
        return const Color(0xFFE91E63); // Pink
      case 'mental_health':
        return const Color(0xFF9C27B0); // Purple
      case 'nutrition':
        return const Color(0xFF4CAF50); // Green
      case 'emergency':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurface;
    }
  }
}