import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Helper class for managing staggered animations
class StaggeredAnimationHelper {
  static List<Animation<double>> createStaggeredAnimations({
    required AnimationController controller,
    required int itemCount,
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    final totalDuration = controller.duration!;
    
    return List.generate(itemCount, (index) {
      final start = (index * staggerDelay.inMilliseconds) / totalDuration.inMilliseconds;
      final end = math.min(1.0, start + 0.6);
      
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });
  }
}

// Staggered List Animation Widget
class StaggeredListView extends StatefulWidget {
  final List<Widget> children;
  final Duration animationDuration;
  final Duration staggerDelay;
  final Curve curve;
  final EdgeInsetsGeometry? padding;
  final bool reverse;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final StaggeredAnimationType animationType;
  final String? healthContext;
  
  const StaggeredListView({
    super.key,
    required this.children,
    this.animationDuration = const Duration(milliseconds: 800),
    this.staggerDelay = const Duration(milliseconds: 100),
    this.curve = Curves.easeOutCubic,
    this.padding,
    this.reverse = false,
    this.physics,
    this.shrinkWrap = false,
    this.animationType = StaggeredAnimationType.slideUp,
    this.healthContext,
  });
  
  @override
  State<StaggeredListView> createState() => _StaggeredListViewState();
}

class _StaggeredListViewState extends State<StaggeredListView>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    // Start animation after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _controller.forward();
        }
      });
    });
  }
  
  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    final itemCount = widget.children.length;
    _animations = <Animation<double>>[];
    _slideAnimations = <Animation<Offset>>[];
    _scaleAnimations = <Animation<double>>[];
    _fadeAnimations = <Animation<double>>[];
    
    for (int i = 0; i < itemCount; i++) {
      final start = (i * widget.staggerDelay.inMilliseconds) / 
                    widget.animationDuration.inMilliseconds;
      final end = math.min(1.0, start + 0.6);
      
      final interval = Interval(start, end, curve: widget.curve);
      final animation = CurvedAnimation(parent: _controller, curve: interval);
      
      _animations.add(animation);
      
      // Different animation types
      switch (widget.animationType) {
        case StaggeredAnimationType.slideUp:
          _slideAnimations.add(
            Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
                .animate(animation)
          );
          break;
        case StaggeredAnimationType.slideLeft:
          _slideAnimations.add(
            Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero)
                .animate(animation)
          );
          break;
        case StaggeredAnimationType.slideRight:
          _slideAnimations.add(
            Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero)
                .animate(animation)
          );
          break;
        case StaggeredAnimationType.scale:
          _scaleAnimations.add(
            Tween<double>(begin: 0.0, end: 1.0).animate(animation)
          );
          break;
        case StaggeredAnimationType.fade:
          _fadeAnimations.add(
            Tween<double>(begin: 0.0, end: 1.0).animate(animation)
          );
          break;
        case StaggeredAnimationType.combined:
          _slideAnimations.add(
            Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                .animate(animation)
          );
          _scaleAnimations.add(
            Tween<double>(begin: 0.8, end: 1.0).animate(animation)
          );
          _fadeAnimations.add(
            Tween<double>(begin: 0.0, end: 1.0).animate(animation)
          );
          break;
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListView.builder(
      padding: widget.padding,
      reverse: widget.reverse,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return _buildAnimatedItem(index, theme);
          },
        );
      },
    );
  }
  
  Widget _buildAnimatedItem(int index, ThemeData theme) {
    final child = widget.children[index];
    
    switch (widget.animationType) {
      case StaggeredAnimationType.slideUp:
      case StaggeredAnimationType.slideLeft:
      case StaggeredAnimationType.slideRight:
        return SlideTransition(
          position: _slideAnimations[index],
          child: FadeTransition(
            opacity: _animations[index],
            child: _addHealthContextGlow(child, index, theme),
          ),
        );
        
      case StaggeredAnimationType.scale:
        return ScaleTransition(
          scale: _scaleAnimations[index],
          child: FadeTransition(
            opacity: _animations[index],
            child: _addHealthContextGlow(child, index, theme),
          ),
        );
        
      case StaggeredAnimationType.fade:
        return FadeTransition(
          opacity: _fadeAnimations[index],
          child: _addHealthContextGlow(child, index, theme),
        );
        
      case StaggeredAnimationType.combined:
        return SlideTransition(
          position: _slideAnimations[index],
          child: ScaleTransition(
            scale: _scaleAnimations[index],
            child: FadeTransition(
              opacity: _fadeAnimations[index],
              child: _addHealthContextGlow(child, index, theme),
            ),
          ),
        );
    }
  }
  
  Widget _addHealthContextGlow(Widget child, int index, ThemeData theme) {
    if (widget.healthContext == null) return child;
    
    final glowIntensity = _animations[index].value;
    final contextColor = _getHealthContextColor(widget.healthContext!, theme);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        boxShadow: glowIntensity > 0.5
            ? [
                BoxShadow(
                  color: contextColor.withValues(alpha: 0.1 * glowIntensity),
                  blurRadius: 8 * glowIntensity,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: child,
    );
  }
  
  Color _getHealthContextColor(String context, ThemeData theme) {
    switch (context.toLowerCase()) {
      case 'medication':
        return const Color(0xFFFFC107);
      case 'heart':
      case 'cardio':
        return const Color(0xFFE91E63);
      case 'wellness':
        return const Color(0xFF9C27B0);
      case 'nutrition':
        return const Color(0xFF4CAF50);
      case 'fitness':
        return const Color(0xFF03A9F4);
      default:
        return theme.colorScheme.primary;
    }
  }
}

enum StaggeredAnimationType {
  slideUp,
  slideLeft,
  slideRight,
  scale,
  fade,
  combined,
}

// Parallax Scroll Effect Widget
class ParallaxContainer extends StatefulWidget {
  final Widget child;
  final Widget? background;
  final double parallaxFactor;
  final bool enableParallax;
  final String? healthContext;
  
  const ParallaxContainer({
    super.key,
    required this.child,
    this.background,
    this.parallaxFactor = 0.5,
    this.enableParallax = true,
    this.healthContext,
  });
  
  @override
  State<ParallaxContainer> createState() => _ParallaxContainerState();
}

class _ParallaxContainerState extends State<ParallaxContainer> {
  double _scrollOffset = 0.0;
  
  @override
  Widget build(BuildContext context) {
    if (!widget.enableParallax) {
      return widget.child;
    }
    
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollUpdateNotification) {
          setState(() {
            _scrollOffset = notification.metrics.pixels;
          });
        }
        return false;
      },
      child: Stack(
        children: [
          // Background with parallax effect
          if (widget.background != null)
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, _scrollOffset * widget.parallaxFactor),
                child: widget.background!,
              ),
            ),
          
          // Foreground content
          widget.child,
        ],
      ),
    );
  }
}

// Health-themed Parallax Background
class HealthParallaxBackground extends StatefulWidget {
  final String healthContext;
  final double opacity;
  
  const HealthParallaxBackground({
    super.key,
    required this.healthContext,
    this.opacity = 0.1,
  });
  
  @override
  State<HealthParallaxBackground> createState() => _HealthParallaxBackgroundState();
}

class _HealthParallaxBackgroundState extends State<HealthParallaxBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AppTheme.getHealthContextGradient(
                  widget.healthContext,
                  isDark: isDarkMode,
                ).begin,
                end: AppTheme.getHealthContextGradient(
                  widget.healthContext,
                  isDark: isDarkMode,
                ).end,
                colors: AppTheme.getHealthContextGradient(
                  widget.healthContext,
                  isDark: isDarkMode,
                ).colors.map((color) => color.withValues(alpha: widget.opacity)).toList(),
              ),
            ),
            child: CustomPaint(
              painter: HealthPatternPainter(
                context: widget.healthContext,
                isDark: isDarkMode,
                opacity: widget.opacity,
              ),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }
}

// Custom painter for health-themed background patterns
class HealthPatternPainter extends CustomPainter {
  final String context;
  final bool isDark;
  final double opacity;
  
  HealthPatternPainter({
    required this.context,
    required this.isDark,
    required this.opacity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    switch (context.toLowerCase()) {
      case 'heart':
      case 'cardio':
        _drawHeartPattern(canvas, size, paint);
        break;
      case 'medication':
        _drawPillPattern(canvas, size, paint);
        break;
      case 'nutrition':
        _drawLeafPattern(canvas, size, paint);
        break;
      case 'fitness':
        _drawWavePattern(canvas, size, paint);
        break;
      default:
        _drawCirclePattern(canvas, size, paint);
    }
  }
  
  void _drawHeartPattern(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFFE91E63).withValues(alpha: opacity);
    
    for (double x = 0; x < size.width; x += 100) {
      for (double y = 0; y < size.height; y += 100) {
        _drawHeart(canvas, Offset(x, y), 15, paint);
      }
    }
  }
  
  void _drawPillPattern(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFFFFC107).withValues(alpha: opacity);
    
    for (double x = 0; x < size.width; x += 80) {
      for (double y = 0; y < size.height; y += 80) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(x, y), width: 30, height: 15),
            const Radius.circular(7.5),
          ),
          paint,
        );
      }
    }
  }
  
  void _drawLeafPattern(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF4CAF50).withValues(alpha: opacity);
    
    for (double x = 0; x < size.width; x += 120) {
      for (double y = 0; y < size.height; y += 120) {
        _drawLeaf(canvas, Offset(x, y), 20, paint);
      }
    }
  }
  
  void _drawWavePattern(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF03A9F4).withValues(alpha: opacity);
    
    for (double y = 0; y < size.height; y += 60) {
      final path = Path();
      path.moveTo(0, y);
      
      for (double x = 0; x <= size.width; x += 20) {
        final waveY = y + math.sin(x / 40) * 10;
        path.lineTo(x, waveY);
      }
      
      canvas.drawPath(path, paint);
    }
  }
  
  void _drawCirclePattern(Canvas canvas, Size size, Paint paint) {
    paint.color = (isDark ? Colors.white : Colors.black).withValues(alpha: opacity);
    
    for (double x = 0; x < size.width; x += 100) {
      for (double y = 0; y < size.height; y += 100) {
        canvas.drawCircle(Offset(x, y), 10, paint);
      }
    }
  }
  
  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    // Simple heart shape
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(
      center.dx - size * 0.5, center.dy - size * 0.2,
      center.dx - size * 0.5, center.dy - size * 0.6,
      center.dx, center.dy - size * 0.3,
    );
    path.cubicTo(
      center.dx + size * 0.5, center.dy - size * 0.6,
      center.dx + size * 0.5, center.dy - size * 0.2,
      center.dx, center.dy + size * 0.3,
    );
    
    canvas.drawPath(path, paint);
  }
  
  void _drawLeaf(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    // Simple leaf shape
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(
      center.dx + size * 0.7, center.dy - size * 0.5,
      center.dx, center.dy + size,
    );
    path.quadraticBezierTo(
      center.dx - size * 0.7, center.dy - size * 0.5,
      center.dx, center.dy - size,
    );
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Premium Staggered Grid for Health Cards
class HealthStaggeredGrid extends StatefulWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final Duration animationDuration;
  final Duration staggerDelay;
  final String? healthContext;
  
  const HealthStaggeredGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.padding,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.staggerDelay = const Duration(milliseconds: 150),
    this.healthContext,
  });
  
  @override
  State<HealthStaggeredGrid> createState() => _HealthStaggeredGridState();
}

class _HealthStaggeredGridState extends State<HealthStaggeredGrid>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _animations = List.generate(widget.children.length, (index) {
      final start = (index * widget.staggerDelay.inMilliseconds) / 
                    widget.animationDuration.inMilliseconds;
      final end = math.min(1.0, start + 0.8);
      
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          mainAxisSpacing: widget.mainAxisSpacing,
          crossAxisSpacing: widget.crossAxisSpacing,
          childAspectRatio: 1.0,
        ),
        itemCount: widget.children.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _animations[index].value,
                child: Opacity(
                  opacity: _animations[index].value,
                  child: widget.children[index],
                ),
              );
            },
          );
        },
      ),
    );
  }
}