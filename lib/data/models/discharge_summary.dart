import 'package:drift/drift.dart';

class DischargeSummaries extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType =>
      text().withDefault(const Constant('discharge_summary')).named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();

  // Discharge Summary-specific fields
  TextColumn get hospital =>
      text().withLength(min: 1, max: 150).named('hospital')();
  TextColumn get attendingPhysician =>
      text().nullable().named('attending_physician')();
  TextColumn get department => text().nullable().named('department')();
  DateTimeColumn get admissionDate => dateTime().named('admission_date')();
  DateTimeColumn get dischargeDate => dateTime().named('discharge_date')();
  IntColumn get lengthOfStay => integer().nullable().named('length_of_stay')();
  TextColumn get admissionDiagnosis =>
      text().nullable().named('admission_diagnosis')();
  TextColumn get dischargeDiagnosis =>
      text().nullable().named('discharge_diagnosis')();
  TextColumn get principalDiagnosis =>
      text().nullable().named('principal_diagnosis')();
  TextColumn get secondaryDiagnoses =>
      text().nullable().named('secondary_diagnoses')(); // JSON array
  TextColumn get proceduresPerformed =>
      text().nullable().named('procedures_performed')(); // JSON array
  TextColumn get hospitalCourse => text().nullable().named('hospital_course')();
  TextColumn get dischargeCondition =>
      text().nullable().named('discharge_condition')();
  TextColumn get dischargeDestination =>
      text().nullable().named('discharge_destination')();
  TextColumn get dischargeMedications =>
      text().nullable().named('discharge_medications')(); // JSON array
  TextColumn get followUpInstructions =>
      text().nullable().named('follow_up_instructions')();
  TextColumn get dietInstructions =>
      text().nullable().named('diet_instructions')();
  TextColumn get activityRestrictions =>
      text().nullable().named('activity_restrictions')();
  DateTimeColumn get followUpDate =>
      dateTime().nullable().named('follow_up_date')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(title)) > 0)',
    'CHECK (LENGTH(TRIM(hospital)) > 0)',
    'CHECK (admission_date <= discharge_date)',
    'CHECK (discharge_date <= CURRENT_TIMESTAMP)',
    'CHECK (length_of_stay IS NULL OR length_of_stay >= 0)',
    'CHECK (follow_up_date IS NULL OR follow_up_date > discharge_date)',
  ];
}

// Common discharge destinations
class DischargeDestinations {
  static const String home = 'Home';
  static const String homeWithServices = 'Home with Services';
  static const String skilledNursing = 'Skilled Nursing Facility';
  static const String rehabilitation = 'Rehabilitation Facility';
  static const String longTermCare = 'Long-term Care Facility';
  static const String assistedLiving = 'Assisted Living';
  static const String hospice = 'Hospice Care';
  static const String anotherHospital = 'Another Hospital';
  static const String deceased = 'Deceased';
  static const String other = 'Other';

  static const List<String> allDestinations = [
    home,
    homeWithServices,
    skilledNursing,
    rehabilitation,
    longTermCare,
    assistedLiving,
    hospice,
    anotherHospital,
    deceased,
    other,
  ];
}

// Common discharge conditions
class DischargeConditions {
  static const String stable = 'Stable';
  static const String improved = 'Improved';
  static const String unchanged = 'Unchanged';
  static const String deteriorated = 'Deteriorated';
  static const String critical = 'Critical';
  static const String deceased = 'Deceased';

  static const List<String> allConditions = [
    stable,
    improved,
    unchanged,
    deteriorated,
    critical,
    deceased,
  ];
}

// Common hospital departments
class HospitalDepartments {
  static const String emergency = 'Emergency Department';
  static const String cardiology = 'Cardiology';
  static const String neurology = 'Neurology';
  static const String orthopedics = 'Orthopedics';
  static const String surgery = 'Surgery';
  static const String internal = 'Internal Medicine';
  static const String pediatrics = 'Pediatrics';
  static const String obstetrics = 'Obstetrics/Gynecology';
  static const String psychiatry = 'Psychiatry';
  static const String icu = 'Intensive Care Unit';
  static const String oncology = 'Oncology';
  static const String pulmonology = 'Pulmonology';
  static const String gastroenterology = 'Gastroenterology';
  static const String urology = 'Urology';
  static const String dermatology = 'Dermatology';

  static const List<String> allDepartments = [
    emergency,
    cardiology,
    neurology,
    orthopedics,
    surgery,
    internal,
    pediatrics,
    obstetrics,
    psychiatry,
    icu,
    oncology,
    pulmonology,
    gastroenterology,
    urology,
    dermatology,
  ];
}