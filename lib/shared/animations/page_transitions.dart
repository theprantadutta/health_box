import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

// Premium Page Transition Types
enum PageTransitionType {
  fade,
  slide,
  scale,
  rotation,
  healthSlide, // Health-themed slide with gradient
  cardFlip,    // 3D card flip effect
  dissolve,    // Particle dissolve effect
  morphing,    // Shape morphing transition
  wave,        // Wave effect
  breathe,     // Breathing animation
}

// Premium Page Route Builder
class PremiumPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final PageTransitionType transitionType;
  final Duration duration;
  final Duration reverseDuration;
  final Curve curve;
  final String? healthContext;
  final bool maintainState;

  PremiumPageRoute({
    required this.child,
    this.transitionType = PageTransitionType.healthSlide,
    this.duration = const Duration(milliseconds: 400),
    this.reverseDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOutCubic,
    this.healthContext,
    this.maintainState = true,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, _) => child,
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
          maintainState: maintainState,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _buildTransition(
      context,
      animation,
      secondaryAnimation,
      child,
      transitionType,
      curve,
      healthContext,
    );
  }
}

// Premium Transition Builder
Widget _buildTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
  PageTransitionType type,
  Curve curve,
  String? healthContext,
) {
  final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;

  switch (type) {
    case PageTransitionType.fade:
      return _buildFadeTransition(curvedAnimation, child);
    
    case PageTransitionType.slide:
      return _buildSlideTransition(curvedAnimation, secondaryAnimation, child);
    
    case PageTransitionType.scale:
      return _buildScaleTransition(curvedAnimation, child);
    
    case PageTransitionType.rotation:
      return _buildRotationTransition(curvedAnimation, child);
    
    case PageTransitionType.healthSlide:
      return _buildHealthSlideTransition(
        curvedAnimation, 
        secondaryAnimation, 
        child, 
        theme, 
        isDarkMode, 
        healthContext
      );
    
    case PageTransitionType.cardFlip:
      return _buildCardFlipTransition(curvedAnimation, secondaryAnimation, child);
    
    case PageTransitionType.dissolve:
      return _buildDissolveTransition(curvedAnimation, child, theme);
    
    case PageTransitionType.morphing:
      return _buildMorphingTransition(curvedAnimation, child, theme);
    
    case PageTransitionType.wave:
      return _buildWaveTransition(curvedAnimation, child, theme);
    
    case PageTransitionType.breathe:
      return _buildBreatheTransition(curvedAnimation, child, theme);
  }
}

// Enhanced Fade Transition with Glow
Widget _buildFadeTransition(Animation<double> animation, Widget child) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      return FadeTransition(
        opacity: animation,
        child: Transform.scale(
          scale: 0.95 + (0.05 * animation.value),
          child: child,
        ),
      );
    },
  );
}

// Enhanced Slide Transition
Widget _buildSlideTransition(
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(animation),
    child: SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.3, 0.0),
      ).animate(secondaryAnimation),
      child: child,
    ),
  );
}

// Enhanced Scale Transition with Bounce
Widget _buildScaleTransition(Animation<double> animation, Widget child) {
  final bounceAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: animation,
    curve: Curves.elasticOut,
  ));

  return AnimatedBuilder(
    animation: bounceAnimation,
    builder: (context, _) {
      return Transform.scale(
        scale: bounceAnimation.value,
        child: child,
      );
    },
  );
}

// Enhanced Rotation Transition
Widget _buildRotationTransition(Animation<double> animation, Widget child) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(math.pi * (1 - animation.value)),
        child: animation.value > 0.5 
          ? child 
          : Container(
              color: Colors.transparent,
            ),
      );
    },
  );
}

// PREMIUM: Health-Themed Slide Transition
Widget _buildHealthSlideTransition(
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
  ThemeData theme,
  bool isDarkMode,
  String? healthContext,
) {
  // Get health context gradient
  final gradient = healthContext != null 
      ? AppTheme.getHealthContextGradient(healthContext, isDark: isDarkMode)
      : AppTheme.getPremiumPrimaryGradient(isDarkMode);

  return AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      return Stack(
        children: [
          // Gradient background overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gradient.colors.first.withValues(alpha: 0.1 * animation.value),
                    gradient.colors.last.withValues(alpha: 0.05 * animation.value),
                  ],
                ),
              ),
            ),
          ),
          
          // Sliding content with enhanced effect
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.2, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: animation,
              child: Transform.scale(
                scale: 0.9 + (0.1 * animation.value),
                child: child,
              ),
            ),
          ),
        ],
      );
    },
  );
}

// PREMIUM: 3D Card Flip Transition
Widget _buildCardFlipTransition(
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      final isShowingFrontSide = animation.value < 0.5;
      
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002) // Perspective
          ..rotateY(animation.value * math.pi),
        child: isShowingFrontSide
          ? Container(
              decoration: BoxDecoration(
                gradient: AppTheme.getPremiumPrimaryGradient(
                  Theme.of(context).brightness == Brightness.dark
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            )
          : Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(math.pi),
              child: child,
            ),
      );
    },
  );
}

// PREMIUM: Dissolve Transition with Particles
Widget _buildDissolveTransition(
  Animation<double> animation,
  Widget child,
  ThemeData theme,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      return Stack(
        children: [
          // Dissolving particles effect
          CustomPaint(
            painter: DissolvePainter(
              progress: animation.value,
              color: theme.colorScheme.primary,
            ),
            child: Container(),
          ),
          
          // Fading content
          FadeTransition(
            opacity: animation,
            child: Transform.scale(
              scale: 0.8 + (0.2 * animation.value),
              child: child,
            ),
          ),
        ],
      );
    },
  );
}

// PREMIUM: Morphing Transition
Widget _buildMorphingTransition(
  Animation<double> animation,
  Widget child,
  ThemeData theme,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      return ClipPath(
        clipper: MorphingClipper(animation.value),
        child: child,
      );
    },
  );
}

// PREMIUM: Wave Transition
Widget _buildWaveTransition(
  Animation<double> animation,
  Widget child,
  ThemeData theme,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      return ClipPath(
        clipper: WaveClipper(animation.value),
        child: child,
      );
    },
  );
}

// PREMIUM: Breathe Transition (for wellness contexts)
Widget _buildBreatheTransition(
  Animation<double> animation,
  Widget child,
  ThemeData theme,
) {
  final breatheAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: animation,
    curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
  ));

  return AnimatedBuilder(
    animation: breatheAnimation,
    builder: (context, _) {
      final breathScale = 0.8 + (0.4 * math.sin(breatheAnimation.value * math.pi));
      final breathOpacity = 0.3 + (0.7 * animation.value);
      
      return Transform.scale(
        scale: breathScale,
        child: Opacity(
          opacity: breathOpacity,
          child: child,
        ),
      );
    },
  );
}

// Custom Painters for Advanced Effects
class DissolvePainter extends CustomPainter {
  final double progress;
  final Color color;
  
  DissolvePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.3);
    final random = math.Random(42);
    
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 5 * progress;
      
      if (progress > random.nextDouble()) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DissolvePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class MorphingClipper extends CustomClipper<Path> {
  final double progress;
  
  MorphingClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    final morphProgress = Curves.easeInOut.transform(progress);
    
    // Create morphing shape
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(size.width, size.height) * morphProgress;
    
    path.addOval(Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: radius,
    ));
    
    return path;
  }

  @override
  bool shouldReclip(MorphingClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double progress;
  
  WaveClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    final waveProgress = Curves.easeInOut.transform(progress);
    
    // Create wave effect
    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x++) {
      final y = size.height * (1 - waveProgress) + 
                math.sin((x / size.width) * 2 * math.pi + waveProgress * 2 * math.pi) * 20;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

// GoRouter Premium Page Builder
Page<T> buildPremiumPage<T>({
  required Widget child,
  PageTransitionType transitionType = PageTransitionType.healthSlide,
  Duration duration = const Duration(milliseconds: 400),
  Duration reverseDuration = const Duration(milliseconds: 300),
  Curve curve = Curves.easeInOutCubic,
  String? healthContext,
  bool maintainState = true,
  LocalKey? key,
  String? name,
  Object? arguments,
}) {
  return CustomTransitionPage<T>(
    key: key,
    name: name,
    arguments: arguments,
    child: child,
    maintainState: maintainState,
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return _buildTransition(
        context,
        animation,
        secondaryAnimation,
        child,
        transitionType,
        curve,
        healthContext,
      );
    },
  );
}

// Utility Extension for Easy Navigation
extension HealthNavigation on BuildContext {
  Future<T?> pushHealthPage<T extends Object?>(
    Widget page, {
    String? healthContext,
    PageTransitionType transition = PageTransitionType.healthSlide,
    Duration? duration,
  }) {
    return Navigator.of(this).push<T>(
      PremiumPageRoute<T>(
        child: page,
        transitionType: transition,
        healthContext: healthContext,
        duration: duration ?? const Duration(milliseconds: 400),
      ),
    );
  }

  Future<T?> replaceHealthPage<T extends Object?, TO extends Object?>(
    Widget page, {
    String? healthContext,
    PageTransitionType transition = PageTransitionType.healthSlide,
    Duration? duration,
    TO? result,
  }) {
    return Navigator.of(this).pushReplacement<T, TO>(
      PremiumPageRoute<T>(
        child: page,
        transitionType: transition,
        healthContext: healthContext,
        duration: duration ?? const Duration(milliseconds: 400),
      ),
      result: result,
    );
  }
}