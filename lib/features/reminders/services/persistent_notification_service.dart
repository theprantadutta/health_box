import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import './notification_service.dart';
import './reminder_service.dart';
import './medication_adherence_service.dart';

/// Service for managing persistent notifications for missed medication doses
class PersistentNotificationService {
  static final PersistentNotificationService _instance =
      PersistentNotificationService._internal();
  factory PersistentNotificationService() => _instance;
  PersistentNotificationService._internal();

  final NotificationService _notificationService = NotificationService();
  final ReminderService _reminderService = ReminderService();
  final MedicationAdherenceService _adherenceService = MedicationAdherenceService();

  // Track active persistent notifications
  final Map<String, PersistentNotificationData> _activeNotifications = {};

  /// Initialize the persistent notification service
  Future<bool> initialize() async {
    await _notificationService.initialize();
    return true;
  }

  /// Show a persistent notification for a missed medication dose
  Future<void> showMissedMedicationNotification({
    required String reminderId,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
    String? instructions,
  }) async {
    try {
      final id = _generatePersistentNotificationId(reminderId);
      const channelKey = 'missed_medications';

      final title = '⚠️ Missed Medication';
      final body = 'You missed taking $medicationName ($dosage) at ${_formatTime(scheduledTime)}';

      final payload = json.encode({
        'type': 'missed_medication',
        'reminderId': reminderId,
        'medicationName': medicationName,
        'dosage': dosage,
        'scheduledTime': scheduledTime.toIso8601String(),
        'instructions': instructions,
      });

      final androidDetails = AndroidNotificationDetails(
        channelKey,
        'Missed Medications',
        channelDescription: 'Persistent notifications for missed medication doses',
        importance: Importance.high,
        priority: Priority.high,
        ongoing: true, // Makes notification persistent
        autoCancel: false, // Prevents auto-dismissal
        showWhen: true,
        when: scheduledTime.millisecondsSinceEpoch,
        color: const Color(0xFFFF6B6B), // Red color for missed doses
        icon: '@drawable/ic_medication_missed',
        actions: [
          const AndroidNotificationAction(
            'mark_taken_late',
            'Mark as Taken',
            showsUserInterface: false,
          ),
          const AndroidNotificationAction(
            'mark_missed',
            'Mark as Missed',
            showsUserInterface: false,
          ),
          const AndroidNotificationAction(
            'reschedule',
            'Reschedule',
            showsUserInterface: true,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'missed_medication',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.critical, // Critical for missed doses
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationService.showImmediateNotification(
        title: title,
        body: body,
      );

      // Track the persistent notification
      _activeNotifications[reminderId] = PersistentNotificationData(
        reminderId: reminderId,
        notificationId: id,
        medicationName: medicationName,
        dosage: dosage,
        scheduledTime: scheduledTime,
        showTime: DateTime.now(),
      );

    } catch (e) {
      throw PersistentNotificationException(
        'Failed to show missed medication notification: ${e.toString()}',
      );
    }
  }

  /// Handle when user marks medication as taken late
  Future<void> markMedicationTakenLate(String reminderId) async {
    try {
      await _dismissPersistentNotification(reminderId);

      // Record in reminder service as taken (late)
      await _reminderService.markReminderSent(reminderId, sentTime: DateTime.now());

      // Record adherence as taken late
      await _recordMedicationAdherence(reminderId, 'taken_late');

    } catch (e) {
      throw PersistentNotificationException(
        'Failed to mark medication as taken: ${e.toString()}',
      );
    }
  }

  /// Handle when user marks medication as missed
  Future<void> markMedicationMissed(String reminderId) async {
    try {
      await _dismissPersistentNotification(reminderId);

      // Record as missed in adherence tracking
      await _recordMedicationAdherence(reminderId, 'missed');

    } catch (e) {
      throw PersistentNotificationException(
        'Failed to mark medication as missed: ${e.toString()}',
      );
    }
  }

  /// Handle rescheduling a missed medication
  Future<void> rescheduleMedication(String reminderId, DateTime newTime) async {
    try {
      await _dismissPersistentNotification(reminderId);

      // Reschedule the reminder
      await _reminderService.rescheduleReminder(reminderId, newTime);

    } catch (e) {
      throw PersistentNotificationException(
        'Failed to reschedule medication: ${e.toString()}',
      );
    }
  }

  /// Get all active persistent notifications
  List<PersistentNotificationData> getActiveNotifications() {
    return _activeNotifications.values.toList();
  }

  /// Check for missed medications and create persistent notifications
  Future<void> checkForMissedMedications() async {
    try {
      final overdueReminders = await _reminderService.getOverdueReminders();

      for (final reminder in overdueReminders) {
        // Only show persistent notification if not already showing and is medication type
        if (!_activeNotifications.containsKey(reminder.id) &&
            reminder.type == 'medication' &&
            reminder.isActive) {

          // Extract medication info from reminder
          final medicationName = _extractMedicationName(reminder.title);
          final dosage = _extractDosage(reminder.title);

          await showMissedMedicationNotification(
            reminderId: reminder.id,
            medicationName: medicationName,
            dosage: dosage,
            scheduledTime: reminder.scheduledTime,
            instructions: reminder.description,
          );
        }
      }
    } catch (e) {
      throw PersistentNotificationException(
        'Failed to check for missed medications: ${e.toString()}',
      );
    }
  }

  /// Dismiss a persistent notification
  Future<void> _dismissPersistentNotification(String reminderId) async {
    final data = _activeNotifications[reminderId];
    if (data != null) {
      await _notificationService.cancelNotification(reminderId);
      _activeNotifications.remove(reminderId);
    }
  }

  /// Record medication adherence
  Future<void> _recordMedicationAdherence(
    String reminderId,
    String status,
  ) async {
    try {
      final reminder = await _reminderService.getReminderById(reminderId);
      if (reminder == null) return;

      // Extract medication details from the reminder
      final medicationName = _extractMedicationName(reminder.title);
      final dosage = _extractDosage(reminder.title);

      // For now, we'll use placeholder values for required fields
      // In a real implementation, these would come from the reminder or medication record
      await _adherenceService.recordMedicationAdherence(
        reminderId: reminderId,
        medicationId: reminder.medicationId ?? 'unknown',
        profileId: 'current_profile', // This should come from context
        medicationName: medicationName,
        dosage: dosage,
        scheduledTime: reminder.scheduledTime,
        status: status,
        recordedTime: DateTime.now(),
      );
    } catch (e) {
      // Log the error but don't throw to avoid breaking the notification flow
      print('Error recording medication adherence: $e');
    }
  }

  /// Generate unique notification ID for persistent notifications
  int _generatePersistentNotificationId(String reminderId) {
    // Use a different range for persistent notifications to avoid conflicts
    return (reminderId.hashCode.abs() % 100000) + 1000000;
  }

  /// Format time for notification display
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Extract medication name from reminder title
  String _extractMedicationName(String title) {
    // Assuming format like "Aspirin - 100mg" or just "Aspirin"
    final parts = title.split(' - ');
    return parts.first.trim();
  }

  /// Extract dosage from reminder title
  String _extractDosage(String title) {
    // Assuming format like "Aspirin - 100mg"
    final parts = title.split(' - ');
    return parts.length > 1 ? parts.last.trim() : 'N/A';
  }

  /// Cleanup all persistent notifications
  Future<void> clearAllPersistentNotifications() async {
    for (final reminderId in _activeNotifications.keys.toList()) {
      await _dismissPersistentNotification(reminderId);
    }
  }
}

/// Data class for tracking persistent notifications
class PersistentNotificationData {
  final String reminderId;
  final int notificationId;
  final String medicationName;
  final String dosage;
  final DateTime scheduledTime;
  final DateTime showTime;

  const PersistentNotificationData({
    required this.reminderId,
    required this.notificationId,
    required this.medicationName,
    required this.dosage,
    required this.scheduledTime,
    required this.showTime,
  });
}

/// Medication adherence status
enum MedicationAdherenceStatus {
  taken,
  takenLate,
  missed,
  skipped,
}

/// Exception for persistent notification errors
class PersistentNotificationException implements Exception {
  final String message;

  const PersistentNotificationException(this.message);

  @override
  String toString() => 'PersistentNotificationException: $message';
}