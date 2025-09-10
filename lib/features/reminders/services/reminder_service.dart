import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/reminder_dao.dart';

class ReminderService {
  final ReminderDao _reminderDao;

  ReminderService({
    ReminderDao? reminderDao,
    AppDatabase? database,
  })  : _reminderDao = reminderDao ?? ReminderDao(database ?? AppDatabase.instance);

  // CRUD Operations

  Future<List<Reminder>> getAllReminders() async {
    try {
      return await _reminderDao.getAllReminders();
    } catch (e) {
      throw ReminderServiceException('Failed to retrieve reminders: ${e.toString()}');
    }
  }

  Future<List<Reminder>> getActiveReminders() async {
    try {
      return await _reminderDao.getActiveReminders();
    } catch (e) {
      throw ReminderServiceException('Failed to retrieve active reminders: ${e.toString()}');
    }
  }

  Future<List<Reminder>> getUpcomingReminders({Duration? within}) async {
    try {
      return await _reminderDao.getUpcomingReminders(within: within);
    } catch (e) {
      throw ReminderServiceException('Failed to retrieve upcoming reminders: ${e.toString()}');
    }
  }

  Future<List<Reminder>> getOverdueReminders() async {
    try {
      return await _reminderDao.getOverdueReminders();
    } catch (e) {
      throw ReminderServiceException('Failed to retrieve overdue reminders: ${e.toString()}');
    }
  }

  Future<Reminder?> getReminderById(String id) async {
    try {
      if (id.isEmpty) {
        throw const ReminderServiceException('Reminder ID cannot be empty');
      }
      return await _reminderDao.getReminderById(id);
    } catch (e) {
      if (e is ReminderServiceException) rethrow;
      throw ReminderServiceException('Failed to retrieve reminder: ${e.toString()}');
    }
  }

  Future<String> createReminder(CreateReminderRequest request) async {
    try {
      _validateCreateReminderRequest(request);
      
      final reminderId = 'reminder_${DateTime.now().millisecondsSinceEpoch}';
      final reminderCompanion = RemindersCompanion(
        id: Value(reminderId),
        medicationId: Value(request.medicationId),
        title: Value(request.title.trim()),
        description: Value(request.description?.trim()),
        scheduledTime: Value(request.scheduledTime),
        frequency: Value(request.frequency),
        daysOfWeek: Value(request.daysOfWeek),
        timeSlots: Value(request.timeSlots),
        isActive: Value(request.isActive),
        nextScheduled: Value(_calculateNextScheduledTime(request.scheduledTime, request.frequency)),
        snoozeMinutes: Value(request.snoozeMinutes),
      );

      return await _reminderDao.createReminder(reminderCompanion);
    } catch (e) {
      if (e is ReminderServiceException) rethrow;
      throw ReminderServiceException('Failed to create reminder: ${e.toString()}');
    }
  }

  Future<bool> updateReminder(String id, UpdateReminderRequest request) async {
    try {
      if (id.isEmpty) {
        throw const ReminderServiceException('Reminder ID cannot be empty');
      }

      final existingReminder = await _reminderDao.getReminderById(id);
      if (existingReminder == null) {
        throw const ReminderServiceException('Reminder not found');
      }

      _validateUpdateReminderRequest(request);

      final reminderCompanion = RemindersCompanion(
        title: request.title != null ? Value(request.title!.trim()) : const Value.absent(),
        description: request.description != null ? Value(request.description?.trim()) : const Value.absent(),
        scheduledTime: request.scheduledTime != null ? Value(request.scheduledTime!) : const Value.absent(),
        frequency: request.frequency != null ? Value(request.frequency!) : const Value.absent(),
        daysOfWeek: request.daysOfWeek != null ? Value(request.daysOfWeek) : const Value.absent(),
        timeSlots: request.timeSlots != null ? Value(request.timeSlots) : const Value.absent(),
        isActive: request.isActive != null ? Value(request.isActive!) : const Value.absent(),
        snoozeMinutes: request.snoozeMinutes != null ? Value(request.snoozeMinutes!) : const Value.absent(),
        nextScheduled: request.scheduledTime != null && request.frequency != null 
          ? Value(_calculateNextScheduledTime(request.scheduledTime!, request.frequency!))
          : const Value.absent(),
      );

      return await _reminderDao.updateReminder(id, reminderCompanion);
    } catch (e) {
      if (e is ReminderServiceException) rethrow;
      throw ReminderServiceException('Failed to update reminder: ${e.toString()}');
    }
  }

  Future<bool> deleteReminder(String id) async {
    try {
      if (id.isEmpty) {
        throw const ReminderServiceException('Reminder ID cannot be empty');
      }

      final existingReminder = await _reminderDao.getReminderById(id);
      if (existingReminder == null) {
        throw const ReminderServiceException('Reminder not found');
      }

      return await _reminderDao.deleteReminder(id);
    } catch (e) {
      if (e is ReminderServiceException) rethrow;
      throw ReminderServiceException('Failed to delete reminder: ${e.toString()}');
    }
  }

  // Reminder State Management

  Future<bool> markReminderSent(String id, {DateTime? sentTime}) async {
    try {
      if (id.isEmpty) {
        throw const ReminderServiceException('Reminder ID cannot be empty');
      }

      final reminder = await _reminderDao.getReminderById(id);
      if (reminder == null) {
        throw const ReminderServiceException('Reminder not found');
      }

      final success = await _reminderDao.markReminderSent(id, sentTime: sentTime);
      
      if (success && reminder.frequency != 'once') {
        // Schedule next occurrence for recurring reminders
        final nextTime = _calculateNextScheduledTime(reminder.scheduledTime, reminder.frequency);
        await _reminderDao.updateNextScheduledTime(id, nextTime);
      }

      return success;
    } catch (e) {
      if (e is ReminderServiceException) rethrow;
      throw ReminderServiceException('Failed to mark reminder as sent: ${e.toString()}');
    }
  }

  Future<bool> snoozeReminder(String id, {int? customMinutes}) async {
    try {
      if (id.isEmpty) {
        throw const ReminderServiceException('Reminder ID cannot be empty');
      }

      return await _reminderDao.snoozeReminder(id, customMinutes: customMinutes);
    } catch (e) {
      if (e is ReminderServiceException) rethrow;
      throw ReminderServiceException('Failed to snooze reminder: ${e.toString()}');
    }
  }

  Future<bool> toggleReminderActive(String id, bool isActive) async {
    try {
      if (id.isEmpty) {
        throw const ReminderServiceException('Reminder ID cannot be empty');
      }

      return await _reminderDao.toggleReminderActive(id, isActive);
    } catch (e) {
      if (e is ReminderServiceException) rethrow;
      throw ReminderServiceException('Failed to toggle reminder active state: ${e.toString()}');
    }
  }

  Future<bool> rescheduleReminder(String id, DateTime newTime) async {
    try {
      if (id.isEmpty) {
        throw const ReminderServiceException('Reminder ID cannot be empty');
      }
      if (newTime.isBefore(DateTime.now())) {
        throw const ReminderServiceException('Cannot reschedule reminder to past time');
      }

      final reminder = await _reminderDao.getReminderById(id);
      if (reminder == null) {
        throw const ReminderServiceException('Reminder not found');
      }

      final reminderCompanion = RemindersCompanion(
        scheduledTime: Value(newTime),
        nextScheduled: Value(newTime),
      );

      return await _reminderDao.updateReminder(id, reminderCompanion);
    } catch (e) {
      if (e is ReminderServiceException) rethrow;
      throw ReminderServiceException('Failed to reschedule reminder: ${e.toString()}');
    }
  }

  // Query Operations

  Future<List<Reminder>> getMedicationReminders({String? medicationId}) async {
    try {
      if (medicationId != null) {
        return await _reminderDao.getRemindersByMedication(medicationId);
      } else {
        return await _reminderDao.getMedicationReminders();
      }
    } catch (e) {
      throw ReminderServiceException('Failed to retrieve medication reminders: ${e.toString()}');
    }
  }

  Future<List<Reminder>> getRemindersByFrequency(String frequency) async {
    try {
      if (!_isValidFrequency(frequency)) {
        throw ReminderServiceException('Invalid frequency: $frequency');
      }
      return await _reminderDao.getRemindersByFrequency(frequency);
    } catch (e) {
      if (e is ReminderServiceException) rethrow;
      throw ReminderServiceException('Failed to retrieve reminders by frequency: ${e.toString()}');
    }
  }

  Future<List<Reminder>> getTodaysReminders() async {
    try {
      return await _reminderDao.getTodaysReminders();
    } catch (e) {
      throw ReminderServiceException('Failed to retrieve today\'s reminders: ${e.toString()}');
    }
  }

  Future<List<Reminder>> searchReminders(String searchTerm) async {
    try {
      if (searchTerm.isEmpty) {
        return await getAllReminders();
      }
      return await _reminderDao.searchReminders(searchTerm);
    } catch (e) {
      throw ReminderServiceException('Failed to search reminders: ${e.toString()}');
    }
  }

  // Analytics and Statistics

  Future<int> getActiveReminderCount() async {
    try {
      return await _reminderDao.getActiveReminderCount();
    } catch (e) {
      throw ReminderServiceException('Failed to retrieve active reminder count: ${e.toString()}');
    }
  }

  Future<int> getOverdueReminderCount() async {
    try {
      return await _reminderDao.getOverdueReminderCount();
    } catch (e) {
      throw ReminderServiceException('Failed to retrieve overdue reminder count: ${e.toString()}');
    }
  }

  Future<Map<String, int>> getReminderCountsByFrequency() async {
    try {
      return await _reminderDao.getReminderCountsByFrequency();
    } catch (e) {
      throw ReminderServiceException('Failed to retrieve reminder counts by frequency: ${e.toString()}');
    }
  }

  Future<ReminderStatistics> getReminderStatistics() async {
    try {
      final activeCount = await getActiveReminderCount();
      final overdueCount = await getOverdueReminderCount();
      final upcomingToday = await getTodaysReminders();
      final frequencyCounts = await getReminderCountsByFrequency();

      return ReminderStatistics(
        totalActiveReminders: activeCount,
        overdueReminders: overdueCount,
        todaysReminders: upcomingToday.length,
        reminderCountsByFrequency: frequencyCounts,
      );
    } catch (e) {
      throw ReminderServiceException('Failed to retrieve reminder statistics: ${e.toString()}');
    }
  }

  // Bulk Operations

  Future<int> bulkDeleteReminders(List<String> reminderIds) async {
    try {
      int deletedCount = 0;
      for (final id in reminderIds) {
        if (await deleteReminder(id)) {
          deletedCount++;
        }
      }
      return deletedCount;
    } catch (e) {
      throw ReminderServiceException('Failed to bulk delete reminders: ${e.toString()}');
    }
  }

  Future<int> bulkToggleReminders(List<String> reminderIds, bool isActive) async {
    try {
      int updatedCount = 0;
      for (final id in reminderIds) {
        if (await toggleReminderActive(id, isActive)) {
          updatedCount++;
        }
      }
      return updatedCount;
    } catch (e) {
      throw ReminderServiceException('Failed to bulk toggle reminders: ${e.toString()}');
    }
  }

  Future<int> bulkSnoozeReminders(List<String> reminderIds, {int? customMinutes}) async {
    try {
      int snoozedCount = 0;
      for (final id in reminderIds) {
        if (await snoozeReminder(id, customMinutes: customMinutes)) {
          snoozedCount++;
        }
      }
      return snoozedCount;
    } catch (e) {
      throw ReminderServiceException('Failed to bulk snooze reminders: ${e.toString()}');
    }
  }

  // Stream Operations

  Stream<List<Reminder>> watchActiveReminders() {
    return _reminderDao.watchActiveReminders();
  }

  Stream<List<Reminder>> watchUpcomingReminders({Duration? within}) {
    return _reminderDao.watchUpcomingReminders(within: within);
  }

  Stream<Reminder?> watchReminder(String id) {
    return _reminderDao.watchReminder(id);
  }

  Stream<int> watchOverdueReminderCount() {
    return _reminderDao.watchOverdueReminderCount();
  }

  // Utility Methods

  Future<bool> reminderExists(String id) async {
    try {
      if (id.isEmpty) return false;
      return await _reminderDao.reminderExists(id);
    } catch (e) {
      return false;
    }
  }

  bool isOverdue(Reminder reminder) {
    return reminder.scheduledTime.isBefore(DateTime.now()) &&
        (reminder.lastSent == null || reminder.lastSent!.isBefore(reminder.scheduledTime));
  }

  bool isUpcoming(Reminder reminder, {Duration within = const Duration(hours: 24)}) {
    final now = DateTime.now();
    final endTime = now.add(within);
    return reminder.nextScheduled != null &&
        reminder.nextScheduled!.isAfter(now) &&
        reminder.nextScheduled!.isBefore(endTime);
  }

  List<String> getValidFrequencies() {
    return ['once', 'daily', 'weekly', 'monthly'];
  }

  // Private Helper Methods

  DateTime _calculateNextScheduledTime(DateTime currentTime, String frequency) {
    switch (frequency) {
      case 'once':
        return currentTime;
      case 'daily':
        return currentTime.add(const Duration(days: 1));
      case 'weekly':
        return currentTime.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(currentTime.year, currentTime.month + 1, currentTime.day,
            currentTime.hour, currentTime.minute);
      default:
        return currentTime;
    }
  }

  void _validateCreateReminderRequest(CreateReminderRequest request) {
    if (request.title.trim().isEmpty) {
      throw const ReminderServiceException('Title cannot be empty');
    }
    if (!_isValidFrequency(request.frequency)) {
      throw ReminderServiceException('Invalid frequency: ${request.frequency}');
    }
    if (request.snoozeMinutes < 0 || request.snoozeMinutes > 1440) {
      throw const ReminderServiceException('Snooze minutes must be between 0 and 1440 (24 hours)');
    }
  }

  void _validateUpdateReminderRequest(UpdateReminderRequest request) {
    if (request.title != null && request.title!.trim().isEmpty) {
      throw const ReminderServiceException('Title cannot be empty');
    }
    if (request.frequency != null && !_isValidFrequency(request.frequency!)) {
      throw ReminderServiceException('Invalid frequency: ${request.frequency}');
    }
    if (request.snoozeMinutes != null &&
        (request.snoozeMinutes! < 0 || request.snoozeMinutes! > 1440)) {
      throw const ReminderServiceException('Snooze minutes must be between 0 and 1440 (24 hours)');
    }
  }

  bool _isValidFrequency(String frequency) {
    return ['once', 'daily', 'weekly', 'monthly'].contains(frequency);
  }
}

// Data Transfer Objects

class CreateReminderRequest {
  final String? medicationId;
  final String title;
  final String? description;
  final DateTime scheduledTime;
  final String frequency;
  final String? daysOfWeek;
  final String? timeSlots;
  final bool isActive;
  final int snoozeMinutes;

  const CreateReminderRequest({
    this.medicationId,
    required this.title,
    this.description,
    required this.scheduledTime,
    required this.frequency,
    this.daysOfWeek,
    this.timeSlots,
    this.isActive = true,
    this.snoozeMinutes = 15,
  });
}

class UpdateReminderRequest {
  final String? title;
  final String? description;
  final DateTime? scheduledTime;
  final String? frequency;
  final String? daysOfWeek;
  final String? timeSlots;
  final bool? isActive;
  final int? snoozeMinutes;

  const UpdateReminderRequest({
    this.title,
    this.description,
    this.scheduledTime,
    this.frequency,
    this.daysOfWeek,
    this.timeSlots,
    this.isActive,
    this.snoozeMinutes,
  });
}

class ReminderStatistics {
  final int totalActiveReminders;
  final int overdueReminders;
  final int todaysReminders;
  final Map<String, int> reminderCountsByFrequency;

  const ReminderStatistics({
    required this.totalActiveReminders,
    required this.overdueReminders,
    required this.todaysReminders,
    required this.reminderCountsByFrequency,
  });
}

// Exceptions

class ReminderServiceException implements Exception {
  final String message;
  
  const ReminderServiceException(this.message);
  
  @override
  String toString() => 'ReminderServiceException: $message';
}