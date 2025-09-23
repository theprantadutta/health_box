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
    'CHECK (record_type IN (\'prescription\', \'lab_report\', \'medication\', \'vaccination\', \'allergy\', \'chronic_condition\', \'surgical_record\', \'radiology_record\', \'pathology_record\', \'discharge_summary\', \'hospital_admission\', \'dental_record\', \'mental_health_record\', \'general_record\'))',

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
  static const String surgicalRecord = 'surgical_record';
  static const String radiologyRecord = 'radiology_record';
  static const String pathologyRecord = 'pathology_record';
  static const String dischargeSummary = 'discharge_summary';
  static const String hospitalAdmission = 'hospital_admission';
  static const String dentalRecord = 'dental_record';
  static const String mentalHealthRecord = 'mental_health_record';
  static const String generalRecord = 'general_record';

  static const List<String> allTypes = [
    prescription,
    labReport,
    medication,
    vaccination,
    allergy,
    chronicCondition,
    surgicalRecord,
    radiologyRecord,
    pathologyRecord,
    dischargeSummary,
    hospitalAdmission,
    dentalRecord,
    mentalHealthRecord,
    generalRecord,
  ];

  static bool isValidType(String type) {
    return allTypes.contains(type);
  }

  static String getDisplayName(String type) {
    switch (type) {
      case prescription:
        return 'Prescription/Appointment';
      case labReport:
        return 'Lab Report';
      case medication:
        return 'Medication';
      case vaccination:
        return 'Vaccination';
      case allergy:
        return 'Allergy';
      case chronicCondition:
        return 'Chronic Condition';
      case surgicalRecord:
        return 'Surgical/Procedure Record';
      case radiologyRecord:
        return 'Radiology/Imaging Report';
      case pathologyRecord:
        return 'Pathology Report';
      case dischargeSummary:
        return 'Discharge Summary';
      case hospitalAdmission:
        return 'Hospital Admission';
      case dentalRecord:
        return 'Dental Record';
      case mentalHealthRecord:
        return 'Mental Health Record';
      case generalRecord:
        return 'General Record';
      default:
        return type;
    }
  }
}
