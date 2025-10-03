import 'package:flutter/material.dart';

import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/modern_card.dart';
import '../services/refill_reminder_service.dart';
import './refill_urgency_indicator_widget.dart';

/// Widget displaying medication refill information in a card format
class RefillInfoCardWidget extends StatelessWidget {
  final MedicationRefillInfo refillInfo;
  final VoidCallback? onRefillTapped;
  final VoidCallback? onViewMedication;
  final VoidCallback? onUpdatePillCount;

  const RefillInfoCardWidget({
    super.key,
    required this.refillInfo,
    this.onRefillTapped,
    this.onViewMedication,
    this.onUpdatePillCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get gradient based on urgency
    final urgencyGradient = refillInfo.urgency == RefillUrgency.critical
        ? HealthBoxDesignSystem.errorGradient
        : refillInfo.urgency == RefillUrgency.high
            ? HealthBoxDesignSystem.warningGradient
            : HealthBoxDesignSystem.medicationGradient;

    return ModernCard(
      elevation: refillInfo.urgency == RefillUrgency.critical
          ? CardElevation.medium
          : CardElevation.low,
      gradientBorder: refillInfo.urgency == RefillUrgency.critical,
      gradient: refillInfo.urgency == RefillUrgency.critical ? urgencyGradient : null,
      onTap: onViewMedication,
      enableHoverEffect: true,
      hoverElevation: CardElevation.medium,
      enablePressEffect: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, urgencyGradient),
          const SizedBox(height: 12),
          _buildMedicationInfo(theme),
          const SizedBox(height: 12),
          _buildRefillInfo(theme, urgencyGradient),
          const SizedBox(height: 16),
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, LinearGradient urgencyGradient) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: urgencyGradient,
            borderRadius: BorderRadius.circular(8),
            boxShadow: HealthBoxDesignSystem.coloredShadow(
              urgencyGradient.colors.first,
              opacity: 0.3,
            ),
          ),
          child: const Icon(Icons.medication, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            refillInfo.medicationName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        RefillUrgencyIndicatorWidget(
          urgency: refillInfo.urgency,
          size: RefillUrgencyIndicatorSize.small,
        ),
      ],
    );
  }

  Widget _buildMedicationInfo(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoItem(
            icon: Icons.medication,
            label: 'Dosage',
            value: refillInfo.dosage,
            theme: theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoItem(
            icon: Icons.schedule,
            label: 'Frequency',
            value: refillInfo.frequency,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildRefillInfo(ThemeData theme, LinearGradient urgencyGradient) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            urgencyGradient.colors.first.withValues(alpha: 0.1),
            urgencyGradient.colors.last.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: urgencyGradient.colors.first.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildRefillInfoItem(
                  'Current Pills',
                  '${refillInfo.currentPillCount}',
                  Icons.inventory,
                  theme,
                ),
              ),
              if (refillInfo.daysRemaining != null)
                Expanded(
                  child: _buildRefillInfoItem(
                    'Days Left',
                    _formatDaysRemaining(refillInfo.daysRemaining!),
                    Icons.timelapse,
                    theme,
                    color: _getDaysRemainingColor(refillInfo.daysRemaining!),
                  ),
                ),
            ],
          ),
          if (refillInfo.runOutDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.event,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Expected to run out: ${_formatDate(refillInfo.runOutDate!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          if (refillInfo.refillReminderDate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.notifications,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Reminder set for: ${_formatDate(refillInfo.refillReminderDate!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        if (refillInfo.needsRefill)
          FilledButton.icon(
            onPressed: onRefillTapped,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Record Refill'),
          )
        else
          OutlinedButton.icon(
            onPressed: onRefillTapped,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Refill'),
          ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onUpdatePillCount,
          icon: const Icon(Icons.edit),
          tooltip: 'Update pill count',
        ),
        IconButton(
          onPressed: onViewMedication,
          icon: const Icon(Icons.visibility),
          tooltip: 'View medication details',
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRefillInfoItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDaysRemaining(int days) {
    if (days <= 0) return 'Out now';
    if (days == 1) return '1 day';
    return '$days days';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);

    if (targetDay == today) {
      return 'Today';
    } else if (targetDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (targetDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getDaysRemainingColor(int days) {
    if (days <= 0) return const Color(0xFFD32F2F); // Red
    if (days <= 3) return const Color(0xFFF57C00); // Orange
    if (days <= 7) return const Color(0xFFFBC02D); // Yellow
    return const Color(0xFF388E3C); // Green
  }
}