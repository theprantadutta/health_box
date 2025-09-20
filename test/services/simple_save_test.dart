import 'package:flutter_test/flutter_test.dart';
import 'package:health_box/features/medical_records/services/prescription_service.dart';
import 'package:health_box/features/medical_records/services/medication_service.dart';
import 'package:health_box/features/medical_records/services/lab_report_service.dart';
import 'package:health_box/data/models/medication.dart';

void main() {
  group('Service Instantiation Tests', () {
    test('should create PrescriptionService instance', () {
      final service = PrescriptionService();
      expect(service, isNotNull);
    });

    test('should create MedicationService instance', () {
      final service = MedicationService();
      expect(service, isNotNull);
    });

    test('should create LabReportService instance', () {
      final service = LabReportService();
      expect(service, isNotNull);
    });
  });

  group('Request Object Tests', () {
    test('should create CreatePrescriptionRequest', () {
      final request = CreatePrescriptionRequest(
        profileId: 'test_profile',
        title: 'Test Prescription',
        recordDate: DateTime.now(),
        medicationName: 'Test Med',
        dosage: '10mg',
        frequency: 'Once daily',
      );

      expect(request.profileId, equals('test_profile'));
      expect(request.title, equals('Test Prescription'));
      expect(request.medicationName, equals('Test Med'));
      expect(request.dosage, equals('10mg'));
      expect(request.frequency, equals('Once daily'));
      expect(request.isPrescriptionActive, isTrue);
    });

    test('should create CreateMedicationRequest', () {
      final request = CreateMedicationRequest(
        profileId: 'test_profile',
        title: 'Test Medication',
        recordDate: DateTime.now(),
        medicationName: 'Test Med',
        dosage: '5mg',
        frequency: 'Twice daily',
        schedule: '["08:00", "20:00"]',
        startDate: DateTime.now(),
        reminderTimes: const [
          MedicationTime(hour: 8, minute: 0),
          MedicationTime(hour: 20, minute: 0),
        ],
      );

      expect(request.profileId, equals('test_profile'));
      expect(request.title, equals('Test Medication'));
      expect(request.medicationName, equals('Test Med'));
      expect(request.dosage, equals('5mg'));
      expect(request.frequency, equals('Twice daily'));
      expect(request.status, equals(MedicationStatus.active));
      expect(request.reminderEnabled, isTrue);
      expect(request.reminderTimes.length, equals(2));
    });

    test('should create CreateLabReportRequest', () {
      final request = CreateLabReportRequest(
        profileId: 'test_profile',
        title: 'Test Lab Report',
        recordDate: DateTime.now(),
        testName: 'Blood Test',
      );

      expect(request.profileId, equals('test_profile'));
      expect(request.title, equals('Test Lab Report'));
      expect(request.testName, equals('Blood Test'));
      expect(request.testStatus, equals('pending'));
      expect(request.isCritical, isFalse);
    });
  });

  group('Validation Tests', () {
    test('should validate medication status constants', () {
      expect(MedicationStatus.active, equals('active'));
      expect(MedicationStatus.paused, equals('paused'));
      expect(MedicationStatus.completed, equals('completed'));
      expect(MedicationStatus.discontinued, equals('discontinued'));

      expect(MedicationStatus.isValidStatus('active'), isTrue);
      expect(MedicationStatus.isValidStatus('invalid'), isFalse);
      expect(MedicationStatus.allStatuses.length, equals(4));
    });

    test('should create MedicationTime objects', () {
      const time1 = MedicationTime(hour: 8, minute: 30);
      const time2 = MedicationTime(hour: 20, minute: 0);

      expect(time1.hour, equals(8));
      expect(time1.minute, equals(30));
      expect(time2.hour, equals(20));
      expect(time2.minute, equals(0));
    });
  });
}
