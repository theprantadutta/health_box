import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// ============================================================================
/// HBCard - Standardized HealthBox Card
/// Material 3 cards with consistent elevation, radius, and interaction
/// ============================================================================

class HBCard extends StatelessWidget {
  const HBCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.elevation = 1,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.gradient,
    this.fullWidth = true,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final Gradient? gradient;
  final bool fullWidth;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final isInteractive = onTap != null || onLongPress != null;

    Widget cardChild = child;

    // Apply padding if specified
    if (padding != null) {
      cardChild = Padding(
        padding: padding!,
        child: cardChild,
      );
    }

    // Build card content
    Widget card = Container(
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: gradient == null
            ? (backgroundColor ?? context.colorScheme.surface)
            : null,
        gradient: gradient,
        borderRadius: AppRadii.radiusMd,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? context.colorScheme.outline,
                width: borderWidth,
              )
            : null,
        boxShadow: gradient != null && elevation > 0
            ? AppElevation.coloredShadow(
                gradient!.colors.first,
                opacity: 0.2,
              )
            : AppElevation.shadow(elevation, isDark: context.isDark),
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: clipBehavior,
        borderRadius: AppRadii.radiusMd,
        child: isInteractive
            ? InkWell(
                onTap: onTap,
                onLongPress: onLongPress,
                borderRadius: AppRadii.radiusMd,
                child: cardChild,
              )
            : cardChild,
      ),
    );

    // Apply margin if specified
    if (margin != null) {
      card = Padding(
        padding: margin!,
        child: card,
      );
    }

    return card;
  }

  // ============================================================================
  // Factory Constructors
  // ============================================================================

  /// Standard card with default elevation
  factory HBCard.standard({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return HBCard(
      key: key,
      onTap: onTap,
      onLongPress: onLongPress,
      elevation: AppElevation.level1,
      padding: padding ?? const EdgeInsets.all(AppSpacing.base),
      margin: margin,
      child: child,
    );
  }

  /// Elevated card with higher shadow
  factory HBCard.elevated({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return HBCard(
      key: key,
      onTap: onTap,
      onLongPress: onLongPress,
      elevation: AppElevation.level2,
      padding: padding ?? const EdgeInsets.all(AppSpacing.base),
      margin: margin,
      child: child,
    );
  }

  /// Flat card with no elevation
  factory HBCard.flat({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? borderColor,
  }) {
    return HBCard(
      key: key,
      onTap: onTap,
      onLongPress: onLongPress,
      elevation: AppElevation.level0,
      borderWidth: 1,
      borderColor: borderColor,
      padding: padding ?? const EdgeInsets.all(AppSpacing.base),
      margin: margin,
      child: child,
    );
  }

  /// Gradient card with colored shadow
  factory HBCard.gradient({
    Key? key,
    required Widget child,
    required Gradient gradient,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return HBCard(
      key: key,
      onTap: onTap,
      onLongPress: onLongPress,
      gradient: gradient,
      elevation: AppElevation.level2,
      padding: padding ?? const EdgeInsets.all(AppSpacing.base),
      margin: margin,
      child: child,
    );
  }

  /// Medical record card with type-specific styling
  factory HBCard.record({
    Key? key,
    required Widget child,
    required String recordType,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    bool useGradient = false,
  }) {
    return HBCard(
      key: key,
      onTap: onTap,
      onLongPress: onLongPress,
      gradient: useGradient ? RecordTypeUtils.getGradient(recordType) : null,
      backgroundColor:
          useGradient ? null : RecordTypeUtils.getColor(recordType),
      elevation: AppElevation.level1,
      padding: padding ?? const EdgeInsets.all(AppSpacing.base),
      margin: margin,
      child: child,
    );
  }

  /// Outlined card with border and no elevation
  factory HBCard.outlined({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? borderColor,
    double borderWidth = 1.5,
  }) {
    return HBCard(
      key: key,
      onTap: onTap,
      onLongPress: onLongPress,
      elevation: AppElevation.level0,
      borderColor: borderColor,
      borderWidth: borderWidth,
      padding: padding ?? const EdgeInsets.all(AppSpacing.base),
      margin: margin,
      child: child,
    );
  }
}

/// ============================================================================
/// HBRecordIcon - Icon widget for medical records with gradient background
/// ============================================================================

class HBRecordIcon extends StatelessWidget {
  const HBRecordIcon({
    super.key,
    required this.recordType,
    this.size = 40,
    this.iconSize,
    this.useGradient = true,
  });

  final String recordType;
  final double size;
  final double? iconSize;
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    final icon = RecordTypeUtils.getIcon(recordType);
    final effectiveIconSize = iconSize ?? size * 0.5;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient:
            useGradient ? RecordTypeUtils.getGradient(recordType) : null,
        color: useGradient ? null : RecordTypeUtils.getColor(recordType),
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: useGradient
            ? RecordTypeUtils.getShadow(recordType)
            : null,
      ),
      child: Icon(
        icon,
        size: effectiveIconSize,
        color: Colors.white,
      ),
    );
  }

  /// Small icon (32px)
  factory HBRecordIcon.small({
    Key? key,
    required String recordType,
    bool useGradient = true,
  }) {
    return HBRecordIcon(
      key: key,
      recordType: recordType,
      size: 32,
      useGradient: useGradient,
    );
  }

  /// Medium icon (40px) - default
  factory HBRecordIcon.medium({
    Key? key,
    required String recordType,
    bool useGradient = true,
  }) {
    return HBRecordIcon(
      key: key,
      recordType: recordType,
      size: 40,
      useGradient: useGradient,
    );
  }

  /// Large icon (56px)
  factory HBRecordIcon.large({
    Key? key,
    required String recordType,
    bool useGradient = true,
  }) {
    return HBRecordIcon(
      key: key,
      recordType: recordType,
      size: 56,
      useGradient: useGradient,
    );
  }
}

/// ============================================================================
/// HBDetailRow - Consistent detail row for detail screens
/// ============================================================================

class HBDetailRow extends StatelessWidget {
  const HBDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.isLoading = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppSizes.iconSm,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 3,
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    value,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: valueColor ?? context.colorScheme.onSurface,
                      fontWeight: AppTypography.fontWeightMedium,
                    ),
                    textAlign: TextAlign.end,
                  ),
          ),
        ],
      ),
    );
  }
}
