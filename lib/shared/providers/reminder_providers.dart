import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../features/reminders/services/reminder_service.dart';
import '../../features/reminders/services/notification_service.dart';

// Service providers
final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Basic reminder providers
final allRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final service = ref.read(reminderServiceProvider);
  return service.getAllReminders();
});

final activeRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final service = ref.read(reminderServiceProvider);
  return service.getActiveReminders();
});

final upcomingRemindersProvider = FutureProvider.family<List<Reminder>, Duration?>((ref, within) async {
  final service = ref.read(reminderServiceProvider);
  return service.getUpcomingReminders(within: within);
});

final overdueRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final service = ref.read(reminderServiceProvider);
  return service.getOverdueReminders();
});

final todaysRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final service = ref.read(reminderServiceProvider);
  return service.getTodaysReminders();
});

final reminderByIdProvider = FutureProvider.family<Reminder?, String>((ref, reminderId) async {
  final service = ref.read(reminderServiceProvider);
  return service.getReminderById(reminderId);
});

// Query providers
final medicationRemindersProvider = FutureProvider.family<List<Reminder>, String?>((ref, medicationId) async {
  final service = ref.read(reminderServiceProvider);
  return service.getMedicationReminders(medicationId: medicationId);
});

final remindersByFrequencyProvider = FutureProvider.family<List<Reminder>, String>((ref, frequency) async {
  final service = ref.read(reminderServiceProvider);
  return service.getRemindersByFrequency(frequency);
});

final searchRemindersProvider = FutureProvider.family<List<Reminder>, String>((ref, searchTerm) async {
  final service = ref.read(reminderServiceProvider);
  return service.searchReminders(searchTerm);
});

// Statistics providers
final activeReminderCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(reminderServiceProvider);
  return service.getActiveReminderCount();
});

final overdueReminderCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(reminderServiceProvider);
  return service.getOverdueReminderCount();
});

final reminderCountsByFrequencyProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.read(reminderServiceProvider);
  return service.getReminderCountsByFrequency();
});

final reminderStatisticsProvider = FutureProvider<ReminderStatistics>((ref) async {
  final service = ref.read(reminderServiceProvider);
  return service.getReminderStatistics();
});

// Stream providers for real-time updates
final watchActiveRemindersProvider = StreamProvider<List<Reminder>>((ref) {
  final service = ref.read(reminderServiceProvider);
  return service.watchActiveReminders();
});

final watchUpcomingRemindersProvider = StreamProvider.family<List<Reminder>, Duration?>((ref, within) {
  final service = ref.read(reminderServiceProvider);
  return service.watchUpcomingReminders(within: within);
});

final watchReminderProvider = StreamProvider.family<Reminder?, String>((ref, reminderId) {
  final service = ref.read(reminderServiceProvider);
  return service.watchReminder(reminderId);
});

final watchOverdueReminderCountProvider = StreamProvider<int>((ref) {
  final service = ref.read(reminderServiceProvider);
  return service.watchOverdueReminderCount();
});

// Reminder management state
class ReminderState {
  final List<Reminder> reminders;
  final Reminder? selectedReminder;
  final String currentView; // 'all', 'active', 'upcoming', 'overdue', 'today'
  final bool isLoading;
  final String? error;

  const ReminderState({
    this.reminders = const [],
    this.selectedReminder,
    this.currentView = 'active',
    this.isLoading = false,
    this.error,
  });

  ReminderState copyWith({
    List<Reminder>? reminders,
    Reminder? selectedReminder,
    String? currentView,
    bool? isLoading,
    String? error,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      selectedReminder: selectedReminder ?? this.selectedReminder,
      currentView: currentView ?? this.currentView,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ReminderNotifier extends StateNotifier<ReminderState> {
  ReminderNotifier(this.ref) : super(const ReminderState());
  
  final Ref ref;

  Future<void> loadAllReminders() async {
    state = state.copyWith(isLoading: true, error: null, currentView: 'all');
    
    try {
      final service = ref.read(reminderServiceProvider);
      final reminders = await service.getAllReminders();
      state = state.copyWith(reminders: reminders, isLoading: false);
    } catch (error) {
      state = state.copyWith(error: error.toString(), isLoading: false);
    }
  }

  Future<void> loadActiveReminders() async {
    state = state.copyWith(isLoading: true, error: null, currentView: 'active');
    
    try {
      final service = ref.read(reminderServiceProvider);
      final reminders = await service.getActiveReminders();
      state = state.copyWith(reminders: reminders, isLoading: false);
    } catch (error) {
      state = state.copyWith(error: error.toString(), isLoading: false);
    }
  }

  Future<void> loadUpcomingReminders({Duration? within}) async {
    state = state.copyWith(isLoading: true, error: null, currentView: 'upcoming');
    
    try {
      final service = ref.read(reminderServiceProvider);
      final reminders = await service.getUpcomingReminders(within: within);
      state = state.copyWith(reminders: reminders, isLoading: false);
    } catch (error) {
      state = state.copyWith(error: error.toString(), isLoading: false);
    }
  }

  Future<void> loadOverdueReminders() async {
    state = state.copyWith(isLoading: true, error: null, currentView: 'overdue');
    
    try {
      final service = ref.read(reminderServiceProvider);
      final reminders = await service.getOverdueReminders();
      state = state.copyWith(reminders: reminders, isLoading: false);
    } catch (error) {
      state = state.copyWith(error: error.toString(), isLoading: false);
    }
  }

  Future<void> loadTodaysReminders() async {
    state = state.copyWith(isLoading: true, error: null, currentView: 'today');
    
    try {
      final service = ref.read(reminderServiceProvider);
      final reminders = await service.getTodaysReminders();
      state = state.copyWith(reminders: reminders, isLoading: false);
    } catch (error) {
      state = state.copyWith(error: error.toString(), isLoading: false);
    }
  }

  Future<void> createReminder(CreateReminderRequest request) async {
    try {
      final service = ref.read(reminderServiceProvider);
      await service.createReminder(request);
      
      // Invalidate related providers
      _invalidateReminderProviders();
      
      // Reload current view
      await _reloadCurrentView();
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> updateReminder(String reminderId, UpdateReminderRequest request) async {
    try {
      final service = ref.read(reminderServiceProvider);
      await service.updateReminder(reminderId, request);
      
      // Invalidate related providers
      _invalidateReminderProviders();
      
      // Reload current view
      await _reloadCurrentView();
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      final service = ref.read(reminderServiceProvider);
      await service.deleteReminder(reminderId);
      
      // Clear selected reminder if it was deleted
      if (state.selectedReminder?.id == reminderId) {
        state = state.copyWith(selectedReminder: null);
      }
      
      // Invalidate related providers
      _invalidateReminderProviders();
      
      // Reload current view
      await _reloadCurrentView();
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> markReminderSent(String reminderId, {DateTime? sentTime}) async {
    try {
      final service = ref.read(reminderServiceProvider);
      await service.markReminderSent(reminderId, sentTime: sentTime);
      
      // Invalidate related providers
      _invalidateReminderProviders();
      
      // Reload current view
      await _reloadCurrentView();
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> snoozeReminder(String reminderId, {int? customMinutes}) async {
    try {
      final service = ref.read(reminderServiceProvider);
      await service.snoozeReminder(reminderId, customMinutes: customMinutes);
      
      // Invalidate related providers
      _invalidateReminderProviders();
      
      // Reload current view
      await _reloadCurrentView();
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> toggleReminderActive(String reminderId, bool isActive) async {
    try {
      final service = ref.read(reminderServiceProvider);
      await service.toggleReminderActive(reminderId, isActive);
      
      // Invalidate related providers
      _invalidateReminderProviders();
      
      // Reload current view
      await _reloadCurrentView();
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  void selectReminder(Reminder? reminder) {
    state = state.copyWith(selectedReminder: reminder);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void _invalidateReminderProviders() {
    ref.invalidate(allRemindersProvider);
    ref.invalidate(activeRemindersProvider);
    ref.invalidate(upcomingRemindersProvider);
    ref.invalidate(overdueRemindersProvider);
    ref.invalidate(todaysRemindersProvider);
    ref.invalidate(activeReminderCountProvider);
    ref.invalidate(overdueReminderCountProvider);
    ref.invalidate(reminderStatisticsProvider);
    ref.invalidate(reminderCountsByFrequencyProvider);
  }

  Future<void> _reloadCurrentView() async {
    switch (state.currentView) {
      case 'all':
        await loadAllReminders();
        break;
      case 'active':
        await loadActiveReminders();
        break;
      case 'upcoming':
        await loadUpcomingReminders();
        break;
      case 'overdue':
        await loadOverdueReminders();
        break;
      case 'today':
        await loadTodaysReminders();
        break;
      default:
        await loadActiveReminders();
        break;
    }
  }
}

final reminderNotifierProvider = StateNotifierProvider<ReminderNotifier, ReminderState>((ref) {
  return ReminderNotifier(ref);
});

// Notification management state
class NotificationState {
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(this.ref) : super(const NotificationState());
  
  final Ref ref;

  Future<void> scheduleNotification(String reminderId, String title, String body, DateTime scheduledTime) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final service = ref.read(notificationServiceProvider);
      await service.scheduleNotification(reminderId, title, body, scheduledTime);
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(error: error.toString(), isLoading: false);
    }
  }

  Future<void> scheduleRepeatingNotification(
    String reminderId,
    String title,
    String body,
    DateTime scheduledTime,
    String frequency,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final service = ref.read(notificationServiceProvider);
      await service.scheduleRepeatingNotification(reminderId, title, body, scheduledTime, frequency);
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(error: error.toString(), isLoading: false);
    }
  }

  Future<void> cancelNotification(String reminderId) async {
    try {
      final service = ref.read(notificationServiceProvider);
      await service.cancelNotification(reminderId);
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> cancelAllNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final service = ref.read(notificationServiceProvider);
      await service.cancelAllNotifications();
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(error: error.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref);
});

// Utility providers
final reminderExistsProvider = FutureProvider.family<bool, String>((ref, reminderId) async {
  final service = ref.read(reminderServiceProvider);
  return service.reminderExists(reminderId);
});

final isReminderOverdueProvider = Provider.family<bool, Reminder>((ref, reminder) {
  final service = ref.read(reminderServiceProvider);
  return service.isOverdue(reminder);
});

final isReminderUpcomingProvider = Provider.family<bool, Map<String, dynamic>>((ref, params) {
  final reminder = params['reminder'] as Reminder;
  final within = params['within'] as Duration? ?? const Duration(hours: 24);
  final service = ref.read(reminderServiceProvider);
  return service.isUpcoming(reminder, within: within);
});

final getValidFrequenciesProvider = Provider<List<String>>((ref) {
  final service = ref.read(reminderServiceProvider);
  return service.getValidFrequencies();
});