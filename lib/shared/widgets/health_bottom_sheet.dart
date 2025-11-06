import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import 'gradient_button.dart';

/// Modern bottom sheet with Material 3 styling and medical theme support
class HealthBottomSheet {
  /// Show a modal bottom sheet with custom content
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    EdgeInsetsGeometry? padding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation ?? 0,
      isScrollControlled: true,
      builder: (context) => _HealthBottomSheetWrapper(
        padding: padding,
        child: child,
      ),
    );
  }

  /// Show a confirmation bottom sheet
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    HealthButtonStyle confirmStyle = HealthButtonStyle.primary,
    IconData? icon,
    bool isDangerous = false,
  }) {
    return show<bool>(
      context: context,
      child: _HealthConfirmationBottomSheet(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmStyle: isDangerous ? HealthButtonStyle.error : confirmStyle,
        icon: icon,
      ),
    );
  }

  /// Show a list selection bottom sheet
  static Future<T?> showListSelection<T>({
    required BuildContext context,
    required String title,
    required List<HealthBottomSheetItem<T>> items,
    T? selectedValue,
    bool showSearch = false,
  }) {
    return show<T>(
      context: context,
      child: _HealthListSelectionBottomSheet<T>(
        title: title,
        items: items,
        selectedValue: selectedValue,
        showSearch: showSearch,
      ),
    );
  }

  /// Show an action sheet with multiple options
  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required List<HealthActionSheetItem<T>> actions,
    bool showCancelButton = true,
    String cancelText = 'Cancel',
  }) {
    return show<T>(
      context: context,
      child: _HealthActionSheetBottomSheet<T>(
        title: title,
        subtitle: subtitle,
        actions: actions,
        showCancelButton: showCancelButton,
        cancelText: cancelText,
      ),
    );
  }

  /// Show a menu bottom sheet
  static Future<void> showMenu({
    required BuildContext context,
    required String title,
    String? subtitle,
    required List<HealthMenuItem> items,
  }) {
    return show<void>(
      context: context,
      child: _HealthMenuBottomSheet(
        title: title,
        subtitle: subtitle,
        items: items,
      ),
    );
  }
}

/// Bottom sheet item for list selection
class HealthBottomSheetItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final LinearGradient? gradient;
  final bool enabled;

  const HealthBottomSheetItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.gradient,
    this.enabled = true,
  });
}

/// Action sheet item
class HealthActionSheetItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final HealthButtonStyle? style;
  final bool isDangerous;

  const HealthActionSheetItem({
    required this.value,
    required this.label,
    this.icon,
    this.style,
    this.isDangerous = false,
  });
}

/// Menu item for menu bottom sheet
class HealthMenuItem {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final LinearGradient? gradient;
  final bool enabled;

  const HealthMenuItem({
    required this.label,
    this.icon,
    required this.onTap,
    this.gradient,
    this.enabled = true,
  });
}

/// Internal wrapper for bottom sheets
class _HealthBottomSheetWrapper extends StatelessWidget {
  const _HealthBottomSheetWrapper({
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(HealthBoxDesignSystem.radius3xl),
          topRight: Radius.circular(HealthBoxDesignSystem.radius3xl),
        ),
        boxShadow: HealthBoxDesignSystem.shadowXl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          SizedBox(height: HealthBoxDesignSystem.spacing2),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: HealthBoxDesignSystem.neutral300,
              borderRadius: BorderRadius.circular(
                HealthBoxDesignSystem.radiusFull,
              ),
            ),
          ),
          SizedBox(height: HealthBoxDesignSystem.spacing4),

          // Content
          Flexible(
            child: Padding(
              padding: padding ??
                  EdgeInsets.fromLTRB(
                    HealthBoxDesignSystem.spacing6,
                    0,
                    HealthBoxDesignSystem.spacing6,
                    HealthBoxDesignSystem.spacing6,
                  ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal confirmation bottom sheet
class _HealthConfirmationBottomSheet extends StatelessWidget {
  const _HealthConfirmationBottomSheet({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.confirmStyle,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final HealthButtonStyle confirmStyle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon (if provided)
        if (icon != null) ...[
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: _getIconGradient(),
                borderRadius: BorderRadius.circular(
                  HealthBoxDesignSystem.radiusXl,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ),
          SizedBox(height: HealthBoxDesignSystem.spacing4),
        ],

        // Title
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
          ),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing3),

        // Message
        Text(
          message,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: HealthBoxDesignSystem.textSecondary,
            height: HealthBoxDesignSystem.lineHeightRelaxed,
          ),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing6),

        // Actions
        Row(
          children: [
            // Cancel button
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(
                    0,
                    HealthBoxDesignSystem.buttonHeightLg,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      HealthBoxDesignSystem.radiusBase,
                    ),
                  ),
                ),
                child: Text(cancelText),
              ),
            ),
            SizedBox(width: HealthBoxDesignSystem.spacing3),

            // Confirm button
            Expanded(
              child: HealthButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: confirmStyle,
                size: HealthButtonSize.large,
                child: Text(confirmText),
              ),
            ),
          ],
        ),
      ],
    );
  }

  LinearGradient _getIconGradient() {
    switch (confirmStyle) {
      case HealthButtonStyle.primary:
        return HealthBoxDesignSystem.medicalBlue;
      case HealthButtonStyle.success:
        return HealthBoxDesignSystem.successGradient;
      case HealthButtonStyle.warning:
        return HealthBoxDesignSystem.warningGradient;
      case HealthButtonStyle.error:
        return HealthBoxDesignSystem.errorGradient;
    }
  }
}

/// Internal list selection bottom sheet
class _HealthListSelectionBottomSheet<T> extends StatefulWidget {
  const _HealthListSelectionBottomSheet({
    required this.title,
    required this.items,
    this.selectedValue,
    this.showSearch = false,
  });

  final String title;
  final List<HealthBottomSheetItem<T>> items;
  final T? selectedValue;
  final bool showSearch;

  @override
  State<_HealthListSelectionBottomSheet<T>> createState() =>
      _HealthListSelectionBottomSheetState<T>();
}

class _HealthListSelectionBottomSheetState<T>
    extends State<_HealthListSelectionBottomSheet<T>> {
  late List<HealthBottomSheetItem<T>> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items
          .where(
            (item) =>
                item.label.toLowerCase().contains(query) ||
                (item.subtitle?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          widget.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
          ),
        ),
        SizedBox(height: HealthBoxDesignSystem.spacing4),

        // Search field (if enabled)
        if (widget.showSearch) ...[
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  HealthBoxDesignSystem.radiusBase,
                ),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: HealthBoxDesignSystem.spacing4,
                vertical: HealthBoxDesignSystem.spacing3,
              ),
            ),
          ),
          SizedBox(height: HealthBoxDesignSystem.spacing3),
        ],

        // List
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              final isSelected = item.value == widget.selectedValue;

              return ListTile(
                enabled: item.enabled,
                leading: item.icon != null
                    ? Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: item.gradient ??
                              HealthBoxDesignSystem.medicalBlue,
                          borderRadius: BorderRadius.circular(
                            HealthBoxDesignSystem.radiusBase,
                          ),
                        ),
                        child: Icon(item.icon, color: Colors.white, size: 20),
                      )
                    : null,
                title: Text(item.label),
                subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: HealthBoxDesignSystem.primaryBlue,
                      )
                    : null,
                selected: isSelected,
                onTap: item.enabled
                    ? () => Navigator.of(context).pop(item.value)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Internal action sheet bottom sheet
class _HealthActionSheetBottomSheet<T> extends StatelessWidget {
  const _HealthActionSheetBottomSheet({
    required this.title,
    this.subtitle,
    required this.actions,
    required this.showCancelButton,
    required this.cancelText,
  });

  final String title;
  final String? subtitle;
  final List<HealthActionSheetItem<T>> actions;
  final bool showCancelButton;
  final String cancelText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
          ),
        ),

        if (subtitle != null) ...[
          SizedBox(height: HealthBoxDesignSystem.spacing2),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: HealthBoxDesignSystem.textSecondary,
            ),
          ),
        ],

        SizedBox(height: HealthBoxDesignSystem.spacing4),

        // Actions
        ...actions.map((action) {
          return Padding(
            padding: EdgeInsets.only(bottom: HealthBoxDesignSystem.spacing2),
            child: HealthButton(
              onPressed: () => Navigator.of(context).pop(action.value),
              style: action.isDangerous
                  ? HealthButtonStyle.error
                  : (action.style ?? HealthButtonStyle.primary),
              size: HealthButtonSize.large,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (action.icon != null) ...[
                    Icon(action.icon, size: 20),
                    SizedBox(width: HealthBoxDesignSystem.spacing2),
                  ],
                  Text(action.label),
                ],
              ),
            ),
          );
        }),

        // Cancel button
        if (showCancelButton) ...[
          SizedBox(height: HealthBoxDesignSystem.spacing2),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(
                double.infinity,
                HealthBoxDesignSystem.buttonHeightLg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  HealthBoxDesignSystem.radiusBase,
                ),
              ),
            ),
            child: Text(cancelText),
          ),
        ],
      ],
    );
  }
}

/// Internal menu bottom sheet
class _HealthMenuBottomSheet extends StatelessWidget {
  const _HealthMenuBottomSheet({
    required this.title,
    this.subtitle,
    required this.items,
  });

  final String title;
  final String? subtitle;
  final List<HealthMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: HealthBoxDesignSystem.fontWeightSemiBold,
          ),
        ),

        if (subtitle != null) ...[
          SizedBox(height: HealthBoxDesignSystem.spacing2),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: HealthBoxDesignSystem.textSecondary,
            ),
          ),
        ],

        SizedBox(height: HealthBoxDesignSystem.spacing4),

        // Menu items
        ...items.map((item) {
          return ListTile(
            enabled: item.enabled,
            leading: item.icon != null
                ? Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient:
                          item.gradient ?? HealthBoxDesignSystem.medicalBlue,
                      borderRadius: BorderRadius.circular(
                        HealthBoxDesignSystem.radiusBase,
                      ),
                    ),
                    child: Icon(item.icon, color: Colors.white, size: 20),
                  )
                : null,
            title: Text(item.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: item.enabled
                ? () {
                    Navigator.of(context).pop();
                    item.onTap();
                  }
                : null,
          );
        }),
      ],
    );
  }
}
