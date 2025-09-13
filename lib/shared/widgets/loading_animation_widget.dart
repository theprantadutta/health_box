import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingAnimationWidget extends StatefulWidget {
  final String? message;
  final double size;
  final LoadingStyle style;
  final String? healthContext; // New: Health context for themed animations
  final Color? primaryColor;
  final Color? accentColor;
  final bool showParticles;

  const LoadingAnimationWidget({
    super.key,
    this.message,
    this.size = 50.0,
    this.style = LoadingStyle.gradient,
    this.healthContext,
    this.primaryColor,
    this.accentColor,
    this.showParticles = false,
  });

  @override
  State<LoadingAnimationWidget> createState() => _LoadingAnimationWidgetState();
}

class _LoadingAnimationWidgetState extends State<LoadingAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _heartbeatController;
  late AnimationController _breathingController;
  late AnimationController _particleController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _heartbeatAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Standard rotation controller
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Pulse controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    // Scale controller for breathing effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Heartbeat controller (for cardio context)
    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();

    // Breathing controller (for wellness/meditation context)
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);

    // Particle controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Set up animations
    _rotationAnimation = CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    );

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    );

    // Heartbeat animation with double beat
    _heartbeatAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
          .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 0.9)
          .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.15)
          .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
          .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_heartbeatController);

    _breathingAnimation = CurvedAnimation(
      parent: _breathingController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
    );

    _particleAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    _heartbeatController.dispose();
    _breathingController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Particle effects background
              if (widget.showParticles)
                SizedBox(
                  width: widget.size * 2,
                  height: widget.size * 2,
                  child: _buildParticleEffect(theme),
                ),
              
              // Main loading indicator
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: _buildHealthThemedIndicator(theme, isDarkMode),
              ),
            ],
          ),
          
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.98 + (0.04 * _pulseAnimation.value),
                  child: Opacity(
                    opacity: 0.7 + (0.3 * _pulseAnimation.value),
                    child: Text(
                      widget.message!,
                      style: AppTheme.getBodyMedium(context, theme).copyWith(
                        color: _getContextColor(theme, isDarkMode),
                        fontWeight: FontWeight.w500,
                        shadows: isDarkMode ? [
                          Shadow(
                            color: _getContextColor(theme, isDarkMode).withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ] : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthThemedIndicator(ThemeData theme, bool isDarkMode) {
    // Choose animation based on health context
    if (widget.healthContext != null) {
      switch (widget.healthContext!.toLowerCase()) {
        case 'heart':
        case 'cardio':
        case 'blood_pressure':
          return _buildHeartbeatIndicator(theme, isDarkMode);
        case 'wellness':
        case 'mental_health':
        case 'meditation':
          return _buildBreathingIndicator(theme, isDarkMode);
        case 'medication':
        case 'pharmacy':
          return _buildPillIndicator(theme, isDarkMode);
        case 'nutrition':
        case 'diet':
          return _buildNutritionIndicator(theme, isDarkMode);
        case 'fitness':
        case 'exercise':
          return _buildFitnessIndicator(theme, isDarkMode);
      }
    }

    // Default to enhanced style-based indicators
    switch (widget.style) {
      case LoadingStyle.gradient:
        return _buildEnhancedGradientIndicator(theme, isDarkMode);
      case LoadingStyle.pulse:
        return _buildPulseIndicator(theme, isDarkMode);
      case LoadingStyle.dots:
        return _buildDotsIndicator(theme, isDarkMode);
      case LoadingStyle.simple:
        return _buildSimpleIndicator(theme, isDarkMode);
      case LoadingStyle.shimmer:
        return _buildShimmerIndicator(theme, isDarkMode);
      case LoadingStyle.orbit:
        return _buildOrbitIndicator(theme, isDarkMode);
    }
  }

  // Enhanced gradient indicator with premium effects
  Widget _buildEnhancedGradientIndicator(ThemeData theme, bool isDarkMode) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * _scaleAnimation.value),
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * math.pi,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.getPremiumPrimaryGradient(isDarkMode),
                boxShadow: [
                  BoxShadow(
                    color: _getContextColor(theme, isDarkMode).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  strokeCap: StrokeCap.round,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Heartbeat indicator for cardio context
  Widget _buildHeartbeatIndicator(ThemeData theme, bool isDarkMode) {
    return AnimatedBuilder(
      animation: _heartbeatAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _heartbeatAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.getHeartGradient(),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE91E63).withValues(alpha: 0.4 * _heartbeatAnimation.value),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.favorite,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  // Breathing indicator for wellness/meditation
  Widget _buildBreathingIndicator(ThemeData theme, bool isDarkMode) {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        final breathScale = 0.7 + (0.3 * _breathingAnimation.value);
        final breathOpacity = 0.6 + (0.4 * _breathingAnimation.value);
        
        return Transform.scale(
          scale: breathScale,
          child: Opacity(
            opacity: breathOpacity,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.getPurpleMystiqueGradient(),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withValues(alpha: 0.3 * breathOpacity),
                    blurRadius: 30 * _breathingAnimation.value,
                    spreadRadius: 5 * _breathingAnimation.value,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.spa,
                  color: Colors.white.withValues(alpha: breathOpacity),
                  size: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Pill indicator for medication context
  Widget _buildPillIndicator(ThemeData theme, bool isDarkMode) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * _pulseAnimation.value),
          child: Transform.rotate(
            angle: _rotationAnimation.value * math.pi / 2, // Slower rotation
            child: Container(
              width: widget.size,
              height: widget.size * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size * 0.3),
                gradient: AppTheme.getVitalityGradient(),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.medication,
                  color: Colors.white,
                  size: widget.size * 0.4,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Nutrition indicator with leaf animation
  Widget _buildNutritionIndicator(ThemeData theme, bool isDarkMode) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: 0.85 + (0.15 * _scaleAnimation.value),
          child: Transform.rotate(
            angle: _rotationAnimation.value * math.pi / 6, // Gentle sway
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.getNatureGradient(),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    blurRadius: 25,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Fitness indicator with dynamic movement
  Widget _buildFitnessIndicator(ThemeData theme, bool isDarkMode) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * _pulseAnimation.value),
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * math.pi,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.getSkyGradient(),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF03A9F4).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Enhanced pulse indicator
  Widget _buildPulseIndicator(ThemeData theme, bool isDarkMode) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _pulseAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.getPremiumPrimaryGradient(isDarkMode),
              boxShadow: [
                BoxShadow(
                  color: _getContextColor(theme, isDarkMode).withValues(alpha: 0.4 * _pulseAnimation.value),
                  blurRadius: 20 * _pulseAnimation.value,
                  spreadRadius: 3 * _pulseAnimation.value,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.favorite,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  // Enhanced dots indicator
  Widget _buildDotsIndicator(ThemeData theme, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            final delay = index * 0.33;
            final animationValue = (_rotationAnimation.value + delay) % 1.0;
            final scale = 0.4 + (0.6 * (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0));
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _getContextColor(theme, isDarkMode),
                        _getContextColor(theme, isDarkMode).withValues(alpha: 0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getContextColor(theme, isDarkMode).withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // Simple indicator with premium styling
  Widget _buildSimpleIndicator(ThemeData theme, bool isDarkMode) {
    return CircularProgressIndicator(
      strokeWidth: 4,
      strokeCap: StrokeCap.round,
      valueColor: AlwaysStoppedAnimation<Color>(_getContextColor(theme, isDarkMode)),
      backgroundColor: _getContextColor(theme, isDarkMode).withValues(alpha: 0.2),
    );
  }

  // Shimmer loading indicator
  Widget _buildShimmerIndicator(ThemeData theme, bool isDarkMode) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.getShimmerGradient(
              baseColor: theme.colorScheme.surfaceContainerHighest,
              highlightColor: _getContextColor(theme, isDarkMode).withValues(alpha: 0.3),
            ),
          ),
        );
      },
    );
  }

  // Orbit indicator with rotating elements
  Widget _buildOrbitIndicator(ThemeData theme, bool isDarkMode) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Center core
            Container(
              width: widget.size * 0.3,
              height: widget.size * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getContextColor(theme, isDarkMode),
              ),
            ),
            // Orbiting elements
            for (int i = 0; i < 3; i++)
              Transform.rotate(
                angle: (_rotationAnimation.value * 2 * math.pi) + (i * 2 * math.pi / 3),
                child: Transform.translate(
                  offset: Offset(widget.size * 0.25, 0),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getContextColor(theme, isDarkMode).withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Particle effect for background
  Widget _buildParticleEffect(ThemeData theme) {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(
            animationValue: _particleAnimation.value,
            color: _getContextColor(theme, theme.brightness == Brightness.dark),
          ),
        );
      },
    );
  }

  // Get context-specific color
  Color _getContextColor(ThemeData theme, bool isDarkMode) {
    if (widget.primaryColor != null) return widget.primaryColor!;
    
    if (widget.healthContext != null) {
      switch (widget.healthContext!.toLowerCase()) {
        case 'heart':
        case 'cardio':
          return const Color(0xFFE91E63);
        case 'wellness':
        case 'mental_health':
          return const Color(0xFF9C27B0);
        case 'medication':
          return const Color(0xFFFFC107);
        case 'nutrition':
          return const Color(0xFF4CAF50);
        case 'fitness':
          return const Color(0xFF03A9F4);
        case 'emergency':
          return theme.colorScheme.error;
      }
    }
    
    return theme.colorScheme.primary;
  }
}

enum LoadingStyle {
  simple,
  gradient,
  pulse,
  dots,
  shimmer,
  orbit,
}

// Custom painter for particle effects
class ParticlesPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  static const int particleCount = 20;

  const ParticlesPainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent particles
    
    for (int i = 0; i < particleCount; i++) {
      final particlePhase = (animationValue + i / particleCount) % 1.0;
      final angle = random.nextDouble() * 2 * math.pi;
      final radius = size.width * 0.5 * particlePhase;
      
      final x = size.width * 0.5 + math.cos(angle) * radius;
      final y = size.height * 0.5 + math.sin(angle) * radius;
      
      final opacity = (1 - particlePhase) * 0.6;
      final particleSize = 2.0 + (3.0 * (1 - particlePhase));
      
      paint.color = color.withValues(alpha: opacity);
      
      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.color != color;
  }
}