import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../features/medical_records/services/prescription_service.dart';
import '../../features/medical_records/services/medication_service.dart';
import '../../features/medical_records/services/lab_report_service.dart';
import '../../data/models/medication.dart';
import 'medical_records_providers.dart';
import 'package:flutter/foundation.dart';

// Save state management for UI feedback
class SaveState {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final String? savedRecordId;

  const SaveState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.savedRecordId,
  });

  SaveState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    String? savedRecordId,
  }) {
    return SaveState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
      savedRecordId: savedRecordId ?? this.savedRecordId,
    );
  }
}

// Prescription Save Provider
class PrescriptionSaveNotifier extends StateNotifier<SaveState> {
  PrescriptionSaveNotifier(this.ref) : super(const SaveState());

  final Ref ref;

  Future<String?> savePrescription(CreatePrescriptionRequest request) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final service = PrescriptionService();
      final prescriptionId = await service.createPrescription(request);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Prescription saved successfully!',
        savedRecordId: prescriptionId,
      );

      // Invalidate related providers to refresh UI
      ref.invalidate(allPrescriptionsProvider);
      ref.invalidate(activePrescriptionsProvider);
      // Also invalidate medical records providers so the records screen refreshes
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider);

      return prescriptionId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save prescription: ${e.toString()}',
      );
      return null;
    }
  }

  void clearState() {
    state = const SaveState();
  }
}

final prescriptionSaveProvider =
    StateNotifierProvider<PrescriptionSaveNotifier, SaveState>((ref) {
      return PrescriptionSaveNotifier(ref);
    });

// Medication Save Provider
class MedicationSaveNotifier extends StateNotifier<SaveState> {
  MedicationSaveNotifier(this.ref) : super(const SaveState());

  final Ref ref;

  Future<String?> saveMedication(CreateMedicationRequest request) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final service = MedicationService();
      final medicationId = await service.createMedication(request);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Medication saved successfully!',
        savedRecordId: medicationId,
      );

      // Invalidate related providers to refresh UI
      ref.invalidate(allMedicationsProvider);
      ref.invalidate(activeMedicationsProvider);
      // Also invalidate medical records providers so the records screen refreshes
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider);

      return medicationId;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save medication: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save medication: ${e.toString()}',
      );
      return null;
    }
  }

  void clearState() {
    state = const SaveState();
  }
}

final medicationSaveProvider =
    StateNotifierProvider<MedicationSaveNotifier, SaveState>((ref) {
      return MedicationSaveNotifier(ref);
    });

// Lab Report Save Provider
class LabReportSaveNotifier extends StateNotifier<SaveState> {
  LabReportSaveNotifier(this.ref) : super(const SaveState());

  final Ref ref;

  Future<String?> saveLabReport(CreateLabReportRequest request) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final service = LabReportService();
      final labReportId = await service.createLabReport(request);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Lab report saved successfully!',
        savedRecordId: labReportId,
      );

      // Invalidate related providers to refresh UI
      ref.invalidate(allLabReportsProvider);
      ref.invalidate(pendingLabReportsProvider);
      ref.invalidate(criticalLabReportsProvider);
      // Also invalidate medical records providers so the records screen refreshes
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider);

      return labReportId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save lab report: ${e.toString()}',
      );
      return null;
    }
  }

  void clearState() {
    state = const SaveState();
  }
}

final labReportSaveProvider =
    StateNotifierProvider<LabReportSaveNotifier, SaveState>((ref) {
      return LabReportSaveNotifier(ref);
    });

// Note: The providers referenced above are imported from medical_records_providers.dart

// Convenience providers for quick access to services
final quickPrescriptionServiceProvider = Provider<PrescriptionService>((ref) {
  return PrescriptionService();
});

final quickMedicationServiceProvider = Provider<MedicationService>((ref) {
  return MedicationService();
});

final quickLabReportServiceProvider = Provider<LabReportService>((ref) {
  return LabReportService();
});

// Helper functions for creating common requests
class MedicalRecordHelpers {
  static CreatePrescriptionRequest createPrescriptionRequest({
    required String profileId,
    required String title,
    required String medicationName,
    required String dosage,
    required String frequency,
    String? description,
    String? instructions,
    String? prescribingDoctor,
    String? pharmacy,
    DateTime? startDate,
    DateTime? endDate,
    int? refillsRemaining,
    bool isPrescriptionActive = true,
  }) {
    return CreatePrescriptionRequest(
      profileId: profileId,
      title: title,
      description: description,
      recordDate: DateTime.now(),
      medicationName: medicationName,
      dosage: dosage,
      frequency: frequency,
      instructions: instructions,
      prescribingDoctor: prescribingDoctor,
      pharmacy: pharmacy,
      startDate: startDate,
      endDate: endDate,
      refillsRemaining: refillsRemaining,
      isPrescriptionActive: isPrescriptionActive,
    );
  }

  static CreateMedicationRequest createMedicationRequest({
    required String profileId,
    required String title,
    required String medicationName,
    required String dosage,
    required String frequency,
    required String schedule,
    String? description,
    String? instructions,
    DateTime? startDate,
    DateTime? endDate,
    bool reminderEnabled = true,
    int? pillCount,
    String status = MedicationStatus.active,
    List<MedicationTime> reminderTimes = const [],
  }) {
    return CreateMedicationRequest(
      profileId: profileId,
      title: title,
      description: description,
      recordDate: DateTime.now(),
      medicationName: medicationName,
      dosage: dosage,
      frequency: frequency,
      schedule: schedule,
      startDate: startDate ?? DateTime.now(),
      endDate: endDate,
      instructions: instructions,
      reminderEnabled: reminderEnabled,
      pillCount: pillCount,
      status: status,
      reminderTimes: reminderTimes,
    );
  }

  static CreateLabReportRequest createLabReportRequest({
    required String profileId,
    required String title,
    required String testName,
    String? description,
    String? testResults,
    String? referenceRange,
    String? orderingPhysician,
    String? labFacility,
    String testStatus = 'pending',
    DateTime? collectionDate,
    bool isCritical = false,
  }) {
    return CreateLabReportRequest(
      profileId: profileId,
      title: title,
      description: description,
      recordDate: DateTime.now(),
      testName: testName,
      testResults: testResults,
      referenceRange: referenceRange,
      orderingPhysician: orderingPhysician,
      labFacility: labFacility,
      testStatus: testStatus,
      collectionDate: collectionDate,
      isCritical: isCritical,
    );
  }
}
