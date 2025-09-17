import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom page transitions for medical app navigation
/// Designed for smooth, professional transitions between health screens
class MedicalPageTransitions {
  // ============ SLIDE TRANSITIONS ============

  /// Smooth slide transition for primary navigation
  static PageRouteBuilder<T> slideTransition<T>({
    required Widget page,
    SlideDirection direction = SlideDirection.fromRight,
    Duration duration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offset = _getSlideOffset(direction);
        final slideAnimation = Tween<Offset>(
          begin: offset,
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final reverseSlideAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: -offset,
        ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve));

        return SlideTransition(
          position: slideAnimation,
          child: SlideTransition(position: reverseSlideAnimation, child: child),
        );
      },
    );
  }

  /// Medical fade transition for subtle screen changes
  static PageRouteBuilder<T> fadeTransition<T>({
    required Widget page,
    Duration duration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final reverseFadeAnimation = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve));

        return FadeTransition(
          opacity: fadeAnimation,
          child: FadeTransition(opacity: reverseFadeAnimation, child: child),
        );
      },
    );
  }

  // ============ SCALE TRANSITIONS ============

  /// Scale transition for modal-like screens (forms, details)
  static PageRouteBuilder<T> scaleTransition<T>({
    required Widget page,
    Duration duration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
    double initialScale = 0.8,
    Alignment alignment = Alignment.center,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: initialScale,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final reverseScaleAnimation = Tween<double>(
          begin: 1.0,
          end: initialScale,
        ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve));

        return ScaleTransition(
          scale: scaleAnimation,
          alignment: alignment,
          child: ScaleTransition(
            scale: reverseScaleAnimation,
            alignment: alignment,
            child: child,
          ),
        );
      },
    );
  }

  // ============ COMBINED TRANSITIONS ============

  /// Fade + Scale transition for premium medical app feel
  static PageRouteBuilder<T> fadeScaleTransition<T>({
    required Widget page,
    Duration duration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
    double initialScale = 0.9,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final scaleAnimation = Tween<double>(
          begin: initialScale,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final reverseFadeAnimation = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve));

        final reverseScaleAnimation = Tween<double>(
          begin: 1.0,
          end: initialScale,
        ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(
              opacity: reverseFadeAnimation,
              child: ScaleTransition(
                scale: reverseScaleAnimation,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Slide + Fade transition for natural navigation
  static PageRouteBuilder<T> slideFadeTransition<T>({
    required Widget page,
    SlideDirection direction = SlideDirection.fromRight,
    Duration duration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offset = _getSlideOffset(direction);

        final slideAnimation = Tween<Offset>(
          begin: offset,
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final reverseSlideAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: -offset * 0.3, // Subtle slide on reverse
        ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve));

        final reverseFadeAnimation = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: reverseSlideAnimation,
              child: FadeTransition(
                opacity: reverseFadeAnimation,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  // ============ SPECIAL MEDICAL TRANSITIONS ============

  /// Heartbeat transition for health success screens
  static PageRouteBuilder<T> heartbeatTransition<T>({
    required Widget page,
    Duration duration = AppTheme.dramaticDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: AppTheme.standardDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final heartbeatAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut));

        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: AppTheme.easeOutCubic),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: AnimatedBuilder(
            animation: heartbeatAnimation,
            builder: (context, child) {
              // Create heartbeat scale effect
              final t = heartbeatAnimation.value;
              late double scale;

              if (t < 0.3) {
                scale = 0.8 + 0.4 * (t / 0.3); // Quick scale up
              } else if (t < 0.6) {
                scale = 1.2 - 0.3 * ((t - 0.3) / 0.3); // Scale down
              } else if (t < 0.8) {
                scale = 0.9 + 0.2 * ((t - 0.6) / 0.2); // Small scale up
              } else {
                scale = 1.1 - 0.1 * ((t - 0.8) / 0.2); // Settle to 1.0
              }

              return Transform.scale(scale: scale, child: child);
            },
            child: child,
          ),
        );
      },
    );
  }

  /// Smooth bottom sheet transition
  static PageRouteBuilder<T> bottomSheetTransition<T>({
    required Widget page,
    Duration duration = AppTheme.standardDuration,
    Curve curve = AppTheme.easeOutCubic,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 0.3,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return Stack(
          children: [
            // Background overlay
            FadeTransition(
              opacity: fadeAnimation,
              child: Container(color: Colors.black),
            ),
            // Bottom sheet content
            SlideTransition(position: slideAnimation, child: child),
          ],
        );
      },
    );
  }

  // ============ HELPER METHODS ============

  static Offset _getSlideOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.fromRight:
        return const Offset(1.0, 0.0);
      case SlideDirection.fromLeft:
        return const Offset(-1.0, 0.0);
      case SlideDirection.fromTop:
        return const Offset(0.0, -1.0);
      case SlideDirection.fromBottom:
        return const Offset(0.0, 1.0);
    }
  }
}

// ============ ENUMS ============

enum SlideDirection { fromRight, fromLeft, fromTop, fromBottom }

// ============ ROUTE EXTENSIONS ============

extension MedicalRouteExtensions on Widget {
  /// Quick extension method for slide transition
  PageRouteBuilder<T> slideRoute<T>({
    SlideDirection direction = SlideDirection.fromRight,
    Duration duration = AppTheme.standardDuration,
    RouteSettings? settings,
  }) {
    return MedicalPageTransitions.slideTransition<T>(
      page: this,
      direction: direction,
      duration: duration,
      settings: settings,
    );
  }

  /// Quick extension method for fade transition
  PageRouteBuilder<T> fadeRoute<T>({
    Duration duration = AppTheme.standardDuration,
    RouteSettings? settings,
  }) {
    return MedicalPageTransitions.fadeTransition<T>(
      page: this,
      duration: duration,
      settings: settings,
    );
  }

  /// Quick extension method for fade + scale transition
  PageRouteBuilder<T> fadeScaleRoute<T>({
    Duration duration = AppTheme.standardDuration,
    double initialScale = 0.9,
    RouteSettings? settings,
  }) {
    return MedicalPageTransitions.fadeScaleTransition<T>(
      page: this,
      duration: duration,
      initialScale: initialScale,
      settings: settings,
    );
  }
}
