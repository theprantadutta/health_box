import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// ============================================================================
/// HBChip - Standardized HealthBox Chip
/// Material 3 chips with consistent styling and variants
/// ============================================================================

class HBChip extends StatelessWidget {
  const HBChip({
    super.key,
    required this.label,
    this.onTap,
    this.onDeleted,
    this.selected = false,
    this.icon,
    this.avatar,
    this.deleteIcon,
    this.backgroundColor,
    this.selectedColor,
    this.gradient,
    this.variant = HBChipVariant.filter,
    this.size = HBChipSize.medium,
  });

  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool selected;
  final IconData? icon;
  final Widget? avatar;
  final IconData? deleteIcon;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Gradient? gradient;
  final HBChipVariant variant;
  final HBChipSize size;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case HBChipVariant.filter:
        return _buildFilterChip(context);
      case HBChipVariant.assist:
        return _buildAssistChip(context);
      case HBChipVariant.input:
        return _buildInputChip(context);
      case HBChipVariant.choice:
        return _buildChoiceChip(context);
    }
  }

  Widget _buildFilterChip(BuildContext context) {
    if (gradient != null && selected) {
      return _buildGradientChip(context);
    }

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      avatar: _buildAvatar(context),
      showCheckmark: false,
      backgroundColor: backgroundColor ?? context.colorScheme.surfaceContainerHighest,
      selectedColor: selectedColor ?? context.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: selected
            ? context.colorScheme.onPrimaryContainer
            : context.colorScheme.onSurfaceVariant,
        fontSize: size.fontSize,
        fontWeight: selected
            ? AppTypography.fontWeightMedium
            : AppTypography.fontWeightNormal,
      ),
      padding: size.padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      side: selected
          ? BorderSide.none
          : BorderSide(
              color: context.colorScheme.outline,
              width: 1,
            ),
    );
  }

  Widget _buildGradientChip(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.full),
      child: Container(
        padding: size.padding,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadii.full),
          boxShadow: AppElevation.coloredShadow(
            gradient!.colors.first,
            opacity: 0.3,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: size.iconSize, color: Colors.white),
              SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: size.fontSize,
                fontWeight: AppTypography.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistChip(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      avatar: _buildAvatar(context),
      backgroundColor: backgroundColor ?? context.colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: context.colorScheme.onSurfaceVariant,
        fontSize: size.fontSize,
      ),
      padding: size.padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      side: BorderSide(
        color: context.colorScheme.outline,
        width: 1,
      ),
    );
  }

  Widget _buildInputChip(BuildContext context) {
    return InputChip(
      label: Text(label),
      onPressed: onTap,
      onDeleted: onDeleted,
      avatar: _buildAvatar(context),
      deleteIcon: Icon(deleteIcon ?? Icons.close, size: size.iconSize),
      backgroundColor: backgroundColor ?? context.colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: context.colorScheme.onSurfaceVariant,
        fontSize: size.fontSize,
      ),
      padding: size.padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      side: BorderSide(
        color: context.colorScheme.outline,
        width: 1,
      ),
    );
  }

  Widget _buildChoiceChip(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      avatar: _buildAvatar(context),
      showCheckmark: false,
      backgroundColor: backgroundColor ?? context.colorScheme.surfaceContainerHighest,
      selectedColor: selectedColor ?? context.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: selected
            ? context.colorScheme.onPrimaryContainer
            : context.colorScheme.onSurfaceVariant,
        fontSize: size.fontSize,
        fontWeight: selected
            ? AppTypography.fontWeightMedium
            : AppTypography.fontWeightNormal,
      ),
      padding: size.padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      side: selected
          ? BorderSide.none
          : BorderSide(
              color: context.colorScheme.outline,
              width: 1,
            ),
    );
  }

  Widget? _buildAvatar(BuildContext context) {
    if (avatar != null) return avatar;
    if (icon != null) {
      return Icon(
        icon,
        size: size.iconSize,
        color: selected
            ? context.colorScheme.onPrimaryContainer
            : context.colorScheme.onSurfaceVariant,
      );
    }
    return null;
  }

  // ============================================================================
  // Factory Constructors
  // ============================================================================

  /// Filter chip for filtering content
  factory HBChip.filter({
    Key? key,
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    IconData? icon,
    Gradient? gradient,
    HBChipSize size = HBChipSize.medium,
  }) {
    return HBChip(
      key: key,
      label: label,
      selected: selected,
      onTap: () => onSelected(!selected),
      icon: icon,
      gradient: gradient,
      variant: HBChipVariant.filter,
      size: size,
    );
  }

  /// Assist chip for actions
  factory HBChip.assist({
    Key? key,
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    HBChipSize size = HBChipSize.medium,
  }) {
    return HBChip(
      key: key,
      label: label,
      onTap: onPressed,
      icon: icon,
      variant: HBChipVariant.assist,
      size: size,
    );
  }

  /// Input chip for user input
  factory HBChip.input({
    Key? key,
    required String label,
    required VoidCallback onDeleted,
    VoidCallback? onPressed,
    IconData? icon,
    IconData? deleteIcon,
    HBChipSize size = HBChipSize.medium,
  }) {
    return HBChip(
      key: key,
      label: label,
      onTap: onPressed,
      onDeleted: onDeleted,
      icon: icon,
      deleteIcon: deleteIcon,
      variant: HBChipVariant.input,
      size: size,
    );
  }

  /// Choice chip for single selection
  factory HBChip.choice({
    Key? key,
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    IconData? icon,
    HBChipSize size = HBChipSize.medium,
  }) {
    return HBChip(
      key: key,
      label: label,
      selected: selected,
      onTap: () => onSelected(!selected),
      icon: icon,
      variant: HBChipVariant.choice,
      size: size,
    );
  }

  /// Medical record type chip with gradient
  factory HBChip.recordType({
    Key? key,
    required String label,
    required String recordType,
    required bool selected,
    required ValueChanged<bool> onSelected,
    HBChipSize size = HBChipSize.medium,
  }) {
    return HBChip(
      key: key,
      label: label,
      selected: selected,
      onTap: () => onSelected(!selected),
      icon: RecordTypeUtils.getIcon(recordType),
      gradient: RecordTypeUtils.getGradient(recordType),
      variant: HBChipVariant.filter,
      size: size,
    );
  }
}

/// ============================================================================
/// HBChipGroup - Group of chips with single or multiple selection
/// ============================================================================

class HBChipGroup extends StatelessWidget {
  const HBChipGroup({
    super.key,
    required this.chips,
    this.spacing = AppSpacing.sm,
    this.runSpacing = AppSpacing.sm,
    this.alignment = WrapAlignment.start,
    this.crossAlignment = WrapCrossAlignment.center,
  });

  final List<Widget> chips;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAlignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      crossAxisAlignment: crossAlignment,
      children: chips,
    );
  }

  /// Single selection chip group
  factory HBChipGroup.singleSelect({
    Key? key,
    required List<String> labels,
    required int? selectedIndex,
    required ValueChanged<int> onSelected,
    List<IconData>? icons,
    HBChipSize size = HBChipSize.medium,
    double spacing = AppSpacing.sm,
    double runSpacing = AppSpacing.sm,
  }) {
    return HBChipGroup(
      key: key,
      spacing: spacing,
      runSpacing: runSpacing,
      chips: List.generate(
        labels.length,
        (index) => HBChip.choice(
          label: labels[index],
          selected: selectedIndex == index,
          onSelected: (selected) {
            if (selected) onSelected(index);
          },
          icon: icons != null && index < icons.length ? icons[index] : null,
          size: size,
        ),
      ),
    );
  }

  /// Multiple selection chip group
  factory HBChipGroup.multiSelect({
    Key? key,
    required List<String> labels,
    required Set<int> selectedIndices,
    required ValueChanged<Set<int>> onChanged,
    List<IconData>? icons,
    List<Gradient>? gradients,
    HBChipSize size = HBChipSize.medium,
    double spacing = AppSpacing.sm,
    double runSpacing = AppSpacing.sm,
  }) {
    return HBChipGroup(
      key: key,
      spacing: spacing,
      runSpacing: runSpacing,
      chips: List.generate(
        labels.length,
        (index) => HBChip.filter(
          label: labels[index],
          selected: selectedIndices.contains(index),
          onSelected: (selected) {
            final newSet = Set<int>.from(selectedIndices);
            if (selected) {
              newSet.add(index);
            } else {
              newSet.remove(index);
            }
            onChanged(newSet);
          },
          icon: icons != null && index < icons.length ? icons[index] : null,
          gradient: gradients != null && index < gradients.length
              ? gradients[index]
              : null,
          size: size,
        ),
      ),
    );
  }

  /// Record type filter chips
  factory HBChipGroup.recordTypes({
    Key? key,
    required List<String> recordTypes,
    required Set<String> selectedTypes,
    required ValueChanged<Set<String>> onChanged,
    HBChipSize size = HBChipSize.medium,
    double spacing = AppSpacing.sm,
    double runSpacing = AppSpacing.sm,
  }) {
    return HBChipGroup(
      key: key,
      spacing: spacing,
      runSpacing: runSpacing,
      chips: recordTypes
          .map(
            (type) => HBChip.recordType(
              label: _formatRecordType(type),
              recordType: type,
              selected: selectedTypes.contains(type),
              onSelected: (selected) {
                final newSet = Set<String>.from(selectedTypes);
                if (selected) {
                  newSet.add(type);
                } else {
                  newSet.remove(type);
                }
                onChanged(newSet);
              },
              size: size,
            ),
          )
          .toList(),
    );
  }

  static String _formatRecordType(String type) {
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

/// ============================================================================
/// Enums
/// ============================================================================

enum HBChipVariant {
  filter,
  assist,
  input,
  choice,
}

enum HBChipSize {
  small(
    fontSize: AppTypography.fontSizeXs,
    iconSize: 14.0,
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ),
  medium(
    fontSize: AppTypography.fontSizeSm,
    iconSize: 16.0,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),
  large(
    fontSize: AppTypography.fontSizeBase,
    iconSize: 18.0,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );

  const HBChipSize({
    required this.fontSize,
    required this.iconSize,
    required this.padding,
  });

  final double fontSize;
  final double iconSize;
  final EdgeInsets padding;
}
