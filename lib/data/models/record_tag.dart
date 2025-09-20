import 'package:drift/drift.dart';

// Junction table for many-to-many relationship between medical records and tags
class RecordTags extends Table {
  TextColumn get recordId => text().named('record_id')();
  TextColumn get tagId => text().named('tag_id')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();

  @override
  Set<Column> get primaryKey => {recordId, tagId};

  @override
  List<String> get customConstraints => [
    // Foreign key constraints (when enabled)
    // 'FOREIGN KEY (record_id) REFERENCES medical_records (id) ON DELETE CASCADE',
    // 'FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE',
  ];
}

// Search history table for storing recent searches
class SearchHistory extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get query => text().named('query')();
  TextColumn get filters => text().nullable().named('filters')(); // JSON string
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  IntColumn get useCount =>
      integer().withDefault(const Constant(1)).named('use_count')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    // Query must not be empty
    'CHECK (LENGTH(TRIM(query)) > 0)',

    // Use count must be positive
    'CHECK (use_count > 0)',
  ];
}
