import 'package:drift/drift.dart';

class HospitalAdmissions extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType =>
      text().withDefault(const Constant('hospital_admission')).named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();

  // Hospital Admission-specific fields
  TextColumn get hospital =>
      text().withLength(min: 1, max: 150).named('hospital')();
  TextColumn get admittingPhysician =>
      text().nullable().named('admitting_physician')();
  TextColumn get department => text().nullable().named('department')();
  DateTimeColumn get admissionDate => dateTime().named('admission_date')();
  DateTimeColumn get dischargeDate =>
      dateTime().nullable().named('discharge_date')();
  TextColumn get admissionType => text().named('admission_type')();
  TextColumn get chiefComplaint => text().nullable().named('chief_complaint')();
  TextColumn get reasonForAdmission =>
      text().nullable().named('reason_for_admission')();
  TextColumn get presentingSymptoms =>
      text().nullable().named('presenting_symptoms')();
  TextColumn get vitalSigns => text().nullable().named('vital_signs')();
  TextColumn get initialDiagnosis =>
      text().nullable().named('initial_diagnosis')();
  TextColumn get workingDiagnosis =>
      text().nullable().named('working_diagnosis')();
  TextColumn get treatmentPlan => text().nullable().named('treatment_plan')();
  TextColumn get medicationsOnAdmission =>
      text().nullable().named('medications_on_admission')(); // JSON array
  TextColumn get allergiesNoted =>
      text().nullable().named('allergies_noted')(); // JSON array
  TextColumn get emergencyContact =>
      text().nullable().named('emergency_contact')();
  TextColumn get insuranceInformation =>
      text().nullable().named('insurance_information')();
  BoolColumn get isEmergencyAdmission =>
      boolean().withDefault(const Constant(false)).named('is_emergency_admission')();
  TextColumn get referringPhysician =>
      text().nullable().named('referring_physician')();
  TextColumn get roomNumber => text().nullable().named('room_number')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(title)) > 0)',
    'CHECK (LENGTH(TRIM(hospital)) > 0)',
    'CHECK (admission_type IN (\'emergency\', \'elective\', \'urgent\', \'observation\', \'transfer\'))',
    'CHECK (admission_date <= CURRENT_TIMESTAMP)',
    'CHECK (discharge_date IS NULL OR discharge_date >= admission_date)',
  ];
}

// Admission types
class AdmissionTypes {
  static const String emergency = 'emergency';
  static const String elective = 'elective';
  static const String urgent = 'urgent';
  static const String observation = 'observation';
  static const String transfer = 'transfer';

  static const List<String> allTypes = [
    emergency,
    elective,
    urgent,
    observation,
    transfer,
  ];

  static String getDisplayName(String type) {
    switch (type) {
      case emergency:
        return 'Emergency';
      case elective:
        return 'Elective';
      case urgent:
        return 'Urgent';
      case observation:
        return 'Observation';
      case transfer:
        return 'Transfer';
      default:
        return type;
    }
  }
}

// Common chief complaints
class ChiefComplaints {
  static const String chestPain = 'Chest Pain';
  static const String shortnessOfBreath = 'Shortness of Breath';
  static const String abdominalPain = 'Abdominal Pain';
  static const String fever = 'Fever';
  static const String nausea = 'Nausea/Vomiting';
  static const String headache = 'Headache';
  static const String dizziness = 'Dizziness';
  static const String weakness = 'Weakness';
  static const String confusion = 'Confusion';
  static const String trauma = 'Trauma/Injury';
  static const String bleeding = 'Bleeding';
  static const String seizure = 'Seizure';
  static const String syncope = 'Syncope/Fainting';
  static const String rash = 'Rash';

  static const List<String> allComplaints = [
    chestPain,
    shortnessOfBreath,
    abdominalPain,
    fever,
    nausea,
    headache,
    dizziness,
    weakness,
    confusion,
    trauma,
    bleeding,
    seizure,
    syncope,
    rash,
  ];
}

// Hospital departments (reusing from discharge_summary)
class AdmissionDepartments {
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