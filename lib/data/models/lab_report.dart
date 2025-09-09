import 'package:drift/drift.dart';

class LabReports extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType => text().withDefault(const Constant('lab_report')).named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive => boolean().withDefault(const Constant(true)).named('is_active')();

  // LabReport-specific fields
  TextColumn get testName => text().withLength(min: 1, max: 100).named('test_name')();
  TextColumn get testResults => text().nullable().named('test_results')();
  TextColumn get referenceRange => text().nullable().named('reference_range')();
  TextColumn get orderingPhysician => text().nullable().named('ordering_physician')();
  TextColumn get labFacility => text().nullable().named('lab_facility')();
  TextColumn get testStatus => text().named('test_status')();
  DateTimeColumn get collectionDate => dateTime().nullable().named('collection_date')();
  BoolColumn get isCritical => boolean().withDefault(const Constant(false)).named('is_critical')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    // Title constraint (non-empty)
    'CHECK (LENGTH(TRIM(title)) > 0)',
    
    // Test name constraint (non-empty)
    'CHECK (LENGTH(TRIM(test_name)) > 0)',
    
    // Test status constraint
    'CHECK (test_status IN (\'pending\', \'completed\', \'reviewed\', \'cancelled\'))',
    
    // Collection date constraint (not future date)
    'CHECK (collection_date IS NULL OR collection_date <= CURRENT_TIMESTAMP)',
    
    // Record date should be on or after collection date
    'CHECK (collection_date IS NULL OR record_date >= collection_date)',
  ];
}

// Test status constants for type safety
class LabTestStatus {
  static const String pending = 'pending';
  static const String completed = 'completed';
  static const String reviewed = 'reviewed';
  static const String cancelled = 'cancelled';

  static const List<String> allStatuses = [
    pending,
    completed,
    reviewed,
    cancelled,
  ];

  static bool isValidStatus(String status) {
    return allStatuses.contains(status);
  }
}