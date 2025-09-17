import 'package:drift/drift.dart';

class Allergies extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType =>
      text().withDefault(const Constant('allergy')).named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();

  // Allergy-specific fields
  TextColumn get allergen =>
      text().withLength(min: 1, max: 100).named('allergen')();
  TextColumn get severity => text().named('severity')();
  TextColumn get symptoms => text().named('symptoms')(); // JSON array
  TextColumn get treatment => text().nullable().named('treatment')();
  TextColumn get notes => text().nullable().named('notes')();
  BoolColumn get isAllergyActive =>
      boolean().withDefault(const Constant(true)).named('is_allergy_active')();
  DateTimeColumn get firstReaction =>
      dateTime().nullable().named('first_reaction')();
  DateTimeColumn get lastReaction =>
      dateTime().nullable().named('last_reaction')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(title)) > 0)',
    'CHECK (LENGTH(TRIM(allergen)) > 0)',
    'CHECK (severity IN (\'mild\', \'moderate\', \'severe\', \'life-threatening\'))',
    'CHECK (LENGTH(TRIM(symptoms)) > 0)',
    'CHECK (first_reaction IS NULL OR first_reaction <= CURRENT_TIMESTAMP)',
    'CHECK (last_reaction IS NULL OR last_reaction <= CURRENT_TIMESTAMP)',
    'CHECK (first_reaction IS NULL OR last_reaction IS NULL OR first_reaction <= last_reaction)',
  ];
}

// Allergy severity levels
class AllergySeverity {
  static const String mild = 'mild';
  static const String moderate = 'moderate';
  static const String severe = 'severe';
  static const String lifeThreatening = 'life-threatening';

  static const List<String> allSeverities = [
    mild,
    moderate,
    severe,
    lifeThreatening,
  ];

  static bool isValidSeverity(String severity) {
    return allSeverities.contains(severity);
  }
}

// Common allergen categories
class AllergenTypes {
  static const String food = 'Food';
  static const String medication = 'Medication';
  static const String environmental = 'Environmental';
  static const String insect = 'Insect';
  static const String latex = 'Latex';
  static const String chemical = 'Chemical';
  static const String other = 'Other';

  static const List<String> allTypes = [
    food,
    medication,
    environmental,
    insect,
    latex,
    chemical,
    other,
  ];
}

// Common allergy symptoms
class AllergySymptoms {
  static const String rash = 'Rash';
  static const String hives = 'Hives';
  static const String itching = 'Itching';
  static const String swelling = 'Swelling';
  static const String runnyNose = 'Runny nose';
  static const String sneezingCough = 'Sneezing/Cough';
  static const String shortnessOfBreath = 'Shortness of breath';
  static const String nausea = 'Nausea';
  static const String vomiting = 'Vomiting';
  static const String diarrhea = 'Diarrhea';
  static const String anaphylaxis = 'Anaphylaxis';

  static const List<String> allSymptoms = [
    rash,
    hives,
    itching,
    swelling,
    runnyNose,
    sneezingCough,
    shortnessOfBreath,
    nausea,
    vomiting,
    diarrhea,
    anaphylaxis,
  ];
}
