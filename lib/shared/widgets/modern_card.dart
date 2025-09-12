import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ModernCard extends StatelessWidget {
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
    this.width,
    this.height,
    this.shadowColor,
    this.border,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final CardElevation elevation;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Color? shadowColor;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final effectiveBorderRadius = borderRadius ?? 
        BorderRadius.circular(AppTheme.getResponsiveCardRadius(context));
    
    List<BoxShadow> shadows;
    switch (elevation) {
      case CardElevation.none:
        shadows = [];
        break;
      case CardElevation.low:
        shadows = AppTheme.getCardShadow(isDarkMode);
        break;
      case CardElevation.medium:
        shadows = AppTheme.getElevatedShadow(isDarkMode);
        break;
      case CardElevation.high:
        shadows = [
          ...AppTheme.getElevatedShadow(isDarkMode),
          BoxShadow(
            color: isDarkMode 
                ? const Color.fromRGBO(0, 0, 0, 0.5)
                : const Color.fromRGBO(0, 0, 0, 0.15),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ];
        break;
    }

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? theme.colorScheme.surface) : null,
        gradient: gradient,
        borderRadius: effectiveBorderRadius,
        boxShadow: shadows,
        border: border,
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: padding ?? AppTheme.getResponsivePadding(context),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: card,
      );
    }

    return card;
  }
}

enum CardElevation {
  none,
  low,
  medium,
  high,
}