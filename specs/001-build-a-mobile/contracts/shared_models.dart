// Shared models and classes for service contracts

// Base validation classes
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({required this.isValid, required this.errors});
}

class ValidationException implements Exception {
  final List<String> errors;
  ValidationException(this.errors);
}

// Domain models (simplified for contract testing)
class FamilyMemberProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final DateTime dateOfBirth;
  final String gender;
  final String? bloodType;
  final double? height;
  final double? weight;
  final String? emergencyContact;
  final String? insuranceInfo;
  final String? profileImagePath;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  FamilyMemberProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.dateOfBirth,
    required this.gender,
    this.bloodType,
    this.height,
    this.weight,
    this.emergencyContact,
    this.insuranceInfo,
    this.profileImagePath,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}

class MedicalRecord {
  final String id;
  final String profileId;
  final String recordType;
  final String title;
  final String? description;
  final DateTime recordDate;
  final Map<String, dynamic> typeSpecificData;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalRecord({
    required this.id,
    required this.profileId,
    required this.recordType,
    required this.title,
    this.description,
    required this.recordDate,
    required this.typeSpecificData,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Prescription {
  final String id;
  final String profileId;
  final String title;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String? instructions;
  final String? prescribingDoctor;
  final String? pharmacy;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? refillsRemaining;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Prescription({
    required this.id,
    required this.profileId,
    required this.title,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    this.instructions,
    this.prescribingDoctor,
    this.pharmacy,
    this.startDate,
    this.endDate,
    this.refillsRemaining,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Medication {
  final String id;
  final String profileId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final List<String> schedule;
  final DateTime startDate;
  final DateTime? endDate;
  final String? instructions;
  final bool reminderEnabled;
  final int? pillCount;
  final String status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    required this.id,
    required this.profileId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.schedule,
    required this.startDate,
    this.endDate,
    this.instructions,
    required this.reminderEnabled,
    this.pillCount,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}

class LabReport {
  final String id;
  final String profileId;
  final String title;
  final String testName;
  final String? testResults;
  final String? referenceRange;
  final String? orderingPhysician;
  final String? labFacility;
  final String testStatus;
  final DateTime? collectionDate;
  final bool isCritical;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  LabReport({
    required this.id,
    required this.profileId,
    required this.title,
    required this.testName,
    this.testResults,
    this.referenceRange,
    this.orderingPhysician,
    this.labFacility,
    required this.testStatus,
    this.collectionDate,
    required this.isCritical,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Reminder {
  final String id;
  final String? medicationId;
  final String title;
  final String? description;
  final DateTime scheduledTime;
  final String frequency;
  final List<int>? daysOfWeek;
  final List<String>? timeSlots;
  final int snoozeMinutes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reminder({
    required this.id,
    this.medicationId,
    required this.title,
    this.description,
    required this.scheduledTime,
    required this.frequency,
    this.daysOfWeek,
    this.timeSlots,
    required this.snoozeMinutes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}

class EmergencyCard {
  final String id;
  final String profileId;
  final List<String> criticalAllergies;
  final List<String> currentMedications;
  final List<String> medicalConditions;
  final String? emergencyContact;
  final String? secondaryContact;
  final String? insuranceInfo;
  final String? additionalNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmergencyCard({
    required this.id,
    required this.profileId,
    required this.criticalAllergies,
    required this.currentMedications,
    required this.medicalConditions,
    this.emergencyContact,
    this.secondaryContact,
    this.insuranceInfo,
    this.additionalNotes,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Tag {
  final String id;
  final String name;
  final String color;
  final String? description;
  final int usageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tag({
    required this.id,
    required this.name,
    required this.color,
    this.description,
    required this.usageCount,
    required this.createdAt,
    required this.updatedAt,
  });
}
