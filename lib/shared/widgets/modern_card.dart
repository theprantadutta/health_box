import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Enhanced Card Interactive States
enum CardInteractiveState {
  normal,
  hovered,
  pressed,
  longPressed,
  focused,
  disabled,
  selected,
  loading,
}

class ModernCard extends StatefulWidget {
  const ModernCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.borderRadius,
    this.elevation = CardElevation.low,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.width,
    this.height,
    this.shadowColor,
    this.border,
    this.animationDuration = const Duration(milliseconds: 200),
    this.hoverScale = 1.02,
    this.tapScale = 0.98,
    this.longPressScale = 1.05,
    this.enableHoverEffects = true,
    this.enableFloatingEffect = false,
    this.enablePulseEffect = false,
    this.enableShimmerEffect = false,
    this.glowColor,
    this.context,
    this.interactiveStates = const {},
    this.floatingHeight = 8.0,
    this.pulseIntensity = 0.1,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final CardElevation elevation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final double? width;
  final double? height;
  final Color? shadowColor;
  final BoxBorder? border;
  final Duration animationDuration;
  final double hoverScale;
  final double tapScale;
  final double longPressScale;
  final bool enableHoverEffects;
  final bool enableFloatingEffect;
  final bool enablePulseEffect;
  final bool enableShimmerEffect;
  final Color? glowColor;
  final String? context; // Health context for dynamic styling
  final Set<CardInteractiveState> interactiveStates;
  final double floatingHeight;
  final double pulseIntensity;

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _tapController;
  late AnimationController _glowController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _longPressController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _borderAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _longPressAnimation;

  bool _isHovered = false;
  bool _isTapped = false;
  bool _isLongPressed = false;
  CardInteractiveState _currentState = CardInteractiveState.normal;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startContinuousAnimations();
  }
  
  void _initializeAnimations() {
    // Basic interaction controllers
    _hoverController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _tapController = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration.inMilliseconds ~/ 2),
      vsync: this,
    );
    
    _longPressController = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration.inMilliseconds + 200),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration.inMilliseconds + 100),
      vsync: this,
    );

    // Advanced effect controllers
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Basic animations
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverScale,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeOutCubic,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: (widget.glowColor ?? Colors.white).withValues(alpha: 0.05),
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _borderAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeOutCubic,
    ));

    // Advanced effect animations
    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: widget.floatingHeight,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0 + widget.pulseIntensity,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));

    _longPressAnimation = Tween<double>(
      begin: 1.0,
      end: widget.longPressScale,
    ).animate(CurvedAnimation(
      parent: _longPressController,
      curve: Curves.elasticOut,
    ));
  }
  
  void _startContinuousAnimations() {
    if (widget.enableFloatingEffect) {
      _floatingController.repeat(reverse: true);
    }
    
    if (widget.enablePulseEffect) {
      _pulseController.repeat(reverse: true);
    }
    
    if (widget.enableShimmerEffect) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _tapController.dispose();
    _longPressController.dispose();
    _glowController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }
  
  void _updateInteractiveState(CardInteractiveState newState) {
    if (_currentState != newState) {
      setState(() {
        _currentState = newState;
      });
      _handleStateTransition(newState);
    }
  }
  
  void _handleStateTransition(CardInteractiveState state) {
    switch (state) {
      case CardInteractiveState.hovered:
        if (widget.enableHoverEffects) {
          _hoverController.forward();
          _glowController.forward();
        }
        break;
      case CardInteractiveState.pressed:
        _tapController.forward();
        break;
      case CardInteractiveState.longPressed:
        _longPressController.forward();
        break;
      case CardInteractiveState.normal:
        _hoverController.reverse();
        _glowController.reverse();
        _tapController.reverse();
        _longPressController.reverse();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final effectiveBorderRadius = widget.borderRadius ?? 
        BorderRadius.circular(AppTheme.getResponsiveCardRadius(context));
    
    // Get dynamic shadows based on elevation and animation state
    List<BoxShadow> baseShadows = _getBaseShadows(isDarkMode);
    List<BoxShadow> elevatedShadows = _getElevatedShadows(isDarkMode);
    
    // Get context-specific colors if health context is provided
    Color? contextGlowColor;
    List<BoxShadow>? contextShadows;
    if (widget.context != null) {
      contextGlowColor = _getContextGlowColor(theme);
      contextShadows = AppTheme.getHealthContextShadow(widget.context!, isDarkMode);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _elevationAnimation,
        _glowAnimation,
        _colorAnimation,
        _borderAnimation,
        _floatingAnimation,
        _pulseAnimation,
        _shimmerAnimation,
        _longPressAnimation,
      ]),
      builder: (context, child) {
        // Calculate complex scale transformations
        double currentScale = _scaleAnimation.value;
        if (_isTapped) {
          currentScale *= widget.tapScale;
        }
        if (_isLongPressed) {
          currentScale *= _longPressAnimation.value;
        }
        if (widget.enablePulseEffect) {
          currentScale *= _pulseAnimation.value;
        }

        // Calculate floating offset
        double floatingOffset = 0.0;
        if (widget.enableFloatingEffect) {
          floatingOffset = -math.sin(_floatingAnimation.value * math.pi / widget.floatingHeight) * widget.floatingHeight;
        }

        // Enhanced shadow calculation
        List<BoxShadow> currentShadows = _calculateEnhancedShadows(
          baseShadows, elevatedShadows, contextShadows, isDarkMode);

        return Transform.translate(
          offset: Offset(0, floatingOffset),
          child: Transform.scale(
            scale: currentScale,
            child: Stack(
              children: [
                // Enhanced glow effects
                ..._buildGlowEffects(effectiveBorderRadius, contextGlowColor, theme),

                // Shimmer overlay
                if (widget.enableShimmerEffect && _shimmerAnimation.value > -1.0 && _shimmerAnimation.value < 2.0)
                  _buildShimmerEffect(effectiveBorderRadius),

                // Main card with all enhancements
                _buildMainCard(
                  context,
                  theme,
                  effectiveBorderRadius,
                  currentShadows,
                  contextGlowColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  List<BoxShadow> _calculateEnhancedShadows(
    List<BoxShadow> baseShadows, 
    List<BoxShadow> elevatedShadows, 
    List<BoxShadow>? contextShadows,
    bool isDarkMode,
  ) {
    List<BoxShadow> currentShadows = baseShadows.map((shadow) {
      double elevationMultiplier = 1.0 + _elevationAnimation.value * 0.5;
      double floatingMultiplier = widget.enableFloatingEffect ? 1.0 + (_floatingAnimation.value / widget.floatingHeight) * 0.3 : 1.0;
      
      return BoxShadow(
        color: shadow.color,
        offset: shadow.offset * elevationMultiplier * floatingMultiplier,
        blurRadius: shadow.blurRadius * elevationMultiplier * floatingMultiplier,
        spreadRadius: shadow.spreadRadius,
      );
    }).toList();

    // Add elevated shadows
    if (_elevationAnimation.value > 0) {
      for (var shadow in elevatedShadows) {
        currentShadows.add(BoxShadow(
          color: shadow.color.withValues(
            alpha: shadow.color.alpha * _elevationAnimation.value,
          ),
          offset: shadow.offset * _elevationAnimation.value,
          blurRadius: shadow.blurRadius * _elevationAnimation.value,
          spreadRadius: shadow.spreadRadius,
        ));
      }
    }

    // Add context-specific shadows
    if (contextShadows != null && _elevationAnimation.value > 0) {
      for (var shadow in contextShadows) {
        currentShadows.add(BoxShadow(
          color: shadow.color.withValues(
            alpha: shadow.color.alpha * _elevationAnimation.value * 0.3,
          ),
          offset: shadow.offset * _elevationAnimation.value,
          blurRadius: shadow.blurRadius * _elevationAnimation.value,
          spreadRadius: shadow.spreadRadius,
        ));
      }
    }
    
    return currentShadows;
  }
  
  List<Widget> _buildGlowEffects(BorderRadius borderRadius, Color? contextGlowColor, ThemeData theme) {
    List<Widget> glowEffects = [];
    
    // Primary glow effect
    if (_glowAnimation.value > 0 && widget.enableHoverEffects) {
      glowEffects.add(
        Positioned.fill(
          child: Container(
            margin: widget.margin,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: (contextGlowColor ?? widget.glowColor ?? theme.colorScheme.primary)
                      .withValues(alpha: 0.2 * _glowAnimation.value),
                  blurRadius: 20 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Pulse glow effect
    if (widget.enablePulseEffect && _pulseAnimation.value > 1.0) {
      double pulseGlow = (_pulseAnimation.value - 1.0) / widget.pulseIntensity;
      glowEffects.add(
        Positioned.fill(
          child: Container(
            margin: widget.margin,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: (contextGlowColor ?? theme.colorScheme.primary)
                      .withValues(alpha: 0.1 * pulseGlow),
                  blurRadius: 15 * pulseGlow,
                  spreadRadius: 1 * pulseGlow,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return glowEffects;
  }
  
  Widget _buildShimmerEffect(BorderRadius borderRadius) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          margin: widget.margin,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _shimmerAnimation.value, 0.0),
              end: Alignment(-0.5 + _shimmerAnimation.value, 0.0),
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMainCard(
    BuildContext context,
    ThemeData theme,
    BorderRadius borderRadius,
    List<BoxShadow> shadows,
    Color? contextGlowColor,
  ) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.gradient == null ? (widget.color ?? theme.colorScheme.surface) : null,
        gradient: widget.gradient,
        borderRadius: borderRadius,
        boxShadow: shadows,
        border: widget.border,
      ),
      child: Stack(
        children: [
          // Interactive state overlays
          ..._buildStateOverlays(borderRadius, contextGlowColor, theme),
          
          // Content with enhanced interaction handling
          _buildInteractiveContent(borderRadius),
        ],
      ),
    );
  }
  
  List<Widget> _buildStateOverlays(BorderRadius borderRadius, Color? contextGlowColor, ThemeData theme) {
    List<Widget> overlays = [];
    
    // Hover color overlay
    if (_colorAnimation.value != null && _colorAnimation.value != Colors.transparent) {
      overlays.add(
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: borderRadius,
            ),
          ),
        ),
      );
    }

    // Border glow effect
    if (_borderAnimation.value > 0 && widget.enableHoverEffects) {
      overlays.add(
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(
                color: (contextGlowColor ?? widget.glowColor ?? theme.colorScheme.primary)
                    .withValues(alpha: 0.1 * _borderAnimation.value),
                width: 1.5 * _borderAnimation.value,
              ),
            ),
          ),
        ),
      );
    }
    
    // Long press state overlay
    if (_isLongPressed) {
      overlays.add(
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: (contextGlowColor ?? theme.colorScheme.primary)
                  .withValues(alpha: 0.03),
            ),
          ),
        ),
      );
    }
    
    return overlays;
  }
  
  Widget _buildInteractiveContent(BorderRadius borderRadius) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress != null ? () {
            widget.onLongPress!();
            _updateInteractiveState(CardInteractiveState.longPressed);
            setState(() => _isLongPressed = true);
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                setState(() => _isLongPressed = false);
                _updateInteractiveState(CardInteractiveState.normal);
              }
            });
          } : null,
          onDoubleTap: widget.onDoubleTap,
          onHover: widget.enableHoverEffects ? (hovering) {
            _updateInteractiveState(hovering ? CardInteractiveState.hovered : CardInteractiveState.normal);
            setState(() => _isHovered = hovering);
          } : null,
          onTapDown: (_) {
            _updateInteractiveState(CardInteractiveState.pressed);
            setState(() => _isTapped = true);
          },
          onTapUp: (_) {
            _updateInteractiveState(CardInteractiveState.normal);
            setState(() => _isTapped = false);
          },
          onTapCancel: () {
            _updateInteractiveState(CardInteractiveState.normal);
            setState(() => _isTapped = false);
          },
          borderRadius: borderRadius,
          child: Padding(
            padding: widget.padding ?? AppTheme.getResponsivePadding(context),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  // Helper methods for getting shadows
  List<BoxShadow> _getBaseShadows(bool isDarkMode) {
    switch (widget.elevation) {
      case CardElevation.none:
        return [];
      case CardElevation.low:
        return AppTheme.getCardShadow(isDarkMode);
      case CardElevation.medium:
        return AppTheme.getElevatedShadow(isDarkMode);
      case CardElevation.high:
        return AppTheme.getFloatingShadow(isDarkMode, elevation: 12.0);
    }
  }

  List<BoxShadow> _getElevatedShadows(bool isDarkMode) {
    switch (widget.elevation) {
      case CardElevation.none:
      case CardElevation.low:
        return AppTheme.getElevatedShadow(isDarkMode);
      case CardElevation.medium:
        return AppTheme.getFloatingShadow(isDarkMode, elevation: 8.0);
      case CardElevation.high:
        return AppTheme.getFloatingShadow(isDarkMode, elevation: 16.0);
    }
  }

  Color? _getContextGlowColor(ThemeData theme) {
    if (widget.context == null) return null;
    
    switch (widget.context!.toLowerCase()) {
      case 'medication':
        return const Color(0xFFFFC107); // Amber
      case 'heart':
      case 'cardio':
        return const Color(0xFFE91E63); // Pink
      case 'wellness':
      case 'mental_health':
        return const Color(0xFF9C27B0); // Purple
      case 'nutrition':
        return const Color(0xFF4CAF50); // Green
      case 'emergency':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.primary;
    }
  }
}

enum CardElevation {
  none,
  low,
  medium,
  high,
}