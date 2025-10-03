import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// Modern chip with gradient background and optional delete button
class GradientChip extends StatelessWidget {
  final String label;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final VoidCallback? onDeleted;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool selected;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  const GradientChip({
    super.key,
    required this.label,
    this.gradient,
    this.backgroundColor,
    this.onDeleted,
    this.onTap,
    this.icon,
    this.selected = false,
    this.padding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveGradient = gradient ?? HealthBoxDesignSystem.medicalBlue;

    Widget chipContent = Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: onDeleted != null ? 12 : 16,
            vertical: 8,
          ),
      decoration: BoxDecoration(
        gradient: selected || gradient != null ? effectiveGradient : null,
        color: !selected && gradient == null
            ? (backgroundColor ?? theme.colorScheme.primaryContainer)
            : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: selected || gradient != null
            ? HealthBoxDesignSystem.coloredShadow(
                effectiveGradient.colors.first,
                opacity: 0.3,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: selected || gradient != null
                  ? Colors.white
                  : theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: selected || gradient != null
                  ? Colors.white
                  : theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDeleted,
              child: Icon(
                Icons.close,
                size: 16,
                color: selected || gradient != null
                    ? Colors.white
                    : theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: chipContent,
      );
    }

    return chipContent;
  }
}

/// Filter chip with selection state
class GradientFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final LinearGradient? selectedGradient;
  final IconData? icon;

  const GradientFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.selectedGradient,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GradientChip(
      label: label,
      selected: selected,
      gradient: selected ? (selectedGradient ?? HealthBoxDesignSystem.medicalBlue) : null,
      onTap: onSelected,
      icon: icon,
    );
  }
}

/// Tag chip for categorization
class TagChip extends StatelessWidget {
  final String label;
  final LinearGradient? gradient;
  final VoidCallback? onDeleted;
  final IconData? icon;

  const TagChip({
    super.key,
    required this.label,
    this.gradient,
    this.onDeleted,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GradientChip(
      label: label,
      gradient: gradient,
      onDeleted: onDeleted,
      icon: icon,
    );
  }
}
