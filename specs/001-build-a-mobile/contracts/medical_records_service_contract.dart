// Medical Records Service Contract - CRUD operations for all medical record types
// Corresponds to FR-003: Users MUST be able to add, edit, and delete medical records

import 'shared_models.dart';

abstract class MedicalRecordsServiceContract {
  // Create new medical record
  // Returns: Record ID on success, throws ValidationException on invalid data
  Future<String> createRecord({
    required String profileId,
    required String recordType, // prescription, lab_report, medication, etc.
    required String title,
    String? description,
    required DateTime recordDate,
    required Map<String, dynamic> typeSpecificData,
  });

  // Update existing medical record
  // Returns: true on success, throws RecordNotFoundException if not found
  Future<bool> updateRecord({
    required String recordId,
    String? title,
    String? description,
    DateTime? recordDate,
    Map<String, dynamic>? typeSpecificData,
  });

  // Get record by ID
  // Returns: MedicalRecord or null if not found
  Future<MedicalRecord?> getRecord(String recordId);

  // Get all records for a profile
  // Returns: List of medical records, optionally filtered by type
  Future<List<MedicalRecord>> getRecordsForProfile({
    required String profileId,
    String? recordType,
    DateTime? fromDate,
    DateTime? toDate,
  });

  // Search records across profile
  // Corresponds to FR-013: System MUST provide search functionality
  Future<List<MedicalRecord>> searchRecords({
    required String profileId,
    required String query,
    List<String>? recordTypes,
    List<String>? tagIds,
  });

  // Filter and tag records
  // Corresponds to FR-005: Users MUST be able to filter and tag medical records
  Future<List<MedicalRecord>> filterRecords({
    required String profileId,
    List<String>? recordTypes,
    List<String>? tagIds,
    DateTime? fromDate,
    DateTime? toDate,
    String? sortBy,
    bool ascending = true,
  });

  // Soft delete record
  // Returns: true on success, throws RecordNotFoundException if not found
  Future<bool> deleteRecord(String recordId);

  // Validate medical record data
  ValidationResult validateRecordData({
    required String recordType,
    required String title,
    String? description,
    required DateTime recordDate,
    required Map<String, dynamic> typeSpecificData,
  });
}

// Prescription-specific operations
abstract class PrescriptionServiceContract {
  Future<String> createPrescription({
    required String profileId,
    required String title,
    required String medicationName,
    required String dosage,
    required String frequency,
    String? instructions,
    String? prescribingDoctor,
    String? pharmacy,
    DateTime? startDate,
    DateTime? endDate,
    int? refillsRemaining,
  });

  Future<bool> updatePrescriptionStatus(String prescriptionId, bool isActive);
  Future<List<Prescription>> getActivePrescriptions(String profileId);
}

// Medication-specific operations (for ongoing tracking)
abstract class MedicationServiceContract {
  Future<String> createMedication({
    required String profileId,
    required String medicationName,
    required String dosage,
    required String frequency,
    required List<String> schedule,
    required DateTime startDate,
    DateTime? endDate,
    String? instructions,
    bool reminderEnabled = true,
    int? pillCount,
  });

  Future<bool> updateMedicationStatus(String medicationId, String status);
  Future<List<Medication>> getActiveMedications(String profileId);
  Future<bool> recordMedicationTaken(String medicationId, DateTime takenAt);
}

// Lab Report-specific operations
abstract class LabReportServiceContract {
  Future<String> createLabReport({
    required String profileId,
    required String title,
    required String testName,
    String? testResults,
    String? referenceRange,
    String? orderingPhysician,
    String? labFacility,
    required String testStatus,
    DateTime? collectionDate,
    bool isCritical = false,
  });

  Future<bool> updateTestStatus(String reportId, String status);
  Future<List<LabReport>> getCriticalResults(String profileId);
}

class RecordNotFoundException implements Exception {
  final String recordId;
  RecordNotFoundException(this.recordId);
}