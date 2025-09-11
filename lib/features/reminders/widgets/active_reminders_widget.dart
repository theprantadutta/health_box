import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/reminder_scheduler.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/reminder_providers.dart';

/// Widget displaying active reminders with management options
class ActiveRemindersWidget extends ConsumerWidget {
  final bool showHeader;
  final int? maxItems;
  final void Function(Reminder)? onReminderTap;
  final void Function(Reminder)? onEditReminder;
  final void Function()? onViewAll;

  const ActiveRemindersWidget({
    super.key,
    this.showHeader = true,
    this.maxItems,
    this.onReminderTap,
    this.onEditReminder,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRemindersAsync = ref.watch(activeRemindersProvider);

    return activeRemindersAsync.when(
      data: (reminders) => _buildContent(context, ref, reminders),
      loading: () => _buildLoading(),
      error: (error, stack) => _buildError(context, error),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Reminder> reminders) {
    final displayReminders = maxItems != null && reminders.length > maxItems!
        ? reminders.take(maxItems!).toList()
        : reminders;

    if (reminders.isEmpty) {
      return _buildEmptyState(context);
    }

    return Card(
      child: Column(
        children: [
          if (showHeader) _buildHeader(context, reminders.length),
          ...displayReminders.map((reminder) => _buildReminderTile(context, ref, reminder)),
          if (maxItems != null && reminders.length > maxItems! && onViewAll != null)
            _buildViewAllButton(context, reminders.length - maxItems!),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int totalCount) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Active Reminders',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (totalCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                totalCount.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReminderTile(BuildContext context, WidgetRef ref, Reminder reminder) {
    final isOverdue = _isOverdue(reminder);
    final nextOccurrence = _getNextOccurrence(reminder);

    return ListTile(
      leading: _buildReminderIcon(context, reminder, isOverdue),
      title: Text(
        reminder.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reminder.description != null && reminder.description!.isNotEmpty)
            Text(
              reminder.description!,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                _formatNextOccurrence(nextOccurrence, reminder.frequency),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isOverdue ? Colors.red : null,
                  fontWeight: isOverdue ? FontWeight.w600 : null,
                ),
              ),
              const SizedBox(width: 12),
              _buildFrequencyChip(context, reminder.frequency),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIndicator(context, reminder, isOverdue),
          PopupMenuButton<String>(
            onSelected: (action) => _handleAction(context, ref, action, reminder),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'toggle',
                child: ListTile(
                  leading: Icon(Icons.pause),
                  title: Text('Pause'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (onEditReminder != null)
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuItem(
                value: 'snooze',
                child: ListTile(
                  leading: Icon(Icons.snooze),
                  title: Text('Snooze'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: onReminderTap != null ? () => onReminderTap!(reminder) : null,
    );
  }

  Widget _buildReminderIcon(BuildContext context, Reminder reminder, bool isOverdue) {
    IconData iconData;
    Color? color;

    switch (reminder.type) {
      case 'medication':
        iconData = Icons.medical_services;
        break;
      case 'appointment':
        iconData = Icons.event;
        break;
      case 'lab_test':
        iconData = Icons.science;
        break;
      case 'vaccination':
        iconData = Icons.vaccines;
        break;
      default:
        iconData = Icons.notifications;
    }

    if (isOverdue) {
      color = Colors.red;
    } else if (!reminder.isActive) {
      color = Theme.of(context).colorScheme.onSurfaceVariant;
    } else {
      color = Theme.of(context).colorScheme.primary;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  Widget _buildFrequencyChip(BuildContext context, String frequency) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        frequency.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, Reminder reminder, bool isOverdue) {
    if (!reminder.isActive) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.pause,
          size: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (isOverdue) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.warning,
          size: 12,
          color: Colors.white,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        size: 12,
        color: Colors.white,
      ),
    );
  }

  Widget _buildViewAllButton(BuildContext context, int moreCount) {
    return InkWell(
      onTap: onViewAll,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View $moreCount more reminders',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load reminders',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _refresh(context),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Reminders',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a reminder to get started',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action, Reminder reminder) {
    switch (action) {
      case 'toggle':
        _toggleReminder(context, ref, reminder);
        break;
      case 'edit':
        onEditReminder?.call(reminder);
        break;
      case 'snooze':
        _snoozeReminder(context, ref, reminder);
        break;
      case 'delete':
        _deleteReminder(context, ref, reminder);
        break;
    }
  }

  Future<void> _toggleReminder(BuildContext context, WidgetRef ref, Reminder reminder) async {
    try {
      final reminderService = ref.read(reminderServiceProvider);
      await reminderService.toggleReminderActive(reminder.id, !reminder.isActive);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              reminder.isActive ? 'Reminder paused' : 'Reminder activated',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _snoozeReminder(BuildContext context, WidgetRef ref, Reminder reminder) async {
    final minutes = await _showSnoozeDialog(context);
    if (minutes == null) return;

    try {
      final reminderScheduler = ReminderScheduler();
      await reminderScheduler.snoozeReminder(reminder.id, minutes: minutes);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder snoozed for $minutes minutes'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteReminder(BuildContext context, WidgetRef ref, Reminder reminder) async {
    final confirm = await _showDeleteDialog(context, reminder);
    if (!confirm) return;

    try {
      final reminderService = ref.read(reminderServiceProvider);
      await reminderService.deleteReminder(reminder.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder deleted'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<int?> _showSnoozeDialog(BuildContext context) async {
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Snooze Reminder'),
        content: const Text('How long would you like to snooze this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(5),
            child: const Text('5 min'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(15),
            child: const Text('15 min'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(30),
            child: const Text('30 min'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(60),
            child: const Text('1 hour'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context, Reminder reminder) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  void _refresh(BuildContext context) {
    // Refresh the provider
    // This would be implemented based on the actual provider structure
  }

  bool _isOverdue(Reminder reminder) {
    return reminder.scheduledTime.isBefore(DateTime.now()) &&
        (reminder.lastSent == null || reminder.lastSent!.isBefore(reminder.scheduledTime));
  }

  DateTime? _getNextOccurrence(Reminder reminder) {
    return reminder.nextScheduled ?? reminder.scheduledTime;
  }

  String _formatNextOccurrence(DateTime? nextOccurrence, String frequency) {
    if (nextOccurrence == null) return 'No schedule';

    final now = DateTime.now();
    final difference = nextOccurrence.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    }

    if (difference.inDays > 0) {
      return 'In ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Now';
    }
  }
}