import 'package:flutter_test/flutter_test.dart';
import 'package:health_box/data/database/app_database.dart';
import 'package:health_box/features/medical_records/services/prescription_service.dart';
import 'package:health_box/features/medical_records/services/medication_service.dart';
import 'package:health_box/features/medical_records/services/lab_report_service.dart';
import 'package:health_box/data/repositories/medical_record_dao.dart';
import 'package:health_box/data/repositories/reminder_dao.dart';
import 'package:health_box/data/models/medication.dart';

void main() {
  late AppDatabase database;
  late PrescriptionService prescriptionService;
  late MedicationService medicationService;
  late LabReportService labReportService;

  setUp(() async {
    // Create an in-memory database for testing
    database = AppDatabase.instance;

    // Initialize services with test database
    final medicalRecordDao = MedicalRecordDao(database);
    final reminderDao = ReminderDao(database);

    prescriptionService = PrescriptionService(
      medicalRecordDao: medicalRecordDao,
      database: database,
    );

    medicationService = MedicationService(
      medicalRecordDao: medicalRecordDao,
      reminderDao: reminderDao,
      database: database,
    );

    labReportService = LabReportService(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  group('Prescription Save Tests', () {
    test('should create a new prescription successfully', () async {
      const profileId = 'test_profile_123';

      final request = CreatePrescriptionRequest(
        profileId: profileId,
        title: 'Test Prescription',
        description: 'Test prescription for unit testing',
        recordDate: DateTime.now(),
        medicationName: 'Test Medication',
        dosage: '10mg',
        frequency: 'Once daily',
        instructions: 'Take with food',
        prescribingDoctor: 'Dr. Test',
        pharmacy: 'Test Pharmacy',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        refillsRemaining: 3,
        isPrescriptionActive: true,
      );

      final prescriptionId = await prescriptionService.createPrescription(
        request,
      );

      expect(prescriptionId, isNotEmpty);
      expect(prescriptionId, startsWith('prescription_'));

      // Verify the prescription was saved
      final savedPrescription = await prescriptionService.getPrescriptionById(
        prescriptionId,
      );
      expect(savedPrescription, isNotNull);
      expect(savedPrescription!.title, equals('Test Prescription'));
      expect(savedPrescription.medicationName, equals('Test Medication'));
      expect(savedPrescription.dosage, equals('10mg'));
      expect(savedPrescription.frequency, equals('Once daily'));
    });

    test('should retrieve all prescriptions for a profile', () async {
      const profileId = 'test_profile_123';

      // Create multiple prescriptions
      for (int i = 1; i <= 3; i++) {
        final request = CreatePrescriptionRequest(
          profileId: profileId,
          title: 'Test Prescription $i',
          recordDate: DateTime.now(),
          medicationName: 'Test Medication $i',
          dosage: '${i * 10}mg',
          frequency: 'Once daily',
        );

        await prescriptionService.createPrescription(request);
      }

      final prescriptions = await prescriptionService.getAllPrescriptions(
        profileId: profileId,
      );
      expect(prescriptions.length, equals(3));
      expect(prescriptions.every((p) => p.profileId == profileId), isTrue);
    });
  });

  group('Medication Save Tests', () {
    test('should create a new medication successfully', () async {
      const profileId = 'test_profile_123';

      final request = CreateMedicationRequest(
        profileId: profileId,
        title: 'Test Medication',
        description: 'Test medication for unit testing',
        recordDate: DateTime.now(),
        medicationName: 'Test Med',
        dosage: '5mg',
        frequency: 'Twice daily',
        schedule: '["08:00", "20:00"]',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 60)),
        instructions: 'Take with water',
        reminderEnabled: true,
        pillCount: 60,
        status: MedicationStatus.active,
        reminderTimes: const [
          MedicationTime(hour: 8, minute: 0),
          MedicationTime(hour: 20, minute: 0),
        ],
      );

      final medicationId = await medicationService.createMedication(request);

      expect(medicationId, isNotEmpty);
      expect(medicationId, startsWith('medication_'));

      // Verify the medication was saved
      final savedMedication = await medicationService.getMedicationById(
        medicationId,
      );
      expect(savedMedication, isNotNull);
      expect(savedMedication!.title, equals('Test Medication'));
      expect(savedMedication.medicationName, equals('Test Med'));
      expect(savedMedication.dosage, equals('5mg'));
      expect(savedMedication.frequency, equals('Twice daily'));
      expect(savedMedication.status, equals(MedicationStatus.active));
    });

    test('should update medication status', () async {
      const profileId = 'test_profile_123';

      final request = CreateMedicationRequest(
        profileId: profileId,
        title: 'Test Medication',
        recordDate: DateTime.now(),
        medicationName: 'Test Med',
        dosage: '5mg',
        frequency: 'Once daily',
        schedule: '["08:00"]',
        startDate: DateTime.now(),
        status: MedicationStatus.active,
        reminderTimes: const [],
      );

      final medicationId = await medicationService.createMedication(request);

      // Update status to paused
      final updated = await medicationService.updateMedicationStatus(
        medicationId,
        MedicationStatus.paused,
      );

      expect(updated, isTrue);

      // Verify status was updated
      final medication = await medicationService.getMedicationById(
        medicationId,
      );
      expect(medication!.status, equals(MedicationStatus.paused));
    });
  });

  group('Lab Report Save Tests', () {
    test('should create a new lab report successfully', () async {
      const profileId = 'test_profile_123';

      final request = CreateLabReportRequest(
        profileId: profileId,
        title: 'Blood Test Results',
        description: 'Complete blood count test results',
        recordDate: DateTime.now(),
        testName: 'Complete Blood Count',
        testResults: 'All values within normal range',
        referenceRange: 'Normal: 4.5-11.0 x10^9/L',
        orderingPhysician: 'Dr. Test',
        labFacility: 'Test Lab',
        testStatus: 'completed',
        collectionDate: DateTime.now().subtract(const Duration(days: 1)),
        isCritical: false,
      );

      final labReportId = await labReportService.createLabReport(request);

      expect(labReportId, isNotEmpty);
      expect(labReportId, startsWith('lab_report_'));

      // Verify the lab report was saved
      final savedLabReport = await labReportService.getLabReportById(
        labReportId,
      );
      expect(savedLabReport, isNotNull);
      expect(savedLabReport!.title, equals('Blood Test Results'));
      expect(savedLabReport.testName, equals('Complete Blood Count'));
      expect(savedLabReport.testStatus, equals('completed'));
      expect(savedLabReport.isCritical, isFalse);
    });

    test('should retrieve lab reports by test name', () async {
      const profileId = 'test_profile_123';

      // Create multiple lab reports
      final testNames = ['Blood Test', 'Urine Test', 'Blood Sugar Test'];

      for (final testName in testNames) {
        final request = CreateLabReportRequest(
          profileId: profileId,
          title: '$testName Results',
          recordDate: DateTime.now(),
          testName: testName,
          testStatus: 'completed',
        );

        await labReportService.createLabReport(request);
      }

      // Search for blood tests
      final bloodTests = await labReportService.getLabReportsByTestName(
        'Blood',
        profileId: profileId,
      );

      expect(bloodTests.length, equals(2)); // Blood Test and Blood Sugar Test
      expect(
        bloodTests.every((test) => test.testName.contains('Blood')),
        isTrue,
      );
    });

    test('should handle critical lab reports', () async {
      const profileId = 'test_profile_123';

      final request = CreateLabReportRequest(
        profileId: profileId,
        title: 'Critical Lab Results',
        recordDate: DateTime.now(),
        testName: 'Critical Test',
        testResults: 'Abnormal values detected',
        testStatus: 'completed',
        isCritical: true,
      );

      final labReportId = await labReportService.createLabReport(request);

      // Verify critical flag
      final savedLabReport = await labReportService.getLabReportById(
        labReportId,
      );
      expect(savedLabReport!.isCritical, isTrue);

      // Test critical reports query
      final criticalReports = await labReportService.getCriticalLabReports(
        profileId: profileId,
      );

      expect(criticalReports.length, equals(1));
      expect(criticalReports.first.id, equals(labReportId));
    });
  });

  group('Integration Tests', () {
    test('should save all three record types for the same profile', () async {
      const profileId = 'integration_test_profile';

      // Create prescription
      final prescriptionRequest = CreatePrescriptionRequest(
        profileId: profileId,
        title: 'Integration Test Prescription',
        recordDate: DateTime.now(),
        medicationName: 'Integration Med',
        dosage: '10mg',
        frequency: 'Once daily',
      );

      final prescriptionId = await prescriptionService.createPrescription(
        prescriptionRequest,
      );

      // Create medication
      final medicationRequest = CreateMedicationRequest(
        profileId: profileId,
        title: 'Integration Test Medication',
        recordDate: DateTime.now(),
        medicationName: 'Integration Med',
        dosage: '5mg',
        frequency: 'Twice daily',
        schedule: '["08:00", "20:00"]',
        startDate: DateTime.now(),
        status: MedicationStatus.active,
        reminderTimes: const [],
      );

      final medicationId = await medicationService.createMedication(
        medicationRequest,
      );

      // Create lab report
      final labReportRequest = CreateLabReportRequest(
        profileId: profileId,
        title: 'Integration Test Lab Report',
        recordDate: DateTime.now(),
        testName: 'Integration Test',
        testStatus: 'completed',
      );

      final labReportId = await labReportService.createLabReport(
        labReportRequest,
      );

      // Verify all records were created
      expect(prescriptionId, isNotEmpty);
      expect(medicationId, isNotEmpty);
      expect(labReportId, isNotEmpty);

      // Verify they can be retrieved
      final prescription = await prescriptionService.getPrescriptionById(
        prescriptionId,
      );
      final medication = await medicationService.getMedicationById(
        medicationId,
      );
      final labReport = await labReportService.getLabReportById(labReportId);

      expect(prescription, isNotNull);
      expect(medication, isNotNull);
      expect(labReport, isNotNull);

      // Verify they all belong to the same profile
      expect(prescription!.profileId, equals(profileId));
      expect(medication!.profileId, equals(profileId));
      expect(labReport!.profileId, equals(profileId));
    });
  });
}
