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
    'FOREIGN KEY (record_id) REFERENCES medical_records (id) ON DELETE CASCADE',
    'FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE',
  ];
}

