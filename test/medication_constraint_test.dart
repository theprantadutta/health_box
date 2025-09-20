import 'package:flutter_test/flutter_test.dart';
import 'package:health_box/features/medical_records/services/medication_service.dart';
import 'package:health_box/data/models/medication.dart';

void main() {
  group('Medication Date Constraint Tests', () {
    test('should accept valid start date', () {
      final request = CreateMedicationRequest(
        profileId: 'test_profile',
        title: 'Test Medication',
        recordDate: DateTime.now(),
        medicationName: 'Test Med',
        dosage: '5mg',
        frequency: 'Once daily',
        schedule: '["08:00"]',
        startDate: DateTime.now(), // Valid current date
        reminderTimes: const [],
      );

      // Should not throw validation error
      expect(request.startDate.isAfter(DateTime(2020, 1, 1)), isTrue);
      expect(request.startDate.isBefore(DateTime.now().add(const Duration(days: 365))), isTrue);
    });

    test('should validate medication status', () {
      expect(MedicationStatus.isValidStatus('active'), isTrue);
      expect(MedicationStatus.isValidStatus('paused'), isTrue);
      expect(MedicationStatus.isValidStatus('completed'), isTrue);
      expect(MedicationStatus.isValidStatus('discontinued'), isTrue);
      expect(MedicationStatus.isValidStatus('invalid'), isFalse);
    });

    test('should create medication time objects', () {
      const time1 = MedicationTime(hour: 8, minute: 0);
      const time2 = MedicationTime(hour: 20, minute: 30);

      expect(time1.hour, equals(8));
      expect(time1.minute, equals(0));
      expect(time2.hour, equals(20));
      expect(time2.minute, equals(30));
    });
  });
}
