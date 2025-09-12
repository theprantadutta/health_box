import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingAnimationWidget extends StatefulWidget {
  final String? message;
  final double size;
  final LoadingStyle style;

  const LoadingAnimationWidget({
    super.key,
    this.message,
    this.size = 50.0,
    this.style = LoadingStyle.gradient,
  });

  @override
  State<LoadingAnimationWidget> createState() => _LoadingAnimationWidgetState();
}

class _LoadingAnimationWidgetState extends State<LoadingAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    );

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
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
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: _buildLoadingIndicator(theme, isDarkMode),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.6 + (0.4 * _pulseAnimation.value),
                  child: Text(
                    widget.message!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme, bool isDarkMode) {
    switch (widget.style) {
      case LoadingStyle.gradient:
        return AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.getPrimaryGradient(isDarkMode),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            );
          },
        );

      case LoadingStyle.pulse:
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * _pulseAnimation.value),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.getPrimaryGradient(isDarkMode),
                ),
                child: const Center(
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

      case LoadingStyle.dots:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                final delay = index * 0.33;
                final animationValue = (_rotationAnimation.value + delay) % 1.0;
                final scale = 0.5 + (0.5 * (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0));
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        );

      case LoadingStyle.simple:
        return CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        );
    }
  }
}

enum LoadingStyle {
  simple,
  gradient,
  pulse,
  dots,
}