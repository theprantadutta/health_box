import 'package:drift/drift.dart';

class DentalRecords extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType =>
      text().withDefault(const Constant('dental_record')).named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();

  // Dental-specific fields
  TextColumn get procedureType =>
      text().withLength(min: 1, max: 100).named('procedure_type')();
  TextColumn get dentistName => text().nullable().named('dentist_name')();
  TextColumn get dentalOffice => text().nullable().named('dental_office')();
  DateTimeColumn get appointmentDate => dateTime().named('appointment_date')();
  TextColumn get toothNumbers => text().nullable().named('tooth_numbers')(); // JSON array
  TextColumn get treatmentArea => text().nullable().named('treatment_area')();
  TextColumn get chiefComplaint => text().nullable().named('chief_complaint')();
  TextColumn get clinicalFindings =>
      text().nullable().named('clinical_findings')();
  TextColumn get diagnosis => text().nullable().named('diagnosis')();
  TextColumn get treatmentProvided =>
      text().nullable().named('treatment_provided')();
  TextColumn get materialsUsed => text().nullable().named('materials_used')();
  TextColumn get anesthesiaUsed => text().nullable().named('anesthesia_used')();
  TextColumn get postTreatmentInstructions =>
      text().nullable().named('post_treatment_instructions')();
  TextColumn get followUpRequired =>
      text().nullable().named('follow_up_required')();
  DateTimeColumn get nextAppointment =>
      dateTime().nullable().named('next_appointment')();
  RealColumn get cost => real().nullable().named('cost')();
  TextColumn get insuranceClaim => text().nullable().named('insurance_claim')();
  BoolColumn get isEmergencyVisit =>
      boolean().withDefault(const Constant(false)).named('is_emergency_visit')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(title)) > 0)',
    'CHECK (LENGTH(TRIM(procedure_type)) > 0)',
    'CHECK (appointment_date <= CURRENT_TIMESTAMP)',
    'CHECK (next_appointment IS NULL OR next_appointment > appointment_date)',
    'CHECK (cost IS NULL OR cost >= 0)',
  ];
}

// Common dental procedures
class DentalProcedureTypes {
  static const String cleaning = 'Routine Cleaning';
  static const String examination = 'Dental Examination';
  static const String xray = 'X-Ray/Imaging';
  static const String filling = 'Filling/Restoration';
  static const String extraction = 'Tooth Extraction';
  static const String rootCanal = 'Root Canal';
  static const String crown = 'Crown/Cap';
  static const String bridge = 'Bridge';
  static const String implant = 'Dental Implant';
  static const String orthodontics = 'Orthodontic Treatment';
  static const String whitening = 'Teeth Whitening';
  static const String periodontal = 'Periodontal Treatment';
  static const String dentures = 'Dentures/Partials';
  static const String oralSurgery = 'Oral Surgery';
  static const String emergency = 'Emergency Treatment';

  static const List<String> allTypes = [
    cleaning,
    examination,
    xray,
    filling,
    extraction,
    rootCanal,
    crown,
    bridge,
    implant,
    orthodontics,
    whitening,
    periodontal,
    dentures,
    oralSurgery,
    emergency,
  ];
}

// Dental anesthesia types
class DentalAnesthesiaTypes {
  static const String none = 'None';
  static const String topical = 'Topical';
  static const String local = 'Local Injection';
  static const String nitrous = 'Nitrous Oxide';
  static const String sedation = 'Conscious Sedation';
  static const String general = 'General Anesthesia';

  static const List<String> allTypes = [
    none,
    topical,
    local,
    nitrous,
    sedation,
    general,
  ];
}

// Dental treatment areas
class DentalTreatmentAreas {
  static const String upperRight = 'Upper Right Quadrant';
  static const String upperLeft = 'Upper Left Quadrant';
  static const String lowerRight = 'Lower Right Quadrant';
  static const String lowerLeft = 'Lower Left Quadrant';
  static const String fullMouth = 'Full Mouth';
  static const String anterior = 'Anterior Teeth';
  static const String posterior = 'Posterior Teeth';
  static const String gums = 'Gums/Periodontal';
  static const String jaw = 'Jaw/TMJ';

  static const List<String> allAreas = [
    upperRight,
    upperLeft,
    lowerRight,
    lowerLeft,
    fullMouth,
    anterior,
    posterior,
    gums,
    jaw,
  ];
}

// Common dental materials
class DentalMaterials {
  static const String amalgam = 'Amalgam';
  static const String composite = 'Composite Resin';
  static const String porcelain = 'Porcelain';
  static const String gold = 'Gold';
  static const String ceramic = 'Ceramic';
  static const String titanium = 'Titanium';
  static const String zirconia = 'Zirconia';
  static const String fluoride = 'Fluoride';
  static const String sealant = 'Dental Sealant';

  static const List<String> allMaterials = [
    amalgam,
    composite,
    porcelain,
    gold,
    ceramic,
    titanium,
    zirconia,
    fluoride,
    sealant,
  ];
}