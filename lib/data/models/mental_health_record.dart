import 'package:drift/drift.dart';

class MentalHealthRecords extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType =>
      text().withDefault(const Constant('mental_health_record')).named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();

  // Mental Health-specific fields
  TextColumn get sessionType =>
      text().withLength(min: 1, max: 100).named('session_type')();
  TextColumn get providerName => text().nullable().named('provider_name')();
  TextColumn get providerType => text().nullable().named('provider_type')();
  TextColumn get facility => text().nullable().named('facility')();
  DateTimeColumn get sessionDate => dateTime().named('session_date')();
  IntColumn get sessionDuration => integer().nullable().named('session_duration')(); // in minutes
  TextColumn get presentingConcerns =>
      text().nullable().named('presenting_concerns')();
  TextColumn get moodAssessment => text().nullable().named('mood_assessment')();
  TextColumn get thoughtProcess => text().nullable().named('thought_process')();
  TextColumn get riskAssessment => text().nullable().named('risk_assessment')();
  TextColumn get treatmentGoals => text().nullable().named('treatment_goals')();
  TextColumn get interventions => text().nullable().named('interventions')();
  TextColumn get homework => text().nullable().named('homework')();
  TextColumn get medicationDiscussion =>
      text().nullable().named('medication_discussion')();
  TextColumn get progressNotes => text().nullable().named('progress_notes')();
  TextColumn get planForNextSession =>
      text().nullable().named('plan_for_next_session')();
  DateTimeColumn get nextAppointment =>
      dateTime().nullable().named('next_appointment')();
  IntColumn get moodRating => integer().nullable().named('mood_rating')(); // 1-10 scale
  IntColumn get anxietyRating => integer().nullable().named('anxiety_rating')(); // 1-10 scale
  BoolColumn get isCrisisSession =>
      boolean().withDefault(const Constant(false)).named('is_crisis_session')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(title)) > 0)',
    'CHECK (LENGTH(TRIM(session_type)) > 0)',
    'CHECK (session_date <= CURRENT_TIMESTAMP)',
    'CHECK (next_appointment IS NULL OR next_appointment > session_date)',
    'CHECK (session_duration IS NULL OR (session_duration > 0 AND session_duration <= 480))', // Max 8 hours
    'CHECK (mood_rating IS NULL OR (mood_rating >= 1 AND mood_rating <= 10))',
    'CHECK (anxiety_rating IS NULL OR (anxiety_rating >= 1 AND anxiety_rating <= 10))',
  ];
}

// Mental health session types
class MentalHealthSessionTypes {
  static const String therapy = 'Individual Therapy';
  static const String groupTherapy = 'Group Therapy';
  static const String familyTherapy = 'Family Therapy';
  static const String coupleTherapy = 'Couple Therapy';
  static const String psychiatric = 'Psychiatric Evaluation';
  static const String medication = 'Medication Management';
  static const String crisis = 'Crisis Intervention';
  static const String assessment = 'Psychological Assessment';
  static const String consultation = 'Consultation';
  static const String followUp = 'Follow-up Session';

  static const List<String> allTypes = [
    therapy,
    groupTherapy,
    familyTherapy,
    coupleTherapy,
    psychiatric,
    medication,
    crisis,
    assessment,
    consultation,
    followUp,
  ];
}

// Mental health provider types
class MentalHealthProviderTypes {
  static const String psychologist = 'Psychologist';
  static const String psychiatrist = 'Psychiatrist';
  static const String therapist = 'Licensed Therapist';
  static const String socialWorker = 'Clinical Social Worker';
  static const String counselor = 'Licensed Counselor';
  static const String nurse = 'Psychiatric Nurse';
  static const String resident = 'Resident/Trainee';
  static const String peerSupport = 'Peer Support Specialist';

  static const List<String> allTypes = [
    psychologist,
    psychiatrist,
    therapist,
    socialWorker,
    counselor,
    nurse,
    resident,
    peerSupport,
  ];
}

// Common therapeutic interventions
class TherapeuticInterventions {
  static const String cbt = 'Cognitive Behavioral Therapy (CBT)';
  static const String dbt = 'Dialectical Behavior Therapy (DBT)';
  static const String emdr = 'EMDR';
  static const String mindfulness = 'Mindfulness/Meditation';
  static const String psychodynamic = 'Psychodynamic Therapy';
  static const String exposure = 'Exposure Therapy';
  static const String relaxation = 'Relaxation Techniques';
  static const String problemSolving = 'Problem-Solving Therapy';
  static const String motivational = 'Motivational Interviewing';
  static const String supportive = 'Supportive Counseling';

  static const List<String> allInterventions = [
    cbt,
    dbt,
    emdr,
    mindfulness,
    psychodynamic,
    exposure,
    relaxation,
    problemSolving,
    motivational,
    supportive,
  ];
}

// Common presenting concerns
class MentalHealthConcerns {
  static const String depression = 'Depression';
  static const String anxiety = 'Anxiety';
  static const String trauma = 'Trauma/PTSD';
  static const String grief = 'Grief/Loss';
  static const String stress = 'Stress Management';
  static const String relationships = 'Relationship Issues';
  static const String addiction = 'Substance Use';
  static const String eating = 'Eating Disorders';
  static const String sleep = 'Sleep Issues';
  static const String anger = 'Anger Management';
  static const String selfEsteem = 'Self-Esteem';
  static const String family = 'Family Issues';
  static const String work = 'Work/Career Stress';
  static const String bipolar = 'Bipolar Disorder';
  static const String ocd = 'OCD';

  static const List<String> allConcerns = [
    depression,
    anxiety,
    trauma,
    grief,
    stress,
    relationships,
    addiction,
    eating,
    sleep,
    anger,
    selfEsteem,
    family,
    work,
    bipolar,
    ocd,
  ];
}