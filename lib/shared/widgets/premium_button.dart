import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// Enhanced Button States
enum PremiumButtonState {
  normal,
  hovered,
  pressed,
  loading,
  disabled,
  success,
  error,
  warning,
}

// Button Styles with Health Context
enum PremiumButtonStyle {
  filled,
  outlined,
  text,
  elevated,
  floating,
  gradient,
  glassmorphic,
  neon,
  pulse,
}

// Premium Multi-State Button
class PremiumButton extends StatefulWidget {
  const PremiumButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.onLongPress,
    this.onHover,
    this.style = PremiumButtonStyle.filled,
    this.state = PremiumButtonState.normal,
    this.width,
    this.height = 48.0,
    this.borderRadius,
    this.padding,
    this.gradient,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.shadowColor,
    this.elevation = 2.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.healthContext,
    this.enableHapticFeedback = true,
    this.enableSoundEffects = false,
    this.loadingIndicator,
    this.successIcon,
    this.errorIcon,
    this.warningIcon,
    this.iconPosition = IconPosition.leading,
    this.expandOnHover = true,
    this.pulseOnFocus = false,
    this.enableParticleEffect = false,
  });

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final Widget child;
  final PremiumButtonStyle style;
  final PremiumButtonState state;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double elevation;
  final Duration animationDuration;
  final String? healthContext;
  final bool enableHapticFeedback;
  final bool enableSoundEffects;
  final Widget? loadingIndicator;
  final Widget? successIcon;
  final Widget? errorIcon;
  final Widget? warningIcon;
  final IconPosition iconPosition;
  final bool expandOnHover;
  final bool pulseOnFocus;
  final bool enableParticleEffect;

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late AnimationController _stateController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _glowController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _borderAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _widthAnimation;

  bool _isFocused = false;
  PremiumButtonState _currentState = PremiumButtonState.normal;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _currentState = widget.state;
    
    if (widget.pulseOnFocus) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PremiumButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _handleStateChange(widget.state);
    }
  }

  void _initializeAnimations() {
    // Main interaction controllers
    _hoverController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pressController = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration.inMilliseconds ~/ 2),
      vsync: this,
    );

    _stateController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Animations
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.expandOnHover ? 1.05 : 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation + 4.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _colorAnimation = ColorTween(
      begin: _getStateColor(PremiumButtonState.normal),
      end: _getStateColor(PremiumButtonState.hovered),
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _stateController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOutQuart,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _widthAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    _stateController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleStateChange(PremiumButtonState newState) {
    if (_currentState != newState) {
      setState(() {
        _currentState = newState;
      });

      switch (newState) {
        case PremiumButtonState.loading:
          _stateController.forward();
          _glowController.repeat(reverse: true);
          break;
        case PremiumButtonState.success:
          _stateController.forward();
          _triggerParticleEffect();
          if (widget.enableHapticFeedback) {
            HapticFeedback.lightImpact();
          }
          break;
        case PremiumButtonState.error:
          _stateController.forward();
          if (widget.enableHapticFeedback) {
            HapticFeedback.heavyImpact();
          }
          break;
        case PremiumButtonState.warning:
          _stateController.forward();
          _pulseController.repeat(reverse: true);
          break;
        case PremiumButtonState.normal:
          _stateController.reverse();
          _glowController.stop();
          _pulseController.stop();
          break;
        default:
          break;
      }
    }
  }

  void _triggerParticleEffect() {
    if (widget.enableParticleEffect) {
      _particleController.forward().then((_) {
        _particleController.reset();
      });
    }
  }

  Color _getStateColor(PremiumButtonState state) {
    final theme = Theme.of(context);
    
    if (widget.healthContext != null) {
      final contextGradient = AppTheme.getHealthContextGradient(
        widget.healthContext!,
        isDark: theme.brightness == Brightness.dark,
      );
      return contextGradient.colors.first;
    }

    switch (state) {
      case PremiumButtonState.normal:
        return widget.backgroundColor ?? theme.colorScheme.primary;
      case PremiumButtonState.hovered:
        return widget.backgroundColor?.withValues(alpha: 0.8) ?? 
               theme.colorScheme.primary.withValues(alpha: 0.8);
      case PremiumButtonState.pressed:
        return widget.backgroundColor?.withValues(alpha: 0.6) ?? 
               theme.colorScheme.primary.withValues(alpha: 0.6);
      case PremiumButtonState.loading:
        return theme.colorScheme.primary.withValues(alpha: 0.7);
      case PremiumButtonState.disabled:
        return theme.colorScheme.onSurface.withValues(alpha: 0.12);
      case PremiumButtonState.success:
        return const Color(0xFF4CAF50);
      case PremiumButtonState.error:
        return theme.colorScheme.error;
      case PremiumButtonState.warning:
        return const Color(0xFFFF9800);
    }
  }

  BoxDecoration _getButtonDecoration() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final currentColor = _colorAnimation.value ?? _getStateColor(_currentState);

    switch (widget.style) {
      case PremiumButtonStyle.filled:
        return BoxDecoration(
          color: currentColor,
          borderRadius: _getEffectiveBorderRadius(),
          boxShadow: _getElevationShadows(isDarkMode),
        );

      case PremiumButtonStyle.outlined:
        return BoxDecoration(
          border: Border.all(
            color: widget.borderColor ?? currentColor,
            width: _borderAnimation.value,
          ),
          borderRadius: _getEffectiveBorderRadius(),
          boxShadow: _getElevationShadows(isDarkMode),
        );

      case PremiumButtonStyle.elevated:
        return BoxDecoration(
          color: currentColor,
          borderRadius: _getEffectiveBorderRadius(),
          boxShadow: _getEnhancedElevationShadows(isDarkMode),
        );

      case PremiumButtonStyle.gradient:
        return BoxDecoration(
          gradient: widget.gradient ?? 
                   (widget.healthContext != null 
                    ? AppTheme.getHealthContextGradient(widget.healthContext!, isDark: isDarkMode)
                    : AppTheme.getPremiumPrimaryGradient(isDarkMode)),
          borderRadius: _getEffectiveBorderRadius(),
          boxShadow: _getElevationShadows(isDarkMode),
        );

      case PremiumButtonStyle.glassmorphic:
        return BoxDecoration(
          color: currentColor.withValues(alpha: 0.1),
          borderRadius: _getEffectiveBorderRadius(),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: -5,
            ),
          ],
        );

      case PremiumButtonStyle.neon:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: _getEffectiveBorderRadius(),
          border: Border.all(
            color: currentColor,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: currentColor.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: currentColor.withValues(alpha: 0.2),
              blurRadius: 40,
              spreadRadius: 0,
            ),
          ],
        );

      case PremiumButtonStyle.floating:
        return BoxDecoration(
          color: currentColor,
          borderRadius: _getEffectiveBorderRadius(),
          boxShadow: AppTheme.getFloatingShadow(isDarkMode),
        );

      case PremiumButtonStyle.pulse:
        return BoxDecoration(
          color: currentColor,
          borderRadius: _getEffectiveBorderRadius(),
          boxShadow: [
            BoxShadow(
              color: currentColor.withValues(alpha: 0.3 * _pulseAnimation.value),
              blurRadius: 20 * _pulseAnimation.value,
              spreadRadius: 5 * _pulseAnimation.value,
            ),
            ...AppTheme.getElevatedShadow(isDarkMode),
          ],
        );

      case PremiumButtonStyle.text:
        return BoxDecoration(
          borderRadius: _getEffectiveBorderRadius(),
        );
    }
  }

  BorderRadius _getEffectiveBorderRadius() {
    return widget.borderRadius ?? BorderRadius.circular(12.0);
  }

  List<BoxShadow> _getElevationShadows(bool isDarkMode) {
    if (widget.style == PremiumButtonStyle.text) return [];
    
    final elevation = _elevationAnimation.value;
    return [
      BoxShadow(
        color: (widget.shadowColor ?? Colors.black).withValues(
          alpha: isDarkMode ? 0.3 : 0.15,
        ),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation / 2),
      ),
    ];
  }

  List<BoxShadow> _getEnhancedElevationShadows(bool isDarkMode) {
    final elevation = _elevationAnimation.value;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.2),
        blurRadius: elevation * 3,
        offset: Offset(0, elevation),
        spreadRadius: -elevation / 2,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.1),
        blurRadius: elevation,
        offset: Offset(0, elevation / 2),
      ),
    ];
  }

  Widget _buildStateWidget() {
    switch (_currentState) {
      case PremiumButtonState.loading:
        return widget.loadingIndicator ?? _buildLoadingIndicator();
      case PremiumButtonState.success:
        return widget.successIcon ?? _buildSuccessIcon();
      case PremiumButtonState.error:
        return widget.errorIcon ?? _buildErrorIcon();
      case PremiumButtonState.warning:
        return widget.warningIcon ?? _buildWarningIcon();
      default:
        return widget.child;
    }
  }

  Widget _buildLoadingIndicator() {
    final theme = Theme.of(context);
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.foregroundColor ?? theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Icon(
      Icons.check_circle,
      color: widget.foregroundColor ?? Colors.white,
      size: 20,
    );
  }

  Widget _buildErrorIcon() {
    return Icon(
      Icons.error,
      color: widget.foregroundColor ?? Colors.white,
      size: 20,
    );
  }

  Widget _buildWarningIcon() {
    return Icon(
      Icons.warning,
      color: widget.foregroundColor ?? Colors.white,
      size: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && _currentState != PremiumButtonState.disabled;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _elevationAnimation,
        _colorAnimation,
        _borderAnimation,
        _pulseAnimation,
        _particleAnimation,
        _glowAnimation,
        _widthAnimation,
      ]),
      builder: (context, child) {
        double currentScale = _scaleAnimation.value;
        if (widget.pulseOnFocus && _isFocused) {
          currentScale *= _pulseAnimation.value;
        }

        return Stack(
          children: [
            // Particle effect layer
            if (widget.enableParticleEffect && _particleAnimation.value > 0)
              _buildParticleEffect(),

            // Glow effect layer
            if (_glowAnimation.value > 0)
              _buildGlowEffect(),

            // Main button
            Transform.scale(
              scale: currentScale,
              child: AnimatedContainer(
                duration: widget.animationDuration,
                width: widget.width != null ? widget.width! * _widthAnimation.value : null,
                height: widget.height,
                decoration: _getButtonDecoration(),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: _getEffectiveBorderRadius(),
                  child: InkWell(
                    onTap: isEnabled ? () {
                      if (widget.enableHapticFeedback) {
                        HapticFeedback.selectionClick();
                      }
                      widget.onPressed?.call();
                    } : null,
                    onLongPress: widget.onLongPress,
                    onHover: (hovering) {
                      if (hovering && isEnabled) {
                        _hoverController.forward();
                        _glowController.forward();
                      } else {
                        _hoverController.reverse();
                        _glowController.reverse();
                      }
                      
                      widget.onHover?.call(hovering);
                    },
                    onTapDown: isEnabled ? (_) {
                      _pressController.forward();
                    } : null,
                    onTapUp: isEnabled ? (_) {
                      _pressController.reverse();
                    } : null,
                    onTapCancel: () {
                      _pressController.reverse();
                    },
                    onFocusChange: (focused) {
                      setState(() => _isFocused = focused);
                      if (widget.pulseOnFocus) {
                        if (focused) {
                          _pulseController.repeat(reverse: true);
                        } else {
                          _pulseController.stop();
                        }
                      }
                    },
                    borderRadius: _getEffectiveBorderRadius(),
                    child: Container(
                      padding: widget.padding ?? 
                               const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Center(
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: widget.foregroundColor ?? theme.colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          child: _buildStateWidget(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildParticleEffect() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ParticleEffectPainter(
          animation: _particleAnimation,
          color: _getStateColor(_currentState),
        ),
      ),
    );
  }

  Widget _buildGlowEffect() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: _getEffectiveBorderRadius(),
          boxShadow: [
            BoxShadow(
              color: _getStateColor(_currentState).withValues(
                alpha: 0.3 * _glowAnimation.value,
              ),
              blurRadius: 20 * _glowAnimation.value,
              spreadRadius: 2 * _glowAnimation.value,
            ),
          ],
        ),
      ),
    );
  }
}

// Icon position enum
enum IconPosition {
  leading,
  trailing,
  top,
  bottom,
}

// Custom painter for particle effects
class ParticleEffectPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  ParticleEffectPainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6 * (1.0 - animation.value))
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;

    // Create particle burst effect
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi * 2) / 12;
      final distance = maxRadius * animation.value;
      final particleX = center.dx + math.cos(angle) * distance;
      final particleY = center.dy + math.sin(angle) * distance;
      
      final particleSize = 4 * (1.0 - animation.value);
      
      canvas.drawCircle(
        Offset(particleX, particleY),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticleEffectPainter oldDelegate) {
    return oldDelegate.animation.value != animation.value;
  }
}

// Button Group for related actions
class PremiumButtonGroup extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;

  const PremiumButtonGroup({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 8.0,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (direction == Axis.horizontal) {
      content = Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _buildChildrenWithSpacing(),
      );
    } else {
      content = Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _buildChildrenWithSpacing(),
      );
    }

    if (backgroundColor != null || border != null) {
      content = Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
          borderRadius: borderRadius ?? BorderRadius.circular(12.0),
        ),
        child: content,
      );
    } else if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return content;
  }

  List<Widget> _buildChildrenWithSpacing() {
    if (children.isEmpty) return [];

    final List<Widget> spacedChildren = [];
    
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      
      if (i < children.length - 1) {
        spacedChildren.add(
          direction == Axis.horizontal
              ? SizedBox(width: spacing)
              : SizedBox(height: spacing),
        );
      }
    }

    return spacedChildren;
  }
}