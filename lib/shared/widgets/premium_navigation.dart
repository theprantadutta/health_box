import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// Premium Navigation Bar with Health Context
class PremiumNavigationBar extends StatefulWidget {
  const PremiumNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = 8.0,
    this.height = 80.0,
    this.borderRadius,
    this.margin,
    this.enableGlow = true,
    this.enableFloating = false,
    this.enableMorphing = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.healthContext,
    this.enableHapticFeedback = true,
  });

  final List<PremiumNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double elevation;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final bool enableGlow;
  final bool enableFloating;
  final bool enableMorphing;
  final Duration animationDuration;
  final String? healthContext;
  final bool enableHapticFeedback;

  @override
  State<PremiumNavigationBar> createState() => _PremiumNavigationBarState();
}

class _PremiumNavigationBarState extends State<PremiumNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _selectionController;
  late AnimationController _glowController;
  late AnimationController _floatingController;
  late AnimationController _morphController;

  late Animation<double> _selectionAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _morphAnimation;

  double _indicatorPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateIndicatorPosition();
  }

  @override
  void didUpdateWidget(PremiumNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _animateToNewSelection();
    }
  }

  void _initializeAnimations() {
    _selectionController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _morphController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOutCubic,
    );

    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );

    _floatingAnimation = CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    );

    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: Curves.elasticOut,
    );

    if (widget.enableFloating) {
      _floatingController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _glowController.dispose();
    _floatingController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  void _animateToNewSelection() {
    _selectionController.forward().then((_) {
      _updateIndicatorPosition();
      _selectionController.reset();
    });

    if (widget.enableGlow) {
      _glowController.forward().then((_) {
        _glowController.reverse();
      });
    }

    if (widget.enableMorphing) {
      _morphController.forward().then((_) {
        _morphController.reverse();
      });
    }

    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
  }

  void _updateIndicatorPosition() {
    if (widget.destinations.isEmpty) return;
    
    final itemWidth = 1.0 / widget.destinations.length;
    setState(() {
      _indicatorPosition = widget.selectedIndex * itemWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _selectionAnimation,
        _glowAnimation,
        _floatingAnimation,
        _morphAnimation,
      ]),
      builder: (context, child) {
        double floatingOffset = 0.0;
        if (widget.enableFloating) {
          floatingOffset = math.sin(_floatingAnimation.value * 2 * math.pi) * 3;
        }

        return Transform.translate(
          offset: Offset(0, floatingOffset),
          child: Container(
            margin: widget.margin ?? const EdgeInsets.all(16.0),
            height: widget.height,
            decoration: _buildNavBarDecoration(theme, isDarkMode),
            child: Stack(
              children: [
                // Selection indicator
                _buildSelectionIndicator(theme, isDarkMode),

                // Glow effect
                if (widget.enableGlow && _glowAnimation.value > 0)
                  _buildGlowEffect(theme, isDarkMode),

                // Navigation items
                _buildNavigationItems(),
              ],
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildNavBarDecoration(ThemeData theme, bool isDarkMode) {
    final baseColor = widget.backgroundColor ?? theme.colorScheme.surface;
    
    List<BoxShadow> shadows = [];
    
    if (widget.elevation > 0) {
      shadows.addAll(AppTheme.getElevatedShadow(isDarkMode));
    }

    if (widget.healthContext != null) {
      final contextShadows = AppTheme.getHealthContextShadow(widget.healthContext!, isDarkMode);
      shadows.addAll(contextShadows.map((shadow) => 
        shadow.copyWith(
          color: shadow.color.withValues(alpha: shadow.color.alpha * 0.3),
        ),
      ));
    }

    return BoxDecoration(
      color: baseColor,
      borderRadius: widget.borderRadius ?? BorderRadius.circular(24.0),
      boxShadow: shadows,
      border: Border.all(
        color: theme.colorScheme.outline.withValues(alpha: 0.1),
        width: 1.0,
      ),
    );
  }

  Widget _buildSelectionIndicator(ThemeData theme, bool isDarkMode) {
    final itemWidth = 1.0 / widget.destinations.length;
    final indicatorColor = widget.selectedItemColor ?? theme.colorScheme.primary;

    return Positioned(
      top: 8,
      bottom: 8,
      left: _indicatorPosition * MediaQuery.of(context).size.width * 0.9,
      width: itemWidth * MediaQuery.of(context).size.width * 0.9,
      child: AnimatedContainer(
        duration: widget.animationDuration,
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          gradient: widget.healthContext != null
              ? AppTheme.getHealthContextGradient(widget.healthContext!, isDark: isDarkMode)
              : LinearGradient(
                  colors: [
                    indicatorColor.withValues(alpha: 0.2),
                    indicatorColor.withValues(alpha: 0.1),
                  ],
                ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Transform.scale(
          scale: 1.0 + (_morphAnimation.value * 0.1),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: indicatorColor.withValues(alpha: 0.3),
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlowEffect(ThemeData theme, bool isDarkMode) {
    final glowColor = widget.selectedItemColor ?? theme.colorScheme.primary;
    final itemWidth = 1.0 / widget.destinations.length;

    return Positioned(
      top: -10,
      bottom: -10,
      left: (_indicatorPosition * MediaQuery.of(context).size.width * 0.9) - 10,
      width: (itemWidth * MediaQuery.of(context).size.width * 0.9) + 20,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26.0),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.3 * _glowAnimation.value),
              blurRadius: 20 * _glowAnimation.value,
              spreadRadius: 5 * _glowAnimation.value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItems() {
    return Row(
      children: widget.destinations.asMap().entries.map((entry) {
        final index = entry.key;
        final destination = entry.value;
        final isSelected = index == widget.selectedIndex;

        return Expanded(
          child: _PremiumNavigationItem(
            destination: destination,
            isSelected: isSelected,
            onTap: () => widget.onDestinationSelected(index),
            selectedColor: widget.selectedItemColor,
            unselectedColor: widget.unselectedItemColor,
            animationValue: isSelected ? 1.0 : 0.0,
            morphValue: _morphAnimation.value,
            healthContext: widget.healthContext,
          ),
        );
      }).toList(),
    );
  }
}

// Premium Navigation Destination
class PremiumNavigationDestination {
  const PremiumNavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
    this.tooltip,
    this.healthContext,
  });

  final Widget icon;
  final Widget? selectedIcon;
  final String label;
  final Widget? badge;
  final String? tooltip;
  final String? healthContext;
}

// Individual Navigation Item with Animations
class _PremiumNavigationItem extends StatefulWidget {
  const _PremiumNavigationItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
    required this.animationValue,
    required this.morphValue,
    this.selectedColor,
    this.unselectedColor,
    this.healthContext,
  });

  final PremiumNavigationDestination destination;
  final bool isSelected;
  final VoidCallback onTap;
  final double animationValue;
  final double morphValue;
  final Color? selectedColor;
  final Color? unselectedColor;
  final String? healthContext;

  @override
  State<_PremiumNavigationItem> createState() => _PremiumNavigationItemState();
}

class _PremiumNavigationItemState extends State<_PremiumNavigationItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = widget.selectedColor ?? theme.colorScheme.primary;
    final unselectedColor = widget.unselectedColor ?? theme.colorScheme.onSurfaceVariant;

    final effectiveColor = Color.lerp(
      unselectedColor,
      selectedColor,
      widget.animationValue,
    )!;

    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _bounceController.forward().then((_) {
                  _bounceController.reverse();
                });
                widget.onTap();
              },
              borderRadius: BorderRadius.circular(16.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with morph animation
                    Transform.scale(
                      scale: 1.0 + (widget.morphValue * 0.2),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Icon
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: widget.isSelected && widget.destination.selectedIcon != null
                                ? widget.destination.selectedIcon!
                                : widget.destination.icon,
                          ),
                          
                          // Badge
                          if (widget.destination.badge != null)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: widget.destination.badge!,
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Label with fade animation
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: widget.isSelected ? 1.0 : 0.7,
                      child: Text(
                        widget.destination.label,
                        style: TextStyle(
                          color: effectiveColor,
                          fontSize: 12,
                          fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Premium Navigation Rail for Desktop/Tablet
class PremiumNavigationRail extends StatefulWidget {
  const PremiumNavigationRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.extended = false,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.width = 80.0,
    this.extendedWidth = 256.0,
    this.elevation = 1.0,
    this.margin,
    this.borderRadius,
    this.enableGlow = true,
    this.healthContext,
  });

  final List<PremiumNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double width;
  final double extendedWidth;
  final double elevation;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool enableGlow;
  final String? healthContext;

  @override
  State<PremiumNavigationRail> createState() => _PremiumNavigationRailState();
}

class _PremiumNavigationRailState extends State<PremiumNavigationRail>
    with TickerProviderStateMixin {
  late AnimationController _selectionController;
  late AnimationController _extendedController;
  late AnimationController _glowController;

  late Animation<double> _selectionAnimation;
  late Animation<double> _extendedAnimation;
  late Animation<double> _glowAnimation;

  double _indicatorTop = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateIndicatorPosition();
  }

  @override
  void didUpdateWidget(PremiumNavigationRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _animateToNewSelection();
    }
    if (oldWidget.extended != widget.extended) {
      _animateExtension();
    }
  }

  void _initializeAnimations() {
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _extendedController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOutCubic,
    );

    _extendedAnimation = CurvedAnimation(
      parent: _extendedController,
      curve: Curves.easeInOutCubic,
    );

    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );

    if (widget.extended) {
      _extendedController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _extendedController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _animateToNewSelection() {
    _selectionController.forward().then((_) {
      _updateIndicatorPosition();
      _selectionController.reset();
    });

    if (widget.enableGlow) {
      _glowController.forward().then((_) {
        _glowController.reverse();
      });
    }
  }

  void _animateExtension() {
    if (widget.extended) {
      _extendedController.forward();
    } else {
      _extendedController.reverse();
    }
  }

  void _updateIndicatorPosition() {
    final itemHeight = 72.0; // Standard rail item height
    final startOffset = 16.0; // Top padding
    setState(() {
      _indicatorTop = startOffset + (widget.selectedIndex * itemHeight);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _selectionAnimation,
        _extendedAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        final currentWidth = widget.width + 
            (widget.extendedWidth - widget.width) * _extendedAnimation.value;

        return Container(
          width: currentWidth,
          margin: widget.margin ?? const EdgeInsets.all(8.0),
          decoration: _buildRailDecoration(theme, isDarkMode),
          child: Stack(
            children: [
              // Selection indicator
              _buildRailSelectionIndicator(theme, isDarkMode),

              // Glow effect
              if (widget.enableGlow && _glowAnimation.value > 0)
                _buildRailGlowEffect(theme, isDarkMode),

              // Rail items
              _buildRailItems(),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _buildRailDecoration(ThemeData theme, bool isDarkMode) {
    return BoxDecoration(
      color: widget.backgroundColor ?? theme.colorScheme.surface,
      borderRadius: widget.borderRadius ?? BorderRadius.circular(16.0),
      boxShadow: widget.elevation > 0 ? AppTheme.getCardShadow(isDarkMode) : [],
      border: Border.all(
        color: theme.colorScheme.outline.withValues(alpha: 0.1),
        width: 1.0,
      ),
    );
  }

  Widget _buildRailSelectionIndicator(ThemeData theme, bool isDarkMode) {
    final indicatorColor = widget.selectedItemColor ?? theme.colorScheme.primary;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      top: _indicatorTop,
      left: 8,
      right: 8,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: widget.healthContext != null
              ? AppTheme.getHealthContextGradient(widget.healthContext!, isDark: isDarkMode)
              : LinearGradient(
                  colors: [
                    indicatorColor.withValues(alpha: 0.2),
                    indicatorColor.withValues(alpha: 0.1),
                  ],
                ),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: indicatorColor.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildRailGlowEffect(ThemeData theme, bool isDarkMode) {
    final glowColor = widget.selectedItemColor ?? theme.colorScheme.primary;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: _indicatorTop - 10,
      left: -2,
      right: -2,
      height: 76,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.0),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.3 * _glowAnimation.value),
              blurRadius: 20 * _glowAnimation.value,
              spreadRadius: 2 * _glowAnimation.value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRailItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: widget.destinations.asMap().entries.map((entry) {
          final index = entry.key;
          final destination = entry.value;
          final isSelected = index == widget.selectedIndex;

          return _PremiumNavigationRailItem(
            destination: destination,
            isSelected: isSelected,
            extended: _extendedAnimation.value > 0.5,
            onTap: () => widget.onDestinationSelected(index),
            selectedColor: widget.selectedItemColor,
            unselectedColor: widget.unselectedItemColor,
            extendedValue: _extendedAnimation.value,
            healthContext: widget.healthContext,
          );
        }).toList(),
      ),
    );
  }
}

// Rail Item with Extended Animation
class _PremiumNavigationRailItem extends StatefulWidget {
  const _PremiumNavigationRailItem({
    required this.destination,
    required this.isSelected,
    required this.extended,
    required this.onTap,
    required this.extendedValue,
    this.selectedColor,
    this.unselectedColor,
    this.healthContext,
  });

  final PremiumNavigationDestination destination;
  final bool isSelected;
  final bool extended;
  final VoidCallback onTap;
  final double extendedValue;
  final Color? selectedColor;
  final Color? unselectedColor;
  final String? healthContext;

  @override
  State<_PremiumNavigationRailItem> createState() => _PremiumNavigationRailItemState();
}

class _PremiumNavigationRailItemState extends State<_PremiumNavigationRailItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;


  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = widget.selectedColor ?? theme.colorScheme.primary;
    final unselectedColor = widget.unselectedColor ?? theme.colorScheme.onSurfaceVariant;

    final effectiveColor = widget.isSelected ? selectedColor : unselectedColor;

    return AnimatedBuilder(
      animation: _hoverAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _hoverAnimation.value,
          child: Container(
            height: 72,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onHover: (hovering) {
                  if (hovering) {
                    _hoverController.forward();
                  } else {
                    _hoverController.reverse();
                  }
                },
                borderRadius: BorderRadius.circular(12.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Icon
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: widget.isSelected && widget.destination.selectedIcon != null
                            ? widget.destination.selectedIcon!
                            : widget.destination.icon,
                      ),
                      
                      // Label (when extended)
                      if (widget.extendedValue > 0)
                        Expanded(
                          child: Opacity(
                            opacity: widget.extendedValue,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                widget.destination.label,
                                style: TextStyle(
                                  color: effectiveColor,
                                  fontSize: 16,
                                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}