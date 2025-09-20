import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/widgets/loading_animation_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/animations/common_transitions.dart';
import '../../../shared/animations/stagger_animations.dart';
import '../../../shared/animations/micro_interactions.dart';
import '../../../shared/providers/reminder_providers.dart';
import '../../../data/database/app_database.dart';
import '../widgets/reminder_form_widget.dart';
import '../services/reminder_service.dart';

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
    'general',
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Reminders',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
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
            Tab(icon: Icon(Icons.schedule), text: 'Active'),
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.analytics), text: 'Stats'),
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
        tooltip: 'Add New Reminder',
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Add Reminder',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
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

    return CommonTransitions.fadeSlideIn(
      child: ModernCard(
        elevation: CardElevation.medium,
        enableHoverEffect: true,
        hoverElevation: CardElevation.high,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Today\'s Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            activeRemindersAsync.when(
              data: (reminders) {
                final todayReminders = reminders
                    .where((r) => r.scheduledTime.day == DateTime.now().day)
                    .length;
                final activeCount = reminders.length;
                final overdueCount = reminders
                    .where((r) => r.scheduledTime.isBefore(DateTime.now()))
                    .length;

                return StaggerAnimations.staggeredGrid(
                  children: [
                    _buildStatItem(
                      'Active',
                      activeCount.toString(),
                      Icons.schedule_rounded,
                      AppTheme.primaryColorLight,
                    ),
                    _buildStatItem(
                      'Today',
                      todayReminders.toString(),
                      Icons.today_rounded,
                      AppTheme.successColor,
                    ),
                    _buildStatItem(
                      'Overdue',
                      overdueCount.toString(),
                      Icons.warning_rounded,
                      overdueCount > 0
                          ? AppTheme.errorColor
                          : AppTheme.neutralColorLight,
                    ),
                  ],
                  crossAxisCount: 3,
                  staggerDelay: AppTheme.microDuration,
                  animationType: StaggerAnimationType.fadeSlide,
                );
              },
              loading: () => Center(
                child: MicroInteractions.breathingDots(
                  color: Theme.of(context).colorScheme.primary,
                  dotCount: 3,
                  dotSize: 10.0,
                ),
              ),
              error: (error, stack) => Text(
                'Error loading stats',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return MicroInteractions.heartbeat(
      intensity: 0.03,
      duration: const Duration(milliseconds: 2000),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return CommonTransitions.fadeSlideIn(
      direction: const Offset(-30, 0),
      child: Container(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _reminderTypes.length,
          itemBuilder: (context, index) {
            final type = _reminderTypes[index];
            final isSelected = _selectedType == type;
            final displayName = type == 'all'
                ? 'All'
                : type
                      .replaceAll('_', ' ')
                      .split(' ')
                      .map((word) => word[0].toUpperCase() + word.substring(1))
                      .join(' ');

            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
                right: index == _reminderTypes.length - 1 ? 0 : 8,
              ),
              child: MicroInteractions.bounceTap(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  child: AnimatedContainer(
                    duration: AppTheme.microDuration,
                    curve: AppTheme.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                _getReminderTypeColor(type),
                                _getReminderTypeColor(
                                  type,
                                ).withValues(alpha: 0.8),
                              ],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? _getReminderTypeColor(type).withValues(alpha: 0.6)
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _getReminderTypeColor(
                                  type,
                                ).withValues(alpha: 0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
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
          filteredReminders = reminders
              .where((r) => r.type == _selectedType)
              .toList();
        }

        // Apply active/inactive filter
        if (!_showInactiveReminders) {
          filteredReminders = filteredReminders
              .where((r) => r.isActive)
              .toList();
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first reminder',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return StaggerAnimations.staggeredList(
          children: filteredReminders
              .map((reminder) => _buildReminderCard(reminder))
              .toList(),
          staggerDelay: AppTheme.microDuration,
          direction: StaggerDirection.bottomToTop,
          animationType: StaggerAnimationType.fadeSlide,
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
    final reminderColor = _getReminderTypeColor(reminder.type);
    final medicalTheme = _getMedicalThemeForReminderType(reminder.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Hero(
        tag: 'reminder_${reminder.id}',
        child: CommonTransitions.fadeSlideIn(
          child: ModernCard(
            medicalTheme: medicalTheme,
            elevation: CardElevation.low,
            enableHoverEffect: true,
            hoverElevation: CardElevation.medium,
            enablePressEffect: true,
            borderRadius: BorderRadius.circular(16),
            border: isOverdue
                ? Border.all(color: AppTheme.errorColor, width: 2)
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Type Icon with heartbeat animation
                    MicroInteractions.heartbeat(
                      intensity: isOverdue ? 0.1 : 0.03,
                      duration: Duration(milliseconds: isOverdue ? 1000 : 2000),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              reminderColor,
                              reminderColor.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: reminderColor.withValues(alpha: 0.4),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          _getReminderTypeIcon(reminder.type),
                          color: Colors.white,
                          size: 20,
                        ),
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

                    // Enhanced Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? AppTheme.errorColor
                            : reminder.isActive
                            ? AppTheme.successColor
                            : AppTheme.neutralColorLight,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isOverdue
                                        ? AppTheme.errorColor
                                        : reminder.isActive
                                        ? AppTheme.successColor
                                        : AppTheme.neutralColorLight)
                                    .withValues(alpha: 0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOverdue
                                ? Icons.warning_rounded
                                : reminder.isActive
                                ? Icons.check_circle_rounded
                                : Icons.pause_circle_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOverdue
                                ? 'Overdue'
                                : reminder.isActive
                                ? 'Active'
                                : 'Inactive',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

                // Enhanced Action Buttons
                const SizedBox(height: 16),
                Row(
                  children: [
                    MicroInteractions.bounceTap(
                      child: HealthButton(
                        onPressed: () => _editReminder(reminder),
                        medicalTheme: MedicalButtonTheme.neutral,
                        size: HealthButtonSize.small,
                        enableHaptics: true,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Edit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    MicroInteractions.bounceTap(
                      child: HealthButton(
                        onPressed: reminder.isActive
                            ? () => _pauseReminder(reminder)
                            : () => _activateReminder(reminder),
                        medicalTheme: reminder.isActive
                            ? MedicalButtonTheme.warning
                            : MedicalButtonTheme.success,
                        size: HealthButtonSize.small,
                        enableHaptics: true,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              reminder.isActive
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              reminder.isActive ? 'Pause' : 'Activate',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    MicroInteractions.bounceTap(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.errorColor.withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => _deleteReminder(reminder),
                          borderRadius: BorderRadius.circular(8),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Reminder History',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View your past reminder events and completion history',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('History feature coming in next update'),
                ),
              );
            },
            child: const Text('Enable History Tracking'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Reminder Statistics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your medication adherence and reminder patterns',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Statistics feature coming in next update'),
                ),
              );
            },
            child: const Text('View Analytics'),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Color _getReminderTypeColor(String type) {
    switch (type) {
      case 'medication':
        return AppTheme.primaryColorLight;
      case 'appointment':
        return AppTheme.successColor;
      case 'lab_test':
        return AppTheme.warningColor;
      case 'vaccination':
        return AppTheme.successColor;
      case 'general':
        return AppTheme.primaryColorLight;
      default:
        return AppTheme.neutralColorLight;
    }
  }

  MedicalCardTheme _getMedicalThemeForReminderType(String type) {
    switch (type) {
      case 'medication':
        return MedicalCardTheme.primary;
      case 'appointment':
        return MedicalCardTheme.success;
      case 'lab_test':
        return MedicalCardTheme.warning;
      case 'vaccination':
        return MedicalCardTheme.success;
      case 'general':
        return MedicalCardTheme.primary;
      default:
        return MedicalCardTheme.neutral;
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
                context.pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.4)
                      : Colors.grey.withValues(alpha: 0.3),
                  offset: const Offset(0, -4),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                // Enhanced Header Section
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    children: [
                      // Drag Handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Header with Icon and Title
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add_alert_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add New Reminder',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Set up your health reminder',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Close Button
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                                  : theme.colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => context.pop(),
                              icon: Icon(
                                Icons.close_rounded,
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // Enhanced Form Content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: ReminderFormWidget(
                        onCancel: () => context.pop(),
                        onReminderCreated: (reminderId) {
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Reminder created successfully!'),
                                ],
                              ),
                              backgroundColor: theme.colorScheme.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          ref.invalidate(activeRemindersProvider);
                        },
                      ),
                    ),
                  ),
                ),
                // Bottom Padding for better spacing
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Reminder',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ReminderFormWidget(
                  reminder: reminder,
                  onReminderUpdated: () {
                    context.pop();
                    ref.invalidate(allRemindersProvider);
                    ref.invalidate(activeRemindersProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reminder updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  onCancel: () => context.pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pauseReminder(Reminder reminder) async {
    try {
      final service = ref.read(reminderServiceProvider);
      final request = UpdateReminderRequest(isActive: false);

      await service.updateReminder(reminder.id, request);

      // Refresh the providers
      ref.invalidate(allRemindersProvider);
      ref.invalidate(activeRemindersProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder "${reminder.title}" paused'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pause reminder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _activateReminder(Reminder reminder) async {
    try {
      final service = ref.read(reminderServiceProvider);
      final request = UpdateReminderRequest(isActive: true);

      await service.updateReminder(reminder.id, request);

      // Refresh the providers
      ref.invalidate(allRemindersProvider);
      ref.invalidate(activeRemindersProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder "${reminder.title}" activated'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to activate reminder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              try {
                final service = ref.read(reminderServiceProvider);
                await service.deleteReminder(reminder.id);

                // Refresh the providers
                ref.invalidate(allRemindersProvider);
                ref.invalidate(activeRemindersProvider);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reminder "${reminder.title}" deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete reminder: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
