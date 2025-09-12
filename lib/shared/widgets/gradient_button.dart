import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
    
    // Get dimensions based on size
    final dimensions = _getButtonDimensions();
    final effectiveHeight = widget.height ?? dimensions.height;
    final effectiveWidth = widget.width ?? dimensions.width;
    final effectiveBorderRadius = widget.borderRadius ?? 
        BorderRadius.circular(effectiveHeight / 2);
    
    // Get gradient based on style
    final gradient = widget.gradient ?? _getStyleGradient(isDarkMode);
    
    // Get text color based on style
    final textColor = _getTextColor();
    
    final isActive = widget.enabled && widget.onPressed != null;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: isActive ? (_) => _controller.forward() : null,
            onTapUp: isActive ? (_) => _controller.reverse() : null,
            onTapCancel: () => _controller.reverse(),
            onTap: widget.isLoading ? null : widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: effectiveWidth,
              height: effectiveHeight,
              decoration: BoxDecoration(
                gradient: isActive ? gradient : _getDisabledGradient(theme),
                borderRadius: effectiveBorderRadius,
                boxShadow: isActive && (widget.elevation ?? 0) > 0
                    ? AppTheme.getElevatedShadow(isDarkMode)
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: effectiveBorderRadius,
                child: Semantics(
                  button: true,
                  enabled: isActive,
                  child: InkWell(
                    borderRadius: effectiveBorderRadius,
                    onTap: widget.isLoading ? null : widget.onPressed,
                  child: Container(
                    padding: dimensions.padding,
                    decoration: BoxDecoration(
                      borderRadius: effectiveBorderRadius,
                    ),
                    child: _buildButtonContent(textColor),
                  ),
                  ),
                ),
              ),
            ),
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
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 8),
          DefaultTextStyle(
            style: TextStyle(color: textColor),
            child: widget.child,
          ),
        ],
      );
    }

    return Center(
      child: DefaultTextStyle(
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        child: widget.child,
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