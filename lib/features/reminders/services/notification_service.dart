import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Initialize the notification service
  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      // Initialize timezone data
      tz.initializeTimeZones();

      const androidInitialization = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosInitialization = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: androidInitialization,
        iOS: iosInitialization,
      );

      final success = await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (success == true) {
        _isInitialized = true;
        await _createNotificationChannels();
      }

      return success == true;
    } catch (e) {
      throw NotificationServiceException(
        'Failed to initialize notification service: ${e.toString()}',
      );
    }
  }

  // Check and request permissions
  Future<bool> requestPermissions() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Android permissions
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final granted = await androidImplementation
            .requestNotificationsPermission();
        if (granted != true) {
          return false;
        }

        // Request exact alarm permission for Android 12+
        await androidImplementation.requestExactAlarmsPermission();
      }

      // iOS permissions
      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosImplementation != null) {
        await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      return true;
    } catch (e) {
      throw NotificationServiceException(
        'Failed to request permissions: ${e.toString()}',
      );
    }
  }

  // Schedule a medication reminder notification
  Future<void> scheduleMedicationReminder({
    required String reminderId,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
    String? instructions,
    String frequency = 'once',
  }) async {
    try {
      if (!_isInitialized) {
        throw const NotificationServiceException(
          'Notification service not initialized',
        );
      }

      final id = reminderId.hashCode;
      const channelKey = 'medication_reminders';

      final title = 'Medication Reminder';
      final body = 'Time to take $medicationName ($dosage)';
      final payload = json.encode({
        'type': 'medication_reminder',
        'reminderId': reminderId,
        'medicationName': medicationName,
        'dosage': dosage,
        'instructions': instructions,
      });

      final androidDetails = AndroidNotificationDetails(
        channelKey,
        'Medication Reminders',
        channelDescription: 'Notifications for medication reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        when: scheduledTime.millisecondsSinceEpoch,
        actions: [
          const AndroidNotificationAction(
            'taken',
            'Mark as Taken',
            showsUserInterface: false,
          ),
          const AndroidNotificationAction(
            'snooze',
            'Snooze 15 min',
            showsUserInterface: false,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'medication_reminder',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      if (frequency == 'once') {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          _convertToTZDateTime(scheduledTime),
          notificationDetails,
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } else {
        // For recurring reminders, schedule the next occurrence
        await _scheduleRecurringReminder(
          id: id,
          title: title,
          body: body,
          scheduledTime: scheduledTime,
          notificationDetails: notificationDetails,
          payload: payload,
          frequency: frequency,
        );
      }
    } catch (e) {
      throw NotificationServiceException(
        'Failed to schedule medication reminder: ${e.toString()}',
      );
    }
  }

  // Schedule a general reminder notification
  Future<void> scheduleGeneralReminder({
    required String reminderId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String frequency = 'once',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (!_isInitialized) {
        throw const NotificationServiceException(
          'Notification service not initialized',
        );
      }

      final id = reminderId.hashCode;
      const channelKey = 'general_reminders';

      final payload = json.encode({
        'type': 'general_reminder',
        'reminderId': reminderId,
        'title': title,
        'body': body,
        'additionalData': additionalData,
      });

      const androidDetails = AndroidNotificationDetails(
        channelKey,
        'General Reminders',
        channelDescription: 'General health-related reminders',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'general_reminder',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      if (frequency == 'once') {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          _convertToTZDateTime(scheduledTime),
          notificationDetails,
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } else {
        await _scheduleRecurringReminder(
          id: id,
          title: title,
          body: body,
          scheduledTime: scheduledTime,
          notificationDetails: notificationDetails,
          payload: payload,
          frequency: frequency,
        );
      }
    } catch (e) {
      throw NotificationServiceException(
        'Failed to schedule general reminder: ${e.toString()}',
      );
    }
  }

  // Generic schedule notification method for compatibility
  Future<void> scheduleNotification(
    String reminderId,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    await scheduleGeneralReminder(
      reminderId: reminderId,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      frequency: 'once',
    );
  }

  // Generic schedule repeating notification method for compatibility
  Future<void> scheduleRepeatingNotification(
    String reminderId,
    String title,
    String body,
    DateTime scheduledTime,
    String frequency,
  ) async {
    await scheduleGeneralReminder(
      reminderId: reminderId,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      frequency: frequency,
    );
  }

  // Show an immediate notification
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    try {
      if (!_isInitialized) {
        throw const NotificationServiceException(
          'Notification service not initialized',
        );
      }

      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final channelKey = _getChannelKeyForType(type);
      final channelName = _getChannelNameForType(type);

      final androidDetails = AndroidNotificationDetails(
        channelKey,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      throw NotificationServiceException(
        'Failed to show immediate notification: ${e.toString()}',
      );
    }
  }

  // Cancel a scheduled notification
  Future<void> cancelNotification(String reminderId) async {
    try {
      final id = reminderId.hashCode;
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      throw NotificationServiceException(
        'Failed to cancel notification: ${e.toString()}',
      );
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      throw NotificationServiceException(
        'Failed to cancel all notifications: ${e.toString()}',
      );
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      throw NotificationServiceException(
        'Failed to get pending notifications: ${e.toString()}',
      );
    }
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final enabled = await androidImplementation.areNotificationsEnabled();
        return enabled ?? false;
      }

      return true; // iOS permissions are handled differently
    } catch (e) {
      return false;
    }
  }

  // Snooze a notification
  Future<void> snoozeNotification({
    required String reminderId,
    required String title,
    required String body,
    int minutes = 15,
    Map<String, dynamic>? payload,
  }) async {
    try {
      // Cancel the existing notification
      await cancelNotification(reminderId);

      // Schedule a new notification for the snooze time
      final snoozeTime = DateTime.now().add(Duration(minutes: minutes));
      final snoozedReminderId =
          '${reminderId}_snoozed_${DateTime.now().millisecondsSinceEpoch}';

      await scheduleGeneralReminder(
        reminderId: snoozedReminderId,
        title: title,
        body: body,
        scheduledTime: snoozeTime,
        additionalData: payload,
      );
    } catch (e) {
      throw NotificationServiceException(
        'Failed to snooze notification: ${e.toString()}',
      );
    }
  }

  // Private helper methods

  Future<void> _createNotificationChannels() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      // Medication reminders channel
      const medicationChannel = AndroidNotificationChannel(
        'medication_reminders',
        'Medication Reminders',
        description: 'Notifications for medication reminders',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      // General reminders channel
      const generalChannel = AndroidNotificationChannel(
        'general_reminders',
        'General Reminders',
        description: 'General health-related reminders',
        importance: Importance.defaultImportance,
        playSound: true,
      );

      // Appointment reminders channel
      const appointmentChannel = AndroidNotificationChannel(
        'appointment_reminders',
        'Appointment Reminders',
        description: 'Notifications for medical appointments',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await androidImplementation.createNotificationChannel(medicationChannel);
      await androidImplementation.createNotificationChannel(generalChannel);
      await androidImplementation.createNotificationChannel(appointmentChannel);
    }
  }

  Future<void> _scheduleRecurringReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required NotificationDetails notificationDetails,
    required String payload,
    required String frequency,
  }) async {
    // For recurring reminders, we schedule the immediate next occurrence
    // The app should handle rescheduling the next occurrence when this fires
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledTime),
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap
    final payload = notificationResponse.payload;
    if (payload != null) {
      try {
        final data = json.decode(payload) as Map<String, dynamic>;
        _handleNotificationAction(data, notificationResponse.actionId);
      } catch (e) {
        // Handle parsing error
      }
    }
  }

  void _handleNotificationAction(Map<String, dynamic> data, String? actionId) {
    final type = data['type'] as String?;

    switch (actionId) {
      case 'taken':
        if (type == 'medication_reminder') {
          // Handle medication taken action
          _onMedicationTaken(data);
        }
        break;
      case 'snooze':
        // Handle snooze action
        _onNotificationSnoozed(data);
        break;
      default:
        // Handle default tap
        _onNotificationDefaultTap(data);
        break;
    }
  }

  void _onMedicationTaken(Map<String, dynamic> data) {
    // This would typically notify other parts of the app
    // that medication was taken via a stream or callback
  }

  void _onNotificationSnoozed(Map<String, dynamic> data) {
    // Handle snooze logic
    final reminderId = data['reminderId'] as String?;
    if (reminderId != null) {
      // Schedule snooze notification
      snoozeNotification(
        reminderId: reminderId,
        title: data['title'] ?? 'Reminder',
        body: data['body'] ?? '',
        payload: data,
      );
    }
  }

  void _onNotificationDefaultTap(Map<String, dynamic> data) {
    // Handle default notification tap
    // This could navigate to a specific screen in the app
  }

  String _getChannelKeyForType(NotificationType type) {
    switch (type) {
      case NotificationType.medication:
        return 'medication_reminders';
      case NotificationType.appointment:
        return 'appointment_reminders';
      case NotificationType.general:
        return 'general_reminders';
    }
  }

  String _getChannelNameForType(NotificationType type) {
    switch (type) {
      case NotificationType.medication:
        return 'Medication Reminders';
      case NotificationType.appointment:
        return 'Appointment Reminders';
      case NotificationType.general:
        return 'General Reminders';
    }
  }

  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final location = tz.local;
    return tz.TZDateTime.from(dateTime, location);
  }
}

// Enums

enum NotificationType { medication, appointment, general }

// Exceptions

class NotificationServiceException implements Exception {
  final String message;

  const NotificationServiceException(this.message);

  @override
  String toString() => 'NotificationServiceException: $message';
}
