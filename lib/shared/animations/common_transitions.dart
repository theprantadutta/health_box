import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Common transition animations for HealthBox medical app
/// Designed for smooth, professional, medical-grade user experience
class CommonTransitions {
  // ============ FADE ANIMATIONS ============

  /// Smooth fade in animation with medical-appropriate timing
  static Widget fadeIn({
    required Widget child,
    Duration duration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
    double? delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }

  /// Fade out animation
  static Widget fadeOut({
    required Widget child,
    Duration duration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 1.0, end: 0.0),
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }

  // ============ SLIDE ANIMATIONS ============

  /// Slide in from bottom (great for modals and bottom sheets)
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
    double distance = 50.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: distance, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(0, value), child: child);
      },
      child: child,
    );
  }

  /// Slide in from right (great for card reveals)
  static Widget slideInFromRight({
    required Widget child,
    Duration duration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
    double distance = 50.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: distance, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(value, 0), child: child);
      },
      child: child,
    );
  }

  /// Slide in from left
  static Widget slideInFromLeft({
    required Widget child,
    Duration duration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
    double distance = 50.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: -distance, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(value, 0), child: child);
      },
      child: child,
    );
  }

  // ============ SCALE ANIMATIONS ============

  /// Gentle scale in animation (perfect for button feedback)
  static Widget scaleIn({
    required Widget child,
    Duration duration = AppTheme.microDuration,
    Curve curve = AppTheme.easeOutCubic,
    double fromScale = 0.8,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: fromScale, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }

  /// Bounce scale animation (for success states)
  static Widget bounceScale({
    required Widget child,
    Duration duration = AppTheme.dramaticDuration,
    double maxScale = 1.1,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: AppTheme.bounceOut,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        // Create a bounce effect that goes slightly above 1.0 then settles
        final scale = value < 0.8
            ? value *
                  1.25 // Scale up quickly to maxScale
            : maxScale -
                  (value - 0.8) * 5 * (maxScale - 1.0); // Then back down to 1.0
        return Transform.scale(scale: scale.clamp(0.0, maxScale), child: child);
      },
      child: child,
    );
  }

  // ============ COMBINED ANIMATIONS ============

  /// Smooth fade + slide combo (most versatile)
  static Widget fadeSlideIn({
    required Widget child,
    Duration duration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
    Offset direction = const Offset(0, 30), // Default: slide from bottom
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              direction.dx * (1 - value),
              direction.dy * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Fade + scale combo (great for cards and modals)
  static Widget fadeScaleIn({
    required Widget child,
    Duration duration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
    double fromScale = 0.8,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final scale = fromScale + (1.0 - fromScale) * value;
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: child,
    );
  }

  // ============ ROTATION ANIMATIONS ============

  /// Gentle rotation (for loading indicators or refresh icons)
  static Widget rotateIn({
    required Widget child,
    Duration duration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
    double rotations = 0.25, // Quarter turn by default
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: rotations, end: 0.0),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159, // Convert to radians
          child: child,
        );
      },
      child: child,
    );
  }

  // ============ SPECIAL MEDICAL ANIMATIONS ============

  /// Heart beat animation for health-related success states
  static Widget heartBeat({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double intensity = 0.1,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeInOut,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        // Create a heartbeat pattern: quick expansion, quick contraction, pause
        late double scale;
        if (value < 0.2) {
          scale = 1.0 + intensity * (value / 0.2);
        } else if (value < 0.4) {
          scale = 1.0 + intensity * (1.0 - (value - 0.2) / 0.2);
        } else if (value < 0.6) {
          scale = 1.0 + intensity * 0.5 * ((value - 0.4) / 0.2);
        } else if (value < 0.8) {
          scale = 1.0 + intensity * 0.5 * (1.0 - (value - 0.6) / 0.2);
        } else {
          scale = 1.0; // Rest period
        }

        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }

  /// Pulse animation for drawing attention to important medical information
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 2000),
    double minOpacity = 0.6,
    double maxOpacity = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeInOut,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        // Create a smooth pulse between min and max opacity
        final opacity =
            minOpacity +
            (maxOpacity - minOpacity) *
                (0.5 + 0.5 * (value < 0.5 ? value * 2 : 2 - value * 2));

        return Opacity(opacity: opacity, child: child);
      },
      child: child,
    );
  }
}
