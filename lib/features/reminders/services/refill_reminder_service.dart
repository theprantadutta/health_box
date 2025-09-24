import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../medical_records/services/medication_service.dart';
import './notification_service.dart';
import './reminder_service.dart';

/// Service for managing medication refill reminders
class RefillReminderService {
  final MedicationService _medicationService;
  final NotificationService _notificationService;
  final ReminderService _reminderService;

  RefillReminderService({
    MedicationService? medicationService,
    NotificationService? notificationService,
    ReminderService? reminderService,
  }) : _medicationService = medicationService ?? MedicationService(),
        _notificationService = notificationService ?? NotificationService(),
        _reminderService = reminderService ?? ReminderService();

  // Core Refill Calculation

  /// Calculate when a medication will run out based on current supply and usage
  DateTime? calculateRunOutDate({
    required int currentPillCount,
    required String dosageFrequency,
    required String dosage,
    DateTime? startDate,
  }) {
    try {
      if (currentPillCount <= 0) {
        return DateTime.now(); // Already out
      }

      final dailyDoses = _calculateDailyDoses(dosageFrequency, dosage);
      if (dailyDoses <= 0) return null;

      final daysRemaining = currentPillCount / dailyDoses;
      return DateTime.now().add(Duration(days: daysRemaining.ceil()));
    } catch (e) {
      return null; // Cannot calculate
    }
  }

  /// Calculate optimal refill reminder date (typically 7-10 days before running out)
  DateTime? calculateRefillReminderDate({
    required int currentPillCount,
    required String dosageFrequency,
    required String dosage,
    int daysBeforeRunOut = 7,
  }) {
    final runOutDate = calculateRunOutDate(
      currentPillCount: currentPillCount,
      dosageFrequency: dosageFrequency,
      dosage: dosage,
    );

    if (runOutDate == null) return null;

    final reminderDate = runOutDate.subtract(Duration(days: daysBeforeRunOut));

    // Don't set reminder in the past
    return reminderDate.isAfter(DateTime.now()) ? reminderDate : DateTime.now().add(const Duration(hours: 1));
  }

  // Medication Analysis

  /// Get medications that are running low (less than threshold days remaining)
  Future<List<MedicationRefillInfo>> getLowInventoryMedications({
    String? profileId,
    int thresholdDays = 7,
  }) async {
    try {
      final medications = await _medicationService.getActiveMedications(
        profileId: profileId,
      );

      final lowInventoryMedications = <MedicationRefillInfo>[];

      for (final medication in medications) {
        if (medication.pillCount == null) continue;

        final refillInfo = await _analyzeMedicationRefillStatus(medication);

        if (refillInfo.daysRemaining != null &&
            refillInfo.daysRemaining! <= thresholdDays) {
          lowInventoryMedications.add(refillInfo);
        }
      }

      // Sort by urgency (least days remaining first)
      lowInventoryMedications.sort((a, b) {
        if (a.daysRemaining == null) return 1;
        if (b.daysRemaining == null) return -1;
        return a.daysRemaining!.compareTo(b.daysRemaining!);
      });

      return lowInventoryMedications;
    } catch (e) {
      throw RefillReminderServiceException(
        'Failed to get low inventory medications: ${e.toString()}',
      );
    }
  }

  /// Get all medications with refill analysis
  Future<List<MedicationRefillInfo>> getAllMedicationRefillInfo({
    String? profileId,
  }) async {
    try {
      final medications = await _medicationService.getActiveMedications(
        profileId: profileId,
      );

      final refillInfoList = <MedicationRefillInfo>[];

      for (final medication in medications) {
        final refillInfo = await _analyzeMedicationRefillStatus(medication);
        refillInfoList.add(refillInfo);
      }

      return refillInfoList;
    } catch (e) {
      throw RefillReminderServiceException(
        'Failed to get medication refill info: ${e.toString()}',
      );
    }
  }

  /// Analyze refill status for a single medication
  Future<MedicationRefillInfo> _analyzeMedicationRefillStatus(
    Medication medication,
  ) async {
    final currentPillCount = medication.pillCount ?? 0;

    final runOutDate = calculateRunOutDate(
      currentPillCount: currentPillCount,
      dosageFrequency: medication.frequency,
      dosage: medication.dosage,
      startDate: medication.startDate,
    );

    final daysRemaining = runOutDate != null
        ? runOutDate.difference(DateTime.now()).inDays
        : null;

    final refillReminderDate = calculateRefillReminderDate(
      currentPillCount: currentPillCount,
      dosageFrequency: medication.frequency,
      dosage: medication.dosage,
    );

    final urgency = _calculateUrgency(daysRemaining);

    return MedicationRefillInfo(
      medication: medication,
      currentPillCount: currentPillCount,
      runOutDate: runOutDate,
      daysRemaining: daysRemaining,
      refillReminderDate: refillReminderDate,
      urgency: urgency,
      needsRefill: daysRemaining != null && daysRemaining <= 7,
    );
  }

  // Reminder Management

  /// Schedule refill reminders for all active medications
  Future<int> scheduleAllRefillReminders({String? profileId}) async {
    try {
      final medications = await _medicationService.getActiveMedications(
        profileId: profileId,
      );

      int scheduledCount = 0;

      for (final medication in medications) {
        if (medication.pillCount == null) continue;

        final success = await scheduleRefillReminder(medication.id);
        if (success) scheduledCount++;
      }

      return scheduledCount;
    } catch (e) {
      throw RefillReminderServiceException(
        'Failed to schedule all refill reminders: ${e.toString()}',
      );
    }
  }

  /// Schedule a refill reminder for a specific medication
  Future<bool> scheduleRefillReminder(String medicationId) async {
    try {
      final medication = await _medicationService.getMedicationById(medicationId);
      if (medication == null || medication.pillCount == null) {
        return false;
      }

      final refillReminderDate = calculateRefillReminderDate(
        currentPillCount: medication.pillCount!,
        dosageFrequency: medication.frequency,
        dosage: medication.dosage,
      );

      if (refillReminderDate == null || refillReminderDate.isBefore(DateTime.now())) {
        return false;
      }

      // Cancel existing refill reminder
      await cancelRefillReminder(medicationId);

      // Create new refill reminder
      final reminderId = 'refill_${medicationId}_${DateTime.now().millisecondsSinceEpoch}';

      final reminderRequest = CreateReminderRequest(
        medicationId: medicationId,
        type: 'refill',
        title: 'Refill ${medication.medicationName}',
        description: 'Time to refill your ${medication.medicationName} prescription. You have approximately 7 days remaining.',
        scheduledTime: refillReminderDate,
        frequency: 'once',
        isActive: true,
        snoozeMinutes: 1440, // 24 hour snooze for refill reminders
      );

      await _reminderService.createReminder(reminderRequest);

      // Schedule the notification
      await _notificationService.scheduleGeneralReminder(
        reminderId: reminderId,
        title: 'Medication Refill Needed',
        body: 'Time to refill your ${medication.medicationName} prescription',
        scheduledTime: refillReminderDate,
        additionalData: {
          'type': 'refill_reminder',
          'medicationId': medicationId,
          'medicationName': medication.medicationName,
        },
      );

      return true;
    } catch (e) {
      throw RefillReminderServiceException(
        'Failed to schedule refill reminder: ${e.toString()}',
      );
    }
  }

  /// Cancel refill reminder for a medication
  Future<bool> cancelRefillReminder(String medicationId) async {
    try {
      // Find existing refill reminders for this medication
      final reminders = await _reminderService.getMedicationReminders(
        medicationId: medicationId,
      );

      bool cancelledAny = false;

      for (final reminder in reminders) {
        if (reminder.type == 'refill') {
          await _reminderService.deleteReminder(reminder.id);
          await _notificationService.cancelNotification(reminder.id);
          cancelledAny = true;
        }
      }

      return cancelledAny;
    } catch (e) {
      throw RefillReminderServiceException(
        'Failed to cancel refill reminder: ${e.toString()}',
      );
    }
  }

  // Inventory Management

  /// Update pill count for a medication and reschedule refill reminder
  Future<bool> updatePillCountWithRefillReschedule({
    required String medicationId,
    required int newPillCount,
  }) async {
    try {
      // Update the pill count
      final success = await _medicationService.updatePillCount(
        medicationId,
        newPillCount,
      );

      if (success) {
        // Reschedule refill reminder with new count
        await scheduleRefillReminder(medicationId);
      }

      return success;
    } catch (e) {
      throw RefillReminderServiceException(
        'Failed to update pill count and reschedule reminder: ${e.toString()}',
      );
    }
  }

  /// Record medication refill
  Future<bool> recordMedicationRefill({
    required String medicationId,
    required int refillAmount,
    required DateTime refillDate,
    String? pharmacy,
    String? notes,
  }) async {
    try {
      final medication = await _medicationService.getMedicationById(medicationId);
      if (medication == null) return false;

      final currentCount = medication.pillCount ?? 0;
      final newCount = currentCount + refillAmount;

      // Update pill count
      final success = await _medicationService.updatePillCount(
        medicationId,
        newCount,
      );

      if (success) {
        // Reschedule refill reminder with new count
        await scheduleRefillReminder(medicationId);

        // TODO: Record refill history entry in a refill log table
        // This would track refill dates, amounts, pharmacy, etc.
      }

      return success;
    } catch (e) {
      throw RefillReminderServiceException(
        'Failed to record medication refill: ${e.toString()}',
      );
    }
  }

  // Utility Methods

  /// Calculate daily doses from frequency and dosage strings
  double _calculateDailyDoses(String frequency, String dosage) {
    // Parse frequency (e.g., "twice daily", "3 times per day", "every 8 hours")
    final frequencyLower = frequency.toLowerCase();

    if (frequencyLower.contains('once') || frequencyLower.contains('daily') && !frequencyLower.contains('twice')) {
      return 1.0;
    } else if (frequencyLower.contains('twice') || frequencyLower.contains('2')) {
      return 2.0;
    } else if (frequencyLower.contains('three') || frequencyLower.contains('3')) {
      return 3.0;
    } else if (frequencyLower.contains('four') || frequencyLower.contains('4')) {
      return 4.0;
    } else if (frequencyLower.contains('every 12 hours')) {
      return 2.0;
    } else if (frequencyLower.contains('every 8 hours')) {
      return 3.0;
    } else if (frequencyLower.contains('every 6 hours')) {
      return 4.0;
    }

    // Try to extract number from frequency string
    final numberMatch = RegExp(r'(\d+)').firstMatch(frequencyLower);
    if (numberMatch != null) {
      return double.tryParse(numberMatch.group(1)!) ?? 1.0;
    }

    return 1.0; // Default to once daily
  }

  /// Calculate urgency level based on days remaining
  RefillUrgency _calculateUrgency(int? daysRemaining) {
    if (daysRemaining == null) return RefillUrgency.unknown;

    if (daysRemaining <= 0) return RefillUrgency.critical;
    if (daysRemaining <= 3) return RefillUrgency.high;
    if (daysRemaining <= 7) return RefillUrgency.medium;
    if (daysRemaining <= 14) return RefillUrgency.low;

    return RefillUrgency.none;
  }

  /// Check if a medication needs immediate refill attention
  bool needsImmediateAttention(MedicationRefillInfo refillInfo) {
    return refillInfo.urgency == RefillUrgency.critical ||
           refillInfo.urgency == RefillUrgency.high;
  }

  /// Get refill urgency color for UI
  static Color getUrgencyColor(RefillUrgency urgency) {
    switch (urgency) {
      case RefillUrgency.critical:
        return const Color(0xFFD32F2F); // Red
      case RefillUrgency.high:
        return const Color(0xFFF57C00); // Orange
      case RefillUrgency.medium:
        return const Color(0xFFFBC02D); // Yellow
      case RefillUrgency.low:
        return const Color(0xFF388E3C); // Green
      case RefillUrgency.none:
        return const Color(0xFF757575); // Grey
      case RefillUrgency.unknown:
        return const Color(0xFF9E9E9E); // Light grey
    }
  }

  /// Get refill urgency icon for UI
  static IconData getUrgencyIcon(RefillUrgency urgency) {
    switch (urgency) {
      case RefillUrgency.critical:
        return Icons.error;
      case RefillUrgency.high:
        return Icons.warning;
      case RefillUrgency.medium:
        return Icons.schedule;
      case RefillUrgency.low:
        return Icons.info;
      case RefillUrgency.none:
        return Icons.check_circle;
      case RefillUrgency.unknown:
        return Icons.help;
    }
  }
}

/// Data class containing medication refill information
class MedicationRefillInfo {
  final Medication medication;
  final int currentPillCount;
  final DateTime? runOutDate;
  final int? daysRemaining;
  final DateTime? refillReminderDate;
  final RefillUrgency urgency;
  final bool needsRefill;

  const MedicationRefillInfo({
    required this.medication,
    required this.currentPillCount,
    this.runOutDate,
    this.daysRemaining,
    this.refillReminderDate,
    required this.urgency,
    required this.needsRefill,
  });

  String get medicationName => medication.medicationName;
  String get dosage => medication.dosage;
  String get frequency => medication.frequency;
}

/// Refill urgency levels
enum RefillUrgency {
  critical, // Out of medication or will run out today
  high,     // Will run out in 1-3 days
  medium,   // Will run out in 4-7 days
  low,      // Will run out in 8-14 days
  none,     // More than 14 days remaining
  unknown,  // Cannot calculate (missing data)
}

/// Exception for refill reminder service errors
class RefillReminderServiceException implements Exception {
  final String message;

  const RefillReminderServiceException(this.message);

  @override
  String toString() => 'RefillReminderServiceException: $message';
}

