import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassmorphismCard extends StatefulWidget {
  const GlassmorphismCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.opacity = 0.1,
    this.blur = 20.0,
    this.border = true,
    this.gradient,
    this.onTap,
    this.shadowIntensity = 0.1,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double opacity;
  final double blur;
  final bool border;
  final LinearGradient? gradient;
  final VoidCallback? onTap;
  final double shadowIntensity;

  @override
  State<GlassmorphismCard> createState() => _GlassmorphismCardState();
}

class _GlassmorphismCardState extends State<GlassmorphismCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final effectiveBorderRadius = widget.borderRadius ?? 
        BorderRadius.circular(AppTheme.getResponsiveCardRadius(context));

    return AnimatedBuilder(
      animation: _hoverAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _hoverAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            child: Stack(
              children: [
                // Background blur effect
                ClipRRect(
                  borderRadius: effectiveBorderRadius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: widget.gradient ?? AppTheme.getGlassmorphismGradient(
                          primaryColor: theme.colorScheme.primary,
                          opacity: widget.opacity,
                        ),
                        borderRadius: effectiveBorderRadius,
                        border: widget.border
                            ? Border.all(
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: widget.shadowIntensity),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: isDarkMode 
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                ClipRRect(
                  borderRadius: effectiveBorderRadius,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onTap,
                      onHover: (hovering) {
                        setState(() {
                          _isHovered = hovering;
                        });
                        if (hovering) {
                          _controller.forward();
                        } else {
                          _controller.reverse();
                        }
                      },
                      borderRadius: effectiveBorderRadius,
                      child: Container(
                        padding: widget.padding ?? AppTheme.getResponsivePadding(context),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FrostedGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FrostedGlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.blur = 15.0,
    this.opacity = 0.1,
    this.gradient,
    this.height = kToolbarHeight,
  });

  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final double blur;
  final double opacity;
  final LinearGradient? gradient;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient ?? AppTheme.getGlassmorphismGradient(
              primaryColor: backgroundColor ?? theme.colorScheme.primary,
              opacity: opacity,
            ),
            border: Border(
              bottom: BorderSide(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
          ),
          child: AppBar(
            title: title,
            actions: actions,
            leading: leading,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
          ),
        ),
      ),
    );
  }
}

class GlassmorphismBottomNavigation extends StatelessWidget {
  const GlassmorphismBottomNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.blur = 20.0,
    this.opacity = 0.1,
    this.height = 80.0,
  });

  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final double blur;
  final double opacity;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: AppTheme.getGlassmorphismGradient(
              primaryColor: theme.colorScheme.primary,
              opacity: opacity,
            ),
            border: Border(
              top: BorderSide(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
          ),
          child: NavigationBar(
            destinations: destinations,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: height,
            indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}

class GlassmorphismDialog extends StatelessWidget {
  const GlassmorphismDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.blur = 20.0,
    this.opacity = 0.15,
  });

  final Widget? title;
  final Widget content;
  final List<Widget>? actions;
  final double blur;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.getGlassmorphismGradient(
                primaryColor: theme.colorScheme.surface,
                opacity: opacity,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: DefaultTextStyle(
                      style: theme.textTheme.headlineSmall!,
                      child: title!,
                    ),
                  ),
                ],
                Padding(
                  padding: EdgeInsets.fromLTRB(24, title != null ? 16 : 24, 24, actions != null ? 16 : 24),
                  child: content,
                ),
                if (actions != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    required Widget content,
    List<Widget>? actions,
    double blur = 20.0,
    double opacity = 0.15,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => GlassmorphismDialog(
        title: title,
        content: content,
        actions: actions,
        blur: blur,
        opacity: opacity,
      ),
    );
  }
}