import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_system.dart';

/// ============================================================================
/// HBButton - Standardized HealthBox Button
/// Material 3 buttons with consistent styling and variants
/// ============================================================================

class HBButton extends StatelessWidget {
  const HBButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = HBButtonVariant.primary,
    this.size = HBButtonSize.medium,
    this.isLoading = false,
    this.enabled = true,
    this.fullWidth = false,
    this.icon,
    this.iconPosition = HBButtonIconPosition.leading,
    this.gradient,
    this.enableHaptics = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final HBButtonVariant variant;
  final HBButtonSize size;
  final bool isLoading;
  final bool enabled;
  final bool fullWidth;
  final IconData? icon;
  final HBButtonIconPosition iconPosition;
  final Gradient? gradient;
  final bool enableHaptics;

  @override
  Widget build(BuildContext context) {
    final isActive = enabled && !isLoading && onPressed != null;

    Widget buttonChild = _buildContent(context);

    switch (variant) {
      case HBButtonVariant.primary:
        return _PrimaryButton(
          onPressed: isActive ? _handlePress : null,
          size: size,
          fullWidth: fullWidth,
          gradient: gradient,
          child: buttonChild,
        );

      case HBButtonVariant.secondary:
        return _SecondaryButton(
          onPressed: isActive ? _handlePress : null,
          size: size,
          fullWidth: fullWidth,
          child: buttonChild,
        );

      case HBButtonVariant.destructive:
        return _DestructiveButton(
          onPressed: isActive ? _handlePress : null,
          size: size,
          fullWidth: fullWidth,
          child: buttonChild,
        );

      case HBButtonVariant.outline:
        return _OutlineButton(
          onPressed: isActive ? _handlePress : null,
          size: size,
          fullWidth: fullWidth,
          child: buttonChild,
        );

      case HBButtonVariant.text:
        return _TextButton(
          onPressed: isActive ? _handlePress : null,
          size: size,
          fullWidth: fullWidth,
          child: buttonChild,
        );

      case HBButtonVariant.tonal:
        return _TonalButton(
          onPressed: isActive ? _handlePress : null,
          size: size,
          fullWidth: fullWidth,
          child: buttonChild,
        );
    }
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLoadingColor(context),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          DefaultTextStyle(
            style: _getTextStyle(context),
            child: child,
          ),
        ],
      );
    }

    if (icon != null) {
      final iconWidget = Icon(icon, size: _getIconSize());
      final spacing = SizedBox(width: AppSpacing.sm);

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: iconPosition == HBButtonIconPosition.leading
            ? [iconWidget, spacing, child]
            : [child, spacing, iconWidget],
      );
    }

    return child;
  }

  void _handlePress() {
    if (enableHaptics) {
      HapticFeedback.selectionClick();
    }
    onPressed?.call();
  }

  double _getIconSize() {
    switch (size) {
      case HBButtonSize.small:
        return AppSizes.iconSm;
      case HBButtonSize.medium:
        return AppSizes.iconSm;
      case HBButtonSize.large:
        return AppSizes.iconMd;
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    final baseStyle = context.textTheme.labelLarge?.copyWith(
          fontWeight: AppTypography.fontWeightMedium,
        ) ??
        const TextStyle();

    switch (size) {
      case HBButtonSize.small:
        return baseStyle.copyWith(fontSize: AppTypography.fontSizeSm);
      case HBButtonSize.medium:
        return baseStyle.copyWith(fontSize: AppTypography.fontSizeBase);
      case HBButtonSize.large:
        return baseStyle.copyWith(fontSize: AppTypography.fontSizeLg);
    }
  }

  Color _getLoadingColor(BuildContext context) {
    switch (variant) {
      case HBButtonVariant.primary:
      case HBButtonVariant.destructive:
        return Colors.white;
      case HBButtonVariant.secondary:
      case HBButtonVariant.outline:
      case HBButtonVariant.text:
      case HBButtonVariant.tonal:
        return context.colorScheme.primary;
    }
  }

  // Factory constructors for common use cases

  factory HBButton.primary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    HBButtonSize size = HBButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
    IconData? icon,
    Gradient? gradient,
  }) {
    return HBButton(
      key: key,
      onPressed: onPressed,
      variant: HBButtonVariant.primary,
      size: size,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: icon,
      gradient: gradient,
      child: child,
    );
  }

  factory HBButton.secondary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    HBButtonSize size = HBButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
    IconData? icon,
  }) {
    return HBButton(
      key: key,
      onPressed: onPressed,
      variant: HBButtonVariant.secondary,
      size: size,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: icon,
      child: child,
    );
  }

  factory HBButton.destructive({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    HBButtonSize size = HBButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
    IconData? icon,
  }) {
    return HBButton(
      key: key,
      onPressed: onPressed,
      variant: HBButtonVariant.destructive,
      size: size,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: icon,
      child: child,
    );
  }

  factory HBButton.outline({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    HBButtonSize size = HBButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
    IconData? icon,
  }) {
    return HBButton(
      key: key,
      onPressed: onPressed,
      variant: HBButtonVariant.outline,
      size: size,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: icon,
      child: child,
    );
  }

  factory HBButton.text({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    HBButtonSize size = HBButtonSize.medium,
    bool isLoading = false,
    IconData? icon,
  }) {
    return HBButton(
      key: key,
      onPressed: onPressed,
      variant: HBButtonVariant.text,
      size: size,
      isLoading: isLoading,
      icon: icon,
      child: child,
    );
  }
}

// ============================================================================
// Button Variants
// ============================================================================

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.onPressed,
    required this.child,
    required this.size,
    required this.fullWidth,
    this.gradient,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final HBButtonSize size;
  final bool fullWidth;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ??
        (context.isDark
            ? AppColors.primaryGradientDark
            : AppColors.primaryGradient);

    return Container(
      width: fullWidth ? double.infinity : null,
      height: size.height,
      decoration: BoxDecoration(
        gradient: onPressed != null ? effectiveGradient : null,
        color: onPressed == null
            ? context.colorScheme.surfaceContainerHighest
            : null,
        borderRadius: AppRadii.radiusMd,
        boxShadow: onPressed != null
            ? AppElevation.coloredShadow(effectiveGradient.colors.first)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadii.radiusMd,
          child: Container(
            padding: size.padding,
            alignment: Alignment.center,
            child: DefaultTextStyle(
              style: TextStyle(
                color: onPressed != null
                    ? Colors.white
                    : context.colorScheme.onSurface.withValues(alpha: 0.38),
                fontWeight: AppTypography.fontWeightMedium,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.onPressed,
    required this.child,
    required this.size,
    required this.fullWidth,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final HBButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.colorScheme.surfaceContainerHighest,
        foregroundColor: context.colorScheme.onSurface,
        disabledBackgroundColor:
            context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
        disabledForegroundColor:
            context.colorScheme.onSurface.withValues(alpha: 0.38),
        elevation: 0,
        minimumSize: Size(fullWidth ? double.infinity : 0, size.height),
        padding: size.padding,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
      ),
      child: child,
    );
  }
}

class _DestructiveButton extends StatelessWidget {
  const _DestructiveButton({
    required this.onPressed,
    required this.child,
    required this.size,
    required this.fullWidth,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final HBButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      height: size.height,
      decoration: BoxDecoration(
        gradient: onPressed != null ? AppColors.errorGradient : null,
        color: onPressed == null ? context.colorScheme.surfaceContainerHighest : null,
        borderRadius: AppRadii.radiusMd,
        boxShadow:
            onPressed != null ? AppElevation.coloredShadow(AppColors.error) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadii.radiusMd,
          child: Container(
            padding: size.padding,
            alignment: Alignment.center,
            child: DefaultTextStyle(
              style: TextStyle(
                color: onPressed != null
                    ? Colors.white
                    : context.colorScheme.onSurface.withValues(alpha: 0.38),
                fontWeight: AppTypography.fontWeightMedium,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.onPressed,
    required this.child,
    required this.size,
    required this.fullWidth,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final HBButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colorScheme.primary,
        disabledForegroundColor:
            context.colorScheme.onSurface.withValues(alpha: 0.38),
        side: BorderSide(
          color: onPressed != null
              ? context.colorScheme.outline
              : context.colorScheme.outline.withValues(alpha: 0.38),
          width: 1.5,
        ),
        minimumSize: Size(fullWidth ? double.infinity : 0, size.height),
        padding: size.padding,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
      ),
      child: child,
    );
  }
}

class _TextButton extends StatelessWidget {
  const _TextButton({
    required this.onPressed,
    required this.child,
    required this.size,
    required this.fullWidth,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final HBButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: context.colorScheme.primary,
        disabledForegroundColor:
            context.colorScheme.onSurface.withValues(alpha: 0.38),
        minimumSize: Size(fullWidth ? double.infinity : 0, size.height),
        padding: size.padding,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
      ),
      child: child,
    );
  }
}

class _TonalButton extends StatelessWidget {
  const _TonalButton({
    required this.onPressed,
    required this.child,
    required this.size,
    required this.fullWidth,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final HBButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: context.colorScheme.secondaryContainer,
        foregroundColor: context.colorScheme.onSecondaryContainer,
        disabledBackgroundColor:
            context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
        disabledForegroundColor:
            context.colorScheme.onSurface.withValues(alpha: 0.38),
        elevation: 0,
        minimumSize: Size(fullWidth ? double.infinity : 0, size.height),
        padding: size.padding,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
      ),
      child: child,
    );
  }
}

// ============================================================================
// Enums
// ============================================================================

enum HBButtonVariant {
  primary, // Filled with gradient
  secondary, // Filled with surface color
  destructive, // Filled with error gradient
  outline, // Outlined with primary color
  text, // Text only
  tonal, // Filled with secondary container
}

enum HBButtonSize {
  small(AppSizes.buttonSm, EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
  medium(AppSizes.buttonMd, EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
  large(AppSizes.buttonLg, EdgeInsets.symmetric(horizontal: 24, vertical: 12));

  const HBButtonSize(this.height, this.padding);
  final double height;
  final EdgeInsets padding;
}

enum HBButtonIconPosition {
  leading,
  trailing,
}
