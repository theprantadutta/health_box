import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class ModernCard extends StatefulWidget {
  const ModernCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.elevation = CardElevation.low,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.shadowColor,
    this.border,
    this.enableHoverEffect = true,
    this.enablePressEffect = true,
    this.enableHaptics = true,
    this.hoverElevation,
    this.pressScale = 0.98,
    this.hoverScale = 1.02,
    this.animationDuration = AppTheme.microDuration,
    this.splashColor,
    this.highlightColor,
    this.backgroundBlur = 0.0,
    this.shimmerEffect = false,
    this.pulseEffect = false,
    this.medicalTheme,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final CardElevation elevation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? width;
  final double? height;
  final Color? shadowColor;
  final BoxBorder? border;

  // Enhanced interaction properties
  final bool enableHoverEffect;
  final bool enablePressEffect;
  final bool enableHaptics;
  final CardElevation? hoverElevation;
  final double pressScale;
  final double hoverScale;
  final Duration animationDuration;
  final Color? splashColor;
  final Color? highlightColor;

  // Premium visual effects
  final double backgroundBlur;
  final bool shimmerEffect;
  final bool pulseEffect;
  final MedicalCardTheme? medicalTheme;

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard> with TickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

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

    // Start effects if enabled
    if (widget.shimmerEffect) {
      _shimmerController.repeat();
    }

    if (widget.pulseEffect) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
    final effectiveColor = widget.color ??
        (_getMedicalThemeColor(context) ?? theme.colorScheme.surface);

    // Build the card content
    Widget cardContent = _buildCardContent(context, effectiveBorderRadius);

    // Apply shimmer effect if enabled
    if (widget.shimmerEffect) {
      cardContent = _buildShimmerEffect(cardContent, effectiveBorderRadius);
    }

    // Apply pulse effect if enabled
    if (widget.pulseEffect) {
      cardContent = _buildPulseEffect(cardContent);
    }

    // Main card container
    Widget card = AnimatedContainer(
      duration: widget.animationDuration,
      curve: AppTheme.easeOutCubic,
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: effectiveBorderRadius,
        boxShadow: shadows,
        border: widget.border,
      ),
      child: cardContent,
    );

    // Apply scale animation
    card = AnimatedScale(
      scale: currentScale,
      duration: widget.animationDuration,
      curve: AppTheme.easeOutCubic,
      child: card,
    );

    // Wrap with interaction handlers if needed
    if (widget.onTap != null || widget.onLongPress != null) {
      return _buildInteractiveCard(card, effectiveBorderRadius);
    }

    return card;
  }

  /// Builds the card content with proper clipping and padding
  Widget _buildCardContent(BuildContext context, BorderRadius borderRadius) {
    Widget content = ClipRRect(
      borderRadius: borderRadius,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: widget.padding ?? AppTheme.getResponsivePadding(context),
          child: widget.child,
        ),
      ),
    );

    // Apply background blur if specified
    if (widget.backgroundBlur > 0) {
      content = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.backgroundBlur,
          sigmaY: widget.backgroundBlur,
        ),
        child: content,
      );
    }

    return content;
  }

  /// Builds interactive wrapper with gesture detection
  Widget _buildInteractiveCard(Widget card, BorderRadius borderRadius) {
    return MouseRegion(
      onEnter: widget.enableHoverEffect ? (_) => _setHovered(true) : null,
      onExit: widget.enableHoverEffect ? (_) => _setHovered(false) : null,
      child: GestureDetector(
        onTapDown: widget.enablePressEffect ? (_) => _setPressed(true) : null,
        onTapUp: widget.enablePressEffect ? (_) => _setPressed(false) : null,
        onTapCancel: widget.enablePressEffect ? () => _setPressed(false) : null,
        onTap: () {
          if (widget.enableHaptics) {
            HapticFeedback.selectionClick();
          }
          widget.onTap?.call();
        },
        onLongPress: () {
          if (widget.enableHaptics) {
            HapticFeedback.mediumImpact();
          }
          widget.onLongPress?.call();
        },
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            borderRadius: borderRadius,
            splashColor:
                widget.splashColor ??
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            highlightColor:
                widget.highlightColor ??
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            onTap: () {}, // Empty onTap to enable ripple effect
            child: card,
          ),
        ),
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
                  color: Colors.white.withValues(alpha: 0.05),
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
          scale: 1.0 + (_pulseController.value * 0.02),
          child: Opacity(
            opacity: 0.8 + (_pulseController.value * 0.2),
            child: child,
          ),
        );
      },
    );
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

  /// Gets medical theme color if specified
  Color? _getMedicalThemeColor(BuildContext context) {
    if (widget.medicalTheme != null) {
      final colorScheme = Theme.of(context).colorScheme;
      switch (widget.medicalTheme!) {
        case MedicalCardTheme.primary:
          return colorScheme.primary;
        case MedicalCardTheme.success:
          return const Color(0xFF81C784); // Light green
        case MedicalCardTheme.warning:
          return const Color(0xFFFFB74D); // Light orange
        case MedicalCardTheme.error:
          return colorScheme.error;
        case MedicalCardTheme.neutral:
          return colorScheme.outline;
      }
    }

    return null;
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

/// Card elevation levels for medical UI
enum CardElevation { none, low, medium, high, floating }

/// Simplified medical-themed card color schemes
enum MedicalCardTheme {
  primary, // Primary medical blue
  success, // Health green
  warning, // Caution orange
  error, // Emergency red
  neutral, // Neutral gray colors
}
