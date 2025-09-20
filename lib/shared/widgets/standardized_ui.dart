import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/design_system.dart';

/// Standardized App Bar Widget for consistent styling across all screens
class HealthBoxAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HealthBoxAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.elevation = 0,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final double elevation;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
          color: foregroundColor ?? Colors.white,
        ),
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: theme.colorScheme.shadow,
      iconTheme: IconThemeData(
        color: foregroundColor ?? Colors.white,
        size: 24,
      ),
      actions: actions?.map((action) => Padding(
        padding: const EdgeInsets.only(right: HealthBoxDesignSystem.spacing2),
        child: action,
      )).toList(),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
              tooltip: 'Back',
            )
          : null,
    );
  }
}

/// Standardized Bottom Navigation Bar for consistent navigation
class HealthBoxBottomNavBar extends StatelessWidget {
  const HealthBoxBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(HealthBoxDesignSystem.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(HealthBoxDesignSystem.radiusXl),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.transparent,
          selectedItemColor: selectedColor ?? theme.colorScheme.primary,
          unselectedItemColor: unselectedColor ?? theme.colorScheme.onSurfaceVariant,
          selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
            fontWeight: HealthBoxDesignSystem.fontWeightMedium,
          ),
          unselectedLabelStyle: theme.textTheme.labelSmall,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outlined),
              activeIcon: Icon(Icons.people),
              label: 'Profiles',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_information_outlined),
              activeIcon: Icon(Icons.medical_information),
              label: 'Records',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

/// Standardized Card Widget using design system
class HealthBoxCard extends StatelessWidget {
  const HealthBoxCard({
    super.key,
    required this.child,
    this.elevation = HealthBoxDesignSystem.shadowBase,
    this.padding = HealthBoxDesignSystem.cardPaddingBase,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
  });

  final Widget child;
  final List<BoxShadow> elevation;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(HealthBoxDesignSystem.radiusLg),
        boxShadow: elevation,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius ?? BorderRadius.circular(HealthBoxDesignSystem.radiusLg),
        child: InkWell(
          borderRadius: borderRadius ?? BorderRadius.circular(HealthBoxDesignSystem.radiusLg),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Standardized Button Widget using design system
class HealthBoxButton extends StatelessWidget {
  const HealthBoxButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height,
    this.margin,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color foregroundColor;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = HealthBoxDesignSystem.primaryBlue;
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.secondary:
        backgroundColor = theme.colorScheme.surfaceVariant;
        foregroundColor = theme.colorScheme.onSurfaceVariant;
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = HealthBoxDesignSystem.primaryBlue;
        break;
      case ButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = theme.colorScheme.onSurface;
        break;
    }

    if (!enabled) {
      backgroundColor = backgroundColor.withValues(alpha: 0.5);
      foregroundColor = foregroundColor.withValues(alpha: 0.5);
    }

    return Container(
      width: width,
      height: height ?? size.height,
      margin: margin,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 1,
          shadowColor: theme.colorScheme.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(HealthBoxDesignSystem.radiusBase),
            side: variant == ButtonVariant.outline
                ? BorderSide(color: backgroundColor, width: 1)
                : BorderSide.none,
          ),
          minimumSize: const Size(0, 0),
          padding: size.padding,
          textStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: HealthBoxDesignSystem.fontWeightMedium,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : child,
      ),
    );
  }
}

/// Button variant enumeration
enum ButtonVariant { primary, secondary, outline, ghost }

/// Button size enumeration
enum ButtonSize {
  small(
    HealthBoxDesignSystem.buttonHeightSm,
    EdgeInsets.symmetric(
      horizontal: HealthBoxDesignSystem.spacing3,
      vertical: HealthBoxDesignSystem.spacing1,
    ),
  ),
  medium(
    HealthBoxDesignSystem.buttonHeightBase,
    EdgeInsets.symmetric(
      horizontal: HealthBoxDesignSystem.spacing4,
      vertical: HealthBoxDesignSystem.spacing3,
    ),
  ),
  large(
    HealthBoxDesignSystem.buttonHeightLg,
    EdgeInsets.symmetric(
      horizontal: HealthBoxDesignSystem.spacing6,
      vertical: HealthBoxDesignSystem.spacing4,
    ),
  );

  const ButtonSize(this.height, this.padding);
  final double height;
  final EdgeInsetsGeometry padding;
}
