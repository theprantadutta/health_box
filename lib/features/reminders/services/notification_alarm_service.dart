import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:alarm/alarm.dart';  // Temporarily disabled

import 'notification_service.dart';
import 'alarm_service.dart';
import '../../../shared/providers/settings_providers.dart';
import '../../../data/database/app_database.dart';

class NotificationAlarmService {
  static final NotificationAlarmService _instance = NotificationAlarmService._internal();
  factory NotificationAlarmService() => _instance;
  NotificationAlarmService._internal();

  final NotificationService _notificationService = NotificationService();
  final AlarmService _alarmService = AlarmService();

  bool _isInitialized = false;
  StreamController<ReminderTriggerEvent>? _triggerStreamController;
  StreamSubscription<AlarmSettings>? _alarmSubscription;

  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      // Initialize notification service first
      final notificationSuccess = await _notificationService.initialize();

      if (!notificationSuccess) {
        debugPrint('Warning: Notification service failed to initialize');
      }

      _triggerStreamController = StreamController<ReminderTriggerEvent>.broadcast();

      // Note: AlarmService is NOT initialized here to prevent foreground service crashes
      // It will be initialized lazily when an alarm is actually needed

      _isInitialized = true;
      debugPrint('NotificationAlarmService initialized successfully (notifications ready, alarms on-demand)');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize NotificationAlarmService: $e');
      return false;
    }
  }

  Stream<ReminderTriggerEvent> get triggerStream {
    if (_triggerStreamController == null) {
      throw const NotificationAlarmServiceException('Service not initialized');
    }
    return _triggerStreamController!.stream;
  }

  Future<void> _ensureAlarmStreamListener() async {
    if (_alarmSubscription != null) return; // Already listening

    try {
      // Subscribe to alarm stream when first needed
      _alarmSubscription = _alarmService.alarmStream.listen((alarmSettings) {
        debugPrint('Alarm triggered for ID: ${alarmSettings.id}');

        // Extract reminder ID from alarm ID
        final reminderId = 'reminder_${alarmSettings.id}';

        _triggerStreamController?.add(ReminderTriggerEvent(
          reminderId: reminderId,
          triggerType: TriggerType.alarm,
          timestamp: DateTime.now(),
          alarmSettings: alarmSettings,
        ));
      });

      debugPrint('Alarm stream listener established');
    } catch (e) {
      debugPrint('Failed to set up alarm stream listener: $e');
    }
  }

  Future<bool> scheduleReminder({
    required Reminder reminder,
    required ReminderType reminderType,
    String? alarmSound,
    double? alarmVolume,
    bool? enableVibration,
  }) async {
    try {
      if (!_isInitialized) {
        // Try to initialize if not already done
        final initialized = await initialize();
        if (!initialized) {
          debugPrint('Failed to initialize notification alarm service, falling back to notifications only');
          return await _scheduleNotification(reminder);
        }
      }

      bool notificationSuccess = true;
      bool alarmSuccess = true;

      switch (reminderType) {
        case ReminderType.notification:
          notificationSuccess = await _scheduleNotification(reminder);
          break;

        case ReminderType.alarm:
          try {
            // Ensure alarm stream listener is set up before scheduling alarms
            await _ensureAlarmStreamListener();

            alarmSuccess = await _scheduleAlarm(
              reminder,
              alarmSound: alarmSound ?? 'gentle',
              alarmVolume: alarmVolume ?? 0.8,
              enableVibration: enableVibration ?? true,
            );
          } catch (e) {
            debugPrint('Alarm scheduling failed, falling back to notification: $e');
            alarmSuccess = false;
            notificationSuccess = await _scheduleNotification(reminder);
          }
          break;

        case ReminderType.both:
          notificationSuccess = await _scheduleNotification(reminder);
          try {
            // Ensure alarm stream listener is set up before scheduling alarms
            await _ensureAlarmStreamListener();

            alarmSuccess = await _scheduleAlarm(
              reminder,
              alarmSound: alarmSound ?? 'gentle',
              alarmVolume: alarmVolume ?? 0.8,
              enableVibration: enableVibration ?? true,
            );
          } catch (e) {
            debugPrint('Alarm scheduling failed: $e');
            alarmSuccess = false;
          }
          break;
      }

      final success = reminderType == ReminderType.notification
          ? notificationSuccess
          : reminderType == ReminderType.alarm
              ? (alarmSuccess || notificationSuccess) // Fallback to notification if alarm fails
              : (notificationSuccess || alarmSuccess);

      if (success) {
        debugPrint('Reminder scheduled successfully: ${reminder.id}');
      } else {
        debugPrint('Failed to schedule reminder: ${reminder.id}');
      }

      return success;
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
      // Don't throw, just return false to prevent crashes
      return false;
    }
  }

  Future<bool> cancelReminder(String reminderId) async {
    try {
      if (!_isInitialized) {
        throw const NotificationAlarmServiceException('Service not initialized');
      }

      bool notificationCancelled = false;
      bool alarmCancelled = false;

      try {
        await _notificationService.cancelNotification(reminderId);
        notificationCancelled = true;
      } catch (e) {
        debugPrint('Error cancelling notification: $e');
      }

      try {
        alarmCancelled = await _alarmService.stopAlarm(reminderId);
      } catch (e) {
        debugPrint('Error stopping alarm: $e');
      }

      final success = notificationCancelled || alarmCancelled;

      if (success) {
        debugPrint('Reminder cancelled successfully: $reminderId');
      } else {
        debugPrint('Warning: No active reminder found to cancel: $reminderId');
      }

      return success;
    } catch (e) {
      debugPrint('Error cancelling reminder: $e');
      throw NotificationAlarmServiceException('Failed to cancel reminder: $e');
    }
  }

  Future<bool> snoozeReminder({
    required String reminderId,
    required String title,
    required String body,
    int? snoozeMinutes,
    ReminderType? reminderType,
    String? alarmSound,
  }) async {
    try {
      if (!_isInitialized) {
        throw const NotificationAlarmServiceException('Service not initialized');
      }

      final actualSnoozeMinutes = snoozeMinutes ?? 15;
      final actualReminderType = reminderType ?? ReminderType.notification;

      await cancelReminder(reminderId);

      final snoozeReminderId = '${reminderId}_snooze_${DateTime.now().millisecondsSinceEpoch}';

      switch (actualReminderType) {
        case ReminderType.notification:
          try {
            await _notificationService.snoozeNotification(
              reminderId: snoozeReminderId,
              title: '$title (Snoozed)',
              body: body,
              minutes: actualSnoozeMinutes,
            );
            return true;
          } catch (e) {
            debugPrint('Error snoozing notification: $e');
            return false;
          }

        case ReminderType.alarm:
          return await _alarmService.snoozeAlarm(
            reminderId: snoozeReminderId,
            title: '$title (Snoozed)',
            body: body,
            snoozeMinutes: actualSnoozeMinutes,
            alarmSound: alarmSound ?? 'gentle',
          );

        case ReminderType.both:
          bool notificationSuccess = true;
          bool alarmSuccess = true;

          try {
            await _notificationService.snoozeNotification(
              reminderId: snoozeReminderId,
              title: '$title (Snoozed)',
              body: body,
              minutes: actualSnoozeMinutes,
            );
          } catch (e) {
            debugPrint('Error snoozing notification: $e');
            notificationSuccess = false;
          }

          try {
            alarmSuccess = await _alarmService.snoozeAlarm(
              reminderId: '${snoozeReminderId}_alarm',
              title: '$title (Snoozed)',
              body: body,
              snoozeMinutes: actualSnoozeMinutes,
              alarmSound: alarmSound ?? 'gentle',
            );
          } catch (e) {
            debugPrint('Error snoozing alarm: $e');
            alarmSuccess = false;
          }

          return notificationSuccess || alarmSuccess;
      }
    } catch (e) {
      debugPrint('Error snoozing reminder: $e');
      throw NotificationAlarmServiceException('Failed to snooze reminder: $e');
    }
  }

  Future<bool> checkPermissions() async {
    try {
      return await _notificationService.areNotificationsEnabled();
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      return await _notificationService.requestPermissions();
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  Future<ReminderStatus> getReminderStatus(String reminderId) async {
    try {
      final hasNotification = await _hasScheduledNotification(reminderId);
      final hasAlarm = await _alarmService.hasAlarm(reminderId);
      final isAlarmRinging = await _alarmService.isAlarmRinging(reminderId);

      return ReminderStatus(
        reminderId: reminderId,
        hasScheduledNotification: hasNotification,
        hasScheduledAlarm: hasAlarm,
        isAlarmRinging: isAlarmRinging,
      );
    } catch (e) {
      debugPrint('Error getting reminder status: $e');
      return ReminderStatus(
        reminderId: reminderId,
        hasScheduledNotification: false,
        hasScheduledAlarm: false,
        isAlarmRinging: false,
      );
    }
  }

  Future<void> cancelAllReminders() async {
    try {
      await _notificationService.cancelAllNotifications();
      await _alarmService.stopAllAlarms();
      debugPrint('All reminders cancelled');
    } catch (e) {
      debugPrint('Error cancelling all reminders: $e');
      throw NotificationAlarmServiceException('Failed to cancel all reminders: $e');
    }
  }

  List<String> getAvailableAlarmSounds() {
    return _alarmService.getAvailableAlarmSounds();
  }

  String getAlarmSoundDisplayName(String soundKey) {
    return _alarmService.getAlarmSoundDisplayName(soundKey);
  }

  Future<bool> _scheduleNotification(Reminder reminder) async {
    try {
      if (reminder.type == 'medication' && reminder.medicationId != null) {
        await _notificationService.scheduleMedicationReminder(
          reminderId: reminder.id,
          medicationName: reminder.title,
          dosage: reminder.description ?? '',
          scheduledTime: reminder.scheduledTime,
          frequency: reminder.frequency,
        );
      } else {
        await _notificationService.scheduleGeneralReminder(
          reminderId: reminder.id,
          title: reminder.title,
          body: reminder.description ?? 'Reminder',
          scheduledTime: reminder.scheduledTime,
          frequency: reminder.frequency,
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      return false;
    }
  }

  Future<bool> _scheduleAlarm(
    Reminder reminder, {
    required String alarmSound,
    required double alarmVolume,
    required bool enableVibration,
  }) async {
    try {
      return await _alarmService.setAlarm(
        reminderId: reminder.id,
        scheduledTime: reminder.scheduledTime,
        title: reminder.title,
        body: reminder.description ?? 'Medication reminder',
        alarmSound: alarmSound,
        volume: alarmVolume,
        vibrate: enableVibration,
      );
    } catch (e) {
      debugPrint('Error scheduling alarm: $e');
      return false;
    }
  }

  Future<bool> _hasScheduledNotification(String reminderId) async {
    try {
      final pendingNotifications = await _notificationService.getPendingNotifications();
      final notificationId = reminderId.hashCode;
      return pendingNotifications.any((notification) => notification.id == notificationId);
    } catch (e) {
      debugPrint('Error checking scheduled notification: $e');
      return false;
    }
  }


  Future<void> dispose() async {
    try {
      await _alarmSubscription?.cancel();
      await _triggerStreamController?.close();
      await _alarmService.dispose();
      _triggerStreamController = null;
      _alarmSubscription = null;
      _isInitialized = false;
      debugPrint('NotificationAlarmService disposed');
    } catch (e) {
      debugPrint('Error disposing NotificationAlarmService: $e');
    }
  }
}

class ReminderTriggerEvent {
  final String reminderId;
  final TriggerType triggerType;
  final DateTime timestamp;
  final AlarmSettings? alarmSettings;

  const ReminderTriggerEvent({
    required this.reminderId,
    required this.triggerType,
    required this.timestamp,
    this.alarmSettings,
  });
}

enum TriggerType {
  notification,
  alarm,
}

class ReminderStatus {
  final String reminderId;
  final bool hasScheduledNotification;
  final bool hasScheduledAlarm;
  final bool isAlarmRinging;

  const ReminderStatus({
    required this.reminderId,
    required this.hasScheduledNotification,
    required this.hasScheduledAlarm,
    required this.isAlarmRinging,
  });

  bool get hasAnyScheduled => hasScheduledNotification || hasScheduledAlarm;
  bool get isActive => hasAnyScheduled || isAlarmRinging;
}

class NotificationAlarmServiceException implements Exception {
  final String message;

  const NotificationAlarmServiceException(this.message);

  @override
  String toString() => 'NotificationAlarmServiceException: $message';
}

final notificationAlarmServiceProvider = Provider<NotificationAlarmService>((ref) {
  return NotificationAlarmService();
});