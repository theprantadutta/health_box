import 'package:drift/drift.dart';
import '../database/app_database.dart';

class ReminderDao {
  final AppDatabase _database;

  ReminderDao(this._database);

  Future<List<Reminder>> getAllReminders() async {
    return await (_database.select(_database.reminders)
          ..where((reminder) => reminder.isActive.equals(true))
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.scheduledTime),
          ]))
        .get();
  }

  Future<List<Reminder>> getActiveReminders() async {
    final now = DateTime.now();
    return await (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & 
              reminder.nextScheduled.isNotNull() &
              reminder.nextScheduled.isBiggerThanValue(now))
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.nextScheduled),
          ]))
        .get();
  }

  Future<List<Reminder>> getUpcomingReminders({Duration? within}) async {
    final now = DateTime.now();
    final endTime = within != null ? now.add(within) : now.add(const Duration(hours: 24));

    return await (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & 
              reminder.nextScheduled.isNotNull() &
              reminder.nextScheduled.isBetweenValues(now, endTime))
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.nextScheduled),
          ]))
        .get();
  }

  Future<List<Reminder>> getOverdueReminders() async {
    final now = DateTime.now();
    return await (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & 
              reminder.scheduledTime.isSmallerThanValue(now) &
              (reminder.lastSent.isNull() | 
               reminder.lastSent.isSmallerThan(reminder.scheduledTime)))
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.scheduledTime),
          ]))
        .get();
  }

  Future<List<Reminder>> getMedicationReminders() async {
    return await (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & 
              reminder.medicationId.isNotNull())
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.scheduledTime),
          ]))
        .get();
  }

  Future<List<Reminder>> getRemindersByFrequency(String frequency) async {
    return await (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & 
              reminder.frequency.equals(frequency))
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.scheduledTime),
          ]))
        .get();
  }

  Future<Reminder?> getReminderById(String id) async {
    return await (_database.select(_database.reminders)
          ..where((reminder) => reminder.id.equals(id) & reminder.isActive.equals(true)))
        .getSingleOrNull();
  }

  Future<List<Reminder>> getRemindersByMedication(String medicationId) async {
    return await (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & 
              reminder.medicationId.equals(medicationId))
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.scheduledTime),
          ]))
        .get();
  }

  Future<List<Reminder>> searchReminders(String searchTerm) async {
    final searchPattern = '%${searchTerm.toLowerCase()}%';
    
    return await (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & (
                reminder.title.lower().like(searchPattern) |
                reminder.description.lower().like(searchPattern)
              ))
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.scheduledTime),
          ]))
        .get();
  }

  Future<List<Reminder>> getRemindersByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) async {
    return await (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & 
              reminder.scheduledTime.isBetweenValues(startDate, endDate))
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.scheduledTime),
          ]))
        .get();
  }

  Future<List<Reminder>> getTodaysReminders() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & 
              reminder.scheduledTime.isBetweenValues(startOfDay, endOfDay))
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.scheduledTime),
          ]))
        .get();
  }

  Future<List<Reminder>> getDailyReminders() async {
    return await (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & 
              reminder.frequency.equals('daily'))
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.scheduledTime),
          ]))
        .get();
  }

  Future<List<Reminder>> getWeeklyReminders() async {
    return await (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & 
              reminder.frequency.equals('weekly'))
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.scheduledTime),
          ]))
        .get();
  }

  Future<List<Reminder>> getMonthlyReminders() async {
    return await (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & 
              reminder.frequency.equals('monthly'))
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.scheduledTime),
          ]))
        .get();
  }

  Future<String> createReminder(RemindersCompanion reminder) async {
    await _database.into(_database.reminders).insert(reminder);
    return reminder.id.value;
  }

  Future<bool> updateReminder(String id, RemindersCompanion reminder) async {
    final rowsAffected = await (_database.update(_database.reminders)
          ..where((r) => r.id.equals(id)))
        .write(reminder);
    
    return rowsAffected > 0;
  }

  Future<bool> markReminderSent(String id, {DateTime? sentTime}) async {
    final now = sentTime ?? DateTime.now();
    final rowsAffected = await (_database.update(_database.reminders)
          ..where((r) => r.id.equals(id)))
        .write(RemindersCompanion(
          lastSent: Value(now),
        ));
    
    return rowsAffected > 0;
  }

  Future<bool> updateNextScheduledTime(String id, DateTime nextTime) async {
    final rowsAffected = await (_database.update(_database.reminders)
          ..where((r) => r.id.equals(id)))
        .write(RemindersCompanion(
          nextScheduled: Value(nextTime),
        ));
    
    return rowsAffected > 0;
  }

  Future<bool> snoozeReminder(String id, {int? customMinutes}) async {
    final reminder = await getReminderById(id);
    if (reminder == null) return false;

    final snoozeMinutes = customMinutes ?? reminder.snoozeMinutes;
    final newScheduledTime = DateTime.now().add(Duration(minutes: snoozeMinutes));

    final rowsAffected = await (_database.update(_database.reminders)
          ..where((r) => r.id.equals(id)))
        .write(RemindersCompanion(
          scheduledTime: Value(newScheduledTime),
          nextScheduled: Value(newScheduledTime),
        ));
    
    return rowsAffected > 0;
  }

  Future<bool> deleteReminder(String id) async {
    final rowsAffected = await (_database.update(_database.reminders)
          ..where((r) => r.id.equals(id)))
        .write(const RemindersCompanion(
          isActive: Value(false),
        ));
    
    return rowsAffected > 0;
  }

  Future<bool> permanentlyDeleteReminder(String id) async {
    final rowsAffected = await (_database.delete(_database.reminders)
          ..where((r) => r.id.equals(id)))
        .go();
    
    return rowsAffected > 0;
  }

  Future<bool> toggleReminderActive(String id, bool isActive) async {
    final rowsAffected = await (_database.update(_database.reminders)
          ..where((r) => r.id.equals(id)))
        .write(RemindersCompanion(
          isActive: Value(isActive),
        ));
    
    return rowsAffected > 0;
  }

  Future<int> getActiveReminderCount() async {
    final query = _database.selectOnly(_database.reminders)
      ..addColumns([_database.reminders.id.count()])
      ..where(_database.reminders.isActive.equals(true));

    final result = await query.getSingle();
    return result.read(_database.reminders.id.count()) ?? 0;
  }

  Future<int> getOverdueReminderCount() async {
    final now = DateTime.now();
    final query = _database.selectOnly(_database.reminders)
      ..addColumns([_database.reminders.id.count()])
      ..where(_database.reminders.isActive.equals(true) & 
              _database.reminders.scheduledTime.isSmallerThanValue(now) &
              (_database.reminders.lastSent.isNull() | 
               _database.reminders.lastSent.isSmallerThan(_database.reminders.scheduledTime)));

    final result = await query.getSingle();
    return result.read(_database.reminders.id.count()) ?? 0;
  }

  Future<Map<String, int>> getReminderCountsByFrequency() async {
    final query = _database.selectOnly(_database.reminders)
      ..addColumns([
        _database.reminders.frequency,
        _database.reminders.id.count(),
      ])
      ..where(_database.reminders.isActive.equals(true))
      ..groupBy([_database.reminders.frequency]);

    final results = await query.get();
    final Map<String, int> counts = {};

    for (final result in results) {
      final frequency = result.read(_database.reminders.frequency)!;
      final count = result.read(_database.reminders.id.count()) ?? 0;
      counts[frequency] = count;
    }

    return counts;
  }

  Future<List<Reminder>> getRecentReminders({int limit = 10}) async {
    return await (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & 
              reminder.lastSent.isNotNull())
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.lastSent, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }

  Future<bool> reminderExists(String id) async {
    final count = await (_database.selectOnly(_database.reminders)
          ..addColumns([_database.reminders.id.count()])
          ..where(_database.reminders.id.equals(id) & 
                  _database.reminders.isActive.equals(true)))
        .getSingle();

    return (count.read(_database.reminders.id.count()) ?? 0) > 0;
  }

  // Bulk operations
  Future<int> deleteRemindersByMedication(String medicationId) async {
    return await (_database.update(_database.reminders)
          ..where((r) => r.medicationId.equals(medicationId)))
        .write(const RemindersCompanion(
          isActive: Value(false),
        ));
  }

  Future<int> updateReminderSchedules(List<String> reminderIds, DateTime newTime) async {
    return await (_database.update(_database.reminders)
          ..where((r) => r.id.isIn(reminderIds)))
        .write(RemindersCompanion(
          scheduledTime: Value(newTime),
          nextScheduled: Value(newTime),
        ));
  }

  // Stream operations for real-time updates
  Stream<List<Reminder>> watchActiveReminders() {
    final now = DateTime.now();
    return (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & 
              reminder.nextScheduled.isNotNull() &
              reminder.nextScheduled.isBiggerThanValue(now))
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.nextScheduled),
          ]))
        .watch();
  }

  Stream<List<Reminder>> watchUpcomingReminders({Duration? within}) {
    final now = DateTime.now();
    final endTime = within != null ? now.add(within) : now.add(const Duration(hours: 24));

    return (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & 
              reminder.nextScheduled.isNotNull() &
              reminder.nextScheduled.isBetweenValues(now, endTime))
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.nextScheduled),
          ]))
        .watch();
  }

  Stream<List<Reminder>> watchMedicationReminders(String medicationId) {
    return (_database.select(_database.reminders)
          ..where((reminder) => 
              reminder.isActive.equals(true) & 
              reminder.medicationId.equals(medicationId))
          ..orderBy([
            (reminder) => OrderingTerm(expression: reminder.scheduledTime),
          ]))
        .watch();
  }

  Stream<Reminder?> watchReminder(String id) {
    return (_database.select(_database.reminders)
          ..where((reminder) => reminder.id.equals(id) & reminder.isActive.equals(true)))
        .watchSingleOrNull();
  }

  Stream<int> watchOverdueReminderCount() {
    final now = DateTime.now();
    final query = _database.selectOnly(_database.reminders)
      ..addColumns([_database.reminders.id.count()])
      ..where(_database.reminders.isActive.equals(true) & 
              _database.reminders.scheduledTime.isSmallerThanValue(now) &
              (_database.reminders.lastSent.isNull() | 
               _database.reminders.lastSent.isSmallerThan(_database.reminders.scheduledTime)));

    return query.watchSingle().map((result) => result.read(_database.reminders.id.count()) ?? 0);
  }
}