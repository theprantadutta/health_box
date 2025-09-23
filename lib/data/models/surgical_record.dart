import 'package:drift/drift.dart';

class SurgicalRecords extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType =>
      text().withDefault(const Constant('surgical_record')).named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();

  // Surgical-specific fields
  TextColumn get procedureName =>
      text().withLength(min: 1, max: 150).named('procedure_name')();
  TextColumn get surgeonName => text().nullable().named('surgeon_name')();
  TextColumn get hospital => text().nullable().named('hospital')();
  TextColumn get operatingRoom => text().nullable().named('operating_room')();
  DateTimeColumn get surgeryDate => dateTime().named('surgery_date')();
  DateTimeColumn get surgeryStartTime =>
      dateTime().nullable().named('surgery_start_time')();
  DateTimeColumn get surgeryEndTime =>
      dateTime().nullable().named('surgery_end_time')();
  TextColumn get anesthesiaType => text().nullable().named('anesthesia_type')();
  TextColumn get anesthesiologist =>
      text().nullable().named('anesthesiologist')();
  TextColumn get indication => text().nullable().named('indication')();
  TextColumn get findings => text().nullable().named('findings')();
  TextColumn get complications => text().nullable().named('complications')();
  TextColumn get recoveryNotes => text().nullable().named('recovery_notes')();
  TextColumn get followUpPlan => text().nullable().named('follow_up_plan')();
  DateTimeColumn get dischargeDate =>
      dateTime().nullable().named('discharge_date')();
  BoolColumn get isEmergency =>
      boolean().withDefault(const Constant(false)).named('is_emergency')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(title)) > 0)',
    'CHECK (LENGTH(TRIM(procedure_name)) > 0)',
    'CHECK (surgery_date <= CURRENT_TIMESTAMP)',
    'CHECK (surgery_start_time IS NULL OR surgery_end_time IS NULL OR surgery_start_time <= surgery_end_time)',
    'CHECK (discharge_date IS NULL OR discharge_date >= surgery_date)',
  ];
}

// Common anesthesia types
class AnesthesiaTypes {
  static const String general = 'General';
  static const String spinal = 'Spinal';
  static const String epidural = 'Epidural';
  static const String local = 'Local';
  static const String sedation = 'Conscious Sedation';
  static const String regionalBlock = 'Regional Block';
  static const String none = 'None';

  static const List<String> allTypes = [
    general,
    spinal,
    epidural,
    local,
    sedation,
    regionalBlock,
    none,
  ];
}

// Common surgical procedure categories
class SurgicalCategories {
  static const String cardiovascular = 'Cardiovascular';
  static const String orthopedic = 'Orthopedic';
  static const String neurological = 'Neurological';
  static const String gastrointestinal = 'Gastrointestinal';
  static const String urological = 'Urological';
  static const String gynecological = 'Gynecological';
  static const String dermatological = 'Dermatological';
  static const String ophthalmological = 'Ophthalmological';
  static const String dental = 'Dental/Oral';
  static const String cosmetic = 'Cosmetic/Plastic';
  static const String emergency = 'Emergency';
  static const String other = 'Other';

  static const List<String> allCategories = [
    cardiovascular,
    orthopedic,
    neurological,
    gastrointestinal,
    urological,
    gynecological,
    dermatological,
    ophthalmological,
    dental,
    cosmetic,
    emergency,
    other,
  ];
}