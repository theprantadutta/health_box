import 'package:drift/drift.dart';

class Prescriptions extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType =>
      text().withDefault(const Constant('prescription')).named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();

  // Prescription-specific fields
  TextColumn get medicationName =>
      text().withLength(min: 1, max: 100).named('medication_name')();
  TextColumn get dosage => text().named('dosage')();
  TextColumn get frequency => text().named('frequency')();
  TextColumn get instructions => text().nullable().named('instructions')();
  TextColumn get prescribingDoctor =>
      text().nullable().named('prescribing_doctor')();
  TextColumn get pharmacy => text().nullable().named('pharmacy')();
  DateTimeColumn get startDate => dateTime().nullable().named('start_date')();
  DateTimeColumn get endDate => dateTime().nullable().named('end_date')();
  IntColumn get refillsRemaining =>
      integer().nullable().named('refills_remaining')();
  BoolColumn get isPrescriptionActive => boolean()
      .withDefault(const Constant(true))
      .named('is_prescription_active')();

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

    // Refills constraint (non-negative)
    'CHECK (refills_remaining IS NULL OR refills_remaining >= 0)',

    // Date range constraint (start_date <= end_date)
    'CHECK (start_date IS NULL OR end_date IS NULL OR start_date <= end_date)',
  ];
}
