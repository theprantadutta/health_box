import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Micro-interaction animations for medical app UI elements
/// Provides subtle feedback for user interactions in healthcare contexts
class MicroInteractions {
  // ============ BUTTON INTERACTIONS ============

  /// Animated button with scale and haptic feedback
  static Widget animatedButton({
    required Widget child,
    required VoidCallback? onPressed,
    Duration duration = AppTheme.microDuration,
    double scaleAmount = 0.95,
    bool enableHaptics = true,
    BorderRadius? borderRadius,
    Color? splashColor,
    Color? highlightColor,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;

        return GestureDetector(
          onTapDown: (_) {
            if (onPressed != null) {
              setState(() => isPressed = true);
              if (enableHaptics) {
                HapticFeedback.selectionClick();
              }
            }
          },
          onTapUp: (_) {
            setState(() => isPressed = false);
            onPressed?.call();
          },
          onTapCancel: () {
            setState(() => isPressed = false);
          },
          child: AnimatedScale(
            scale: isPressed ? scaleAmount : 1.0,
            duration: duration,
            curve: AppTheme.easeOutCubic,
            child: child,
          ),
        );
      },
    );
  }

  /// Button with ripple effect
  static Widget rippleButton({
    required Widget child,
    required VoidCallback? onPressed,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
    Color? splashColor,
    Color? highlightColor,
    Duration duration = AppTheme.microDuration,
    double scaleAmount = 0.98,
  }) {
    return Builder(
      builder: (context) => Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          splashColor:
              splashColor ??
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          highlightColor:
              highlightColor ??
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          onTap: onPressed,
          child: child,
        ),
      ),
    );
  }

  // ============ CARD INTERACTIONS ============

  /// Interactive card with hover and press effects
  static Widget interactiveCard({
    required Widget child,
    VoidCallback? onTap,
    Duration duration = AppTheme.microDuration,
    double hoverScale = 1.02,
    double pressScale = 0.98,
    double hoverElevation = 8.0,
    double baseElevation = 2.0,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(16)),
    bool enableShadowAnimation = true,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        bool isPressed = false;

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final currentElevation = isHovered ? hoverElevation : baseElevation;
        final currentScale = isPressed
            ? pressScale
            : (isHovered ? hoverScale : 1.0);

        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => isPressed = true),
            onTapUp: (_) {
              setState(() => isPressed = false);
              onTap?.call();
            },
            onTapCancel: () => setState(() => isPressed = false),
            child: AnimatedScale(
              scale: currentScale,
              duration: duration,
              curve: AppTheme.easeOutCubic,
              child: AnimatedContainer(
                duration: duration,
                curve: AppTheme.easeOutCubic,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  boxShadow: enableShadowAnimation
                      ? AppTheme.getElevationShadow(
                          isDark,
                          currentElevation > 4
                              ? ElevationLevel.medium
                              : ElevationLevel.low,
                        )
                      : null,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  // ============ INPUT INTERACTIONS ============

  /// Animated text field with focus effects
  static Widget animatedTextField({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Duration duration = AppTheme.standardDuration,
    Color? focusColor,
    bool enableFloatingLabel = true,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isFocused = false;
        final theme = Theme.of(context);

        return Focus(
          onFocusChange: (focused) => setState(() => isFocused = focused),
          child: AnimatedContainer(
            duration: duration,
            curve: AppTheme.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFocused
                    ? (focusColor ?? theme.colorScheme.primary)
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: isFocused ? 2.0 : 1.0,
              ),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: (focusColor ?? theme.colorScheme.primary)
                            .withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: enableFloatingLabel ? labelText : null,
                hintText: hintText,
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============ TOGGLE INTERACTIONS ============

  /// Animated switch with smooth transitions
  static Widget animatedSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    Duration duration = AppTheme.standardDuration,
    Color? activeColor,
    Color? inactiveColor,
    double scale = 1.0,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;

        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          onTap: () => onChanged(!value),
          child: AnimatedScale(
            scale: isPressed ? 0.95 : scale,
            duration: AppTheme.microDuration,
            curve: AppTheme.easeOutCubic,
            child: AnimatedContainer(
              duration: duration,
              curve: AppTheme.easeOutCubic,
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: value
                    ? (activeColor ?? Theme.of(context).colorScheme.primary)
                    : (inactiveColor ??
                          Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3)),
              ),
              child: AnimatedAlign(
                duration: duration,
                curve: AppTheme.easeOutCubic,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============ LOADING INTERACTIONS ============

  /// Pulsing loading indicator
  static Widget pulsingLoader({
    Duration duration = const Duration(milliseconds: 1200),
    Color? color,
    double size = 24.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final opacity =
            0.3 + 0.7 * (0.5 + 0.5 * (value < 0.5 ? value * 2 : 2 - value * 2));
        final scale =
            0.8 + 0.2 * (0.5 + 0.5 * (value < 0.5 ? value * 2 : 2 - value * 2));

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Breathing dots loader (medical-themed)
  static Widget breathingDots({
    Duration duration = const Duration(milliseconds: 1500),
    Color? color,
    int dotCount = 3,
    double dotSize = 8.0,
    double spacing = 8.0,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(dotCount, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < dotCount - 1 ? spacing : 0),
          child: TweenAnimationBuilder<double>(
            duration: duration,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              // Create breathing effect with staggered timing
              final staggeredValue = (value + index * 0.2) % 1.0;
              final scale =
                  0.6 +
                  0.4 *
                      (0.5 +
                          0.5 *
                              (staggeredValue < 0.5
                                  ? staggeredValue * 2
                                  : 2 - staggeredValue * 2));

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color ?? Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  // ============ FEEDBACK INTERACTIONS ============

  /// Success checkmark animation
  static Widget successCheckmark({
    Duration duration = AppTheme.dramaticDuration,
    Color? color,
    double size = 48.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value < 0.8
              ? value * 1.25
              : 1.0 + 0.25 * (1.0 - (value - 0.8) / 0.2),
          child: Opacity(
            opacity: value,
            child: Icon(
              Icons.check_circle,
              size: size,
              color: color ?? AppTheme.successColor,
            ),
          ),
        );
      },
    );
  }

  /// Error shake animation
  static Widget errorShake({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double intensity = 5.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        late double offset;

        if (value < 0.2) {
          offset = intensity * (value / 0.2);
        } else if (value < 0.4) {
          offset = intensity * (1.0 - (value - 0.2) / 0.2);
        } else if (value < 0.6) {
          offset = -intensity * 0.5 * ((value - 0.4) / 0.2);
        } else if (value < 0.8) {
          offset = -intensity * 0.5 * (1.0 - (value - 0.6) / 0.2);
        } else {
          offset = 0.0;
        }

        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: child,
    );
  }

  // ============ MEDICAL-SPECIFIC INTERACTIONS ============

  /// Heartbeat animation for health metrics
  static Widget heartbeat({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double intensity = 0.1,
    bool continuous = true,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        late double scale;

        // Create heartbeat pattern
        if (value < 0.1) {
          scale = 1.0 + intensity * (value / 0.1);
        } else if (value < 0.2) {
          scale = 1.0 + intensity * (1.0 - (value - 0.1) / 0.1);
        } else if (value < 0.3) {
          scale = 1.0 + intensity * 0.5 * ((value - 0.2) / 0.1);
        } else if (value < 0.4) {
          scale = 1.0 + intensity * 0.5 * (1.0 - (value - 0.3) / 0.1);
        } else {
          scale = 1.0;
        }

        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }

  /// Vital signs pulse for metrics display
  static Widget vitalPulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 2000),
    Color pulseColor = Colors.red,
    double intensity = 0.05,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final pulseValue = value % 1.0;
        final glowIntensity = pulseValue < 0.1
            ? pulseValue * 10
            : pulseValue < 0.2
            ? 1.0 - (pulseValue - 0.1) * 10
            : 0.0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: glowIntensity > 0
                ? [
                    BoxShadow(
                      color: pulseColor.withValues(alpha: glowIntensity * 0.3),
                      blurRadius: 8 * glowIntensity,
                      spreadRadius: 2 * glowIntensity,
                    ),
                  ]
                : null,
          ),
          child: Transform.scale(
            scale: 1.0 + intensity * glowIntensity,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Bounce tap animation for interactive elements
  static Widget bounceTap({
    required Widget child,
    double scaleDown = 0.95,
    Duration duration = const Duration(milliseconds: 100),
    Key? key,
  }) {
    return StatefulBuilder(
      key: key,
      builder: (context, setState) {
        bool isPressed = false;

        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          child: AnimatedScale(
            scale: isPressed ? scaleDown : 1.0,
            duration: duration,
            curve: AppTheme.easeOutCubic,
            child: child,
          ),
        );
      },
    );
  }
}
