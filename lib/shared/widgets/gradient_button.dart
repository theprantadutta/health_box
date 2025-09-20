import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../theme/design_system.dart';
import 'modern_card.dart';

class HealthButton extends StatefulWidget {
  const HealthButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.style = HealthButtonStyle.primary,
    this.size = HealthButtonSize.medium,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height,
    this.borderRadius,
    this.elevation = CardElevation.low,

    // Enhanced interaction properties
    this.enableHoverEffect = true,
    this.enablePressEffect = true,
    this.enableHaptics = true,
    this.enableRipple = true,
    this.hoverElevation,
    this.pressScale = 0.96,
    this.hoverScale = 1.02,
    this.animationDuration = AppTheme.microDuration,
    this.splashColor,
    this.highlightColor,

    // Premium visual effects
    this.shimmerEffect = false,
    this.pulseEffect = false,
    this.glowEffect = false,
    this.medicalTheme,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final HealthButtonStyle style;
  final HealthButtonSize size;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final CardElevation elevation;

  // Enhanced interaction properties
  final bool enableHoverEffect;
  final bool enablePressEffect;
  final bool enableHaptics;
  final bool enableRipple;
  final CardElevation? hoverElevation;
  final double pressScale;
  final double hoverScale;
  final Duration animationDuration;
  final Color? splashColor;
  final Color? highlightColor;

  // Premium visual effects
  final bool shimmerEffect;
  final bool pulseEffect;
  final bool glowEffect;
  final MedicalButtonTheme? medicalTheme;

  @override
  State<HealthButton> createState() => _HealthButtonState();
}

class _HealthButtonState extends State<HealthButton>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    // Initialize scale animation
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Initialize shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize glow animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Start effects if enabled
    if (widget.shimmerEffect) {
      _shimmerController.repeat();
    }

    if (widget.pulseEffect) {
      _pulseController.repeat(reverse: true);
    }

    if (widget.glowEffect) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Get dimensions based on size
    final dimensions = _getButtonDimensions();
    final effectiveHeight = widget.height ?? dimensions.height;
    final effectiveWidth = widget.width ?? dimensions.width;
    final effectiveBorderRadius =
        widget.borderRadius ??
        BorderRadius.circular(AppTheme.getResponsiveCardRadius(context));

    // Determine current elevation based on interaction state
    final currentElevation = _isHovered && widget.hoverElevation != null
        ? widget.hoverElevation!
        : widget.elevation;

    // Get shadows based on current elevation
    final shadows = _getShadows(isDarkMode, currentElevation);

    // Calculate current scale
    final currentScale = _isPressed
        ? widget.pressScale
        : (_isHovered && widget.enableHoverEffect ? widget.hoverScale : 1.0);

    // Get effective color based on medical theme
    final effectiveColor = _getEffectiveColor(context);

    // Get text color based on style and state
    final textColor = _getTextColor();

    final isActive =
        widget.enabled && widget.onPressed != null && !widget.isLoading;

    // Build the button content
    Widget buttonContent = _buildButtonContent(
      effectiveBorderRadius,
      dimensions,
      textColor,
      isActive,
    );

    // Apply shimmer effect if enabled
    if (widget.shimmerEffect && isActive) {
      buttonContent = _buildShimmerEffect(buttonContent, effectiveBorderRadius);
    }

    // Apply pulse effect if enabled
    if (widget.pulseEffect && isActive) {
      buttonContent = _buildPulseEffect(buttonContent);
    }

    // Apply glow effect if enabled
    if (widget.glowEffect && isActive) {
      buttonContent = _buildGlowEffect(buttonContent, effectiveBorderRadius);
    }

    // Main button container
    Widget button = AnimatedContainer(
      duration: widget.animationDuration,
      curve: AppTheme.easeOutCubic,
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: isActive ? effectiveColor : _getDisabledColor(theme),
        borderRadius: effectiveBorderRadius,
        boxShadow: shadows,
      ),
      child: buttonContent,
    );

    // Apply scale animation
    button = AnimatedScale(
      scale: currentScale,
      duration: widget.animationDuration,
      curve: AppTheme.easeOutCubic,
      child: button,
    );

    // Wrap with interaction handlers
    return _buildInteractiveButton(button, effectiveBorderRadius, isActive);
  }

  /// Builds the button content with proper clipping and padding
  Widget _buildButtonContent(
    BorderRadius borderRadius,
    ButtonDimensions dimensions,
    Color textColor,
    bool isActive,
  ) {
    Widget content = ClipRRect(
      borderRadius: borderRadius,
      child: Material(
        color: Colors.transparent,
        child: Semantics(
          button: true,
          enabled: isActive,
          child: widget.enableRipple && isActive
              ? InkWell(
                  borderRadius: borderRadius,
                  splashColor:
                      widget.splashColor ?? textColor.withValues(alpha: 0.1),
                  highlightColor:
                      widget.highlightColor ??
                      textColor.withValues(alpha: 0.05),
                  onTap: () {}, // Empty onTap to enable ripple effect
                  child: Container(
                    padding: dimensions.padding,
                    child: _buildContent(textColor),
                  ),
                )
              : Container(
                  padding: dimensions.padding,
                  child: _buildContent(textColor),
                ),
        ),
      ),
    );

    return content;
  }

  /// Builds the actual button content (text/icon with loading state)
  Widget _buildContent(Color textColor) {
    if (widget.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 8),
          DefaultTextStyle(
            style: TextStyle(color: textColor),
            child: widget.child,
          ),
        ],
      );
    }

    return Center(
      child: DefaultTextStyle(
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        child: widget.child,
      ),
    );
  }

  /// Builds interactive wrapper with gesture detection
  Widget _buildInteractiveButton(
    Widget button,
    BorderRadius borderRadius,
    bool isActive,
  ) {
    return MouseRegion(
      onEnter: widget.enableHoverEffect && isActive
          ? (_) => _setHovered(true)
          : null,
      onExit: widget.enableHoverEffect && isActive
          ? (_) => _setHovered(false)
          : null,
      child: GestureDetector(
        onTapDown: widget.enablePressEffect && isActive
            ? (_) => _setPressed(true)
            : null,
        onTapUp: widget.enablePressEffect && isActive
            ? (_) => _setPressed(false)
            : null,
        onTapCancel: widget.enablePressEffect && isActive
            ? () => _setPressed(false)
            : null,
        onTap: isActive
            ? () {
                if (widget.enableHaptics) {
                  HapticFeedback.selectionClick();
                }
                widget.onPressed?.call();
              }
            : null,
        child: button,
      ),
    );
  }

  /// Builds shimmer effect overlay
  Widget _buildShimmerEffect(Widget child, BorderRadius borderRadius) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        return Stack(
          children: [
            child,
            ClipRRect(
              borderRadius: borderRadius,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: borderRadius,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds pulse effect
  Widget _buildPulseEffect(Widget child) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.03),
          child: Opacity(
            opacity: 0.9 + (_pulseController.value * 0.1),
            child: child,
          ),
        );
      },
    );
  }

  /// Builds glow effect
  Widget _buildGlowEffect(Widget child, BorderRadius borderRadius) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        final glowIntensity = _glowController.value;
        final glowColor = _getGlowColor(context);

        return Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: glowIntensity > 0
                ? [
                    BoxShadow(
                      color: glowColor.withValues(alpha: glowIntensity * 0.4),
                      blurRadius: 12 * glowIntensity,
                      spreadRadius: 3 * glowIntensity,
                    ),
                    BoxShadow(
                      color: glowColor.withValues(alpha: glowIntensity * 0.2),
                      blurRadius: 24 * glowIntensity,
                      spreadRadius: 6 * glowIntensity,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
    );
  }

  ButtonDimensions _getButtonDimensions() {
    switch (widget.size) {
      case HealthButtonSize.small:
        return const ButtonDimensions(
          height: 32,
          width: null,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      case HealthButtonSize.medium:
        return const ButtonDimensions(
          height: 44,
          width: null,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        );
      case HealthButtonSize.large:
        return const ButtonDimensions(
          height: 56,
          width: null,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        );
    }
  }

  /// Gets shadows based on elevation level
  List<BoxShadow> _getShadows(bool isDarkMode, CardElevation elevation) {
    switch (elevation) {
      case CardElevation.none:
        return [];
      case CardElevation.low:
        return AppTheme.getElevationShadow(isDarkMode, ElevationLevel.low);
      case CardElevation.medium:
        return AppTheme.getElevationShadow(isDarkMode, ElevationLevel.medium);
      case CardElevation.high:
        return AppTheme.getElevationShadow(isDarkMode, ElevationLevel.high);
      case CardElevation.floating:
        return AppTheme.getElevationShadow(isDarkMode, ElevationLevel.floating);
    }
  }

  /// Gets effective color based on medical theme and user settings
  Color _getEffectiveColor(BuildContext context) {
    if (widget.color != null) return widget.color!;

    final colorScheme = Theme.of(context).colorScheme;

    if (widget.medicalTheme != null) {
      switch (widget.medicalTheme!) {
        case MedicalButtonTheme.primary:
          return colorScheme.primary;
        case MedicalButtonTheme.success:
          return const Color(0xFF81C784); // Light green
        case MedicalButtonTheme.warning:
          return const Color(0xFFFFB74D); // Light orange
        case MedicalButtonTheme.error:
          return colorScheme.error;
        case MedicalButtonTheme.neutral:
          return colorScheme.outline;
      }
    }

    if (widget.medicalTheme != null) {
      switch (widget.medicalTheme!) {
        case MedicalButtonTheme.primary:
          return HealthBoxDesignSystem.primaryBlue;
        case MedicalButtonTheme.success:
          return HealthBoxDesignSystem.successColor;
        case MedicalButtonTheme.warning:
          return HealthBoxDesignSystem.warningColor;
        case MedicalButtonTheme.error:
          return HealthBoxDesignSystem.errorColor;
        case MedicalButtonTheme.neutral:
          return HealthBoxDesignSystem.neutral400;
      }
    }

    switch (widget.style) {
      case HealthButtonStyle.primary:
        return HealthBoxDesignSystem.primaryBlue;
      case HealthButtonStyle.success:
        return HealthBoxDesignSystem.successColor;
      case HealthButtonStyle.warning:
        return HealthBoxDesignSystem.warningColor;
      case HealthButtonStyle.error:
        return HealthBoxDesignSystem.errorColor;
    }
  }

  Color _getTextColor() {
    switch (widget.style) {
      case HealthButtonStyle.primary:
      case HealthButtonStyle.success:
      case HealthButtonStyle.error:
        return Colors.white;
      case HealthButtonStyle.warning:
        return Colors.black87;
    }
  }

  Color _getGlowColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.medicalTheme != null) {
      switch (widget.medicalTheme!) {
        case MedicalButtonTheme.primary:
          return colorScheme.primary;
        case MedicalButtonTheme.success:
          return const Color(0xFF81C784); // Light green
        case MedicalButtonTheme.warning:
          return const Color(0xFFFFB74D); // Light orange
        case MedicalButtonTheme.error:
          return colorScheme.error;
        case MedicalButtonTheme.neutral:
          return colorScheme.outline;
      }
    }

    switch (widget.style) {
      case HealthButtonStyle.primary:
        return colorScheme.primary;
      case HealthButtonStyle.success:
        return const Color(0xFF81C784); // Light green
      case HealthButtonStyle.warning:
        return const Color(0xFFFFB74D); // Light orange
      case HealthButtonStyle.error:
        return colorScheme.error;
    }
  }

  Color _getDisabledColor(ThemeData theme) {
    return theme.colorScheme.surfaceContainerHighest;
  }

  void _setHovered(bool hovered) {
    if (_isHovered != hovered) {
      setState(() {
        _isHovered = hovered;
      });
    }
  }

  void _setPressed(bool pressed) {
    if (_isPressed != pressed) {
      setState(() {
        _isPressed = pressed;
      });
    }
  }
}

enum HealthButtonStyle { primary, success, warning, error }

enum HealthButtonSize { small, medium, large }

class ButtonDimensions {
  const ButtonDimensions({
    required this.height,
    this.width,
    required this.padding,
  });

  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;
}

/// Simplified medical-themed button color schemes
enum MedicalButtonTheme {
  primary, // Primary medical blue
  success, // Health green
  warning, // Caution orange
  error, // Emergency red
  neutral, // Neutral gray theme
}
