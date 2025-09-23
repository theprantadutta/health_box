import 'package:drift/drift.dart';

class GeneralRecords extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get profileId => text().named('profile_id')();
  TextColumn get recordType =>
      text().withDefault(const Constant('general_record')).named('record_type')();
  TextColumn get title => text().withLength(min: 1, max: 200).named('title')();
  TextColumn get description => text().nullable().named('description')();
  DateTimeColumn get recordDate => dateTime().named('record_date')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();

  // General Record-specific fields
  TextColumn get category =>
      text().withLength(min: 1, max: 100).named('category')();
  TextColumn get subcategory => text().nullable().named('subcategory')();
  TextColumn get providerName => text().nullable().named('provider_name')();
  TextColumn get institution => text().nullable().named('institution')();
  DateTimeColumn get documentDate => dateTime().nullable().named('document_date')();
  TextColumn get documentType => text().nullable().named('document_type')();
  TextColumn get referenceNumber => text().nullable().named('reference_number')();
  TextColumn get relatedCondition =>
      text().nullable().named('related_condition')();
  TextColumn get notes => text().nullable().named('notes')();
  TextColumn get followUpRequired =>
      text().nullable().named('follow_up_required')();
  DateTimeColumn get expirationDate =>
      dateTime().nullable().named('expiration_date')();
  DateTimeColumn get reminderDate =>
      dateTime().nullable().named('reminder_date')();
  TextColumn get tags => text().nullable().named('tags')(); // JSON array
  BoolColumn get isConfidential =>
      boolean().withDefault(const Constant(false)).named('is_confidential')();
  BoolColumn get requiresAction =>
      boolean().withDefault(const Constant(false)).named('requires_action')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(title)) > 0)',
    'CHECK (LENGTH(TRIM(category)) > 0)',
    'CHECK (document_date IS NULL OR document_date <= CURRENT_TIMESTAMP)',
    'CHECK (expiration_date IS NULL OR expiration_date >= document_date)',
    'CHECK (reminder_date IS NULL OR reminder_date >= CURRENT_TIMESTAMP)',
  ];
}

// General record categories
class GeneralRecordCategories {
  static const String referral = 'Referral Letter';
  static const String consent = 'Consent Form';
  static const String insurance = 'Insurance Document';
  static const String billing = 'Billing/Payment';
  static const String legal = 'Legal Document';
  static const String correspondence = 'Medical Correspondence';
  static const String certificate = 'Medical Certificate';
  static const String screening = 'Health Screening';
  static const String fitness = 'Fitness Assessment';
  static const String research = 'Research/Study';
  static const String education = 'Health Education Material';
  static const String advance = 'Advance Directive';
  static const String proxy = 'Healthcare Proxy';
  static const String travel = 'Travel Medicine';
  static const String employment = 'Employment Health';
  static const String other = 'Other Document';

  static const List<String> allCategories = [
    referral,
    consent,
    insurance,
    billing,
    legal,
    correspondence,
    certificate,
    screening,
    fitness,
    research,
    education,
    advance,
    proxy,
    travel,
    employment,
    other,
  ];
}

// Document types
class GeneralDocumentTypes {
  static const String letter = 'Letter';
  static const String form = 'Form';
  static const String report = 'Report';
  static const String certificate = 'Certificate';
  static const String authorization = 'Authorization';
  static const String agreement = 'Agreement';
  static const String directive = 'Directive';
  static const String receipt = 'Receipt';
  static const String invoice = 'Invoice';
  static const String summary = 'Summary';
  static const String policy = 'Policy';
  static const String card = 'Card';

  static const List<String> allTypes = [
    letter,
    form,
    report,
    certificate,
    authorization,
    agreement,
    directive,
    receipt,
    invoice,
    summary,
    policy,
    card,
  ];
}

// Subcategories for specific categories
class GeneralRecordSubcategories {
  // Referral subcategories
  static const List<String> referralSubs = [
    'Specialist Referral',
    'Inter-hospital Transfer',
    'Physical Therapy',
    'Diagnostic Imaging',
    'Laboratory Testing',
    'Mental Health Services',
  ];

  // Insurance subcategories
  static const List<String> insuranceSubs = [
    'Policy Documents',
    'Claims',
    'Pre-authorization',
    'Explanation of Benefits',
    'Coverage Details',
    'Denial Letters',
  ];

  // Consent subcategories
  static const List<String> consentSubs = [
    'Treatment Consent',
    'Surgery Consent',
    'Research Participation',
    'Information Release',
    'Photography/Video',
    'Emergency Treatment',
  ];

  // Legal subcategories
  static const List<String> legalSubs = [
    'Medical Malpractice',
    'Disability Documentation',
    'Workers Compensation',
    'Court Ordered Evaluation',
    'Medical Records Request',
    'HIPAA Authorization',
  ];

  static List<String> getSubcategoriesForCategory(String category) {
    switch (category) {
      case GeneralRecordCategories.referral:
        return referralSubs;
      case GeneralRecordCategories.insurance:
        return insuranceSubs;
      case GeneralRecordCategories.consent:
        return consentSubs;
      case GeneralRecordCategories.legal:
        return legalSubs;
      default:
        return [];
    }
  }
}