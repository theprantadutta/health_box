# Data Model: HealthBox Medical Data Manager

## Entity Overview

The HealthBox data model follows a hierarchical structure with Family Member Profiles as the root containers for all medical information. Each profile contains various types of medical records, with shared components for organization (tags, attachments) and functionality (reminders, emergency cards).

## Core Entities

### FamilyMemberProfile
**Purpose**: Root container representing an individual person's medical identity
**Relationships**: One-to-many with all medical record types

```dart
class FamilyMemberProfile {
  String id;                    // UUID primary key
  String firstName;             // Required, 1-50 characters
  String lastName;              // Required, 1-50 characters
  String? middleName;           // Optional, 1-50 characters
  DateTime dateOfBirth;         // Required for age calculations
  String gender;                // Required: Male/Female/Other/Unspecified
  String bloodType;             // Optional: A+, A-, B+, B-, AB+, AB-, O+, O-, Unknown
  double? height;               // Optional, in centimeters
  double? weight;               // Optional, in kilograms
  String? emergencyContact;     // Optional contact information
  String? insuranceInfo;        // Optional insurance details
  String? profileImagePath;     // Optional local file path
  DateTime createdAt;           // Auto-generated
  DateTime updatedAt;           // Auto-updated
  bool isActive;                // Soft delete flag
}
```

**Validation Rules**:
- firstName, lastName: Non-empty, alphanumeric + spaces, hyphens, apostrophes
- dateOfBirth: Cannot be future date, reasonable age range (0-150 years)
- gender: Must be one of predefined values
- bloodType: Must be valid blood type if provided
- height: 30-300 cm if provided
- weight: 0.5-500 kg if provided

### MedicalRecord (Base Entity)
**Purpose**: Abstract base for all medical information
**Relationships**: Belongs to FamilyMemberProfile, many-to-many with Tag, one-to-many with Attachment

```dart
abstract class MedicalRecord {
  String id;                    // UUID primary key
  String profileId;             // Foreign key to FamilyMemberProfile
  String recordType;            // Discriminator: prescription, lab_report, etc.
  String title;                 // Required, 1-200 characters
  String? description;          // Optional detailed notes
  DateTime recordDate;          // Date of medical event
  DateTime createdAt;           // Auto-generated
  DateTime updatedAt;           // Auto-updated
  bool isActive;                // Soft delete flag
}
```

### Prescription
**Purpose**: Medication prescriptions with dosage and provider information
**Extends**: MedicalRecord

```dart
class Prescription extends MedicalRecord {
  String medicationName;        // Required, 1-100 characters
  String dosage;                // Required, e.g., "10mg", "2 tablets"
  String frequency;             // Required, e.g., "twice daily", "as needed"
  String? instructions;         // Optional special instructions
  String? prescribingDoctor;    // Optional provider name
  String? pharmacy;             // Optional pharmacy information
  DateTime? startDate;          // When to start taking
  DateTime? endDate;            // When to stop (if applicable)
  int? refillsRemaining;        // Number of refills left
  bool isActive;                // Currently taking this medication
}
```

**State Transitions**: Active → Completed → Inactive

### LabReport
**Purpose**: Laboratory test results and reports
**Extends**: MedicalRecord

```dart
class LabReport extends MedicalRecord {
  String testName;              // Required, 1-100 characters
  String? testResults;          // Optional results text
  String? referenceRange;       // Optional normal ranges
  String? orderingPhysician;    // Optional provider name
  String? labFacility;          // Optional lab name
  String testStatus;            // Required: pending, completed, reviewed
  DateTime? collectionDate;     // When sample was collected
  bool isCritical;              // Flags abnormal/critical results
}
```

### Medication
**Purpose**: Ongoing medication tracking with reminder integration
**Extends**: MedicalRecord

```dart
class Medication extends MedicalRecord {
  String medicationName;        // Required, 1-100 characters
  String dosage;                // Required dosage amount
  String frequency;             // Required frequency description
  List<String> schedule;        // Required time slots, e.g., ["08:00", "20:00"]
  DateTime startDate;           // Required start date
  DateTime? endDate;            // Optional end date for courses
  String? instructions;         // Optional special instructions
  bool reminderEnabled;         // Enable/disable notifications
  int? pillCount;               // Optional pill tracking
  String status;                // Required: active, paused, completed
}
```

**State Transitions**: Active → Paused → Active, Active → Completed

### Vaccination
**Purpose**: Immunization records with scheduling
**Extends**: MedicalRecord

```dart
class Vaccination extends MedicalRecord {
  String vaccineName;           // Required, 1-100 characters
  String? manufacturer;         // Optional vaccine manufacturer
  String? batchNumber;          // Optional lot number
  DateTime administrationDate;  // Required date of vaccination
  String? administeredBy;       // Optional healthcare provider
  String? site;                 // Optional injection site
  DateTime? nextDueDate;        // Optional next dose date
  int? doseNumber;              // Optional dose in series (1, 2, etc.)
  bool isComplete;              // Series completion status
}
```

### Allergy
**Purpose**: Allergy and adverse reaction information
**Extends**: MedicalRecord

```dart
class Allergy extends MedicalRecord {
  String allergen;              // Required, 1-100 characters
  String severity;              // Required: mild, moderate, severe, life-threatening
  List<String> symptoms;        // Required list of reactions
  String? treatment;            // Optional emergency treatment
  String? notes;                // Optional additional notes
  bool isActive;                // Currently active allergy
  DateTime? firstReaction;      // Optional date of first reaction
  DateTime? lastReaction;       // Optional date of most recent reaction
}
```

### ChronicCondition
**Purpose**: Long-term health conditions and management
**Extends**: MedicalRecord

```dart
class ChronicCondition extends MedicalRecord {
  String conditionName;         // Required, 1-100 characters
  DateTime diagnosisDate;       // Required diagnosis date
  String? diagnosingProvider;   // Optional healthcare provider
  String severity;              // Required: mild, moderate, severe
  String status;                // Required: active, managed, resolved
  String? treatment;            // Optional current treatment
  String? managementPlan;       // Optional management notes
  List<String> relatedMedications; // Optional linked medication IDs
}
```

## Supporting Entities

### Tag
**Purpose**: Organizational labels for categorizing medical records
**Relationships**: Many-to-many with MedicalRecord

```dart
class Tag {
  String id;                    // UUID primary key
  String name;                  // Required, unique, 1-50 characters
  String color;                 // Required hex color code
  String? description;          // Optional tag description
  DateTime createdAt;           // Auto-generated
  int usageCount;               // Number of records with this tag
}
```

**Validation Rules**:
- name: Unique per device, alphanumeric + spaces, no special characters
- color: Valid hex color format (#RRGGBB)

### Attachment
**Purpose**: Files and images associated with medical records
**Relationships**: Belongs to MedicalRecord

```dart
class Attachment {
  String id;                    // UUID primary key
  String recordId;              // Foreign key to MedicalRecord
  String fileName;              // Required original filename
  String filePath;              // Required local file path
  String fileType;              // Required: image, pdf, document, other
  int fileSize;                 // Required size in bytes
  String? description;          // Optional file description
  DateTime createdAt;           // Auto-generated
  bool isSynced;                // Google Drive sync status
}
```

**Validation Rules**:
- filePath: Must exist and be readable
- fileSize: Must be > 0 and < 50MB
- fileType: Must be supported type (jpg, png, pdf, txt, doc)

### Reminder
**Purpose**: Scheduled notifications for medications and appointments
**Relationships**: Can belong to Medication, or standalone for appointments

```dart
class Reminder {
  String id;                    // UUID primary key
  String? medicationId;         // Optional foreign key to Medication
  String title;                 // Required reminder title
  String? description;          // Optional detailed message
  DateTime scheduledTime;       // Required notification time
  String frequency;             // Required: once, daily, weekly, monthly
  List<int>? daysOfWeek;        // For weekly reminders (1=Monday, 7=Sunday)
  List<String>? timeSlots;      // For multiple daily reminders
  bool isActive;                // Enable/disable reminder
  DateTime? lastSent;           // Last notification timestamp
  DateTime? nextScheduled;      // Next scheduled notification
  int snoozeMinutes;            // Default snooze duration
}
```

**State Transitions**: Active → Snoozed → Active, Active → Completed

### EmergencyCard
**Purpose**: Critical medical information for emergencies
**Relationships**: Belongs to FamilyMemberProfile

```dart
class EmergencyCard {
  String id;                    // UUID primary key
  String profileId;             // Foreign key to FamilyMemberProfile
  List<String> criticalAllergies; // Life-threatening allergies
  List<String> currentMedications; // Essential current medications
  List<String> medicalConditions; // Chronic/critical conditions
  String? emergencyContact;     // Primary emergency contact
  String? secondaryContact;     // Secondary emergency contact
  String? insuranceInfo;        // Insurance/medical ID info
  String? additionalNotes;      // Other critical information
  DateTime lastUpdated;         // Auto-updated
  bool isActive;                // Card enabled/disabled
}
```

## Data Relationships

### Hierarchical Structure
```
FamilyMemberProfile (1)
├── Prescriptions (0..*)
├── LabReports (0..*)
├── Medications (0..*)
├── Vaccinations (0..*)
├── Allergies (0..*)
├── ChronicConditions (0..*)
├── EmergencyCard (0..1)
└── Tags (0..*) ← Many-to-Many with MedicalRecords

MedicalRecord (1)
├── Attachments (0..*)
└── Tags (0..*) ← Many-to-Many

Medication (1)
└── Reminders (0..*)
```

### Cross-References
- Medications can reference ChronicConditions for management tracking
- EmergencyCard aggregates critical information from Allergies, Medications, and ChronicConditions
- Tags provide cross-cutting organization across all record types

## Database Constraints

### Primary Keys
- All entities use UUID strings as primary keys for offline sync compatibility
- Foreign keys are UUID strings referencing parent entities

### Indexes
- profileId on all MedicalRecord subtypes for efficient profile queries
- recordDate on MedicalRecord for chronological sorting
- scheduledTime on Reminder for notification queries
- isActive flags for soft-delete filtering

### Soft Deletes
- All entities support soft deletion via isActive boolean
- Deleted records are hidden from UI but preserved for sync integrity
- Physical deletion only occurs during data export cleanup

---

**Data Model Status**: ✅ COMPLETE
**Next Phase**: Contract Generation