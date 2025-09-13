import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Advanced Parallax Scroll Widget
class PremiumParallaxScroll extends StatefulWidget {
  final List<ParallaxLayer> layers;
  final Widget child;
  final ScrollController? controller;
  final String? healthContext;
  final bool enableHealthEffects;
  
  const PremiumParallaxScroll({
    super.key,
    required this.layers,
    required this.child,
    this.controller,
    this.healthContext,
    this.enableHealthEffects = true,
  });
  
  @override
  State<PremiumParallaxScroll> createState() => _PremiumParallaxScrollState();
}

class _PremiumParallaxScrollState extends State<PremiumParallaxScroll>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  
  double _scrollOffset = 0.0;
  bool _isOwnerOfController = false;
  
  @override
  void initState() {
    super.initState();
    
    _scrollController = widget.controller ?? ScrollController();
    _isOwnerOfController = widget.controller == null;
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));
    
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (_isOwnerOfController) {
      _scrollController.dispose();
    }
    _backgroundController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (mounted) {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Parallax Layers
        ...widget.layers.map((layer) => _buildParallaxLayer(layer, theme, isDarkMode)),
        
        // Health Context Background Effects
        if (widget.enableHealthEffects && widget.healthContext != null)
          _buildHealthBackgroundEffects(theme, isDarkMode),
        
        // Main Scrollable Content
        SingleChildScrollView(
          controller: _scrollController,
          child: widget.child,
        ),
      ],
    );
  }
  
  Widget _buildParallaxLayer(ParallaxLayer layer, ThemeData theme, bool isDarkMode) {
    final parallaxOffset = _scrollOffset * layer.parallaxFactor;
    
    return Positioned.fill(
      child: Transform.translate(
        offset: Offset(0, parallaxOffset),
        child: Opacity(
          opacity: layer.opacity,
          child: layer.child,
        ),
      ),
    );
  }
  
  Widget _buildHealthBackgroundEffects(ThemeData theme, bool isDarkMode) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: HealthParallaxPainter(
              context: widget.healthContext!,
              isDark: isDarkMode,
              animationValue: _backgroundAnimation.value,
              scrollOffset: _scrollOffset,
            ),
          ),
        );
      },
    );
  }
}

// Parallax Layer Configuration
class ParallaxLayer {
  final Widget child;
  final double parallaxFactor;
  final double opacity;
  final BlendMode? blendMode;
  
  const ParallaxLayer({
    required this.child,
    required this.parallaxFactor,
    this.opacity = 1.0,
    this.blendMode,
  });
}

// Scroll-based Card Reveal Animation
class ScrollRevealWidget extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;
  final Curve curve;
  final double revealOffset;
  final RevealDirection direction;
  final bool enableHealthGlow;
  final String? healthContext;
  
  const ScrollRevealWidget({
    super.key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.revealOffset = 0.3,
    this.direction = RevealDirection.up,
    this.enableHealthGlow = false,
    this.healthContext,
  });
  
  @override
  State<ScrollRevealWidget> createState() => _ScrollRevealWidgetState();
}

class _ScrollRevealWidgetState extends State<ScrollRevealWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isVisible = false;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    
    _slideAnimation = Tween<Offset>(
      begin: _getBeginOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Offset _getBeginOffset() {
    switch (widget.direction) {
      case RevealDirection.up:
        return Offset(0, widget.revealOffset);
      case RevealDirection.down:
        return Offset(0, -widget.revealOffset);
      case RevealDirection.left:
        return Offset(widget.revealOffset, 0);
      case RevealDirection.right:
        return Offset(-widget.revealOffset, 0);
    }
  }
  
  void _checkVisibility() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      final screenHeight = MediaQuery.of(context).size.height;
      
      final isInView = position.dy < screenHeight * 0.8 && 
                       position.dy + size.height > 0;
      
      if (isInView && !_isVisible) {
        setState(() {
          _isVisible = true;
        });
        _controller.forward();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
    
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _checkVisibility();
        return false;
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          Widget animatedChild = SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: widget.child,
              ),
            ),
          );
          
          // Add health glow effect if enabled
          if (widget.enableHealthGlow && widget.healthContext != null) {
            animatedChild = _addHealthGlow(animatedChild);
          }
          
          return animatedChild;
        },
      ),
    );
  }
  
  Widget _addHealthGlow(Widget child) {
    final theme = Theme.of(context);
    final contextColor = _getHealthContextColor(widget.healthContext!, theme);
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: contextColor.withValues(alpha: 0.2 * _glowAnimation.value),
                blurRadius: 20 * _glowAnimation.value,
                spreadRadius: 2 * _glowAnimation.value,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
  
  Color _getHealthContextColor(String context, ThemeData theme) {
    switch (context.toLowerCase()) {
      case 'medication':
        return const Color(0xFFFFC107);
      case 'heart':
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

enum RevealDirection { up, down, left, right }

// Floating Action Button with Scroll-based Animation
class ScrollAwareFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final String? healthContext;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double scrollThreshold;
  
  const ScrollAwareFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.healthContext,
    this.backgroundColor,
    this.foregroundColor,
    this.scrollThreshold = 100.0,
  });
  
  @override
  State<ScrollAwareFAB> createState() => _ScrollAwareFABState();
}

class _ScrollAwareFABState extends State<ScrollAwareFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isVisible = false;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onScrollUpdate(double scrollOffset) {
    final shouldShow = scrollOffset > widget.scrollThreshold;
    
    if (shouldShow != _isVisible) {
      setState(() {
        _isVisible = shouldShow;
      });
      
      if (shouldShow) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          _onScrollUpdate(notification.metrics.pixels);
        }
        return false;
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: Transform.rotate(
                angle: _rotationAnimation.value * math.pi / 4,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.healthContext != null
                        ? AppTheme.getHealthContextGradient(
                            widget.healthContext!,
                            isDark: isDarkMode,
                          )
                        : null,
                    boxShadow: widget.healthContext != null
                        ? AppTheme.getHealthContextShadow(widget.healthContext!, isDarkMode)
                        : AppTheme.getFloatingShadow(isDarkMode),
                  ),
                  child: FloatingActionButton(
                    onPressed: widget.onPressed,
                    tooltip: widget.tooltip,
                    backgroundColor: widget.backgroundColor ?? Colors.transparent,
                    foregroundColor: widget.foregroundColor ?? Colors.white,
                    elevation: 0,
                    child: Icon(widget.icon),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom Painter for Health-themed Parallax Backgrounds
class HealthParallaxPainter extends CustomPainter {
  final String context;
  final bool isDark;
  final double animationValue;
  final double scrollOffset;
  
  HealthParallaxPainter({
    required this.context,
    required this.isDark,
    required this.animationValue,
    required this.scrollOffset,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Create flowing particle effect based on health context
    switch (context.toLowerCase()) {
      case 'heart':
        _drawFloatingHearts(canvas, size, paint);
        break;
      case 'medication':
        _drawFloatingPills(canvas, size, paint);
        break;
      case 'nutrition':
        _drawFloatingLeaves(canvas, size, paint);
        break;
      case 'fitness':
        _drawEnergyWaves(canvas, size, paint);
        break;
      default:
        _drawFloatingDots(canvas, size, paint);
    }
  }
  
  void _drawFloatingHearts(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFFE91E63).withValues(alpha: 0.1);
    
    for (int i = 0; i < 15; i++) {
      final x = (i * 100.0 + animationValue * 50) % (size.width + 100);
      final y = (i * 80.0 - scrollOffset * 0.3) % (size.height + 100);
      final heartSize = 10 + math.sin(animationValue * 2 + i) * 5;
      
      _drawHeart(canvas, Offset(x, y), heartSize, paint);
    }
  }
  
  void _drawFloatingPills(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFFFFC107).withValues(alpha: 0.15);
    
    for (int i = 0; i < 20; i++) {
      final x = (i * 80.0 + animationValue * 30) % (size.width + 100);
      final y = (i * 60.0 - scrollOffset * 0.2) % (size.height + 100);
      final rotation = animationValue * 2 + i;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-15, -8, 30, 16),
          const Radius.circular(8),
        ),
        paint,
      );
      canvas.restore();
    }
  }
  
  void _drawFloatingLeaves(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF4CAF50).withValues(alpha: 0.12);
    
    for (int i = 0; i < 18; i++) {
      final x = (i * 90.0 + animationValue * 40) % (size.width + 100);
      final y = (i * 70.0 - scrollOffset * 0.25) % (size.height + 100);
      final leafSize = 12 + math.sin(animationValue + i * 0.5) * 3;
      
      _drawLeaf(canvas, Offset(x, y), leafSize, paint);
    }
  }
  
  void _drawEnergyWaves(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(0xFF03A9F4).withValues(alpha: 0.1);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final yOffset = i * size.height / 5 - scrollOffset * 0.1;
      
      path.moveTo(-50, yOffset);
      
      for (double x = -50; x <= size.width + 50; x += 10) {
        final wave = math.sin((x / 100) + animationValue * 4 + i) * 30;
        path.lineTo(x, yOffset + wave);
      }
      
      canvas.drawPath(path, paint);
    }
  }
  
  void _drawFloatingDots(Canvas canvas, Size size, Paint paint) {
    paint.color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05);
    
    for (int i = 0; i < 25; i++) {
      final x = (i * 75.0 + animationValue * 25) % (size.width + 100);
      final y = (i * 50.0 - scrollOffset * 0.15) % (size.height + 100);
      final radius = 3 + math.sin(animationValue * 3 + i) * 2;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
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
  bool shouldRepaint(HealthParallaxPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.scrollOffset != scrollOffset;
  }
}