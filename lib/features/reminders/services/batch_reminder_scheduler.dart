import 'dart:async';
import 'dart:developer' as developer;

import '../../../data/database/app_database.dart';
import '../../../data/models/medication_batch.dart';
import '../../../shared/providers/settings_providers.dart';
import '../../medical_records/services/medication_batch_service.dart';
import 'notification_alarm_service.dart';
import 'reminder_service.dart';

/// Service responsible for scheduling batch-aware medication reminders
class BatchReminderScheduler {
  final NotificationAlarmService _notificationAlarmService;
  final ReminderService _reminderService;
  final MedicationBatchService _batchService;

  BatchReminderScheduler({
    NotificationAlarmService? notificationAlarmService,
    ReminderService? reminderService,
    MedicationBatchService? batchService,
  }) : _notificationAlarmService = notificationAlarmService ?? NotificationAlarmService(),
       _reminderService = reminderService ?? ReminderService(),
       _batchService = batchService ?? MedicationBatchService();

  /// Initialize the batch reminder scheduler
  Future<bool> initialize() async {
    try {
      final serviceInitialized = await _notificationAlarmService.initialize();

      if (serviceInitialized) {
        // Reschedule all active batch reminders
        await rescheduleAllActiveBatchReminders();
      }

      return serviceInitialized;
    } catch (e) {
      developer.log('Failed to initialize BatchReminderScheduler: $e', name: 'BatchReminderScheduler');
      return false;
    }
  }

  /// Schedule reminders for a medication batch
  Future<bool> scheduleBatchReminder(String batchId) async {
    try {
      final batch = await _batchService.getBatchById(batchId);
      if (batch == null || !batch.isActive) {
        developer.log('Batch not found or inactive: $batchId', name: 'BatchReminderScheduler');
        return false;
      }

      final medications = await _batchService.getMedicationsInBatch(batchId);
      if (medications.isEmpty) {
        developer.log('No medications in batch: $batchId', name: 'BatchReminderScheduler');
        return false;
      }

      // Filter active medications only
      final activeMedications = medications.where((m) => m.status == 'active').toList();
      if (activeMedications.isEmpty) {
        developer.log('No active medications in batch: $batchId', name: 'BatchReminderScheduler');
        return false;
      }

      // Calculate next reminder times based on batch timing
      final reminderTimes = await _calculateBatchReminderTimes(batch);

      bool allScheduled = true;
      for (final reminderTime in reminderTimes) {
        final reminderId = '${batchId}_${reminderTime.millisecondsSinceEpoch}';

        try {
          // Create a consolidated reminder for all medications in the batch
          final reminder = await _createBatchReminder(
            reminderId: reminderId,
            batch: batch,
            medications: activeMedications,
            scheduledTime: reminderTime,
          );

          final scheduled = await _notificationAlarmService.scheduleReminder(
            reminder: reminder,
            reminderType: ReminderType.notification, // Default to notification for now
          );

          if (!scheduled) {
            allScheduled = false;
            developer.log('Failed to schedule reminder for batch $batchId at $reminderTime',
                         name: 'BatchReminderScheduler');
          }
        } catch (e) {
          allScheduled = false;
          developer.log('Error scheduling reminder for batch $batchId: $e',
                       name: 'BatchReminderScheduler');
        }
      }

      return allScheduled;
    } catch (e) {
      developer.log('Failed to schedule batch reminder: $e', name: 'BatchReminderScheduler');
      return false;
    }
  }

  /// Cancel all reminders for a medication batch
  Future<bool> cancelBatchReminders(String batchId) async {
    try {
      // Find all reminders for this batch
      final activeReminders = await _reminderService.getActiveReminders();
      final batchReminders = activeReminders.where((r) =>
        r.id.startsWith(batchId) || (r.recordId != null && r.recordId == batchId)
      ).toList();

      bool allCancelled = true;
      for (final reminder in batchReminders) {
        try {
          final cancelled = await _notificationAlarmService.cancelReminder(reminder.id);
          if (!cancelled) {
            allCancelled = false;
          }
        } catch (e) {
          allCancelled = false;
          developer.log('Error cancelling reminder ${reminder.id}: $e', name: 'BatchReminderScheduler');
        }
      }

      return allCancelled;
    } catch (e) {
      developer.log('Failed to cancel batch reminders: $e', name: 'BatchReminderScheduler');
      return false;
    }
  }

  /// Reschedule all active batch reminders
  Future<void> rescheduleAllActiveBatchReminders() async {
    try {
      final activeBatches = await _batchService.getActiveBatches();

      for (final batch in activeBatches) {
        final medications = await _batchService.getMedicationsInBatch(batch.id);
        final activeMedications = medications.where((m) =>
          m.status == 'active' && m.reminderEnabled
        ).toList();

        if (activeMedications.isNotEmpty) {
          try {
            await scheduleBatchReminder(batch.id);
          } catch (e) {
            developer.log('Failed to reschedule batch ${batch.id}: $e', name: 'BatchReminderScheduler');
          }
        }
      }
    } catch (e) {
      developer.log('Failed to reschedule all batch reminders: $e', name: 'BatchReminderScheduler');
    }
  }

  /// Update batch reminders when batch timing changes
  Future<bool> updateBatchReminders(String batchId) async {
    try {
      // Cancel existing reminders
      await cancelBatchReminders(batchId);

      // Schedule new reminders
      return await scheduleBatchReminder(batchId);
    } catch (e) {
      developer.log('Failed to update batch reminders: $e', name: 'BatchReminderScheduler');
      return false;
    }
  }

  /// Handle medication added to batch
  Future<void> onMedicationAddedToBatch(String medicationId, String batchId) async {
    try {
      // Reschedule the entire batch to include new medication
      await updateBatchReminders(batchId);
    } catch (e) {
      developer.log('Failed to handle medication added to batch: $e', name: 'BatchReminderScheduler');
    }
  }

  /// Handle medication removed from batch
  Future<void> onMedicationRemovedFromBatch(String medicationId, String batchId) async {
    try {
      // Reschedule the batch without the removed medication
      await updateBatchReminders(batchId);
    } catch (e) {
      developer.log('Failed to handle medication removed from batch: $e', name: 'BatchReminderScheduler');
    }
  }

  /// Calculate next reminder times for a batch based on its timing configuration
  Future<List<DateTime>> _calculateBatchReminderTimes(MedicationBatche batch) async {
    final reminderTimes = <DateTime>[];
    final now = DateTime.now();

    try {
      final timingDetails = _batchService.parseTimingDetails(batch.timingType, batch.timingDetails);

      switch (batch.timingType) {
        case MedicationBatchTimingType.afterMeal:
        case MedicationBatchTimingType.beforeMeal:
          reminderTimes.addAll(await _calculateMealBasedTimes(batch.timingType, timingDetails, now));
          break;

        case MedicationBatchTimingType.fixedTime:
          reminderTimes.addAll(await _calculateFixedTimes(timingDetails, now));
          break;

        case MedicationBatchTimingType.interval:
          reminderTimes.addAll(await _calculateIntervalTimes(timingDetails, now));
          break;

        case MedicationBatchTimingType.asNeeded:
          // As-needed medications don't get automatic reminders
          break;

        default:
          developer.log('Unknown timing type: ${batch.timingType}', name: 'BatchReminderScheduler');
      }
    } catch (e) {
      developer.log('Error calculating reminder times for batch ${batch.id}: $e', name: 'BatchReminderScheduler');
    }

    return reminderTimes;
  }

  /// Calculate meal-based reminder times
  Future<List<DateTime>> _calculateMealBasedTimes(
    String timingType,
    Map<String, dynamic>? timingDetails,
    DateTime now,
  ) async {
    final times = <DateTime>[];

    if (timingDetails == null) return times;

    try {
      final mealTiming = MealTimingDetails.fromJson(timingDetails);
      final mealTimes = await _getConfiguredMealTimes();

      final mealTime = mealTimes[mealTiming.mealType];
      if (mealTime != null) {
        // Calculate reminder time based on meal time and offset
        DateTime reminderTime;
        if (timingType == MedicationBatchTimingType.afterMeal) {
          reminderTime = mealTime.add(Duration(minutes: mealTiming.minutesAfterBefore));
        } else {
          reminderTime = mealTime.subtract(Duration(minutes: mealTiming.minutesAfterBefore));
        }

        // Schedule for today if time hasn't passed, otherwise tomorrow
        final today = DateTime(now.year, now.month, now.day, reminderTime.hour, reminderTime.minute);
        if (today.isAfter(now)) {
          times.add(today);
        } else {
          times.add(today.add(const Duration(days: 1)));
        }
      }
    } catch (e) {
      developer.log('Error calculating meal-based times: $e', name: 'BatchReminderScheduler');
    }

    return times;
  }

  /// Calculate fixed reminder times
  Future<List<DateTime>> _calculateFixedTimes(
    Map<String, dynamic>? timingDetails,
    DateTime now,
  ) async {
    final times = <DateTime>[];

    if (timingDetails == null) return times;

    try {
      final fixedTiming = FixedTimeDetails.fromJson(timingDetails);

      for (final timeStr in fixedTiming.times) {
        final timeParts = timeStr.split(':');
        if (timeParts.length == 2) {
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          final today = DateTime(now.year, now.month, now.day, hour, minute);
          if (today.isAfter(now)) {
            times.add(today);
          } else {
            times.add(today.add(const Duration(days: 1)));
          }
        }
      }
    } catch (e) {
      developer.log('Error calculating fixed times: $e', name: 'BatchReminderScheduler');
    }

    return times;
  }

  /// Calculate interval-based reminder times
  Future<List<DateTime>> _calculateIntervalTimes(
    Map<String, dynamic>? timingDetails,
    DateTime now,
  ) async {
    final times = <DateTime>[];

    if (timingDetails == null) return times;

    try {
      final intervalTiming = IntervalTimingDetails.fromJson(timingDetails);

      // Calculate next reminder based on interval
      DateTime nextReminder = now.add(Duration(hours: intervalTiming.intervalHours));

      // Respect start and end times if specified
      if (intervalTiming.startTime != null && intervalTiming.endTime != null) {
        final startParts = intervalTiming.startTime!.split(':');
        final endParts = intervalTiming.endTime!.split(':');

        if (startParts.length == 2 && endParts.length == 2) {
          final startHour = int.parse(startParts[0]);
          final startMinute = int.parse(startParts[1]);
          final endHour = int.parse(endParts[0]);
          final endMinute = int.parse(endParts[1]);

          // Only schedule if within the time window
          if (_isWithinTimeWindow(nextReminder, startHour, startMinute, endHour, endMinute)) {
            times.add(nextReminder);
          }
        }
      } else {
        times.add(nextReminder);
      }
    } catch (e) {
      developer.log('Error calculating interval times: $e', name: 'BatchReminderScheduler');
    }

    return times;
  }

  /// Create a batch reminder object
  Future<Reminder> _createBatchReminder({
    required String reminderId,
    required MedicationBatche batch,
    required List<Medication> medications,
    required DateTime scheduledTime,
  }) async {
    // Create a consolidated title and description for the batch
    final medicationNames = medications.map((m) => m.medicationName).join(', ');
    final medicationCount = medications.length;

    String title;
    if (medicationCount == 1) {
      title = 'Medication Reminder: ${medications.first.medicationName}';
    } else {
      title = '${batch.name} ($medicationCount medications)';
    }

    final description = 'Time to take: $medicationNames';

    // Create reminder companion for database insertion
    return Reminder(
      id: reminderId,
      recordId: batch.id,
      medicationId: null, // This is a batch reminder, not for individual medication
      type: 'medication',
      title: title,
      description: description,
      scheduledTime: scheduledTime,
      frequency: 'daily', // Batches typically repeat daily
      daysOfWeek: null,
      timeSlots: null,
      isActive: true,
      lastSent: null,
      nextScheduled: scheduledTime,
      snoozeMinutes: 15,
    );
  }

  /// Get configured meal times from user preferences or defaults
  Future<Map<String, DateTime>> _getConfiguredMealTimes() async {
    // TODO: Get from user preferences/settings
    // For now, use reasonable defaults
    final now = DateTime.now();
    return {
      MealType.breakfast: DateTime(now.year, now.month, now.day, 8, 0), // 8:00 AM
      MealType.lunch: DateTime(now.year, now.month, now.day, 12, 30), // 12:30 PM
      MealType.dinner: DateTime(now.year, now.month, now.day, 19, 0), // 7:00 PM
      MealType.snack: DateTime(now.year, now.month, now.day, 15, 0), // 3:00 PM
    };
  }

  /// Check if a time is within the specified time window
  bool _isWithinTimeWindow(DateTime time, int startHour, int startMinute, int endHour, int endMinute) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    if (endMinutes > startMinutes) {
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    } else {
      // Handle overnight window (e.g., 22:00 to 06:00)
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
  }
}

/// Exception thrown by BatchReminderScheduler
class BatchReminderSchedulerException implements Exception {
  final String message;

  const BatchReminderSchedulerException(this.message);

  @override
  String toString() => 'BatchReminderSchedulerException: $message';
}