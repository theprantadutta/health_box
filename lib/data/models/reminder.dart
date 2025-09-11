import 'package:drift/drift.dart';

class Reminders extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get recordId => text().nullable().named('record_id')(); // Reference to medical record
  TextColumn get medicationId => text().nullable().named('medication_id')(); // Optional reference to medication
  TextColumn get type => text().named('type')(); // Type of reminder (medication, appointment, etc.)
  TextColumn get title => text().named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get scheduledTime => dateTime().named('scheduled_time')();
  TextColumn get frequency => text().named('frequency')();
  TextColumn get daysOfWeek => text().nullable().named('days_of_week')(); // JSON array
  TextColumn get timeSlots => text().nullable().named('time_slots')(); // JSON array
  BoolColumn get isActive => boolean().withDefault(const Constant(true)).named('is_active')();
  DateTimeColumn get lastSent => dateTime().nullable().named('last_sent')();
  DateTimeColumn get nextScheduled => dateTime().nullable().named('next_scheduled')();
  IntColumn get snoozeMinutes => integer().withDefault(const Constant(15)).named('snooze_minutes')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(title)) > 0)',
    'CHECK (type IN (\'medication\', \'appointment\', \'lab_test\', \'vaccination\', \'general\'))',
    'CHECK (frequency IN (\'once\', \'daily\', \'weekly\', \'monthly\'))',
    'CHECK (snooze_minutes >= 0 AND snooze_minutes <= 1440)', // Max 24 hours
    'CHECK (last_sent IS NULL OR last_sent <= CURRENT_TIMESTAMP)',
  ];
}