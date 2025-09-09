import 'package:drift/drift.dart';

class Attachments extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get recordId => text().named('record_id')(); // References any medical record
  TextColumn get fileName => text().named('file_name')();
  TextColumn get filePath => text().named('file_path')();
  TextColumn get fileType => text().named('file_type')();
  IntColumn get fileSize => integer().named('file_size')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime).named('created_at')();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false)).named('is_synced')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(file_name)) > 0)',
    'CHECK (LENGTH(TRIM(file_path)) > 0)',
    'CHECK (file_type IN (\'image\', \'pdf\', \'document\', \'other\'))',
    'CHECK (file_size > 0 AND file_size <= 52428800)', // 50MB max
  ];
}