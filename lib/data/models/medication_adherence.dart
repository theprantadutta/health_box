import 'package:drift/drift.dart';

/// Table for tracking medication adherence records
class MedicationAdherence extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get reminderId => text().named('reminder_id')();
  TextColumn get medicationId => text().named('medication_id')();
  TextColumn get profileId => text().named('profile_id')();

  // Medication details at time of adherence record
  TextColumn get medicationName => text().named('medication_name')();
  TextColumn get dosage => text().named('dosage')();

  // Adherence tracking
  DateTimeColumn get scheduledTime => dateTime().named('scheduled_time')();
  DateTimeColumn get recordedTime => dateTime().named('recorded_time')();
  TextColumn get status => text().named('status')();

  // Optional notes from user
  TextColumn get notes => text().nullable().named('notes')();

  // Metadata
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(reminder_id)) > 0)',
    'CHECK (LENGTH(TRIM(medication_id)) > 0)',
    'CHECK (LENGTH(TRIM(profile_id)) > 0)',
    'CHECK (LENGTH(TRIM(medication_name)) > 0)',
    'CHECK (LENGTH(TRIM(dosage)) > 0)',
    'CHECK (status IN (\'taken\', \'taken_late\', \'missed\', \'skipped\', \'rescheduled\'))',
    'CHECK (recorded_time >= scheduled_time OR status IN (\'missed\', \'skipped\'))',
  ];
}

/// Constants for medication adherence status
class MedicationAdherenceStatus {
  static const String taken = 'taken';
  static const String takenLate = 'taken_late';
  static const String missed = 'missed';
  static const String skipped = 'skipped';
  static const String rescheduled = 'rescheduled';

  static const List<String> allStatuses = [
    taken,
    takenLate,
    missed,
    skipped,
    rescheduled,
  ];

  static bool isValidStatus(String status) {
    return allStatuses.contains(status);
  }

  static String getDisplayName(String status) {
    switch (status) {
      case taken:
        return 'Taken on Time';
      case takenLate:
        return 'Taken Late';
      case missed:
        return 'Missed';
      case skipped:
        return 'Skipped';
      case rescheduled:
        return 'Rescheduled';
      default:
        return status;
    }
  }

  static bool isPositiveAdherence(String status) {
    return status == taken || status == takenLate;
  }
}