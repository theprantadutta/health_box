import 'package:drift/drift.dart';

class EmergencyCards extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get criticalAllergies => text().named('critical_allergies')(); // JSON array
  TextColumn get currentMedications => text().named('current_medications')(); // JSON array
  TextColumn get medicalConditions => text().named('medical_conditions')(); // JSON array
  TextColumn get emergencyContact => text().nullable().named('emergency_contact')();
  TextColumn get secondaryContact => text().nullable().named('secondary_contact')();
  TextColumn get insuranceInfo => text().nullable().named('insurance_info')();
  TextColumn get additionalNotes => text().nullable().named('additional_notes')();
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime).named('last_updated')();
  BoolColumn get isActive => boolean().withDefault(const Constant(true)).named('is_active')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(critical_allergies)) >= 2)', // At least "[]"
    'CHECK (LENGTH(TRIM(current_medications)) >= 2)', // At least "[]"
    'CHECK (LENGTH(TRIM(medical_conditions)) >= 2)', // At least "[]"
  ];
}

