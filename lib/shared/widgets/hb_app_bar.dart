import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_system.dart';

/// ============================================================================
/// HBAppBar - Standardized HealthBox App Bar
/// Material 3 app bar with optional gradient background
/// ============================================================================

class HBAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HBAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.useGradient = false,
    this.gradient,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.shadowColor,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.flexibleSpace,
    this.systemOverlayStyle,
  }) : assert(
          title == null || titleWidget == null,
          'Cannot provide both title and titleWidget',
        );

  /// Simple text title
  final String? title;

  /// Custom title widget (use instead of title for complex layouts)
  final Widget? titleWidget;

  /// Leading widget (usually back button or menu icon)
  final Widget? leading;

  /// Action buttons on the right
  final List<Widget>? actions;

  /// Whether to use gradient background
  final bool useGradient;

  /// Custom gradient (defaults to primary gradient)
  final Gradient? gradient;

  /// Solid background color (ignored if useGradient is true)
  final Color? backgroundColor;

  /// Foreground color for icons and text
  final Color? foregroundColor;

  /// Elevation level
  final double elevation;

  /// Shadow color
  final Color? shadowColor;

  /// Whether to center the title
  final bool centerTitle;

  /// Whether to automatically add a back button
  final bool automaticallyImplyLeading;

  /// Optional bottom widget (like TabBar)
  final PreferredSizeWidget? bottom;

  /// Custom flexible space widget
  final Widget? flexibleSpace;

  /// System overlay style (status bar)
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(AppSizes.appBarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveForegroundColor = foregroundColor ??
        (useGradient ? Colors.white : context.colorScheme.onSurface);

    final effectiveGradient = gradient ??
        (context.isDark
            ? AppColors.primaryGradientDark
            : AppColors.primaryGradient);

    // System overlay style for status bar
    final effectiveSystemOverlayStyle = systemOverlayStyle ??
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              useGradient ? Brightness.light : (context.isDark ? Brightness.light : Brightness.dark),
          statusBarBrightness:
              useGradient ? Brightness.dark : (context.isDark ? Brightness.dark : Brightness.light),
        );

    return AppBar(
      systemOverlayStyle: effectiveSystemOverlayStyle,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: useGradient ? Colors.transparent : null,
      backgroundColor: useGradient ? Colors.transparent : backgroundColor,
      foregroundColor: effectiveForegroundColor,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: AppTypography.fontWeightSemiBold,
                    color: effectiveForegroundColor,
                  ),
                )
              : null),
      actions: actions,
      bottom: bottom,
      flexibleSpace: useGradient
          ? _GradientFlexibleSpace(
              gradient: effectiveGradient,
              elevation: elevation,
              child: flexibleSpace,
            )
          : flexibleSpace,
    );
  }

  /// Factory: Standard app bar with gradient
  factory HBAppBar.gradient({
    Key? key,
    required String title,
    List<Widget>? actions,
    Widget? leading,
    Gradient? gradient,
    bool centerTitle = true,
    PreferredSizeWidget? bottom,
  }) {
    return HBAppBar(
      key: key,
      title: title,
      actions: actions,
      leading: leading,
      useGradient: true,
      gradient: gradient,
      centerTitle: centerTitle,
      bottom: bottom,
    );
  }

  /// Factory: Standard app bar without gradient
  factory HBAppBar.standard({
    Key? key,
    required String title,
    List<Widget>? actions,
    Widget? leading,
    Color? backgroundColor,
    bool centerTitle = true,
    PreferredSizeWidget? bottom,
  }) {
    return HBAppBar(
      key: key,
      title: title,
      actions: actions,
      leading: leading,
      useGradient: false,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      bottom: bottom,
    );
  }

  /// Factory: Large app bar with gradient (for main screens)
  factory HBAppBar.large({
    Key? key,
    required String title,
    String? subtitle,
    List<Widget>? actions,
    Gradient? gradient,
  }) {
    return HBAppBar(
      key: key,
      titleWidget: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppTypography.fontSize2xl,
              fontWeight: AppTypography.fontWeightBold,
              color: Colors.white,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: AppTypography.fontSizeSm,
                fontWeight: AppTypography.fontWeightNormal,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
      actions: actions,
      useGradient: true,
      gradient: gradient,
      centerTitle: false,
    );
  }
}

/// Internal: Gradient flexible space with shadow
class _GradientFlexibleSpace extends StatelessWidget {
  const _GradientFlexibleSpace({
    required this.gradient,
    required this.elevation,
    this.child,
  });

  final Gradient gradient;
  final double elevation;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
