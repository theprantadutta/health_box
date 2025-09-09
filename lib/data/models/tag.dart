import 'package:drift/drift.dart';

class Tags extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get name => text().withLength(min: 1, max: 50).named('name').unique()();
  TextColumn get color => text().named('color')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime).named('created_at')();
  IntColumn get usageCount => integer().withDefault(const Constant(0)).named('usage_count')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(name)) > 0)',
    'CHECK (color LIKE \'#______\')', // Simple hex color validation
    'CHECK (usage_count >= 0)',
  ];
}