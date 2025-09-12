import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:health_box/features/medical_records/services/medical_records_service.dart';
import 'package:health_box/data/repositories/medical_record_dao.dart';
import 'package:health_box/data/models/medical_record.dart';

import 'medical_records_service_test.mocks.dart';

@GenerateMocks([MedicalRecordDao])
void main() {
  late MedicalRecordsService medicalRecordsService;
  late MockMedicalRecordDao mockMedicalRecordDao;

  setUp(() {
    mockMedicalRecordDao = MockMedicalRecordDao();
    medicalRecordsService = MedicalRecordsService(mockMedicalRecordDao);
  });

  group('MedicalRecordsService', () {
    const testRecord = MedicalRecord(
      id: 1,
      profileId: 1,
      type: 'prescription',
      title: 'Test Prescription',
      description: 'Test description',
      date: '2025-01-01',
      createdAt: '2025-01-01T00:00:00.000Z',
      updatedAt: '2025-01-01T00:00:00.000Z',
    );

    group('createRecord', () {
      test('should create record successfully', () async {
        // Arrange
        when(mockMedicalRecordDao.insertRecord(any))
            .thenAnswer((_) async => 1);

        // Act
        final result = await medicalRecordsService.createRecord(
          profileId: testRecord.profileId,
          type: testRecord.type,
          title: testRecord.title,
          description: testRecord.description,
          date: testRecord.date,
        );

        // Assert
        expect(result, equals(1));
        verify(mockMedicalRecordDao.insertRecord(any)).called(1);
      });

      test('should throw exception when dao throws', () async {
        // Arrange
        when(mockMedicalRecordDao.insertRecord(any))
            .thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => medicalRecordsService.createRecord(
            profileId: testRecord.profileId,
            type: testRecord.type,
            title: testRecord.title,
            description: testRecord.description,
            date: testRecord.date,
          ),
          throwsException,
        );
      });
    });

    group('getRecord', () {
      test('should return record when found', () async {
        // Arrange
        when(mockMedicalRecordDao.getRecordById(1))
            .thenAnswer((_) async => testRecord);

        // Act
        final result = await medicalRecordsService.getRecord(1);

        // Assert
        expect(result, equals(testRecord));
        verify(mockMedicalRecordDao.getRecordById(1)).called(1);
      });

      test('should return null when record not found', () async {
        // Arrange
        when(mockMedicalRecordDao.getRecordById(1))
            .thenAnswer((_) async => null);

        // Act
        final result = await medicalRecordsService.getRecord(1);

        // Assert
        expect(result, isNull);
        verify(mockMedicalRecordDao.getRecordById(1)).called(1);
      });
    });

    group('getRecordsByProfile', () {
      test('should return records for profile', () async {
        // Arrange
        final records = [testRecord];
        when(mockMedicalRecordDao.getRecordsByProfile(1))
            .thenAnswer((_) async => records);

        // Act
        final result = await medicalRecordsService.getRecordsByProfile(1);

        // Assert
        expect(result, equals(records));
        verify(mockMedicalRecordDao.getRecordsByProfile(1)).called(1);
      });

      test('should return empty list when no records exist', () async {
        // Arrange
        when(mockMedicalRecordDao.getRecordsByProfile(1))
            .thenAnswer((_) async => <MedicalRecord>[]);

        // Act
        final result = await medicalRecordsService.getRecordsByProfile(1);

        // Assert
        expect(result, isEmpty);
        verify(mockMedicalRecordDao.getRecordsByProfile(1)).called(1);
      });
    });

    group('getRecordsByType', () {
      test('should return records of specific type', () async {
        // Arrange
        final records = [testRecord];
        when(mockMedicalRecordDao.getRecordsByType(1, 'prescription'))
            .thenAnswer((_) async => records);

        // Act
        final result = await medicalRecordsService.getRecordsByType(1, 'prescription');

        // Assert
        expect(result, equals(records));
        verify(mockMedicalRecordDao.getRecordsByType(1, 'prescription')).called(1);
      });
    });

    group('searchRecords', () {
      test('should return matching records', () async {
        // Arrange
        final matchingRecords = [testRecord];
        when(mockMedicalRecordDao.searchRecords(1, 'Test'))
            .thenAnswer((_) async => matchingRecords);

        // Act
        final result = await medicalRecordsService.searchRecords(1, 'Test');

        // Assert
        expect(result, equals(matchingRecords));
        verify(mockMedicalRecordDao.searchRecords(1, 'Test')).called(1);
      });

      test('should return empty list when no matches found', () async {
        // Arrange
        when(mockMedicalRecordDao.searchRecords(1, 'NonExistent'))
            .thenAnswer((_) async => <MedicalRecord>[]);

        // Act
        final result = await medicalRecordsService.searchRecords(1, 'NonExistent');

        // Assert
        expect(result, isEmpty);
        verify(mockMedicalRecordDao.searchRecords(1, 'NonExistent')).called(1);
      });
    });

    group('updateRecord', () {
      test('should update record successfully', () async {
        // Arrange
        final updatedRecord = testRecord.copyWith(title: 'Updated Title');
        when(mockMedicalRecordDao.updateRecord(updatedRecord))
            .thenAnswer((_) async => true);

        // Act
        final result = await medicalRecordsService.updateRecord(updatedRecord);

        // Assert
        expect(result, isTrue);
        verify(mockMedicalRecordDao.updateRecord(updatedRecord)).called(1);
      });

      test('should return false when update fails', () async {
        // Arrange
        when(mockMedicalRecordDao.updateRecord(any))
            .thenAnswer((_) async => false);

        // Act
        final result = await medicalRecordsService.updateRecord(testRecord);

        // Assert
        expect(result, isFalse);
        verify(mockMedicalRecordDao.updateRecord(testRecord)).called(1);
      });
    });

    group('deleteRecord', () {
      test('should delete record successfully', () async {
        // Arrange
        when(mockMedicalRecordDao.deleteRecord(1))
            .thenAnswer((_) async => true);

        // Act
        final result = await medicalRecordsService.deleteRecord(1);

        // Assert
        expect(result, isTrue);
        verify(mockMedicalRecordDao.deleteRecord(1)).called(1);
      });

      test('should return false when delete fails', () async {
        // Arrange
        when(mockMedicalRecordDao.deleteRecord(1))
            .thenAnswer((_) async => false);

        // Act
        final result = await medicalRecordsService.deleteRecord(1);

        // Assert
        expect(result, isFalse);
        verify(mockMedicalRecordDao.deleteRecord(1)).called(1);
      });
    });

    group('getRecordsByDateRange', () {
      test('should return records in date range', () async {
        // Arrange
        final records = [testRecord];
        when(mockMedicalRecordDao.getRecordsByDateRange(1, '2025-01-01', '2025-12-31'))
            .thenAnswer((_) async => records);

        // Act
        final result = await medicalRecordsService.getRecordsByDateRange(
          1, 
          '2025-01-01', 
          '2025-12-31'
        );

        // Assert
        expect(result, equals(records));
        verify(mockMedicalRecordDao.getRecordsByDateRange(1, '2025-01-01', '2025-12-31')).called(1);
      });
    });
  });
}