import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/database/app_database.dart';
import '../../features/medical_records/services/medical_records_service.dart';
import '../../features/medical_records/services/prescription_service.dart';
import '../../features/medical_records/services/medication_service.dart';
import '../../features/medical_records/services/lab_report_service.dart';

// Service providers
final medicalRecordsServiceProvider = Provider<MedicalRecordsService>((ref) {
  return MedicalRecordsService();
});

final prescriptionServiceProvider = Provider<PrescriptionService>((ref) {
  return PrescriptionService();
});

final medicationServiceProvider = Provider<MedicationService>((ref) {
  return MedicationService();
});

final labReportServiceProvider = Provider<LabReportService>((ref) {
  return LabReportService();
});

// Medical Records providers
final allMedicalRecordsProvider = FutureProvider<List<MedicalRecord>>((
  ref,
) async {
  final service = ref.read(medicalRecordsServiceProvider);
  return service.getAllRecords();
});

final recordsByProfileIdProvider =
    FutureProvider.family<List<MedicalRecord>, String>((ref, profileId) async {
      final service = ref.read(medicalRecordsServiceProvider);
      return service.getRecordsByProfileId(profileId);
    });

final recordsByTypeProvider =
    FutureProvider.family<List<MedicalRecord>, String>((ref, recordType) async {
      final service = ref.read(medicalRecordsServiceProvider);
      return service.getRecordsByType(recordType);
    });

final medicalRecordByIdProvider = FutureProvider.family<MedicalRecord?, String>(
  (ref, recordId) async {
    final service = ref.read(medicalRecordsServiceProvider);
    return service.getRecordById(recordId);
  },
);

final recentMedicalRecordsProvider =
    FutureProvider.family<List<MedicalRecord>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      try {
        final service = ref.read(medicalRecordsServiceProvider);
        final limit = params['limit'] as int? ?? 10;
        final profileId = params['profileId'] as String?;
        return await service.getRecentRecords(
          limit: limit,
          profileId: profileId,
        );
      } catch (e) {
        // If there's any error (like table doesn't exist), return empty list
        // This prevents infinite loading states
        print('Error loading recent medical records: $e');
        return <MedicalRecord>[];
      }
    });

final medicalRecordsStatisticsProvider =
    FutureProvider.family<MedicalRecordsStatistics, String?>((
      ref,
      profileId,
    ) async {
      final service = ref.read(medicalRecordsServiceProvider);
      return service.getRecordsStatistics(profileId: profileId);
    });

// Prescription providers
final allPrescriptionsProvider = FutureProvider<List<Prescription>>((
  ref,
) async {
  final service = ref.read(prescriptionServiceProvider);
  return service.getAllPrescriptions();
});

final prescriptionsByProfileIdProvider =
    FutureProvider.family<List<Prescription>, String>((ref, profileId) async {
      final service = ref.read(prescriptionServiceProvider);
      return service.getAllPrescriptions(profileId: profileId);
    });

final activePrescriptionsProvider =
    FutureProvider.family<List<Prescription>, String?>((ref, profileId) async {
      final service = ref.read(prescriptionServiceProvider);
      return service.getActivePrescriptions(profileId: profileId);
    });

final expiringPrescriptionsProvider =
    FutureProvider.family<List<Prescription>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final service = ref.read(prescriptionServiceProvider);
      final daysAhead = params['daysAhead'] as int? ?? 30;
      final profileId = params['profileId'] as String?;
      return service.getExpiringPrescriptions(
        daysAhead: daysAhead,
        profileId: profileId,
      );
    });

// Medication providers
final allMedicationsProvider = FutureProvider<List<Medication>>((ref) async {
  final service = ref.read(medicationServiceProvider);
  return service.getAllMedications();
});

final medicationsByProfileIdProvider =
    FutureProvider.family<List<Medication>, String>((ref, profileId) async {
      final service = ref.read(medicationServiceProvider);
      return service.getAllMedications(profileId: profileId);
    });

final activeMedicationsProvider =
    FutureProvider.family<List<Medication>, String?>((ref, profileId) async {
      final service = ref.read(medicationServiceProvider);
      return service.getActiveMedications(profileId: profileId);
    });

final lowInventoryMedicationsProvider =
    FutureProvider.family<List<Medication>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final service = ref.read(medicationServiceProvider);
      final threshold = params['threshold'] as int? ?? 7;
      final profileId = params['profileId'] as String?;
      return service.getMedicationsLowOnPills(
        threshold: threshold,
        profileId: profileId,
      );
    });

// Lab Report providers
final allLabReportsProvider = FutureProvider<List<LabReport>>((ref) async {
  final service = ref.read(labReportServiceProvider);
  return service.getAllLabReports();
});

final labReportsByProfileIdProvider =
    FutureProvider.family<List<LabReport>, String>((ref, profileId) async {
      final service = ref.read(labReportServiceProvider);
      return service.getAllLabReports(profileId: profileId);
    });

final pendingLabReportsProvider =
    FutureProvider.family<List<LabReport>, String?>((ref, profileId) async {
      final service = ref.read(labReportServiceProvider);
      return service.getPendingLabReports(profileId: profileId);
    });

final criticalLabReportsProvider =
    FutureProvider.family<List<LabReport>, String?>((ref, profileId) async {
      final service = ref.read(labReportServiceProvider);
      return service.getCriticalLabReports(profileId: profileId);
    });

// Stream providers for real-time updates
final watchRecordsByProfileProvider =
    StreamProvider.family<List<MedicalRecord>, String>((ref, profileId) {
      final service = ref.read(medicalRecordsServiceProvider);
      return service.watchRecordsByProfile(profileId);
    });

final watchRecordsByTypeProvider =
    StreamProvider.family<List<MedicalRecord>, String>((ref, recordType) {
      final service = ref.read(medicalRecordsServiceProvider);
      return service.watchRecordsByType(recordType);
    });

final watchMedicalRecordProvider =
    StreamProvider.family<MedicalRecord?, String>((ref, recordId) {
      final service = ref.read(medicalRecordsServiceProvider);
      return service.watchRecord(recordId);
    });

// Medical Records management state
class MedicalRecordsState {
  final List<MedicalRecord> records;
  final MedicalRecord? selectedRecord;
  final String? selectedProfileId;
  final String? selectedRecordType;
  final bool isLoading;
  final String? error;

  const MedicalRecordsState({
    this.records = const [],
    this.selectedRecord,
    this.selectedProfileId,
    this.selectedRecordType,
    this.isLoading = false,
    this.error,
  });

  MedicalRecordsState copyWith({
    List<MedicalRecord>? records,
    MedicalRecord? selectedRecord,
    String? selectedProfileId,
    String? selectedRecordType,
    bool? isLoading,
    String? error,
  }) {
    return MedicalRecordsState(
      records: records ?? this.records,
      selectedRecord: selectedRecord ?? this.selectedRecord,
      selectedProfileId: selectedProfileId ?? this.selectedProfileId,
      selectedRecordType: selectedRecordType ?? this.selectedRecordType,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MedicalRecordsNotifier extends StateNotifier<MedicalRecordsState> {
  MedicalRecordsNotifier(this.ref) : super(const MedicalRecordsState());

  final Ref ref;

  Future<void> loadAllRecords() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(medicalRecordsServiceProvider);
      final records = await service.getAllRecords();
      state = state.copyWith(records: records, isLoading: false);
    } catch (error) {
      state = state.copyWith(error: error.toString(), isLoading: false);
    }
  }

  Future<void> loadRecordsByProfile(String profileId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedProfileId: profileId,
    );

    try {
      final service = ref.read(medicalRecordsServiceProvider);
      final records = await service.getRecordsByProfileId(profileId);
      state = state.copyWith(records: records, isLoading: false);
    } catch (error) {
      state = state.copyWith(error: error.toString(), isLoading: false);
    }
  }

  Future<void> createRecord(CreateMedicalRecordRequest request) async {
    try {
      final service = ref.read(medicalRecordsServiceProvider);
      await service.createRecord(request);

      // Refresh records list
      if (state.selectedProfileId != null) {
        await loadRecordsByProfile(state.selectedProfileId!);
      } else {
        await loadAllRecords();
      }

      // Invalidate related providers
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(medicalRecordsStatisticsProvider);
      ref.invalidate(recentMedicalRecordsProvider);
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> updateRecord(
    String recordId,
    UpdateMedicalRecordRequest request,
  ) async {
    try {
      final service = ref.read(medicalRecordsServiceProvider);
      await service.updateRecord(recordId, request);

      // Refresh records list
      if (state.selectedProfileId != null) {
        await loadRecordsByProfile(state.selectedProfileId!);
      } else {
        await loadAllRecords();
      }

      // Invalidate related providers
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recentMedicalRecordsProvider);
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> deleteRecord(String recordId) async {
    try {
      final service = ref.read(medicalRecordsServiceProvider);
      await service.deleteRecord(recordId);

      // Clear selected record if it was deleted
      if (state.selectedRecord?.id == recordId) {
        state = state.copyWith(selectedRecord: null);
      }

      // Refresh records list
      if (state.selectedProfileId != null) {
        await loadRecordsByProfile(state.selectedProfileId!);
      } else {
        await loadAllRecords();
      }

      // Invalidate related providers
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(medicalRecordsStatisticsProvider);
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  void selectRecord(MedicalRecord? record) {
    state = state.copyWith(selectedRecord: record);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final medicalRecordsNotifierProvider =
    StateNotifierProvider<MedicalRecordsNotifier, MedicalRecordsState>((ref) {
      return MedicalRecordsNotifier(ref);
    });

// Medication management state
class MedicationState {
  final List<Medication> medications;
  final Medication? selectedMedication;
  final bool isLoading;
  final String? error;

  const MedicationState({
    this.medications = const [],
    this.selectedMedication,
    this.isLoading = false,
    this.error,
  });

  MedicationState copyWith({
    List<Medication>? medications,
    Medication? selectedMedication,
    bool? isLoading,
    String? error,
  }) {
    return MedicationState(
      medications: medications ?? this.medications,
      selectedMedication: selectedMedication ?? this.selectedMedication,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MedicationNotifier extends StateNotifier<MedicationState> {
  MedicationNotifier(this.ref) : super(const MedicationState());

  final Ref ref;

  Future<void> loadMedications({String? profileId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(medicationServiceProvider);
      List<Medication> medications;

      if (profileId != null) {
        medications = await service.getAllMedications(profileId: profileId);
      } else {
        medications = await service.getAllMedications();
      }

      state = state.copyWith(medications: medications, isLoading: false);
    } catch (error) {
      state = state.copyWith(error: error.toString(), isLoading: false);
    }
  }

  Future<void> createMedication(CreateMedicationRequest request) async {
    try {
      final service = ref.read(medicationServiceProvider);
      await service.createMedication(request);

      // Refresh medications list
      await loadMedications();

      // Invalidate related providers
      ref.invalidate(allMedicationsProvider);
      ref.invalidate(activeMedicationsProvider);
      ref.invalidate(lowInventoryMedicationsProvider);
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> updateMedicationStatus(
    String medicationId,
    String status,
  ) async {
    try {
      final service = ref.read(medicationServiceProvider);
      await service.updateMedicationStatus(medicationId, status);

      // Refresh medications list
      await loadMedications();

      // Invalidate related providers
      ref.invalidate(activeMedicationsProvider);
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final medicationNotifierProvider =
    StateNotifierProvider<MedicationNotifier, MedicationState>((ref) {
      return MedicationNotifier(ref);
    });
