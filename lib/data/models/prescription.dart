import 'package:drift/drift.dart';

class Prescriptions extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType =>
      text().withDefault(const Constant('prescription')).named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();

  // Type field to distinguish between prescription and appointment
  TextColumn get prescriptionType => text().named('prescription_type')();

  // Prescription-specific fields
  TextColumn get medicationName =>
      text().nullable().named('medication_name')();
  TextColumn get dosage => text().nullable().named('dosage')();
  TextColumn get frequency => text().nullable().named('frequency')();
  TextColumn get instructions => text().nullable().named('instructions')();
  TextColumn get prescribingDoctor =>
      text().nullable().named('prescribing_doctor')();
  TextColumn get pharmacy => text().nullable().named('pharmacy')();
  DateTimeColumn get startDate => dateTime().nullable().named('start_date')();
  DateTimeColumn get endDate => dateTime().nullable().named('end_date')();
  IntColumn get refillsRemaining =>
      integer().nullable().named('refills_remaining')();
  BoolColumn get isPrescriptionActive => boolean()
      .withDefault(const Constant(true))
      .named('is_prescription_active')();

  // Appointment-specific fields
  DateTimeColumn get appointmentDate =>
      dateTime().nullable().named('appointment_date')();
  TextColumn get appointmentTime =>
      text().nullable().named('appointment_time')();
  TextColumn get doctorName => text().nullable().named('doctor_name')();
  TextColumn get specialty => text().nullable().named('specialty')();
  TextColumn get clinicName => text().nullable().named('clinic_name')();
  TextColumn get clinicAddress => text().nullable().named('clinic_address')();
  TextColumn get appointmentType => text().nullable().named('appointment_type')();
  TextColumn get reasonForVisit => text().nullable().named('reason_for_visit')();
  TextColumn get appointmentStatus => text().nullable().named('appointment_status')();
  TextColumn get appointmentNotes => text().nullable().named('appointment_notes')();
  BoolColumn get reminderSet =>
      boolean().withDefault(const Constant(false)).named('reminder_set')();
  IntColumn get reminderMinutes =>
      integer().nullable().named('reminder_minutes')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    // Title constraint (non-empty)
    'CHECK (LENGTH(TRIM(title)) > 0)',

    // Prescription type constraint
    'CHECK (prescription_type IN (\'prescription\', \'appointment\'))',

    // Prescription-specific constraints
    'CHECK (prescription_type != \'prescription\' OR (medication_name IS NOT NULL AND LENGTH(TRIM(medication_name)) > 0))',
    'CHECK (prescription_type != \'prescription\' OR (dosage IS NOT NULL AND LENGTH(TRIM(dosage)) > 0))',
    'CHECK (prescription_type != \'prescription\' OR (frequency IS NOT NULL AND LENGTH(TRIM(frequency)) > 0))',

    // Appointment-specific constraints
    'CHECK (prescription_type != \'appointment\' OR appointment_date IS NOT NULL)',
    'CHECK (prescription_type != \'appointment\' OR (doctor_name IS NOT NULL AND LENGTH(TRIM(doctor_name)) > 0))',

    // General constraints
    'CHECK (refills_remaining IS NULL OR refills_remaining >= 0)',
    'CHECK (start_date IS NULL OR end_date IS NULL OR start_date <= end_date)',
    'CHECK (appointment_date IS NULL OR appointment_date >= DATE(\'now\', \'-1 year\'))',
    'CHECK (reminder_minutes IS NULL OR (reminder_minutes >= 5 AND reminder_minutes <= 10080))', // 5 min to 1 week
    'CHECK (appointment_status IS NULL OR appointment_status IN (\'scheduled\', \'confirmed\', \'completed\', \'cancelled\', \'rescheduled\'))',
  ];
}

// Prescription types
class PrescriptionType {
  static const String prescription = 'prescription';
  static const String appointment = 'appointment';

  static const List<String> allTypes = [
    prescription,
    appointment,
  ];

  static String getDisplayName(String type) {
    switch (type) {
      case prescription:
        return 'Prescription';
      case appointment:
        return 'Doctor Appointment';
      default:
        return type;
    }
  }
}

// Appointment types
class AppointmentType {
  static const String checkup = 'Routine Checkup';
  static const String followUp = 'Follow-up';
  static const String consultation = 'Consultation';
  static const String procedure = 'Procedure';
  static const String screening = 'Screening';
  static const String vaccination = 'Vaccination';
  static const String labWork = 'Lab Work';
  static const String imaging = 'Imaging/X-ray';
  static const String surgery = 'Surgery';
  static const String emergency = 'Emergency';
  static const String telehealth = 'Telehealth';

  static const List<String> allTypes = [
    checkup,
    followUp,
    consultation,
    procedure,
    screening,
    vaccination,
    labWork,
    imaging,
    surgery,
    emergency,
    telehealth,
  ];
}

// Appointment status
class AppointmentStatus {
  static const String scheduled = 'scheduled';
  static const String confirmed = 'confirmed';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String rescheduled = 'rescheduled';

  static const List<String> allStatuses = [
    scheduled,
    confirmed,
    completed,
    cancelled,
    rescheduled,
  ];

  static String getDisplayName(String status) {
    switch (status) {
      case scheduled:
        return 'Scheduled';
      case confirmed:
        return 'Confirmed';
      case completed:
        return 'Completed';
      case cancelled:
        return 'Cancelled';
      case rescheduled:
        return 'Rescheduled';
      default:
        return status;
    }
  }
}

// Medical specialties
class MedicalSpecialties {
  static const String primaryCare = 'Primary Care';
  static const String cardiology = 'Cardiology';
  static const String dermatology = 'Dermatology';
  static const String endocrinology = 'Endocrinology';
  static const String gastroenterology = 'Gastroenterology';
  static const String neurology = 'Neurology';
  static const String oncology = 'Oncology';
  static const String orthopedics = 'Orthopedics';
  static const String pediatrics = 'Pediatrics';
  static const String psychiatry = 'Psychiatry';
  static const String pulmonology = 'Pulmonology';
  static const String urology = 'Urology';
  static const String gynecology = 'Gynecology';
  static const String ophthalmology = 'Ophthalmology';
  static const String otolaryngology = 'ENT';
  static const String radiology = 'Radiology';
  static const String pathology = 'Pathology';
  static const String anesthesiology = 'Anesthesiology';
  static const String emergency = 'Emergency Medicine';
  static const String dentistry = 'Dentistry';

  static const List<String> allSpecialties = [
    primaryCare,
    cardiology,
    dermatology,
    endocrinology,
    gastroenterology,
    neurology,
    oncology,
    orthopedics,
    pediatrics,
    psychiatry,
    pulmonology,
    urology,
    gynecology,
    ophthalmology,
    otolaryngology,
    radiology,
    pathology,
    anesthesiology,
    emergency,
    dentistry,
  ];
}

// Common reminder intervals (in minutes)
class ReminderIntervals {
  static const int fifteenMinutes = 15;
  static const int thirtyMinutes = 30;
  static const int oneHour = 60;
  static const int twoHours = 120;
  static const int oneDay = 1440;
  static const int twoDays = 2880;
  static const int oneWeek = 10080;

  static const Map<int, String> intervalLabels = {
    fifteenMinutes: '15 minutes before',
    thirtyMinutes: '30 minutes before',
    oneHour: '1 hour before',
    twoHours: '2 hours before',
    oneDay: '1 day before',
    twoDays: '2 days before',
    oneWeek: '1 week before',
  };

  static const List<int> allIntervals = [
    fifteenMinutes,
    thirtyMinutes,
    oneHour,
    twoHours,
    oneDay,
    twoDays,
    oneWeek,
  ];
}
