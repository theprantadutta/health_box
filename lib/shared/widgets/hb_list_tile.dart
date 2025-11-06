import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import 'hb_card.dart';

/// ============================================================================
/// HBListTile - Standardized HealthBox List Tile
/// Consistent list items with Material 3 styling
/// ============================================================================

class HBListTile extends StatelessWidget {
  const HBListTile({
    super.key,
    this.leading,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.contentPadding,
    this.dense = false,
    this.isThreeLine = false,
    this.visualDensity,
  });

  final Widget? leading;
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool selected;
  final EdgeInsetsGeometry? contentPadding;
  final bool dense;
  final bool isThreeLine;
  final VisualDensity? visualDensity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: titleWidget ?? (title != null ? Text(title!) : null),
      subtitle: subtitleWidget ?? (subtitle != null ? Text(subtitle!) : null),
      trailing: trailing,
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      enabled: enabled,
      selected: selected,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      dense: dense,
      isThreeLine: isThreeLine,
      visualDensity: visualDensity,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.radiusMd,
      ),
    );
  }

  // ============================================================================
  // Factory Constructors
  // ============================================================================

  /// Standard list tile with icon
  factory HBListTile.icon({
    Key? key,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool enabled = true,
    Color? iconColor,
    Gradient? iconGradient,
  }) {
    return HBListTile(
      key: key,
      leading: iconGradient != null
          ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: iconGradient,
                borderRadius: BorderRadius.circular(AppRadii.md),
                boxShadow: AppElevation.coloredShadow(
                  iconGradient.colors.first,
                  opacity: 0.3,
                ),
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            )
          : Icon(icon, color: iconColor),
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
      enabled: enabled,
    );
  }

  /// Medical record list tile
  factory HBListTile.record({
    Key? key,
    required String recordType,
    required String title,
    required String subtitle,
    String? date,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool enabled = true,
    bool useGradient = true,
  }) {
    return HBListTile(
      key: key,
      leading: HBRecordIcon(
        recordType: recordType,
        size: 40,
        useGradient: useGradient,
      ),
      titleWidget: Text(
        title,
        style: const TextStyle(
          fontWeight: AppTypography.fontWeightMedium,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (date != null) ...[
            const SizedBox(height: 2),
            Builder(
              builder: (context) => Text(
                date,
                style: TextStyle(
                  fontSize: AppTypography.fontSizeXs,
                  color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      onLongPress: onLongPress,
      enabled: enabled,
      isThreeLine: date != null,
    );
  }

  /// Settings list tile
  factory HBListTile.settings({
    Key? key,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool enabled = true,
    Color? iconColor,
  }) {
    return HBListTile(
      key: key,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor?.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor,
        ),
      ),
      title: title,
      subtitle: subtitle,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      enabled: enabled,
    );
  }

  /// Switch list tile
  factory HBListTile.switchTile({
    Key? key,
    required String title,
    String? subtitle,
    IconData? icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
    Color? iconColor,
  }) {
    return HBListTile(
      key: key,
      leading: icon != null
          ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor?.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            )
          : null,
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
      onTap: enabled ? () => onChanged(!value) : null,
      enabled: enabled,
    );
  }

  /// Checkbox list tile
  factory HBListTile.checkboxTile({
    Key? key,
    required String title,
    String? subtitle,
    IconData? icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
    Color? iconColor,
  }) {
    return HBListTile(
      key: key,
      leading: icon != null
          ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor?.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            )
          : null,
      title: title,
      subtitle: subtitle,
      trailing: Checkbox(
        value: value,
        onChanged: enabled ? (v) => onChanged(v ?? false) : null,
      ),
      onTap: enabled ? () => onChanged(!value) : null,
      enabled: enabled,
    );
  }

  /// Radio list tile
  factory HBListTile.radioTile<T>({
    Key? key,
    required String title,
    String? subtitle,
    IconData? icon,
    required T value,
    required T groupValue,
    required ValueChanged<T> onChanged,
    bool enabled = true,
    Color? iconColor,
  }) {
    return HBListTile(
      key: key,
      leading: icon != null
          ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor?.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            )
          : null,
      title: title,
      subtitle: subtitle,
      trailing: Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: enabled ? (v) => onChanged(v as T) : null,
      ),
      onTap: enabled ? () => onChanged(value) : null,
      enabled: enabled,
      selected: value == groupValue,
    );
  }

  /// Avatar list tile
  factory HBListTile.avatar({
    Key? key,
    required Widget avatar,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool enabled = true,
  }) {
    return HBListTile(
      key: key,
      leading: avatar,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
      enabled: enabled,
    );
  }

  /// Profile list tile with circular avatar
  factory HBListTile.profile({
    Key? key,
    required String name,
    String? relationship,
    String? avatarUrl,
    IconData? fallbackIcon = Icons.person,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool enabled = true,
  }) {
    return HBListTile(
      key: key,
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? Icon(fallbackIcon, size: 20)
            : null,
      ),
      title: name,
      subtitle: relationship,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      onLongPress: onLongPress,
      enabled: enabled,
    );
  }

  /// Expandable list tile header
  factory HBListTile.expandable({
    Key? key,
    required String title,
    String? subtitle,
    IconData? icon,
    required bool expanded,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return HBListTile(
      key: key,
      leading: icon != null
          ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor?.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            )
          : null,
      title: title,
      subtitle: subtitle,
      trailing: AnimatedRotation(
        turns: expanded ? 0.5 : 0,
        duration: AppDurations.normal,
        child: const Icon(Icons.expand_more),
      ),
      onTap: onTap,
    );
  }
}

/// ============================================================================
/// HBSectionHeader - Section header for lists
/// ============================================================================

class HBSectionHeader extends StatelessWidget {
  const HBSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.lg,
        AppSpacing.base,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: AppTypography.fontWeightSemiBold,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// ============================================================================
/// HBDivider - Consistent divider for lists
/// ============================================================================

class HBDivider extends StatelessWidget {
  const HBDivider({
    super.key,
    this.indent,
    this.endIndent,
    this.height,
    this.thickness,
    this.color,
  });

  final double? indent;
  final double? endIndent;
  final double? height;
  final double? thickness;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      indent: indent,
      endIndent: endIndent,
      height: height ?? AppSpacing.base,
      thickness: thickness ?? 1,
      color: color ?? context.colorScheme.outlineVariant,
    );
  }

  /// Divider with standard indent (for list tiles with leading icons)
  factory HBDivider.indent({
    Key? key,
    Color? color,
  }) {
    return HBDivider(
      key: key,
      indent: AppSpacing.base + 40 + AppSpacing.base, // padding + icon + spacing
      color: color,
    );
  }
}
