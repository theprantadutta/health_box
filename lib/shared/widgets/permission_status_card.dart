import 'package:flutter/material.dart';

/// Widget for displaying permission status with action buttons
/// Shows the current state of notification and alarm permissions with options to fix issues
class PermissionStatusCard extends StatelessWidget {
  final PermissionStatus permissionStatus;
  final VoidCallback? onRequestPermissions;
  final VoidCallback? onOpenSettings;
  final bool showActions;
  final EdgeInsetsGeometry? margin;

  const PermissionStatusCard({
    super.key,
    required this.permissionStatus,
    this.onRequestPermissions,
    this.onOpenSettings,
    this.showActions = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      child: Card(
        elevation: permissionStatus.hasIssues ? 4 : 2,
        color: _getCardColor(colorScheme),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getIconBackgroundColor(colorScheme),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: _getIconColor(colorScheme),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusTitle(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getTextColor(colorScheme),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getStatusDescription(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getSubtitleColor(colorScheme),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context),
                ],
              ),
              if (permissionStatus.hasIssues) ...[
                const SizedBox(height: 16),
                _buildIssuesList(context),
              ],
              if (showActions && (permissionStatus.hasIssues || !permissionStatus.isOptimal)) ...[
                const SizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBadgeColor(colorScheme),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getBadgeText(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: _getBadgeTextColor(colorScheme),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildIssuesList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final issues = _getIssuesList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: colorScheme.error,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Issues found:',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...issues.map((issue) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 8),
                Text(
                  '•',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    issue,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        if (permissionStatus.canRequestPermissions && onRequestPermissions != null)
          Expanded(
            child: FilledButton.icon(
              onPressed: onRequestPermissions,
              icon: const Icon(Icons.security, size: 18),
              label: const Text('Grant Permissions'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ),
        if (permissionStatus.canRequestPermissions &&
            onRequestPermissions != null &&
            onOpenSettings != null)
          const SizedBox(width: 8),
        if (onOpenSettings != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('Open Settings'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (permissionStatus.level) {
      case PermissionLevel.optimal:
        return Icons.check_circle_outline;
      case PermissionLevel.basic:
        return Icons.warning_amber_outlined;
      case PermissionLevel.none:
        return Icons.block_outlined;
    }
  }

  String _getStatusTitle() {
    switch (permissionStatus.level) {
      case PermissionLevel.optimal:
        return 'All Set!';
      case PermissionLevel.basic:
        return 'Partial Setup';
      case PermissionLevel.none:
        return 'Setup Required';
    }
  }

  String _getStatusDescription() {
    switch (permissionStatus.level) {
      case PermissionLevel.optimal:
        return 'All permissions configured for reliable reminders';
      case PermissionLevel.basic:
        return 'Basic notifications enabled, some features limited';
      case PermissionLevel.none:
        return 'Permissions needed for reminders to work';
    }
  }

  String _getBadgeText() {
    switch (permissionStatus.level) {
      case PermissionLevel.optimal:
        return 'READY';
      case PermissionLevel.basic:
        return 'LIMITED';
      case PermissionLevel.none:
        return 'BLOCKED';
    }
  }

  List<String> _getIssuesList() {
    final issues = <String>[];

    if (!permissionStatus.notificationsEnabled) {
      issues.add('Notifications are disabled');
    }
    if (!permissionStatus.exactAlarmsEnabled) {
      issues.add('Exact alarms are disabled (Android 12+)');
    }
    if (!permissionStatus.batteryOptimizationDisabled) {
      issues.add('Battery optimization is enabled (may stop alarms)');
    }
    if (permissionStatus.soundEnabled == false) {
      issues.add('Notification sounds are disabled');
    }
    if (permissionStatus.badgeEnabled == false) {
      issues.add('App badge notifications are disabled');
    }

    return issues;
  }

  Color _getCardColor(ColorScheme colorScheme) {
    switch (permissionStatus.level) {
      case PermissionLevel.optimal:
        return colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
      case PermissionLevel.basic:
        return colorScheme.tertiaryContainer.withValues(alpha: 0.3);
      case PermissionLevel.none:
        return colorScheme.errorContainer.withValues(alpha: 0.3);
    }
  }

  Color _getIconBackgroundColor(ColorScheme colorScheme) {
    switch (permissionStatus.level) {
      case PermissionLevel.optimal:
        return colorScheme.primaryContainer.withValues(alpha: 0.5);
      case PermissionLevel.basic:
        return colorScheme.tertiaryContainer.withValues(alpha: 0.5);
      case PermissionLevel.none:
        return colorScheme.errorContainer.withValues(alpha: 0.5);
    }
  }

  Color _getIconColor(ColorScheme colorScheme) {
    switch (permissionStatus.level) {
      case PermissionLevel.optimal:
        return colorScheme.primary;
      case PermissionLevel.basic:
        return colorScheme.tertiary;
      case PermissionLevel.none:
        return colorScheme.error;
    }
  }

  Color _getTextColor(ColorScheme colorScheme) {
    return colorScheme.onSurface;
  }

  Color _getSubtitleColor(ColorScheme colorScheme) {
    return colorScheme.onSurfaceVariant;
  }

  Color _getBadgeColor(ColorScheme colorScheme) {
    switch (permissionStatus.level) {
      case PermissionLevel.optimal:
        return colorScheme.primary;
      case PermissionLevel.basic:
        return colorScheme.tertiary;
      case PermissionLevel.none:
        return colorScheme.error;
    }
  }

  Color _getBadgeTextColor(ColorScheme colorScheme) {
    switch (permissionStatus.level) {
      case PermissionLevel.optimal:
        return colorScheme.onPrimary;
      case PermissionLevel.basic:
        return colorScheme.onTertiary;
      case PermissionLevel.none:
        return colorScheme.onError;
    }
  }
}

/// Comprehensive permission status information
class PermissionStatus {
  final bool notificationsEnabled;
  final bool exactAlarmsEnabled;
  final bool canScheduleExactAlarms;
  final bool batteryOptimizationDisabled;
  final bool? soundEnabled;
  final bool? badgeEnabled;

  const PermissionStatus({
    required this.notificationsEnabled,
    required this.exactAlarmsEnabled,
    required this.canScheduleExactAlarms,
    required this.batteryOptimizationDisabled,
    this.soundEnabled,
    this.badgeEnabled,
  });

  PermissionLevel get level {
    if (isOptimal) return PermissionLevel.optimal;
    if (hasBasicPermissions) return PermissionLevel.basic;
    return PermissionLevel.none;
  }

  bool get isOptimal {
    return notificationsEnabled &&
           exactAlarmsEnabled &&
           batteryOptimizationDisabled &&
           (soundEnabled ?? true) &&
           (badgeEnabled ?? true);
  }

  bool get hasBasicPermissions {
    return notificationsEnabled;
  }

  bool get hasIssues {
    return !notificationsEnabled ||
           !exactAlarmsEnabled ||
           !batteryOptimizationDisabled ||
           (soundEnabled == false) ||
           (badgeEnabled == false);
  }

  bool get canRequestPermissions {
    return !notificationsEnabled || !exactAlarmsEnabled;
  }

  String get statusDescription {
    switch (level) {
      case PermissionLevel.optimal:
        return 'All permissions configured for reliable reminders';
      case PermissionLevel.basic:
        return 'Basic notifications enabled, some features may be limited';
      case PermissionLevel.none:
        return 'Notifications disabled, reminders will not work';
    }
  }
}

enum PermissionLevel {
  none,
  basic,
  optimal,
}

/// Compact permission status indicator
class PermissionStatusIndicator extends StatelessWidget {
  final PermissionStatus permissionStatus;
  final bool showLabel;
  final double size;

  const PermissionStatusIndicator({
    super.key,
    required this.permissionStatus,
    this.showLabel = true,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final color = switch (permissionStatus.level) {
      PermissionLevel.optimal => colorScheme.primary,
      PermissionLevel.basic => colorScheme.tertiary,
      PermissionLevel.none => colorScheme.error,
    };

    final icon = switch (permissionStatus.level) {
      PermissionLevel.optimal => Icons.check_circle,
      PermissionLevel.basic => Icons.warning_amber,
      PermissionLevel.none => Icons.block,
    };

    if (!showLabel) {
      return Icon(icon, color: color, size: size);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: size),
        const SizedBox(width: 4),
        Text(
          permissionStatus.level.name.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}