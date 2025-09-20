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
