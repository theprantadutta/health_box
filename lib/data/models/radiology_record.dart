import 'package:drift/drift.dart';

class RadiologyRecords extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType =>
      text().withDefault(const Constant('radiology_record')).named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();

  // Radiology-specific fields
  TextColumn get studyType =>
      text().withLength(min: 1, max: 100).named('study_type')();
  TextColumn get bodyPart => text().nullable().named('body_part')();
  TextColumn get radiologist => text().nullable().named('radiologist')();
  TextColumn get facility => text().nullable().named('facility')();
  DateTimeColumn get studyDate => dateTime().named('study_date')();
  TextColumn get technique => text().nullable().named('technique')();
  TextColumn get contrast => text().nullable().named('contrast')();
  TextColumn get findings => text().nullable().named('findings')();
  TextColumn get impression => text().nullable().named('impression')();
  TextColumn get recommendation => text().nullable().named('recommendation')();
  TextColumn get urgency => text().named('urgency')();
  BoolColumn get isNormal =>
      boolean().withDefault(const Constant(false)).named('is_normal')();
  TextColumn get referringPhysician =>
      text().nullable().named('referring_physician')();
  TextColumn get protocolUsed => text().nullable().named('protocol_used')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(title)) > 0)',
    'CHECK (LENGTH(TRIM(study_type)) > 0)',
    'CHECK (urgency IN (\'routine\', \'urgent\', \'stat\', \'emergency\'))',
    'CHECK (study_date <= CURRENT_TIMESTAMP)',
  ];
}

// Common radiology study types
class RadiologyStudyTypes {
  static const String xray = 'X-Ray';
  static const String ct = 'CT Scan';
  static const String mri = 'MRI';
  static const String ultrasound = 'Ultrasound';
  static const String mammography = 'Mammography';
  static const String dexa = 'DEXA Scan';
  static const String nuclear = 'Nuclear Medicine';
  static const String pet = 'PET Scan';
  static const String fluoroscopy = 'Fluoroscopy';
  static const String angiography = 'Angiography';

  static const List<String> allTypes = [
    xray,
    ct,
    mri,
    ultrasound,
    mammography,
    dexa,
    nuclear,
    pet,
    fluoroscopy,
    angiography,
  ];
}

// Urgency levels
class RadiologyUrgency {
  static const String routine = 'routine';
  static const String urgent = 'urgent';
  static const String stat = 'stat';
  static const String emergency = 'emergency';

  static const List<String> allLevels = [
    routine,
    urgent,
    stat,
    emergency,
  ];
}

// Common body parts for radiology
class RadiologyBodyParts {
  static const String head = 'Head/Brain';
  static const String neck = 'Neck';
  static const String chest = 'Chest/Thorax';
  static const String abdomen = 'Abdomen';
  static const String pelvis = 'Pelvis';
  static const String spine = 'Spine';
  static const String upperExtremity = 'Upper Extremity';
  static const String lowerExtremity = 'Lower Extremity';
  static const String cardiac = 'Cardiac';
  static const String vascular = 'Vascular';

  static const List<String> allParts = [
    head,
    neck,
    chest,
    abdomen,
    pelvis,
    spine,
    upperExtremity,
    lowerExtremity,
    cardiac,
    vascular,
  ];
}