import 'package:flutter/material.dart';

/// Widget for selecting reminder type (notification, alarm, or both)
/// Used across all medical record forms to let users choose how they want to be reminded
class ReminderTypeSelector extends StatelessWidget {
  final ReminderType selectedType;
  final ValueChanged<ReminderType> onChanged;
  final bool enabled;
  final String? helpText;

  const ReminderTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
    this.enabled = true,
    this.helpText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notification_important_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reminder Type',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            if (helpText != null) ...[
              const SizedBox(height: 4),
              Text(
                helpText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildTypeOption(
              context,
              type: ReminderType.notification,
              icon: Icons.notifications_outlined,
              title: 'Notification',
              subtitle: 'Silent notification that appears in your notification bar',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildTypeOption(
              context,
              type: ReminderType.alarm,
              icon: Icons.alarm_outlined,
              title: 'Alarm',
              subtitle: 'Loud alarm with sound that requires dismissal',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildTypeOption(
              context,
              type: ReminderType.both,
              icon: Icons.double_arrow_outlined,
              title: 'Both',
              subtitle: 'Notification first, then alarm if not acknowledged',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(
    BuildContext context, {
    required ReminderType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = selectedType == type;

    return Material(
      elevation: isSelected ? 4 : 1,
      borderRadius: BorderRadius.circular(12),
      color: isSelected ? color.withValues(alpha: 0.1) : colorScheme.surface,
      child: InkWell(
        onTap: enabled ? () => onChanged(type) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? color : color.withValues(alpha: 0.7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                          ? color.withValues(alpha: 0.8)
                          : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enum for different reminder types
enum ReminderType {
  notification,
  alarm,
  both,
}

extension ReminderTypeExtension on ReminderType {
  String get displayName {
    switch (this) {
      case ReminderType.notification:
        return 'Notification';
      case ReminderType.alarm:
        return 'Alarm';
      case ReminderType.both:
        return 'Both';
    }
  }

  String get description {
    switch (this) {
      case ReminderType.notification:
        return 'Silent notification that appears in your notification bar';
      case ReminderType.alarm:
        return 'Loud alarm with sound that requires dismissal';
      case ReminderType.both:
        return 'Notification first, then alarm if not acknowledged';
    }
  }

  IconData get icon {
    switch (this) {
      case ReminderType.notification:
        return Icons.notifications_outlined;
      case ReminderType.alarm:
        return Icons.alarm_outlined;
      case ReminderType.both:
        return Icons.double_arrow_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ReminderType.notification:
        return Colors.blue;
      case ReminderType.alarm:
        return Colors.orange;
      case ReminderType.both:
        return Colors.purple;
    }
  }

  /// Convert to string for database storage
  String get value {
    switch (this) {
      case ReminderType.notification:
        return 'notification';
      case ReminderType.alarm:
        return 'alarm';
      case ReminderType.both:
        return 'both';
    }
  }

  /// Create from database string value
  static ReminderType fromValue(String value) {
    switch (value) {
      case 'notification':
        return ReminderType.notification;
      case 'alarm':
        return ReminderType.alarm;
      case 'both':
        return ReminderType.both;
      default:
        return ReminderType.notification; // Default fallback
    }
  }
}