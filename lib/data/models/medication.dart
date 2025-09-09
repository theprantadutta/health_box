import 'package:drift/drift.dart';

class Medications extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType => text().withDefault(const Constant('medication')).named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive => boolean().withDefault(const Constant(true)).named('is_active')();

  // Medication-specific fields
  TextColumn get medicationName => text().withLength(min: 1, max: 100).named('medication_name')();
  TextColumn get dosage => text().named('dosage')();
  TextColumn get frequency => text().named('frequency')();
  TextColumn get schedule => text().named('schedule')(); // JSON array of time slots
  DateTimeColumn get startDate => dateTime().named('start_date')();
  DateTimeColumn get endDate => dateTime().nullable().named('end_date')();
  TextColumn get instructions => text().nullable().named('instructions')();
  BoolColumn get reminderEnabled => boolean().withDefault(const Constant(true)).named('reminder_enabled')();
  IntColumn get pillCount => integer().nullable().named('pill_count')();
  TextColumn get status => text().named('status')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    // Title constraint (non-empty)
    'CHECK (LENGTH(TRIM(title)) > 0)',
    
    // Medication name constraint (non-empty)
    'CHECK (LENGTH(TRIM(medication_name)) > 0)',
    
    // Dosage constraint (non-empty)
    'CHECK (LENGTH(TRIM(dosage)) > 0)',
    
    // Frequency constraint (non-empty)
    'CHECK (LENGTH(TRIM(frequency)) > 0)',
    
    // Schedule constraint (valid JSON array)
    'CHECK (LENGTH(TRIM(schedule)) > 0)',
    
    // Status constraint
    'CHECK (status IN (\'active\', \'paused\', \'completed\', \'discontinued\'))',
    
    // Pill count constraint (non-negative)
    'CHECK (pill_count IS NULL OR pill_count >= 0)',
    
    // Date range constraint (start_date <= end_date)
    'CHECK (end_date IS NULL OR start_date <= end_date)',
    
    // Start date constraint (not too far in the past or future)
    'CHECK (start_date >= DATE(\'2020-01-01\') AND start_date <= DATE(\'now\', \'+1 year\'))',
  ];
}

// Medication status constants for type safety
class MedicationStatus {
  static const String active = 'active';
  static const String paused = 'paused';
  static const String completed = 'completed';
  static const String discontinued = 'discontinued';

  static const List<String> allStatuses = [
    active,
    paused,
    completed,
    discontinued,
  ];

  static bool isValidStatus(String status) {
    return allStatuses.contains(status);
  }
}