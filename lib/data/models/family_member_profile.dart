import 'package:drift/drift.dart';

class FamilyMemberProfiles extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get firstName =>
      text().withLength(min: 1, max: 50).named('first_name')();
  TextColumn get lastName =>
      text().withLength(min: 1, max: 50).named('last_name')();
  TextColumn get middleName =>
      text().withLength(min: 1, max: 50).nullable().named('middle_name')();
  DateTimeColumn get dateOfBirth => dateTime().named('date_of_birth')();
  TextColumn get gender => text().named('gender')();
  TextColumn get bloodType => text().nullable().named('blood_type')();
  RealColumn get height => real().nullable().named('height')();
  RealColumn get weight => real().nullable().named('weight')();
  TextColumn get emergencyContact =>
      text().nullable().named('emergency_contact')();
  TextColumn get insuranceInfo => text().nullable().named('insurance_info')();
  TextColumn get profileImagePath =>
      text().nullable().named('profile_image_path')();
  TextColumn get relationship => text().nullable().named('relationship')();
  TextColumn get phone => text().nullable().named('phone')();
  TextColumn get email => text().nullable().named('email')();
  TextColumn get address => text().nullable().named('address')();
  TextColumn get medicalConditions => text().nullable().named('medical_conditions')();
  TextColumn get allergies => text().nullable().named('allergies')();
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
    // Gender constraint
    'CHECK (gender IN (\'Male\', \'Female\', \'Other\', \'Unspecified\'))',

    // Blood type constraint
    'CHECK (blood_type IS NULL OR blood_type IN (\'A+\', \'A-\', \'B+\', \'B-\', \'AB+\', \'AB-\', \'O+\', \'O-\', \'Unknown\'))',

    // Height constraint (30-300 cm)
    'CHECK (height IS NULL OR (height >= 30 AND height <= 300))',

    // Weight constraint (0.5-500 kg)
    'CHECK (weight IS NULL OR (weight >= 0.5 AND weight <= 500))',

    // Date of birth constraint (not future date)
    'CHECK (date_of_birth <= CURRENT_TIMESTAMP)',

    // Name constraints (non-empty)
    'CHECK (LENGTH(TRIM(first_name)) > 0)',
    'CHECK (LENGTH(TRIM(last_name)) > 0)',
    'CHECK (middle_name IS NULL OR LENGTH(TRIM(middle_name)) > 0)',

    // Extended field constraints
    'CHECK (relationship IS NULL OR LENGTH(TRIM(relationship)) > 0)',
    'CHECK (phone IS NULL OR LENGTH(TRIM(phone)) > 0)',
    'CHECK (email IS NULL OR (LENGTH(TRIM(email)) > 0 AND email LIKE \'%@%\'))',
    'CHECK (address IS NULL OR LENGTH(TRIM(address)) > 0)',
    'CHECK (medical_conditions IS NULL OR LENGTH(TRIM(medical_conditions)) > 0)',
    'CHECK (allergies IS NULL OR LENGTH(TRIM(allergies)) > 0)',
  ];
}
