import 'package:drift/drift.dart';

class MedicalRecords extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType => text().named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    // Record type constraint
    'CHECK (record_type IN (\'prescription\', \'lab_report\', \'medication\', \'vaccination\', \'allergy\', \'chronic_condition\'))',

    // Title constraint (non-empty)
    'CHECK (LENGTH(TRIM(title)) > 0)',

    // Record date constraint (not future date for most record types)
    'CHECK (record_date <= CURRENT_TIMESTAMP OR record_type = \'vaccination\')',
  ];
}

// Record type constants for type safety
class MedicalRecordType {
  static const String prescription = 'prescription';
  static const String labReport = 'lab_report';
  static const String medication = 'medication';
  static const String vaccination = 'vaccination';
  static const String allergy = 'allergy';
  static const String chronicCondition = 'chronic_condition';

  static const List<String> allTypes = [
    prescription,
    labReport,
    medication,
    vaccination,
    allergy,
    chronicCondition,
  ];

  static bool isValidType(String type) {
    return allTypes.contains(type);
  }
}
