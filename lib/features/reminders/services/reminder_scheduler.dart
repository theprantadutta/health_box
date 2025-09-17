import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../data/database/app_database.dart';
import './notification_config.dart';
import './reminder_service.dart';

/// Service responsible for scheduling and managing reminder notifications
class ReminderScheduler {
  final ReminderService _reminderService;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  ReminderScheduler({
    ReminderService? reminderService,
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _reminderService = reminderService ?? ReminderService(),
       _notificationsPlugin =
           notificationsPlugin ?? NotificationConfig.instance;

  /// Initialize the reminder scheduler
  Future<bool> initialize() async {
    final bool notificationsInitialized = await NotificationConfig.initialize();

    if (notificationsInitialized) {
      await NotificationConfig.setupCategories();
      _initializeNotificationHandling();
      // Reschedule all active reminders on app start
      await rescheduleAllActiveReminders();
    }

    return notificationsInitialized;
  }

  /// Schedule a notification for a specific reminder
  Future<bool> scheduleReminder(Reminder reminder) async {
    try {
      if (!reminder.isActive) {
        return false;
      }

      final bool permissionGranted =
          await NotificationConfig.areNotificationsEnabled();
      if (!permissionGranted) {
        throw const ReminderSchedulerException(
          'Notification permissions not granted',
        );
      }

      // Cancel any existing notification for this reminder
      await cancelReminder(reminder.id);

      // Schedule based on frequency
      switch (reminder.frequency) {
        case 'once':
          return await _scheduleOneTimeReminder(reminder);
        case 'daily':
          return await _scheduleDailyReminder(reminder);
        case 'weekly':
          return await _scheduleWeeklyReminder(reminder);
        case 'monthly':
          return await _scheduleMonthlyReminder(reminder);
        default:
          throw ReminderSchedulerException(
            'Unsupported frequency: ${reminder.frequency}',
          );
      }
    } catch (e) {
      throw ReminderSchedulerException(
        'Failed to schedule reminder: ${e.toString()}',
      );
    }
  }

  /// Cancel a scheduled reminder notification
  Future<bool> cancelReminder(String reminderId) async {
    try {
      final int notificationId = _generateNotificationId(reminderId);
      await _notificationsPlugin.cancel(notificationId);
      return true;
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

      // Cancel current notification
      await cancelReminder(reminderId);

      // Schedule new notification for snooze duration
      final snoozeTime = DateTime.now().add(Duration(minutes: minutes));
      final notificationId = _generateNotificationId(reminderId);

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        reminder.title,
        reminder.description ?? 'Snoozed reminder',
        tz.TZDateTime.from(snoozeTime, tz.local),
        NotificationConfig.platformChannelSpecifics,
        payload: _createNotificationPayload(reminder, isSnooze: true),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      // Update reminder service
      await _reminderService.snoozeReminder(reminderId, customMinutes: minutes);

      return true;
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

      // Cancel all existing notifications first
      await _notificationsPlugin.cancelAll();

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
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      throw ReminderSchedulerException(
        'Failed to get pending notifications: ${e.toString()}',
      );
    }
  }

  /// Clear all scheduled notifications
  Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      throw ReminderSchedulerException(
        'Failed to cancel all reminders: ${e.toString()}',
      );
    }
  }

  /// Initialize notification response listening
  void _initializeNotificationHandling() {
    NotificationConfig.notificationStream.listen((
      NotificationResponse response,
    ) {
      _handleNotificationResponse(response);
    });
  }

  /// Handle notification responses
  Future<void> _handleNotificationResponse(
    NotificationResponse response,
  ) async {
    try {
      final payload = response.payload;
      if (payload != null) {
        final payloadData = jsonDecode(payload);
        final reminderId = payloadData['reminderId'] as String?;
        final actionId = response.actionId;

        if (reminderId != null) {
          if (actionId != null) {
            // Handle action button taps
            await _handleNotificationAction(actionId, reminderId);
          } else {
            // Handle notification tap (no action button)
            await _handleNotificationTap(reminderId);
          }
        }
      }
    } catch (e) {
      print('Error handling notification response: $e');
    }
  }

  /// Handle notification action responses
  Future<void> _handleNotificationAction(
    String action,
    String reminderId,
  ) async {
    try {
      switch (action) {
        case 'take_medication':
          await _handleTakeMedication(reminderId);
          break;
        case 'skip_medication':
          await _handleSkipMedication(reminderId);
          break;
        case 'snooze_medication':
          await snoozeReminder(reminderId, minutes: 15);
          break;
        default:
          print('Unknown notification action: $action');
      }
    } catch (e) {
      throw ReminderSchedulerException(
        'Failed to handle notification action: ${e.toString()}',
      );
    }
  }

  /// Handle notification tap (when no action button is used)
  Future<void> _handleNotificationTap(String reminderId) async {
    // This could open the app to the reminder details screen
    print('Notification tapped for reminder: $reminderId');
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await NotificationConfig.areNotificationsEnabled();
  }

  // Private Methods

  Future<bool> _scheduleOneTimeReminder(Reminder reminder) async {
    if (reminder.nextScheduled == null ||
        reminder.nextScheduled!.isBefore(DateTime.now())) {
      return false; // Don't schedule past reminders
    }

    final notificationId = _generateNotificationId(reminder.id);

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      reminder.title,
      reminder.description ?? 'Time for your reminder',
      tz.TZDateTime.from(reminder.nextScheduled!, tz.local),
      _getNotificationDetails(reminder),
      payload: _createNotificationPayload(reminder),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    return true;
  }

  Future<bool> _scheduleDailyReminder(Reminder reminder) async {
    final now = DateTime.now();
    DateTime scheduledTime = reminder.scheduledTime;

    // If today's time has passed, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = _getNextDailyOccurrence(scheduledTime);
    }

    final notificationId = _generateNotificationId(reminder.id);

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      reminder.title,
      reminder.description ?? 'Time for your daily reminder',
      tz.TZDateTime.from(scheduledTime, tz.local),
      _getNotificationDetails(reminder),
      payload: _createNotificationPayload(reminder),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );

    return true;
  }

  Future<bool> _scheduleWeeklyReminder(Reminder reminder) async {
    final now = DateTime.now();
    DateTime scheduledTime = reminder.scheduledTime;

    // If this week's time has passed, schedule for next week
    if (scheduledTime.isBefore(now)) {
      scheduledTime = _getNextWeeklyOccurrence(scheduledTime);
    }

    final notificationId = _generateNotificationId(reminder.id);

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      reminder.title,
      reminder.description ?? 'Time for your weekly reminder',
      tz.TZDateTime.from(scheduledTime, tz.local),
      _getNotificationDetails(reminder),
      payload: _createNotificationPayload(reminder),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime, // Repeat weekly
    );

    return true;
  }

  Future<bool> _scheduleMonthlyReminder(Reminder reminder) async {
    final now = DateTime.now();
    DateTime scheduledTime = reminder.scheduledTime;

    // If this month's time has passed, schedule for next month
    if (scheduledTime.isBefore(now)) {
      scheduledTime = _getNextMonthlyOccurrence(scheduledTime);
    }

    final notificationId = _generateNotificationId(reminder.id);

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      reminder.title,
      reminder.description ?? 'Time for your monthly reminder',
      tz.TZDateTime.from(scheduledTime, tz.local),
      _getNotificationDetails(reminder),
      payload: _createNotificationPayload(reminder),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.dayOfMonthAndTime, // Repeat monthly
    );

    return true;
  }

  DateTime _getNextDailyOccurrence(DateTime scheduledTime) {
    final now = DateTime.now();
    DateTime nextTime = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (nextTime.isBefore(now)) {
      nextTime = nextTime.add(const Duration(days: 1));
    }

    return nextTime;
  }

  DateTime _getNextWeeklyOccurrence(DateTime scheduledTime) {
    final now = DateTime.now();
    int daysToAdd = (scheduledTime.weekday - now.weekday + 7) % 7;

    DateTime nextTime = DateTime(
      now.year,
      now.month,
      now.day + daysToAdd,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (nextTime.isBefore(now)) {
      nextTime = nextTime.add(const Duration(days: 7));
    }

    return nextTime;
  }

  DateTime _getNextMonthlyOccurrence(DateTime scheduledTime) {
    final now = DateTime.now();
    DateTime nextTime = DateTime(
      now.year,
      now.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (nextTime.isBefore(now)) {
      nextTime = DateTime(
        now.month == 12 ? now.year + 1 : now.year,
        now.month == 12 ? 1 : now.month + 1,
        scheduledTime.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );
    }

    return nextTime;
  }

  NotificationDetails _getNotificationDetails(Reminder reminder) {
    final androidDetails = reminder.type == 'medication'
        ? AndroidNotificationDetails(
            NotificationConfig.androidNotificationDetails.channelId,
            NotificationConfig.androidNotificationDetails.channelName,
            channelDescription: NotificationConfig
                .androidNotificationDetails
                .channelDescription,
            importance:
                NotificationConfig.androidNotificationDetails.importance,
            priority: NotificationConfig.androidNotificationDetails.priority,
            actions: NotificationConfig.medicationActions,
          )
        : NotificationConfig.androidNotificationDetails;

    return NotificationDetails(
      android: androidDetails,
      iOS: NotificationConfig.darwinNotificationDetails,
      macOS: NotificationConfig.darwinNotificationDetails,
    );
  }

  String _createNotificationPayload(
    Reminder reminder, {
    bool isSnooze = false,
  }) {
    return jsonEncode({
      'reminderId': reminder.id,
      'type': reminder.type,
      'medicationId': reminder.medicationId,
      'isSnooze': isSnooze,
      'scheduledTime': reminder.scheduledTime.toIso8601String(),
    });
  }

  int _generateNotificationId(String reminderId) {
    return reminderId.hashCode.abs() % 2147483647; // Keep within int32 range
  }

  Future<void> _handleTakeMedication(String reminderId) async {
    try {
      await _reminderService.markReminderSent(reminderId);
      await cancelReminder(reminderId);

      // If it's a recurring reminder, schedule the next occurrence
      final reminder = await _reminderService.getReminderById(reminderId);
      if (reminder != null && reminder.frequency != 'once') {
        await scheduleReminder(reminder);
      }
    } catch (e) {
      print('Error handling take medication action: $e');
    }
  }

  Future<void> _handleSkipMedication(String reminderId) async {
    try {
      await _reminderService.markReminderSent(reminderId);
      await cancelReminder(reminderId);

      // If it's a recurring reminder, schedule the next occurrence
      final reminder = await _reminderService.getReminderById(reminderId);
      if (reminder != null && reminder.frequency != 'once') {
        await scheduleReminder(reminder);
      }
    } catch (e) {
      print('Error handling skip medication action: $e');
    }
  }
}

/// Exception thrown by ReminderScheduler
class ReminderSchedulerException implements Exception {
  final String message;

  const ReminderSchedulerException(this.message);

  @override
  String toString() => 'ReminderSchedulerException: $message';
}
