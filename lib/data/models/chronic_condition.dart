import 'package:drift/drift.dart';

class ChronicConditions extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType => text().withDefault(const Constant('chronic_condition')).named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive => boolean().withDefault(const Constant(true)).named('is_active')();

  // ChronicCondition-specific fields
  TextColumn get conditionName => text().withLength(min: 1, max: 100).named('condition_name')();
  DateTimeColumn get diagnosisDate => dateTime().named('diagnosis_date')();
  TextColumn get diagnosingProvider => text().nullable().named('diagnosing_provider')();
  TextColumn get severity => text().named('severity')();
  TextColumn get status => text().named('status')();
  TextColumn get treatment => text().nullable().named('treatment')();
  TextColumn get managementPlan => text().nullable().named('management_plan')();
  TextColumn get relatedMedications => text().nullable().named('related_medications')(); // JSON array

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(title)) > 0)',
    'CHECK (LENGTH(TRIM(condition_name)) > 0)',
    'CHECK (severity IN (\'mild\', \'moderate\', \'severe\'))',
    'CHECK (status IN (\'active\', \'managed\', \'resolved\'))',
    'CHECK (diagnosis_date <= CURRENT_TIMESTAMP)',
  ];
}

// Chronic condition severity levels
class ConditionSeverity {
  static const String mild = 'mild';
  static const String moderate = 'moderate';
  static const String severe = 'severe';

  static const List<String> allSeverities = [
    mild,
    moderate,
    severe,
  ];

  static bool isValidSeverity(String severity) {
    return allSeverities.contains(severity);
  }
}

// Chronic condition status types
class ConditionStatus {
  static const String active = 'active';
  static const String managed = 'managed';
  static const String resolved = 'resolved';

  static const List<String> allStatuses = [
    active,
    managed,
    resolved,
  ];

  static bool isValidStatus(String status) {
    return allStatuses.contains(status);
  }
}

// Common chronic condition categories
class ConditionCategories {
  static const String cardiovascular = 'Cardiovascular';
  static const String respiratory = 'Respiratory';
  static const String endocrine = 'Endocrine';
  static const String neurological = 'Neurological';
  static const String musculoskeletal = 'Musculoskeletal';
  static const String gastrointestinal = 'Gastrointestinal';
  static const String autoimmune = 'Autoimmune';
  static const String mental = 'Mental Health';
  static const String oncological = 'Oncological';
  static const String dermatological = 'Dermatological';
  static const String other = 'Other';

  static const List<String> allCategories = [
    cardiovascular,
    respiratory,
    endocrine,
    neurological,
    musculoskeletal,
    gastrointestinal,
    autoimmune,
    mental,
    oncological,
    dermatological,
    other,
  ];
}

