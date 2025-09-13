import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Premium Hero Animation Wrapper
class PremiumHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final String? healthContext;
  final bool enableGlow;
  final bool enableScale;
  final Duration? flightDuration;
  final Curve? curve;

  const PremiumHero({
    super.key,
    required this.tag,
    required this.child,
    this.healthContext,
    this.enableGlow = true,
    this.enableScale = true,
    this.flightDuration,
    this.curve,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: _flightShuttleBuilder,
      createRectTween: _createRectTween,
      child: child,
    );
  }

  Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final theme = Theme.of(flightContext);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Enhanced flight animation with health context
        Widget flightChild = child ?? this.child;

        // Add glow effect during flight
        if (enableGlow) {
          flightChild = _addGlowEffect(flightChild, animation, theme, isDarkMode);
        }

        // Add scale effect during flight
        if (enableScale) {
          flightChild = _addScaleEffect(flightChild, animation);
        }

        // Add rotation effect for dynamic flight
        flightChild = _addRotationEffect(flightChild, animation);

        return flightChild;
      },
      child: child,
    );
  }

  Widget _addGlowEffect(Widget child, Animation<double> animation, ThemeData theme, bool isDarkMode) {
    final glowColor = _getHealthContextColor(theme, isDarkMode);
    final glowIntensity = math.sin(animation.value * math.pi) * 0.5;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: glowIntensity),
            blurRadius: 20 * glowIntensity,
            spreadRadius: 3 * glowIntensity,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _addScaleEffect(Widget child, Animation<double> animation) {
    final scale = 1.0 + (math.sin(animation.value * math.pi) * 0.1);
    return Transform.scale(scale: scale, child: child);
  }

  Widget _addRotationEffect(Widget child, Animation<double> animation) {
    final rotation = math.sin(animation.value * math.pi) * 0.05;
    return Transform.rotate(angle: rotation, child: child);
  }

  Color _getHealthContextColor(ThemeData theme, bool isDarkMode) {
    if (healthContext == null) return theme.colorScheme.primary;
    
    switch (healthContext!.toLowerCase()) {
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
      default:
        return theme.colorScheme.primary;
    }
  }

  CreateRectTween get _createRectTween => (Rect? begin, Rect? end) {
    return PremiumRectTween(begin: begin, end: end);
  };
}

// Premium Rect Tween for Smooth Hero Transitions
class PremiumRectTween extends RectTween {
  PremiumRectTween({super.begin, super.end});

  @override
  Rect? lerp(double t) {
    final curvedT = Curves.easeInOutCubic.transform(t);
    return super.lerp(curvedT);
  }
}

// Health Card Hero for Medical Records
class HealthCardHero extends StatelessWidget {
  final String heroTag;
  final Widget child;
  final String healthCategory;
  final VoidCallback? onTap;

  const HealthCardHero({
    super.key,
    required this.heroTag,
    required this.child,
    required this.healthCategory,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumHero(
      tag: heroTag,
      healthContext: healthCategory,
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

// Profile Avatar Hero with Health Status
class ProfileAvatarHero extends StatefulWidget {
  final String heroTag;
  final String profileName;
  final String? profileImage;
  final String healthStatus;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatarHero({
    super.key,
    required this.heroTag,
    required this.profileName,
    this.profileImage,
    required this.healthStatus,
    this.size = 60.0,
    this.onTap,
  });

  @override
  State<ProfileAvatarHero> createState() => _ProfileAvatarHeroState();
}

class _ProfileAvatarHeroState extends State<ProfileAvatarHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(widget.healthStatus);

    return PremiumHero(
      tag: widget.heroTag,
      healthContext: widget.healthStatus,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing health status ring
                Container(
                  width: widget.size + 8,
                  height: widget.size + 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3 + (0.4 * _pulseAnimation.value)),
                      width: 2,
                    ),
                  ),
                ),
                
                // Avatar
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.profileImage == null
                        ? AppTheme.getHealthContextGradient(widget.healthStatus, isDark: theme.brightness == Brightness.dark)
                        : null,
                    image: widget.profileImage != null
                        ? DecorationImage(
                            image: AssetImage(widget.profileImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: widget.profileImage == null
                      ? Center(
                          child: Text(
                            widget.profileName.isNotEmpty 
                                ? widget.profileName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: widget.size * 0.4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
                
                // Health status indicator
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: widget.size * 0.25,
                    height: widget.size * 0.25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'good':
        return const Color(0xFF4CAF50);
      case 'warning':
      case 'attention':
        return const Color(0xFFFF9800);
      case 'critical':
      case 'urgent':
        return const Color(0xFFF44336);
      case 'unknown':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF2196F3);
    }
  }
}

// Floating Action Button Hero with Health Context
class HealthFABHero extends StatefulWidget {
  final String heroTag;
  final IconData icon;
  final String healthContext;
  final VoidCallback onPressed;
  final String? tooltip;

  const HealthFABHero({
    super.key,
    required this.heroTag,
    required this.icon,
    required this.healthContext,
    required this.onPressed,
    this.tooltip,
  });

  @override
  State<HealthFABHero> createState() => _HealthFABHeroState();
}

class _HealthFABHeroState extends State<HealthFABHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return PremiumHero(
      tag: widget.heroTag,
      healthContext: widget.healthContext,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * math.pi / 4,
            child: FloatingActionButton(
              heroTag: widget.heroTag,
              onPressed: () {
                _rotationController.forward().then((_) {
                  _rotationController.reverse();
                });
                widget.onPressed();
              },
              tooltip: widget.tooltip,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.getHealthContextGradient(widget.healthContext, isDark: isDarkMode),
                  boxShadow: AppTheme.getHealthContextShadow(widget.healthContext, isDarkMode),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Text Hero with Gradient Effect
class GradientTextHero extends StatelessWidget {
  final String heroTag;
  final String text;
  final TextStyle? baseStyle;
  final String? healthContext;

  const GradientTextHero({
    super.key,
    required this.heroTag,
    required this.text,
    this.baseStyle,
    this.healthContext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumHero(
      tag: heroTag,
      healthContext: healthContext,
      child: Text(
        text,
        style: AppTheme.getGradientTextStyle(
          context, 
          theme,
          fontSize: baseStyle?.fontSize,
          fontWeight: baseStyle?.fontWeight,
        ),
      ),
    );
  }
}

// Morphing Icon Hero
class MorphingIconHero extends StatefulWidget {
  final String heroTag;
  final IconData fromIcon;
  final IconData toIcon;
  final String? healthContext;
  final double size;
  final VoidCallback? onTap;

  const MorphingIconHero({
    super.key,
    required this.heroTag,
    required this.fromIcon,
    required this.toIcon,
    this.healthContext,
    this.size = 24.0,
    this.onTap,
  });

  @override
  State<MorphingIconHero> createState() => _MorphingIconHeroState();
}

class _MorphingIconHeroState extends State<MorphingIconHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _morphController;
  late Animation<double> _morphAnimation;
  bool _showSecondIcon = false;

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _morphAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumHero(
      tag: widget.heroTag,
      healthContext: widget.healthContext,
      child: GestureDetector(
        onTap: () {
          _morphIcon();
          widget.onTap?.call();
        },
        child: AnimatedBuilder(
          animation: _morphAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // First icon
                Transform.scale(
                  scale: _showSecondIcon ? 1.0 - _morphAnimation.value : 1.0,
                  child: Opacity(
                    opacity: _showSecondIcon ? 1.0 - _morphAnimation.value : 1.0,
                    child: Icon(
                      widget.fromIcon,
                      size: widget.size,
                    ),
                  ),
                ),
                
                // Second icon
                Transform.scale(
                  scale: _showSecondIcon ? _morphAnimation.value : 0.0,
                  child: Opacity(
                    opacity: _showSecondIcon ? _morphAnimation.value : 0.0,
                    child: Icon(
                      widget.toIcon,
                      size: widget.size,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _morphIcon() {
    setState(() {
      _showSecondIcon = !_showSecondIcon;
    });
    
    if (_showSecondIcon) {
      _morphController.forward();
    } else {
      _morphController.reverse();
    }
  }
}

// Hero Animation Utils
class HeroAnimationUtils {
  // Generate unique hero tags with health context
  static String generateHealthHeroTag(String base, String healthContext, {String? id}) {
    return 'health_${healthContext}_${base}${id != null ? '_$id' : ''}';
  }

  // Create health-themed hero tags
  static String profileHeroTag(String profileId) => 'profile_avatar_$profileId';
  static String cardHeroTag(String recordId, String category) => 'health_card_${category}_$recordId';
  static String fabHeroTag(String context) => 'health_fab_$context';
  static String textHeroTag(String identifier) => 'health_text_$identifier';
  static String iconHeroTag(String identifier) => 'health_icon_$identifier';
}