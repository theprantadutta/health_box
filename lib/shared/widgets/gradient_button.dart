import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RipplePainter extends CustomPainter {
  const RipplePainter({
    required this.animation,
    required this.color,
  });

  final Animation<double> animation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value == 0) return;

    final paint = Paint()
      ..color = color.withValues(alpha: (1 - animation.value) * color.alpha)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * animation.value * 0.8;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
           oldDelegate.color != color;
  }
}

class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient,
    this.style = GradientButtonStyle.primary,
    this.size = GradientButtonSize.medium,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height,
    this.borderRadius,
    this.elevation,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Gradient? gradient;
  final GradientButtonStyle style;
  final GradientButtonSize size;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double? elevation;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _rippleController;
  late AnimationController _glowController;
  late AnimationController _bounceController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    // Press animation controller
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Ripple animation controller
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Glow animation controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Bounce/Success animation controller
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Scale animation (press effect)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    // Ripple animation
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOutCirc,
    ));

    // Glow animation (hover effect)
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Bounce animation (success feedback)
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    // Shadow animation
    _shadowAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    // Color animation for hover
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.white.withValues(alpha: 0.1),
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pressController.dispose();
    _rippleController.dispose();
    _glowController.dispose();
    _bounceController.dispose();
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
    final effectiveBorderRadius = widget.borderRadius ?? 
        BorderRadius.circular(effectiveHeight / 2);
    
    // Get premium gradient based on style
    final gradient = widget.gradient ?? _getPremiumStyleGradient(isDarkMode);
    
    // Get text color based on style
    final textColor = _getTextColor();
    
    final isActive = widget.enabled && widget.onPressed != null;
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _rippleAnimation,
        _glowAnimation,
        _bounceAnimation,
        _shadowAnimation,
        _colorAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _bounceAnimation.value,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Glow effect (hover)
              if (_glowAnimation.value > 0)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: effectiveBorderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3 * _glowAnimation.value,
                          ),
                          blurRadius: 20 * _glowAnimation.value,
                          spreadRadius: 2 * _glowAnimation.value,
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Main button
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: effectiveWidth,
                height: effectiveHeight,
                decoration: BoxDecoration(
                  gradient: isActive ? gradient : _getDisabledGradient(theme),
                  borderRadius: effectiveBorderRadius,
                  boxShadow: isActive 
                      ? _getPremiumStyleShadows(isDarkMode).map((shadow) => BoxShadow(
                          color: shadow.color.withValues(
                            alpha: shadow.color.alpha * _shadowAnimation.value,
                          ),
                          offset: shadow.offset * _shadowAnimation.value,
                          blurRadius: shadow.blurRadius * _shadowAnimation.value,
                          spreadRadius: shadow.spreadRadius,
                        )).toList()
                      : null,
                ),
                child: Stack(
                  children: [
                    // Ripple effect
                    if (_rippleAnimation.value > 0)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: effectiveBorderRadius,
                          child: CustomPaint(
                            painter: RipplePainter(
                              animation: _rippleAnimation,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                    
                    // Hover overlay
                    if (_colorAnimation.value != null)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _colorAnimation.value,
                            borderRadius: effectiveBorderRadius,
                          ),
                        ),
                      ),
                    
                    // Button content
                    Material(
                      color: Colors.transparent,
                      borderRadius: effectiveBorderRadius,
                      child: Semantics(
                        button: true,
                        enabled: isActive,
                        child: InkWell(
                          borderRadius: effectiveBorderRadius,
                          onTap: isActive && !widget.isLoading ? () async {
                            // Trigger ripple and press animations
                            _rippleController.forward(from: 0);
                            await _pressController.forward();
                            
                            // Call the callback
                            widget.onPressed!();
                            
                            // Trigger success bounce
                            _bounceController.forward(from: 0);
                            await _pressController.reverse();
                          } : null,
                          onTapDown: isActive ? (_) {
                            setState(() => _isPressed = true);
                            _pressController.forward();
                          } : null,
                          onTapUp: (_) {
                            setState(() => _isPressed = false);
                          },
                          onTapCancel: () {
                            setState(() => _isPressed = false);
                            _pressController.reverse();
                          },
                          onHover: (hovering) {
                            setState(() => _isHovered = hovering);
                            if (hovering) {
                              _glowController.forward();
                            } else {
                              _glowController.reverse();
                            }
                          },
                          child: Container(
                            padding: dimensions.padding,
                            child: _buildButtonContent(textColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (widget.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Premium loading spinner
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          const SizedBox(width: 12),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              shadows: _isHovered ? [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ] : null,
            ),
            child: widget.child,
          ),
        ],
      );
    }

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated text with premium styling
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: _getButtonDimensions().height * 0.32, // Responsive font size
              letterSpacing: 0.5,
              shadows: _isHovered ? [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ] : null,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(
                _isPressed ? 0.95 : 1.0,
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  ButtonDimensions _getButtonDimensions() {
    switch (widget.size) {
      case GradientButtonSize.small:
        return const ButtonDimensions(
          height: 32,
          width: null,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      case GradientButtonSize.medium:
        return const ButtonDimensions(
          height: 44,
          width: null,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        );
      case GradientButtonSize.large:
        return const ButtonDimensions(
          height: 56,
          width: null,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        );
    }
  }

  Gradient _getStyleGradient(bool isDarkMode) {
    switch (widget.style) {
      case GradientButtonStyle.primary:
        return AppTheme.getPrimaryGradient(isDarkMode);
      case GradientButtonStyle.success:
        return AppTheme.getSuccessGradient();
      case GradientButtonStyle.warning:
        return AppTheme.getWarningGradient();
      case GradientButtonStyle.error:
        return AppTheme.getErrorGradient();
    }
  }

  // Premium gradients for enhanced button styles
  Gradient _getPremiumStyleGradient(bool isDarkMode) {
    switch (widget.style) {
      case GradientButtonStyle.primary:
        return AppTheme.getPremiumPrimaryGradient(isDarkMode);
      case GradientButtonStyle.success:
        return AppTheme.getAuroraSuccessGradient();
      case GradientButtonStyle.warning:
        return AppTheme.getSunsetFireGradient();
      case GradientButtonStyle.error:
        return AppTheme.getErrorGradient();
    }
  }

  // Premium shadows for enhanced button styles
  List<BoxShadow> _getPremiumStyleShadows(bool isDarkMode) {
    switch (widget.style) {
      case GradientButtonStyle.primary:
        return AppTheme.getElevatedShadow(isDarkMode);
      case GradientButtonStyle.success:
        return AppTheme.getSuccessShadow(isDarkMode);
      case GradientButtonStyle.warning:
        return AppTheme.getWarningShadow(isDarkMode);
      case GradientButtonStyle.error:
        return AppTheme.getErrorShadow(isDarkMode);
    }
  }

  Color _getTextColor() {
    switch (widget.style) {
      case GradientButtonStyle.primary:
      case GradientButtonStyle.success:
      case GradientButtonStyle.error:
        return Colors.white;
      case GradientButtonStyle.warning:
        return Colors.black87;
    }
  }

  Gradient _getDisabledGradient(ThemeData theme) {
    return LinearGradient(
      colors: [
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.surfaceContainerHighest,
      ],
    );
  }
}

enum GradientButtonStyle {
  primary,
  success,
  warning,
  error,
}

enum GradientButtonSize {
  small,
  medium,
  large,
}

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