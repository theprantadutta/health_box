import 'package:drift/drift.dart';

class Vaccinations extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType =>
      text().withDefault(const Constant('vaccination')).named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();

  // Vaccination-specific fields
  TextColumn get vaccineName =>
      text().withLength(min: 1, max: 100).named('vaccine_name')();
  TextColumn get manufacturer => text().nullable().named('manufacturer')();
  TextColumn get batchNumber => text().nullable().named('batch_number')();
  DateTimeColumn get administrationDate =>
      dateTime().named('administration_date')();
  TextColumn get administeredBy => text().nullable().named('administered_by')();
  TextColumn get site => text().nullable().named('site')();
  DateTimeColumn get nextDueDate =>
      dateTime().nullable().named('next_due_date')();
  IntColumn get doseNumber => integer().nullable().named('dose_number')();
  BoolColumn get isComplete =>
      boolean().withDefault(const Constant(false)).named('is_complete')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    // Title constraint (non-empty)
    'CHECK (LENGTH(TRIM(title)) > 0)',

    // Vaccine name constraint (non-empty)
    'CHECK (LENGTH(TRIM(vaccine_name)) > 0)',

    // Dose number constraint (positive)
    'CHECK (dose_number IS NULL OR dose_number > 0)',

    // Administration date constraint (not too far in the future)
    'CHECK (administration_date <= DATE(\'now\', \'+7 days\'))',

    // Next due date constraint (after administration date)
    'CHECK (next_due_date IS NULL OR next_due_date > administration_date)',

    // Record date should match or be after administration date
    'CHECK (record_date >= administration_date)',
  ];
}

// Common vaccination sites
class VaccinationSites {
  static const String leftArmDeltoid = 'Left arm (deltoid)';
  static const String rightArmDeltoid = 'Right arm (deltoid)';
  static const String leftThigh = 'Left thigh';
  static const String rightThigh = 'Right thigh';
  static const String oral = 'Oral';
  static const String nasalSpray = 'Nasal spray';

  static const List<String> allSites = [
    leftArmDeltoid,
    rightArmDeltoid,
    leftThigh,
    rightThigh,
    oral,
    nasalSpray,
  ];
}

// Common vaccine manufacturers
class VaccineManufacturers {
  static const String pfizer = 'Pfizer';
  static const String moderna = 'Moderna';
  static const String johnsonAndJohnson = 'Johnson & Johnson';
  static const String astraZeneca = 'AstraZeneca';
  static const String novavax = 'Novavax';
  static const String gsk = 'GSK';
  static const String merck = 'Merck';
  static const String sanofi = 'Sanofi';

  static const List<String> allManufacturers = [
    pfizer,
    moderna,
    johnsonAndJohnson,
    astraZeneca,
    novavax,
    gsk,
    merck,
    sanofi,
  ];
}
