import 'package:drift/drift.dart';

class PathologyRecords extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType =>
      text().withDefault(const Constant('pathology_record')).named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();

  // Pathology-specific fields
  TextColumn get specimenType =>
      text().withLength(min: 1, max: 100).named('specimen_type')();
  TextColumn get specimenSite => text().nullable().named('specimen_site')();
  TextColumn get pathologist => text().nullable().named('pathologist')();
  TextColumn get laboratory => text().nullable().named('laboratory')();
  DateTimeColumn get collectionDate => dateTime().named('collection_date')();
  DateTimeColumn get reportDate => dateTime().nullable().named('report_date')();
  TextColumn get collectionMethod =>
      text().nullable().named('collection_method')();
  TextColumn get grossDescription =>
      text().nullable().named('gross_description')();
  TextColumn get microscopicFindings =>
      text().nullable().named('microscopic_findings')();
  TextColumn get diagnosis => text().nullable().named('diagnosis')();
  TextColumn get stagingGrading => text().nullable().named('staging_grading')();
  TextColumn get immunohistochemistry =>
      text().nullable().named('immunohistochemistry')();
  TextColumn get molecularStudies =>
      text().nullable().named('molecular_studies')();
  TextColumn get recommendation => text().nullable().named('recommendation')();
  TextColumn get urgency => text().named('urgency')();
  BoolColumn get isMalignant =>
      boolean().withDefault(const Constant(false)).named('is_malignant')();
  TextColumn get referringPhysician =>
      text().nullable().named('referring_physician')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(title)) > 0)',
    'CHECK (LENGTH(TRIM(specimen_type)) > 0)',
    'CHECK (urgency IN (\'routine\', \'urgent\', \'stat\', \'emergency\'))',
    'CHECK (collection_date <= CURRENT_TIMESTAMP)',
    'CHECK (report_date IS NULL OR report_date >= collection_date)',
  ];
}

// Common specimen types
class PathologySpecimenTypes {
  static const String biopsy = 'Biopsy';
  static const String cytology = 'Cytology';
  static const String excision = 'Excision';
  static const String resection = 'Resection';
  static const String fna = 'Fine Needle Aspiration';
  static const String fluidAnalysis = 'Fluid Analysis';
  static const String bloodSmear = 'Blood Smear';
  static const String bonemarrow = 'Bone Marrow';
  static const String frozen = 'Frozen Section';

  static const List<String> allTypes = [
    biopsy,
    cytology,
    excision,
    resection,
    fna,
    fluidAnalysis,
    bloodSmear,
    bonemarrow,
    frozen,
  ];
}

// Collection methods
class PathologyCollectionMethods {
  static const String endoscopy = 'Endoscopy';
  static const String surgery = 'Surgical';
  static const String needle = 'Needle Biopsy';
  static const String shave = 'Shave Biopsy';
  static const String punch = 'Punch Biopsy';
  static const String brush = 'Brush Cytology';
  static const String lavage = 'Lavage';
  static const String aspiration = 'Aspiration';

  static const List<String> allMethods = [
    endoscopy,
    surgery,
    needle,
    shave,
    punch,
    brush,
    lavage,
    aspiration,
  ];
}

// Urgency levels for pathology
class PathologyUrgency {
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

// Common anatomical sites
class PathologyAnatomicalSites {
  static const String skin = 'Skin';
  static const String breast = 'Breast';
  static const String lung = 'Lung';
  static const String colon = 'Colon';
  static const String prostate = 'Prostate';
  static const String cervix = 'Cervix';
  static const String stomach = 'Stomach';
  static const String liver = 'Liver';
  static const String kidney = 'Kidney';
  static const String bladder = 'Bladder';
  static const String thyroid = 'Thyroid';
  static const String lymphNode = 'Lymph Node';
  static const String bone = 'Bone';
  static const String brain = 'Brain';
  static const String other = 'Other';

  static const List<String> allSites = [
    skin,
    breast,
    lung,
    colon,
    prostate,
    cervix,
    stomach,
    liver,
    kidney,
    bladder,
    thyroid,
    lymphNode,
    bone,
    brain,
    other,
  ];
}