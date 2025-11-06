import 'package:flutter/material.dart';

/// HealthBox Design System - Comprehensive UI Design Tokens
/// This file defines the complete design system for consistent UI across all screens

class HealthBoxDesignSystem {
  // ============ CORE BRAND COLORS ============

  /// Primary brand color - Medical blue representing trust and professionalism
  static const Color primaryBlue = Color(0xFF2563EB); // Blue-600
  static const Color primaryBlueLight = Color(0xFF3B82F6); // Blue-500
  static const Color primaryBlueDark = Color(0xFF1D4ED8); // Blue-700

  /// Secondary accent colors for variety
  static const Color accentPurple = Color(0xFF8B5CF6); // Purple-500
  static const Color accentGreen = Color(0xFF10B981); // Emerald-500
  static const Color accentOrange = Color(0xFFF97316); // Orange-500
  static const Color accentPink = Color(0xFFEC4899); // Pink-500
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan-500

  /// Success, warning, and error states
  static const Color successColor = Color(0xFF059669); // Emerald-600
  static const Color warningColor = Color(0xFFD97706); // Amber-600
  static const Color errorColor = Color(0xFFDC2626); // Red-600

  // ============ NEUTRAL COLORS ============

  /// Grayscale palette for text and surfaces
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // ============ SEMANTIC COLORS ============

  /// Surface colors with subtle variations
  static const Color surfacePrimary = Colors.white;
  static const Color surfaceSecondary = Color(0xFFFEFEFE);
  static const Color surfaceTertiary = Color(0xFFF8FAFC);

  /// Text colors for different hierarchy levels
  static const Color textPrimary = neutral900;
  static const Color textSecondary = neutral600;
  static const Color textTertiary = neutral500;
  static const Color textDisabled = neutral400;

  // ============ TYPOGRAPHY SCALE ============

  /// Font sizes for text hierarchy
  static const double textSizeXs = 12.0;
  static const double textSizeSm = 14.0;
  static const double textSizeBase = 16.0;
  static const double textSizeLg = 18.0;
  static const double textSizeXl = 20.0;
  static const double textSize2xl = 24.0;
  static const double textSize3xl = 30.0;
  static const double textSize4xl = 36.0;

  /// Line heights for better readability
  static const double lineHeightTight = 1.25;
  static const double lineHeightSnug = 1.375;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.625;
  static const double lineHeightLoose = 2.0;

  /// Font weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;

  // ============ SPACING SYSTEM ============

  /// Consistent spacing scale (multiplied by 4px base unit)
  static const double spacing1 = 4.0; // 4px
  static const double spacing2 = 8.0; // 8px
  static const double spacing3 = 12.0; // 12px
  static const double spacing4 = 16.0; // 16px
  static const double spacing5 = 20.0; // 20px
  static const double spacing6 = 24.0; // 24px
  static const double spacing8 = 32.0; // 32px
  static const double spacing10 = 40.0; // 40px
  static const double spacing12 = 48.0; // 48px
  static const double spacing16 = 64.0; // 64px
  static const double spacing20 = 80.0; // 80px
  static const double spacing24 = 96.0; // 96px

  // ============ BORDER RADIUS SCALE ============

  static const double radiusNone = 0.0;
  static const double radiusSm = 4.0;
  static const double radiusBase = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 24.0;
  static const double radius3xl = 28.0;
  static const double radiusFull = 9999.0;

  // ============ SHADOW SYSTEM ============

  /// Elevation-based shadows for different UI elements
  static const List<BoxShadow> shadowNone = [];

  static const List<BoxShadow> shadowXs = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0F000000), // 6% opacity
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowBase = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 25),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 10),
      blurRadius: 10,
      spreadRadius: -5,
    ),
  ];

  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 25),
      blurRadius: 50,
      spreadRadius: -12,
    ),
  ];

  // ============ ANIMATION TOKENS ============

  /// Animation duration tokens
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationBase = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);
  static const Duration durationSlower = Duration(milliseconds: 500);

  /// Animation easing curves
  static const Curve curveLinear = Curves.linear;
  static const Curve curveEase = Curves.ease;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveBounce = Curves.bounceOut;
  static const Curve curveElastic = Curves.elasticOut;

  // ============ COMPONENT TOKENS ============

  /// Button heights
  static const double buttonHeightSm = 32.0;
  static const double buttonHeightBase = 40.0;
  static const double buttonHeightLg = 48.0;

  /// Input field heights
  static const double inputHeightSm = 32.0;
  static const double inputHeightBase = 40.0;
  static const double inputHeightLg = 48.0;

  /// Card padding
  static const EdgeInsets cardPaddingSm = EdgeInsets.all(spacing3);
  static const EdgeInsets cardPaddingBase = EdgeInsets.all(spacing4);
  static const EdgeInsets cardPaddingLg = EdgeInsets.all(spacing6);

  // ============ BREAKPOINTS ============

  static const double breakpointSm = 640.0;
  static const double breakpointMd = 768.0;
  static const double breakpointLg = 1024.0;
  static const double breakpointXl = 1280.0;
  static const double breakpoint2xl = 1536.0;

  // ============ Z-INDEX SCALE ============

  static const int zIndexDropdown = 1000;
  static const int zIndexSticky = 1020;
  static const int zIndexFixed = 1030;
  static const int zIndexModalBackdrop = 1040;
  static const int zIndexModal = 1050;
  static const int zIndexPopover = 1060;
  static const int zIndexTooltip = 1070;
  static const int zIndexToast = 1080;

  // ============ GRADIENT SYSTEM ============

  /// Medical-themed gradients for various UI elements

  // Primary Medical Gradients
  static const LinearGradient medicalBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)], // Blue to Cyan
  );

  static const LinearGradient medicalPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)], // Purple to Pink
  );

  static const LinearGradient medicalGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF06B6D4)], // Green to Cyan
  );

  static const LinearGradient medicalOrange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF97316), Color(0xFFFBBF24)], // Orange to Yellow
  );

  static const LinearGradient medicalRed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFF87171)], // Red to Light Red
  );

  // Category-specific gradients
  static const LinearGradient medicationGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)], // Blue → Cyan
  );

  static const LinearGradient prescriptionGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)], // Purple → Light Purple
  );

  static const LinearGradient labReportGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF97316), Color(0xFFFBBF24)], // Orange → Yellow
  );

  static const LinearGradient vaccinationGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF34D399)], // Green → Light Green
  );

  static const LinearGradient allergyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFF87171)], // Red → Light Red
  );

  static const LinearGradient vitalsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)], // Pink → Light Pink
  );

  static const LinearGradient chronicConditionGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], // Indigo → Purple
  );

  static const LinearGradient surgicalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)], // Cyan → Dark Cyan
  );

  static const LinearGradient radiologyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)], // Purple → Indigo
  );

  static const LinearGradient pathologyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)], // Amber → Orange
  );

  static const LinearGradient dentalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)], // Cyan → Blue
  );

  static const LinearGradient mentalHealthGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA78BFA), Color(0xFFC084FC)], // Light Purple → Purple
  );

  // Status gradients
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)], // Emerald
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)], // Red
  );

  static const LinearGradient infoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)], // Blue
  );

  // Background gradients
  static const LinearGradient subtleBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)], // Very subtle
  );

  static const LinearGradient boldBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient meshBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFFF59E0B),
    ],
    stops: [0.0, 0.33, 0.66, 1.0],
  );

  // Specialty gradients
  static const LinearGradient cardiologyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFF87171)], // Red heart theme
  );

  static const LinearGradient neurologyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)], // Purple brain theme
  );

  static const LinearGradient pediatricsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBBF24), Color(0xFFFCD34D)], // Yellow cheerful
  );

  static const LinearGradient geriatricsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6B7280), Color(0xFF9CA3AF)], // Gray wisdom
  );

  // Shimmer gradient for loading states
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
    colors: [
      Color(0xFFE5E7EB),
      Color(0xFFF9FAFB),
      Color(0xFFE5E7EB),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Dark mode gradients
  static const LinearGradient darkMedicalBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E40AF), Color(0xFF0E7490)], // Darker blue to cyan
  );

  static const LinearGradient darkMedicalPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6D28D9), Color(0xFF9333EA)], // Darker purple
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)], // Dark slate
  );

  // ============ ENHANCED SHADOW SYSTEM ============

  /// Colored shadows for depth and emphasis
  static List<BoxShadow> coloredShadow(Color color, {double opacity = 0.3}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        offset: const Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: color.withValues(alpha: opacity * 0.5),
        offset: const Offset(0, 2),
        blurRadius: 6,
        spreadRadius: 0,
      ),
    ];
  }

  /// Glow effects for emphasis
  static List<BoxShadow> glowEffect(Color color, {double intensity = 0.5}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: intensity * 0.6),
        offset: const Offset(0, 0),
        blurRadius: 20,
        spreadRadius: 5,
      ),
      BoxShadow(
        color: color.withValues(alpha: intensity * 0.4),
        offset: const Offset(0, 0),
        blurRadius: 40,
        spreadRadius: 10,
      ),
    ];
  }

  /// Soft glow for subtle emphasis
  static List<BoxShadow> softGlow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.2),
        offset: const Offset(0, 0),
        blurRadius: 15,
        spreadRadius: 3,
      ),
    ];
  }

  /// Strong glow for high emphasis
  static List<BoxShadow> strongGlow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.8),
        offset: const Offset(0, 0),
        blurRadius: 30,
        spreadRadius: 8,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.4),
        offset: const Offset(0, 0),
        blurRadius: 60,
        spreadRadius: 15,
      ),
    ];
  }

  /// Layered shadows for maximum depth
  static List<BoxShadow> layeredShadow = [
    const BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x16000000),
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: -1,
    ),
    const BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
  ];

  /// Inner shadow effect (using borders + shadow trick)
  static BoxDecoration innerShadowDecoration(Color shadowColor) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radiusMd),
      boxShadow: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.1),
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: -2,
        ),
      ],
    );
  }

  // ============ GRADIENT HELPER METHODS ============

  /// Get gradient for medical record type
  static LinearGradient getRecordTypeGradient(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'medication':
        return medicationGradient;
      case 'prescription':
        return prescriptionGradient;
      case 'lab_report':
      case 'lab report':
        return labReportGradient;
      case 'vaccination':
        return vaccinationGradient;
      case 'allergy':
        return allergyGradient;
      case 'chronic_condition':
      case 'chronic condition':
        return chronicConditionGradient;
      case 'surgical_record':
      case 'surgical record':
        return surgicalGradient;
      case 'radiology_record':
      case 'radiology record':
        return radiologyGradient;
      case 'pathology_record':
      case 'pathology record':
        return pathologyGradient;
      case 'dental_record':
      case 'dental record':
        return dentalGradient;
      case 'mental_health_record':
      case 'mental health record':
        return mentalHealthGradient;
      default:
        return medicalBlue;
    }
  }

  /// Get colored shadow for record type
  static List<BoxShadow> getRecordTypeShadow(String recordType) {
    final gradient = getRecordTypeGradient(recordType);
    final color = gradient.colors.first;
    return coloredShadow(color);
  }
}

// ============ THEME EXTENSIONS ============

/// Extension methods for theme access
extension HealthBoxThemeExtension on BuildContext {
  /// Access the design system colors
  Color get primaryColor => HealthBoxDesignSystem.primaryBlue;
  Color get primaryLight => HealthBoxDesignSystem.primaryBlueLight;
  Color get primaryDark => HealthBoxDesignSystem.primaryBlueDark;

  /// Access semantic colors
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get surfaceVariant =>
      Theme.of(this).colorScheme.surfaceContainerHighest;
  Color get onSurface => Theme.of(this).colorScheme.onSurface;
  Color get onSurfaceVariant => Theme.of(this).colorScheme.onSurfaceVariant;

  /// Access text colors
  Color get textPrimary => HealthBoxDesignSystem.textPrimary;
  Color get textSecondary => HealthBoxDesignSystem.textSecondary;
  Color get textTertiary => HealthBoxDesignSystem.textTertiary;

  /// Access spacing
  double get spacing1 => HealthBoxDesignSystem.spacing1;
  double get spacing2 => HealthBoxDesignSystem.spacing2;
  double get spacing3 => HealthBoxDesignSystem.spacing3;
  double get spacing4 => HealthBoxDesignSystem.spacing4;
  double get spacing6 => HealthBoxDesignSystem.spacing6;
  double get spacing8 => HealthBoxDesignSystem.spacing8;

  /// Access radius
  double get radiusSm => HealthBoxDesignSystem.radiusSm;
  double get radiusBase => HealthBoxDesignSystem.radiusBase;
  double get radiusMd => HealthBoxDesignSystem.radiusMd;
  double get radiusLg => HealthBoxDesignSystem.radiusLg;
  double get radiusXl => HealthBoxDesignSystem.radiusXl;
}

/// Utility class for consistent styling
class HealthBoxStyle {
  /// Get consistent text style with design system
  static TextStyle getTextStyle({
    required BuildContext context,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium!.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight ?? HealthBoxDesignSystem.fontWeightNormal,
      color: color ?? theme.colorScheme.onSurface,
      height: height ?? HealthBoxDesignSystem.lineHeightNormal,
    );
  }

  /// Get consistent card decoration
  static BoxDecoration getCardDecoration({
    required BuildContext context,
    bool elevated = false,
    Color? backgroundColor,
    BorderRadius? borderRadius,
  }) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: backgroundColor ?? theme.colorScheme.surface,
      borderRadius:
          borderRadius ?? BorderRadius.circular(HealthBoxDesignSystem.radiusMd),
      boxShadow: elevated
          ? HealthBoxDesignSystem.shadowBase
          : HealthBoxDesignSystem.shadowNone,
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
        width: 0.5,
      ),
    );
  }

  /// Get consistent button style
  static ButtonStyle getButtonStyle({
    required BuildContext context,
    ButtonType type = ButtonType.primary,
    ButtonSize size = ButtonSize.medium,
    bool isDisabled = false,
  }) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color foregroundColor;

    switch (type) {
      case ButtonType.primary:
        backgroundColor = HealthBoxDesignSystem.primaryBlue;
        foregroundColor = Colors.white;
        break;
      case ButtonType.secondary:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        foregroundColor = theme.colorScheme.onSurfaceVariant;
        break;
      case ButtonType.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = HealthBoxDesignSystem.primaryBlue;
        break;
      case ButtonType.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = theme.colorScheme.onSurface;
        break;
    }

    if (isDisabled) {
      backgroundColor = backgroundColor.withValues(alpha: 0.5);
      foregroundColor = foregroundColor.withValues(alpha: 0.5);
    }

    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      minimumSize: Size(0, size.height),
      padding: size.padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
        side: type == ButtonType.outline
            ? BorderSide(color: backgroundColor, width: 1)
            : BorderSide.none,
      ),
    );
  }
}

/// Button type enumeration
enum ButtonType { primary, secondary, outline, ghost }

/// Button size enumeration
enum ButtonSize {
  small(
    HealthBoxDesignSystem.buttonHeightSm,
    EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),
  medium(
    HealthBoxDesignSystem.buttonHeightBase,
    EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  ),
  large(
    HealthBoxDesignSystem.buttonHeightLg,
    EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  );

  const ButtonSize(this.height, this.padding);
  final double height;
  final EdgeInsets padding;
}

// ============================================================================
// NEW MATERIAL 3 TOKEN CLASSES (Standardized Naming)
// These provide a cleaner API while maintaining backwards compatibility
// ============================================================================

/// Simplified color tokens class (Material 3 naming convention)
class AppColors {
  // Primary colors
  static const Color primary = HealthBoxDesignSystem.primaryBlue;
  static const Color primaryLight = HealthBoxDesignSystem.primaryBlueLight;
  static const Color primaryDark = HealthBoxDesignSystem.primaryBlueDark;

  // Secondary colors
  static const Color secondary = HealthBoxDesignSystem.accentCyan;
  static const Color tertiary = HealthBoxDesignSystem.accentPurple;

  // Semantic colors
  static const Color success = HealthBoxDesignSystem.successColor;
  static const Color warning = HealthBoxDesignSystem.warningColor;
  static const Color error = HealthBoxDesignSystem.errorColor;
  static const Color info = HealthBoxDesignSystem.primaryBlue;

  // Neutral scale
  static const Color neutral50 = HealthBoxDesignSystem.neutral50;
  static const Color neutral100 = HealthBoxDesignSystem.neutral100;
  static const Color neutral200 = HealthBoxDesignSystem.neutral200;
  static const Color neutral300 = HealthBoxDesignSystem.neutral300;
  static const Color neutral400 = HealthBoxDesignSystem.neutral400;
  static const Color neutral500 = HealthBoxDesignSystem.neutral500;
  static const Color neutral600 = HealthBoxDesignSystem.neutral600;
  static const Color neutral700 = HealthBoxDesignSystem.neutral700;
  static const Color neutral800 = HealthBoxDesignSystem.neutral800;
  static const Color neutral900 = HealthBoxDesignSystem.neutral900;

  // Gradients
  static const LinearGradient primaryGradient = HealthBoxDesignSystem.medicalBlue;
  static const LinearGradient primaryGradientDark = HealthBoxDesignSystem.darkMedicalBlue;
  static const LinearGradient successGradient = HealthBoxDesignSystem.successGradient;
  static const LinearGradient errorGradient = HealthBoxDesignSystem.errorGradient;
  static const LinearGradient warningGradient = HealthBoxDesignSystem.warningGradient;
}

/// Typography tokens class
class AppTypography {
  static const double fontSizeXs = HealthBoxDesignSystem.textSizeXs;
  static const double fontSizeSm = HealthBoxDesignSystem.textSizeSm;
  static const double fontSizeBase = HealthBoxDesignSystem.textSizeBase;
  static const double fontSizeLg = HealthBoxDesignSystem.textSizeLg;
  static const double fontSizeXl = HealthBoxDesignSystem.textSizeXl;
  static const double fontSize2xl = HealthBoxDesignSystem.textSize2xl;
  static const double fontSize3xl = HealthBoxDesignSystem.textSize3xl;
  static const double fontSize4xl = HealthBoxDesignSystem.textSize4xl;

  static const FontWeight fontWeightLight = HealthBoxDesignSystem.fontWeightLight;
  static const FontWeight fontWeightNormal = HealthBoxDesignSystem.fontWeightNormal;
  static const FontWeight fontWeightMedium = HealthBoxDesignSystem.fontWeightMedium;
  static const FontWeight fontWeightSemiBold = HealthBoxDesignSystem.fontWeightSemiBold;
  static const FontWeight fontWeightBold = HealthBoxDesignSystem.fontWeightBold;

  static const double lineHeightTight = HealthBoxDesignSystem.lineHeightTight;
  static const double lineHeightSnug = HealthBoxDesignSystem.lineHeightSnug;
  static const double lineHeightNormal = HealthBoxDesignSystem.lineHeightNormal;
  static const double lineHeightRelaxed = HealthBoxDesignSystem.lineHeightRelaxed;
  static const double lineHeightLoose = HealthBoxDesignSystem.lineHeightLoose;
}

/// Spacing tokens class (4px grid)
class AppSpacing {
  static const double none = 0.0;
  static const double xs = HealthBoxDesignSystem.spacing1;
  static const double sm = HealthBoxDesignSystem.spacing2;
  static const double md = HealthBoxDesignSystem.spacing3;
  static const double base = HealthBoxDesignSystem.spacing4;
  static const double lg = HealthBoxDesignSystem.spacing5;
  static const double xl = HealthBoxDesignSystem.spacing6;
  static const double xl2 = HealthBoxDesignSystem.spacing8;
  static const double xl3 = HealthBoxDesignSystem.spacing10;
  static const double xl4 = HealthBoxDesignSystem.spacing12;
  static const double xl5 = HealthBoxDesignSystem.spacing16;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingBase = EdgeInsets.all(base);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
}

/// Border radius tokens class
class AppRadii {
  static const double none = HealthBoxDesignSystem.radiusNone;
  static const double xs = HealthBoxDesignSystem.radiusSm;
  static const double sm = HealthBoxDesignSystem.radiusBase;
  static const double md = HealthBoxDesignSystem.radiusMd;
  static const double lg = HealthBoxDesignSystem.radiusLg;
  static const double xl = HealthBoxDesignSystem.radiusXl;
  static const double xl2 = HealthBoxDesignSystem.radius2xl;
  static const double xl3 = HealthBoxDesignSystem.radius3xl;
  static const double full = HealthBoxDesignSystem.radiusFull;

  static BorderRadius get radiusXs => BorderRadius.circular(xs);
  static BorderRadius get radiusSm => BorderRadius.circular(sm);
  static BorderRadius get radiusMd => BorderRadius.circular(md);
  static BorderRadius get radiusLg => BorderRadius.circular(lg);
  static BorderRadius get radiusXl => BorderRadius.circular(xl);
  static BorderRadius get radiusXl2 => BorderRadius.circular(xl2);
  static BorderRadius get radiusXl3 => BorderRadius.circular(xl3);
  static BorderRadius get radiusFull => BorderRadius.circular(full);
}

/// Elevation tokens class
class AppElevation {
  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 2.0;
  static const double level3 = 4.0;
  static const double level4 = 6.0;
  static const double level5 = 12.0;

  static List<BoxShadow> shadow(double elevation, {bool isDark = false}) {
    if (elevation == 0) return [];
    final opacity = isDark ? 0.4 : 0.1;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: opacity),
        offset: Offset(0, elevation / 2),
        blurRadius: elevation * 2,
        spreadRadius: elevation / 4,
      ),
    ];
  }

  static List<BoxShadow> coloredShadow(Color color, {double opacity = 0.3}) {
    return HealthBoxDesignSystem.coloredShadow(color, opacity: opacity);
  }
}

/// Animation duration tokens
class AppDurations {
  static const Duration instant = Duration(milliseconds: 50);
  static const Duration fast = HealthBoxDesignSystem.durationFast;
  static const Duration normal = HealthBoxDesignSystem.durationBase;
  static const Duration slow = HealthBoxDesignSystem.durationSlow;
  static const Duration slower = HealthBoxDesignSystem.durationSlower;

  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve spring = Curves.elasticOut;
}

/// Responsive breakpoints
class AppBreakpoints {
  static const double phone = 600.0;
  static const double tablet = 1024.0;
  static const double desktop = 1440.0;

  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < phone;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= phone && width < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;

  static double responsivePadding(BuildContext context) {
    if (isPhone(context)) return AppSpacing.base;
    if (isTablet(context)) return AppSpacing.xl;
    return AppSpacing.xl2;
  }

  static double responsiveRadius(BuildContext context) {
    if (isPhone(context)) return AppRadii.md;
    if (isTablet(context)) return AppRadii.lg;
    return AppRadii.xl;
  }
}

/// Component size tokens
class AppSizes {
  static const double buttonSm = HealthBoxDesignSystem.buttonHeightSm;
  static const double buttonMd = HealthBoxDesignSystem.buttonHeightBase;
  static const double buttonLg = HealthBoxDesignSystem.buttonHeightLg;

  static const double inputSm = HealthBoxDesignSystem.inputHeightSm;
  static const double inputMd = HealthBoxDesignSystem.inputHeightBase;
  static const double inputLg = HealthBoxDesignSystem.inputHeightLg;

  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 80.0;

  static const double appBarHeight = 64.0;
  static const double appBarCollapsedHeight = 56.0;
  static const double bottomNavHeight = 80.0;
  static const double minTouchTarget = 48.0;
}

// ============================================================================
// ENHANCED CONTEXT EXTENSIONS
// ============================================================================

extension BuildContextExtensions on BuildContext {
  // Theme access
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Responsive helpers
  bool get isPhone => AppBreakpoints.isPhone(this);
  bool get isTablet => AppBreakpoints.isTablet(this);
  bool get isDesktop => AppBreakpoints.isDesktop(this);

  double get responsivePadding => AppBreakpoints.responsivePadding(this);
  double get responsiveRadius => AppBreakpoints.responsiveRadius(this);

  // Screen dimensions
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
}

// ============================================================================
// COLOR SCHEME EXTENSIONS
// ============================================================================

extension ColorSchemeExtensions on ColorScheme {
  // Semantic colors
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
  Color get info => AppColors.info;

  // Neutral colors
  Color get neutral => AppColors.neutral500;
  Color get neutralLight => AppColors.neutral300;
  Color get neutralDark => AppColors.neutral700;
}

// ============================================================================
// RECORD TYPE UTILITIES
// ============================================================================

class RecordTypeUtils {
  static Color getColor(String recordType) {
    final colors = <String, Color>{
      'medication': HealthBoxDesignSystem.primaryBlue,
      'prescription': HealthBoxDesignSystem.accentPurple,
      'lab_report': HealthBoxDesignSystem.accentOrange,
      'vaccination': HealthBoxDesignSystem.accentGreen,
      'allergy': HealthBoxDesignSystem.errorColor,
      'chronic_condition': const Color(0xFF6366F1),
      'surgical_record': HealthBoxDesignSystem.accentCyan,
      'radiology_record': HealthBoxDesignSystem.accentPurple,
      'pathology_record': const Color(0xFFF97316),
      'discharge_summary': HealthBoxDesignSystem.primaryBlue,
      'hospital_admission': const Color(0xFF14B8A6),
      'dental_record': HealthBoxDesignSystem.accentCyan,
      'mental_health_record': const Color(0xFFA78BFA),
      'general_record': HealthBoxDesignSystem.neutral500,
    };
    return colors[recordType] ?? AppColors.neutral500;
  }

  static IconData getIcon(String recordType) {
    const icons = <String, IconData>{
      'medication': Icons.medication_rounded,
      'prescription': Icons.receipt_rounded,
      'lab_report': Icons.science_rounded,
      'vaccination': Icons.vaccines_rounded,
      'allergy': Icons.warning_amber_rounded,
      'chronic_condition': Icons.favorite_rounded,
      'surgical_record': Icons.medical_services_rounded,
      'radiology_record': Icons.camera_alt_rounded,
      'pathology_record': Icons.biotech_rounded,
      'discharge_summary': Icons.description_rounded,
      'hospital_admission': Icons.local_hospital_rounded,
      'dental_record': Icons.medication_liquid_rounded,
      'mental_health_record': Icons.psychology_rounded,
      'general_record': Icons.note_add_rounded,
    };
    return icons[recordType] ?? Icons.folder_rounded;
  }

  static LinearGradient getGradient(String recordType) {
    return HealthBoxDesignSystem.getRecordTypeGradient(recordType);
  }

  static List<BoxShadow> getShadow(String recordType) {
    return HealthBoxDesignSystem.getRecordTypeShadow(recordType);
  }
}
