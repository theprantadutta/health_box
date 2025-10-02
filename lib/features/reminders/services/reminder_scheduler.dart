import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../shared/providers/settings_providers.dart';
import './notification_alarm_service.dart';
import './reminder_service.dart';

/// Service responsible for scheduling and managing reminder notifications
class ReminderScheduler {
  final ReminderService _reminderService;
  final NotificationAlarmService _notificationAlarmService;
  final ProviderContainer? _container;

  ReminderScheduler({
    ReminderService? reminderService,
    NotificationAlarmService? notificationAlarmService,
    ProviderContainer? container,
  }) : _reminderService = reminderService ?? ReminderService(),
       _notificationAlarmService =
           notificationAlarmService ?? NotificationAlarmService(),
       _container = container;

  /// Initialize the reminder scheduler
  Future<bool> initialize() async {
    final bool serviceInitialized = await _notificationAlarmService
        .initialize();

    if (serviceInitialized) {
      // Reschedule all active reminders on app start
      await rescheduleAllActiveReminders();
    }

    return serviceInitialized;
  }

  /// Schedule a notification for a specific reminder
  ///
  /// Optional parameters allow overriding default settings from preferences
  /// This is useful when creating reminders with specific settings (e.g., from medication forms)
  Future<bool> scheduleReminder(
    Reminder reminder, {
    String? reminderType, // 'notification', 'alarm', or 'both'
    String? alarmSound,
    double? volume,
    bool? enableVibration,
  }) async {
    try {
      if (!reminder.isActive) {
        return false;
      }

      // Use provided parameters or fall back to user preferences
      final defaultAlarmSettings = _getAlarmSettings();

      // Convert string reminderType to ReminderType enum
      ReminderType effectiveReminderType;
      if (reminderType != null) {
        switch (reminderType.toLowerCase()) {
          case 'notification':
            effectiveReminderType = ReminderType.notification;
            break;
          case 'alarm':
            effectiveReminderType = ReminderType.alarm;
            break;
          case 'both':
            effectiveReminderType = ReminderType.both;
            break;
          default:
            effectiveReminderType = _getReminderType();
        }
      } else {
        effectiveReminderType = _getReminderType();
      }

      return await _notificationAlarmService.scheduleReminder(
        reminder: reminder,
        reminderType: effectiveReminderType,
        alarmSound: alarmSound ?? defaultAlarmSettings.alarmSound,
        alarmVolume: volume ?? defaultAlarmSettings.alarmVolume,
        enableVibration: enableVibration ?? defaultAlarmSettings.enableVibration,
      );
    } catch (e) {
      throw ReminderSchedulerException(
        'Failed to schedule reminder: ${e.toString()}',
      );
    }
  }

  /// Cancel a scheduled reminder notification
  Future<bool> cancelReminder(String reminderId) async {
    try {
      return await _notificationAlarmService.cancelReminder(reminderId);
    } catch (e) {
      throw ReminderSchedulerException(
        'Failed to cancel reminder: ${e.toString()}',
      );
    }
  }

  /// Snooze a reminder for the specified duration
  Future<bool> snoozeReminder(String reminderId, {int minutes = 15}) async {
    try {
      final reminder = await _reminderService.getReminderById(reminderId);
      if (reminder == null) {
        throw const ReminderSchedulerException('Reminder not found');
      }

      final reminderType = _getReminderType();
      final alarmSettings = _getAlarmSettings();

      final success = await _notificationAlarmService.snoozeReminder(
        reminderId: reminderId,
        title: reminder.title,
        body: reminder.description ?? 'Snoozed reminder',
        snoozeMinutes: minutes,
        reminderType: reminderType,
        alarmSound: alarmSettings.alarmSound,
      );

      if (success) {
        // Update reminder service
        await _reminderService.snoozeReminder(
          reminderId,
          customMinutes: minutes,
        );
      }

      return success;
    } catch (e) {
      throw ReminderSchedulerException(
        'Failed to snooze reminder: ${e.toString()}',
      );
    }
  }

  /// Reschedule all active reminders (useful for app restart)
  Future<void> rescheduleAllActiveReminders() async {
    try {
      final activeReminders = await _reminderService.getActiveReminders();

      // Cancel all existing notifications and alarms first
      await _notificationAlarmService.cancelAllReminders();

      for (final reminder in activeReminders) {
        try {
          await scheduleReminder(reminder);
        } catch (e) {
          // Log individual failures but continue with others
          print('Failed to reschedule reminder ${reminder.id}: $e');
        }
      }
    } catch (e) {
      throw ReminderSchedulerException(
        'Failed to reschedule active reminders: ${e.toString()}',
      );
    }
  }

  /// Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationAlarmService.checkPermissions() ? [] : [];
    } catch (e) {
      throw ReminderSchedulerException(
        'Failed to get pending notifications: ${e.toString()}',
      );
    }
  }

  /// Clear all scheduled notifications
  Future<void> cancelAllReminders() async {
    try {
      await _notificationAlarmService.cancelAllReminders();
    } catch (e) {
      throw ReminderSchedulerException(
        'Failed to cancel all reminders: ${e.toString()}',
      );
    }
  }


  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await _notificationAlarmService.checkPermissions();
  }

  // Helper Methods

  ReminderType _getReminderType() {
    if (_container != null) {
      try {
        return _container.read(reminderTypeProvider);
      } catch (e) {
        print('Error reading reminder type from provider: $e');
      }
    }
    return ReminderType.notification; // Default fallback
  }

  AlarmSettings _getAlarmSettings() {
    if (_container != null) {
      try {
        return AlarmSettings(
          alarmSound: _container.read(alarmSoundProvider),
          alarmVolume: _container.read(alarmVolumeProvider),
          enableVibration: _container.read(enableAlarmVibrationProvider),
        );
      } catch (e) {
        print('Error reading alarm settings from provider: $e');
      }
    }
    return const AlarmSettings(
      alarmSound: 'gentle',
      alarmVolume: 0.8,
      enableVibration: true,
    );
  }

  // Legacy compatibility methods (minimal implementation)

  // ignore: unused_element
  int _generateNotificationId(String reminderId) {
    return reminderId.hashCode.abs() % 2147483647; // Keep within int32 range
  }
}

/// Exception thrown by ReminderScheduler
class ReminderSchedulerException implements Exception {
  final String message;

  const ReminderSchedulerException(this.message);

  @override
  String toString() => 'ReminderSchedulerException: $message';
}

/// Helper class for alarm settings
class AlarmSettings {
  final String alarmSound;
  final double alarmVolume;
  final bool enableVibration;

  const AlarmSettings({
    required this.alarmSound,
    required this.alarmVolume,
    required this.enableVibration,
  });
}
