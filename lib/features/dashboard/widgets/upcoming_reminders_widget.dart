import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/reminder_providers.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/modern_card.dart';

class UpcomingRemindersWidget extends ConsumerWidget {
  const UpcomingRemindersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final upcomingRemindersAsync = ref.watch(
      upcomingRemindersProvider(const Duration(days: 7)),
    );

    return ModernCard(
      elevation: CardElevation.low,
      enableHoverEffect: true,
      hoverElevation: CardElevation.medium,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: HealthBoxDesignSystem.chronicConditionGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: HealthBoxDesignSystem.coloredShadow(
                    HealthBoxDesignSystem.chronicConditionGradient.colors.first,
                    opacity: 0.3,
                  ),
                ),
                child: const Icon(Icons.upcoming, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Upcoming Reminders',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'All reminders view - Coming in Phase 3.9',
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('View All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          upcomingRemindersAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => _buildErrorState(context, error),
            data: (reminders) => _buildRemindersList(context, reminders),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
          const SizedBox(height: 8),
          Text('Error loading reminders', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            error.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList(BuildContext context, List<Reminder> reminders) {
    final theme = Theme.of(context);

    if (reminders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: theme.colorScheme.primary,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text('No upcoming reminders', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'You\'re all caught up for the next 7 days!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add reminder form - Coming in Phase 3.9'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Reminder'),
            ),
          ],
        ),
      );
    }

    // Show maximum 3 upcoming reminders
    final displayReminders = reminders.take(3).toList();

    return Column(
      children: [
        ...displayReminders.map(
          (reminder) => _buildReminderItem(context, reminder),
        ),
        if (reminders.length > 3) ...[
          const SizedBox(height: 8),
          Text(
            '${reminders.length - 3} more reminders',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReminderItem(BuildContext context, Reminder reminder) {
    final theme = Theme.of(context);
    final scheduledTime = reminder.scheduledTime;
    final now = DateTime.now();
    final isOverdue = scheduledTime.isBefore(now);
    final isToday =
        scheduledTime.year == now.year &&
        scheduledTime.month == now.month &&
        scheduledTime.day == now.day;

    // Get gradient based on status
    final statusGradient = isOverdue
        ? HealthBoxDesignSystem.errorGradient
        : isToday
        ? HealthBoxDesignSystem.medicalBlue
        : HealthBoxDesignSystem.medicalPurple;

    return ModernCard(
      elevation: CardElevation.low,
      enableHoverEffect: true,
      hoverElevation: CardElevation.medium,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      gradientBorder: true,
      gradient: statusGradient,
      child: Row(
        children: [
          // Status Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: statusGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: HealthBoxDesignSystem.coloredShadow(
                statusGradient.colors.first,
                opacity: 0.3,
              ),
            ),
            child: Icon(
              _getReminderIcon(reminder.type),
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // Reminder Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatReminderTime(scheduledTime),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOverdue
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (reminder.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    reminder.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Status Badge
          if (isOverdue)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: HealthBoxDesignSystem.errorGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: HealthBoxDesignSystem.coloredShadow(
                  HealthBoxDesignSystem.errorGradient.colors.first,
                  opacity: 0.4,
                ),
              ),
              child: Text(
                'OVERDUE',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: HealthBoxDesignSystem.medicalBlue,
                borderRadius: BorderRadius.circular(10),
                boxShadow: HealthBoxDesignSystem.coloredShadow(
                  HealthBoxDesignSystem.medicalBlue.colors.first,
                  opacity: 0.4,
                ),
              ),
              child: Text(
                'TODAY',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getReminderIcon(String reminderType) {
    switch (reminderType.toLowerCase()) {
      case 'medication':
        return Icons.medication;
      case 'appointment':
        return Icons.calendar_today;
      case 'prescription':
        return Icons.receipt;
      case 'exercise':
        return Icons.fitness_center;
      case 'vitals':
        return Icons.monitor_heart;
      default:
        return Icons.notifications;
    }
  }

  String _formatReminderTime(DateTime scheduledTime) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);

    if (scheduledTime.isBefore(now)) {
      // Overdue
      if (difference.inDays.abs() > 0) {
        return '${difference.inDays.abs()} days overdue';
      } else if (difference.inHours.abs() > 0) {
        return '${difference.inHours.abs()} hours overdue';
      } else {
        return '${difference.inMinutes.abs()} minutes overdue';
      }
    } else {
      // Upcoming
      if (difference.inDays > 0) {
        return 'In ${difference.inDays} days';
      } else if (difference.inHours > 0) {
        return 'In ${difference.inHours} hours';
      } else if (difference.inMinutes > 0) {
        return 'In ${difference.inMinutes} minutes';
      } else {
        return 'Now';
      }
    }
  }
}
