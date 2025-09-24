import 'package:flutter/material.dart';

import '../services/refill_reminder_service.dart';

/// Widget for displaying refill urgency indicators
class RefillUrgencyIndicatorWidget extends StatelessWidget {
  final RefillUrgency urgency;
  final RefillUrgencyIndicatorSize size;
  final bool showLabel;

  const RefillUrgencyIndicatorWidget({
    super.key,
    required this.urgency,
    this.size = RefillUrgencyIndicatorSize.medium,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (size) {
      case RefillUrgencyIndicatorSize.small:
        return _buildSmallIndicator(context);
      case RefillUrgencyIndicatorSize.medium:
        return _buildMediumIndicator(context);
      case RefillUrgencyIndicatorSize.large:
        return _buildLargeIndicator(context);
    }
  }

  Widget _buildSmallIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final color = RefillReminderService.getUrgencyColor(urgency);
    final icon = RefillReminderService.getUrgencyIcon(urgency);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              _getUrgencyLabel(urgency),
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediumIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final color = RefillReminderService.getUrgencyColor(urgency);
    final icon = RefillReminderService.getUrgencyIcon(urgency);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 8),
            Text(
              _getUrgencyLabel(urgency),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLargeIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final color = RefillReminderService.getUrgencyColor(urgency);
    final icon = RefillReminderService.getUrgencyIcon(urgency);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: 8),
            Text(
              _getUrgencyLabel(urgency),
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _getUrgencyDescription(urgency),
              style: theme.textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  String _getUrgencyLabel(RefillUrgency urgency) {
    switch (urgency) {
      case RefillUrgency.critical:
        return 'Critical';
      case RefillUrgency.high:
        return 'High';
      case RefillUrgency.medium:
        return 'Medium';
      case RefillUrgency.low:
        return 'Low';
      case RefillUrgency.none:
        return 'Good';
      case RefillUrgency.unknown:
        return 'Unknown';
    }
  }

  String _getUrgencyDescription(RefillUrgency urgency) {
    switch (urgency) {
      case RefillUrgency.critical:
        return 'Refill immediately';
      case RefillUrgency.high:
        return 'Refill within 1-3 days';
      case RefillUrgency.medium:
        return 'Refill within a week';
      case RefillUrgency.low:
        return 'Refill within 2 weeks';
      case RefillUrgency.none:
        return 'No refill needed soon';
      case RefillUrgency.unknown:
        return 'Cannot determine';
    }
  }
}

/// Helper widget for creating urgency badges in lists
class RefillUrgencyBadge extends StatelessWidget {
  final RefillUrgency urgency;
  final int? daysRemaining;

  const RefillUrgencyBadge({
    super.key,
    required this.urgency,
    this.daysRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = RefillReminderService.getUrgencyColor(urgency);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        daysRemaining != null ? '${daysRemaining}d' : _getShortLabel(urgency),
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  String _getShortLabel(RefillUrgency urgency) {
    switch (urgency) {
      case RefillUrgency.critical:
        return 'NOW';
      case RefillUrgency.high:
        return 'HIGH';
      case RefillUrgency.medium:
        return 'MED';
      case RefillUrgency.low:
        return 'LOW';
      case RefillUrgency.none:
        return 'OK';
      case RefillUrgency.unknown:
        return '?';
    }
  }
}

/// Widget for showing refill status in a progress format
class RefillProgressIndicator extends StatelessWidget {
  final int currentPillCount;
  final int? originalPillCount;
  final RefillUrgency urgency;

  const RefillProgressIndicator({
    super.key,
    required this.currentPillCount,
    this.originalPillCount,
    required this.urgency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = RefillReminderService.getUrgencyColor(urgency);

    // Calculate progress based on original count if available
    final progress = originalPillCount != null && originalPillCount! > 0
        ? currentPillCount / originalPillCount!
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pills Remaining',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '$currentPillCount${originalPillCount != null ? ' / $originalPillCount' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}

enum RefillUrgencyIndicatorSize {
  small,
  medium,
  large,
}