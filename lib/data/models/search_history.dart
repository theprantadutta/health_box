import 'package:drift/drift.dart';

class SearchHistory extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get searchTerm => text().withLength(min: 1, max: 200).named('search_term')();
  TextColumn get searchType => text().named('search_type')();
  IntColumn get searchCount => integer().withDefault(const Constant(1)).named('search_count')();
  DateTimeColumn get lastSearched =>
      dateTime().withDefault(currentDateAndTime).named('last_searched')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(search_term)) > 0)',
    'CHECK (search_type IN (\'general\', \'medical_record\', \'medication\', \'profile\', \'tag\'))',
    'CHECK (search_count > 0)',
  ];
}

// Search types for categorizing searches
class SearchTypes {
  static const String general = 'general';
  static const String medicalRecord = 'medical_record';
  static const String medication = 'medication';
  static const String profile = 'profile';
  static const String tag = 'tag';

  static const List<String> allTypes = [
    general,
    medicalRecord,
    medication,
    profile,
    tag,
  ];
}