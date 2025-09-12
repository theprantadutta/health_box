import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/widgets/loading_animation_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/providers/reminder_providers.dart';
import '../../../data/database/app_database.dart';
import '../widgets/reminder_form_widget.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedType = 'all';
  bool _showInactiveReminders = false;

  final List<String> _reminderTypes = [
    'all',
    'medication',
    'appointment', 
    'lab_test',
    'vaccination',
    'general'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reminders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.getPrimaryGradient(isDarkMode),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Reminders',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddReminderDialog(context),
            tooltip: 'Add Reminder',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.schedule),
              text: 'Active',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'History',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Stats',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveRemindersTab(),
          _buildHistoryTab(),
          _buildStatsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
      ),
    );
  }

  Widget _buildActiveRemindersTab() {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(activeRemindersProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Quick Stats Card
            _buildQuickStatsCard(),
            const SizedBox(height: 16),
            
            // Filter Chips
            _buildFilterChips(),
            const SizedBox(height: 16),
            
            // Active Reminders List
            _buildActiveRemindersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    final activeRemindersAsync = ref.watch(activeRemindersProvider);
    
    return ModernCard(
      elevation: CardElevation.medium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Today\'s Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          activeRemindersAsync.when(
            data: (reminders) {
              final todayReminders = reminders.where((r) => 
                r.scheduledTime.day == DateTime.now().day).length;
              final activeCount = reminders.length;
              final overdueCount = reminders.where((r) => 
                r.scheduledTime.isBefore(DateTime.now())).length;

              return Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Active',
                      activeCount.toString(),
                      Icons.schedule,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Today',
                      todayReminders.toString(),
                      Icons.today,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Overdue',
                      overdueCount.toString(),
                      Icons.warning,
                      overdueCount > 0 ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: LoadingAnimationWidget(
                message: 'Loading stats...',
                style: LoadingStyle.dots,
                size: 40,
              ),
            ),
            error: (error, stack) => Text(
              'Error loading stats',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _reminderTypes.map((type) {
          final isSelected = _selectedType == type;
          final displayName = type == 'all' ? 'All' : 
            type.replaceAll('_', ' ').split(' ')
              .map((word) => word[0].toUpperCase() + word.substring(1))
              .join(' ');
              
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedType = type;
                  });
                }
              },
              backgroundColor: isSelected 
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : null,
              selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveRemindersList() {
    final activeRemindersAsync = ref.watch(activeRemindersProvider);
    
    return activeRemindersAsync.when(
      data: (reminders) {
        var filteredReminders = reminders;
        
        // Apply type filter
        if (_selectedType != 'all') {
          filteredReminders = reminders.where((r) => r.type == _selectedType).toList();
        }
        
        // Apply active/inactive filter
        if (!_showInactiveReminders) {
          filteredReminders = filteredReminders.where((r) => r.isActive).toList();
        }

        if (filteredReminders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No reminders found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first reminder',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: filteredReminders.map((reminder) => 
            _buildReminderCard(reminder)).toList(),
        );
      },
      loading: () => const Center(
        child: LoadingAnimationWidget(
          message: 'Loading reminders...',
          style: LoadingStyle.gradient,
        ),
      ),
      error: (error, stack) => ErrorStateWidget(
        title: 'Error Loading Reminders',
        message: 'Unable to load your reminders. Please try again.',
        onRetry: () {
          ref.invalidate(activeRemindersProvider);
        },
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final theme = Theme.of(context);
    final isOverdue = reminder.scheduledTime.isBefore(DateTime.now());
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ModernCard(
        elevation: CardElevation.low,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Type Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getReminderTypeColor(reminder.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getReminderTypeIcon(reminder.type),
                    color: _getReminderTypeColor(reminder.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Title and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isOverdue ? theme.colorScheme.error : null,
                        ),
                      ),
                      if (reminder.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          reminder.description!,
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOverdue 
                        ? theme.colorScheme.error.withValues(alpha: 0.1)
                        : reminder.isActive 
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOverdue 
                        ? 'Overdue'
                        : reminder.isActive 
                            ? 'Active' 
                            : 'Inactive',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isOverdue 
                          ? theme.colorScheme.error
                          : reminder.isActive 
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Schedule Info
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatScheduleTime(reminder),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.repeat,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  reminder.frequency.replaceAll('_', ' '),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            
            // Action Buttons
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _editReminder(reminder),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                TextButton.icon(
                  onPressed: reminder.isActive 
                      ? () => _pauseReminder(reminder)
                      : () => _activateReminder(reminder),
                  icon: Icon(
                    reminder.isActive ? Icons.pause : Icons.play_arrow,
                    size: 16,
                  ),
                  label: Text(reminder.isActive ? 'Pause' : 'Activate'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _deleteReminder(reminder),
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  tooltip: 'Delete Reminder',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return const Center(
      child: Text('Reminder History - Coming Soon'),
    );
  }

  Widget _buildStatsTab() {
    return const Center(
      child: Text('Reminder Statistics - Coming Soon'),
    );
  }

  // Helper Methods
  Color _getReminderTypeColor(String type) {
    switch (type) {
      case 'medication':
        return Colors.blue;
      case 'appointment':
        return Colors.green;
      case 'lab_test':
        return Colors.orange;
      case 'vaccination':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getReminderTypeIcon(String type) {
    switch (type) {
      case 'medication':
        return Icons.medication;
      case 'appointment':
        return Icons.event;
      case 'lab_test':
        return Icons.science;
      case 'vaccination':
        return Icons.vaccines;
      default:
        return Icons.notifications;
    }
  }

  String _formatScheduleTime(Reminder reminder) {
    final now = DateTime.now();
    final scheduledTime = reminder.scheduledTime;
    
    if (scheduledTime.day == now.day) {
      return 'Today at ${TimeOfDay.fromDateTime(scheduledTime).format(context)}';
    } else if (scheduledTime.day == now.day + 1) {
      return 'Tomorrow at ${TimeOfDay.fromDateTime(scheduledTime).format(context)}';
    } else {
      return '${scheduledTime.day}/${scheduledTime.month} at ${TimeOfDay.fromDateTime(scheduledTime).format(context)}';
    }
  }

  // Action Methods
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Reminders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Show Inactive Reminders'),
              value: _showInactiveReminders,
              onChanged: (value) {
                setState(() {
                  _showInactiveReminders = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) => Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: ReminderFormWidget(
                    onCancel: () => Navigator.pop(context),
                    onReminderCreated: (reminderId) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reminder created successfully!'),
                        ),
                      );
                      ref.invalidate(activeRemindersProvider);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editReminder(Reminder reminder) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit reminder functionality coming soon'),
      ),
    );
  }

  void _pauseReminder(Reminder reminder) {
    // TODO: Implement pause functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder paused'),
      ),
    );
  }

  void _activateReminder(Reminder reminder) {
    // TODO: Implement activate functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder activated'),
      ),
    );
  }

  void _deleteReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reminder deleted'),
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}