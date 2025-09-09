import 'package:flutter_test/flutter_test.dart';
import '../../specs/001-build-a-mobile/contracts/export_service_contract.dart';
import '../../specs/001-build-a-mobile/contracts/shared_models.dart';

void main() {
  group('ExportServiceContract', () {
    late ExportServiceContract service;

    setUpAll(() async {
      // This will fail until we implement ExportService
      throw UnimplementedError('ExportService not yet implemented - this test MUST fail');
    });

    group('exportProfileData', () {
      test('should export profile data as PDF', () async {
        final filePath = await service.exportProfileData(
          profileId: 'test-profile-id',
          format: ExportFormat.pdf,
        );
        
        expect(filePath, isNotEmpty);
        expect(filePath, endsWith('.pdf'));
      });

      test('should export profile data as CSV', () async {
        final filePath = await service.exportProfileData(
          profileId: 'test-profile-id',
          format: ExportFormat.csv,
        );
        
        expect(filePath, endsWith('.csv'));
      });

      test('should export profile data as JSON', () async {
        final filePath = await service.exportProfileData(
          profileId: 'test-profile-id',
          format: ExportFormat.json,
        );
        
        expect(filePath, endsWith('.json'));
      });

      test('should export with encrypted ZIP format', () async {
        final filePath = await service.exportProfileData(
          profileId: 'test-profile-id',
          format: ExportFormat.encryptedZip,
          password: 'test-password',
        );
        
        expect(filePath, endsWith('.zip'));
      });

      test('should export with date range filter', () async {
        final fromDate = DateTime.now().subtract(const Duration(days: 30));
        final toDate = DateTime.now();
        
        final filePath = await service.exportProfileData(
          profileId: 'test-profile-id',
          format: ExportFormat.json,
          fromDate: fromDate,
          toDate: toDate,
        );
        
        expect(filePath, isNotEmpty);
      });

      test('should export specific record types only', () async {
        final filePath = await service.exportProfileData(
          profileId: 'test-profile-id',
          format: ExportFormat.json,
          recordTypes: ['prescription', 'lab_report'],
        );
        
        expect(filePath, isNotEmpty);
      });

      test('should exclude attachments when specified', () async {
        final filePath = await service.exportProfileData(
          profileId: 'test-profile-id',
          format: ExportFormat.json,
          includeAttachments: false,
        );
        
        expect(filePath, isNotEmpty);
      });
    });

    group('exportAllProfiles', () {
      test('should export all profiles data', () async {
        final filePath = await service.exportAllProfiles(
          format: ExportFormat.json,
        );
        
        expect(filePath, isNotEmpty);
        expect(filePath, contains('all_profiles'));
      });

      test('should export all profiles with filters', () async {
        final filePath = await service.exportAllProfiles(
          format: ExportFormat.csv,
          recordTypes: ['medication', 'vaccination'],
          includeAttachments: false,
        );
        
        expect(filePath, isNotEmpty);
      });

      test('should create encrypted export of all profiles', () async {
        final filePath = await service.exportAllProfiles(
          format: ExportFormat.encryptedZip,
          password: 'secure-password',
        );
        
        expect(filePath, endsWith('.zip'));
      });
    });

    group('generateEmergencyCard', () {
      test('should generate PDF emergency card', () async {
        final filePath = await service.generateEmergencyCard(
          profileId: 'test-profile-id',
          format: EmergencyCardFormat.pdfCard,
        );
        
        expect(filePath, isNotEmpty);
        expect(filePath, endsWith('.pdf'));
      });

      test('should generate full page PDF emergency card', () async {
        final filePath = await service.generateEmergencyCard(
          profileId: 'test-profile-id',
          format: EmergencyCardFormat.pdfFull,
        );
        
        expect(filePath, endsWith('.pdf'));
      });

      test('should generate image emergency card', () async {
        final filePath = await service.generateEmergencyCard(
          profileId: 'test-profile-id',
          format: EmergencyCardFormat.image,
        );
        
        expect(filePath, endsWith('.png'));
      });

      test('should generate QR code emergency card', () async {
        final filePath = await service.generateEmergencyCard(
          profileId: 'test-profile-id',
          format: EmergencyCardFormat.qrCode,
        );
        
        expect(filePath, isNotEmpty);
      });

      test('should include photo in emergency card', () async {
        final filePath = await service.generateEmergencyCard(
          profileId: 'test-profile-id',
          format: EmergencyCardFormat.pdfFull,
          includePhoto: true,
        );
        
        expect(filePath, isNotEmpty);
      });

      test('should include additional fields', () async {
        final filePath = await service.generateEmergencyCard(
          profileId: 'test-profile-id',
          format: EmergencyCardFormat.pdfCard,
          additionalFields: ['blood_type', 'special_instructions'],
        );
        
        expect(filePath, isNotEmpty);
      });
    });

    group('importData', () {
      test('should import JSON data successfully', () async {
        final result = await service.importData(
          filePath: '/path/to/export.json',
        );
        
        expect(result.success, isTrue);
        expect(result.profilesImported, greaterThanOrEqualTo(0));
        expect(result.recordsImported, greaterThanOrEqualTo(0));
        expect(result.filesImported, greaterThanOrEqualTo(0));
        expect(result.errors, isA<List<String>>());
        expect(result.warnings, isA<List<String>>());
        expect(result.skippedRecords, isA<List<String>>());
      });

      test('should import encrypted data with password', () async {
        final result = await service.importData(
          filePath: '/path/to/encrypted_export.zip',
          password: 'import-password',
        );
        
        expect(result.success, isTrue);
      });

      test('should import with custom options', () async {
        final options = ImportOptions(
          mergeExistingProfiles: true,
          skipDuplicateRecords: true,
          importAttachments: false,
          updateExistingRecords: true,
        );
        
        final result = await service.importData(
          filePath: '/path/to/export.json',
          options: options,
        );
        
        expect(result.success, isTrue);
      });

      test('should handle import errors gracefully', () async {
        final result = await service.importData(
          filePath: '/path/to/corrupted_file.json',
        );
        
        expect(result.success, isFalse);
        expect(result.errors, isNotEmpty);
      });

      test('should report warnings for minor issues', () async {
        final result = await service.importData(
          filePath: '/path/to/export_with_warnings.json',
        );
        
        expect(result.success, isTrue);
        expect(result.warnings, isNotEmpty);
      });
    });

    group('validateImportFile', () {
      test('should validate JSON import file', () async {
        final validation = await service.validateImportFile(
          filePath: '/path/to/valid_export.json',
        );
        
        expect(validation.isValid, isTrue);
        expect(validation.fileFormat, equals('json'));
        expect(validation.estimatedProfiles, greaterThanOrEqualTo(0));
        expect(validation.estimatedRecords, greaterThanOrEqualTo(0));
        expect(validation.estimatedFiles, greaterThanOrEqualTo(0));
        expect(validation.issues, isA<List<String>>());
        expect(validation.requiresPassword, isFalse);
      });

      test('should validate encrypted import file', () async {
        final validation = await service.validateImportFile(
          filePath: '/path/to/encrypted_export.zip',
        );
        
        expect(validation.requiresPassword, isTrue);
      });

      test('should identify invalid import file', () async {
        final validation = await service.validateImportFile(
          filePath: '/path/to/invalid_file.txt',
        );
        
        expect(validation.isValid, isFalse);
        expect(validation.issues, isNotEmpty);
      });

      test('should validate encrypted file with password', () async {
        final validation = await service.validateImportFile(
          filePath: '/path/to/encrypted_export.zip',
          password: 'test-password',
        );
        
        expect(validation.isValid, isTrue);
      });
    });

    group('getExportHistory', () {
      test('should return export history with default limit', () async {
        final history = await service.getExportHistory();
        
        expect(history, isA<List<ExportHistoryEntry>>());
        expect(history.length, lessThanOrEqualTo(50));
      });

      test('should respect custom limit', () async {
        final history = await service.getExportHistory(limit: 10);
        
        expect(history.length, lessThanOrEqualTo(10));
      });

      test('should return entries with complete information', () async {
        final history = await service.getExportHistory();
        
        if (history.isNotEmpty) {
          final entry = history.first;
          expect(entry.id, isNotEmpty);
          expect(entry.timestamp, isA<DateTime>());
          expect(entry.profileId, isNotEmpty);
          expect(entry.format, isA<ExportFormat>());
          expect(entry.filePath, isNotEmpty);
          expect(entry.recordCount, isA<int>());
          expect(entry.includeAttachments, isA<bool>());
        }
      });
    });

    group('shareExportedFile', () {
      test('should share exported file successfully', () async {
        final result = await service.shareExportedFile(
          filePath: '/path/to/exported_data.pdf',
        );
        
        expect(result, isTrue);
      });

      test('should share with custom title and text', () async {
        final result = await service.shareExportedFile(
          filePath: '/path/to/exported_data.pdf',
          shareTitle: 'Medical Data Export',
          shareText: 'Here is my medical data export',
        );
        
        expect(result, isTrue);
      });

      test('should handle share failure', () async {
        final result = await service.shareExportedFile(
          filePath: '/path/to/nonexistent_file.pdf',
        );
        
        expect(result, isFalse);
      });
    });

    group('deleteExportedFile', () {
      test('should delete exported file successfully', () async {
        final result = await service.deleteExportedFile(
          '/path/to/exported_data.pdf',
        );
        
        expect(result, isTrue);
      });

      test('should handle deletion of non-existent file', () async {
        final result = await service.deleteExportedFile(
          '/path/to/nonexistent_file.pdf',
        );
        
        expect(result, isFalse);
      });
    });
  });

  group('EmergencyCardServiceContract', () {
    late EmergencyCardServiceContract service;

    setUpAll(() {
      throw UnimplementedError('EmergencyCardService not yet implemented - this test MUST fail');
    });

    group('createEmergencyCard', () {
      test('should create emergency card with full information', () async {
        final cardId = await service.createEmergencyCard(
          profileId: 'test-profile-id',
          criticalAllergies: ['Penicillin', 'Shellfish'],
          currentMedications: ['Lisinopril 10mg', 'Aspirin 81mg'],
          medicalConditions: ['Hypertension', 'Diabetes Type 2'],
          emergencyContact: 'John Doe - (555) 123-4567',
          secondaryContact: 'Jane Smith - (555) 987-6543',
          insuranceInfo: 'Blue Cross Blue Shield - Policy #12345',
          additionalNotes: 'DNR on file',
        );
        
        expect(cardId, isNotEmpty);
        expect(cardId.length, equals(36)); // UUID length
      });

      test('should create minimal emergency card', () async {
        final cardId = await service.createEmergencyCard(
          profileId: 'test-profile-id',
        );
        
        expect(cardId, isNotEmpty);
      });

      test('should update existing emergency card', () async {
        final cardId = await service.createEmergencyCard(
          profileId: 'existing-profile-id',
          criticalAllergies: ['Updated allergy info'],
        );
        
        expect(cardId, isNotEmpty);
      });
    });

    group('getEmergencyCard', () {
      test('should return emergency card for existing profile', () async {
        final card = await service.getEmergencyCard('profile-with-card');
        
        expect(card, isNotNull);
        expect(card!.profileId, equals('profile-with-card'));
        expect(card.criticalAllergies, isA<List<String>>());
        expect(card.currentMedications, isA<List<String>>());
        expect(card.medicalConditions, isA<List<String>>());
      });

      test('should return null for profile without emergency card', () async {
        final card = await service.getEmergencyCard('profile-without-card');
        
        expect(card, isNull);
      });

      test('should return null for non-existent profile', () async {
        final card = await service.getEmergencyCard('non-existent-profile');
        
        expect(card, isNull);
      });
    });

    group('generatePrintableCard', () {
      test('should generate PDF card with QR code', () async {
        final filePath = await service.generatePrintableCard(
          profileId: 'test-profile-id',
          format: EmergencyCardFormat.pdfCard,
          includeQRCode: true,
        );
        
        expect(filePath, isNotEmpty);
        expect(filePath, endsWith('.pdf'));
      });

      test('should generate full page PDF without photo', () async {
        final filePath = await service.generatePrintableCard(
          profileId: 'test-profile-id',
          format: EmergencyCardFormat.pdfFull,
          includeQRCode: false,
          includePhoto: false,
        );
        
        expect(filePath, endsWith('.pdf'));
      });

      test('should generate image format with photo', () async {
        final filePath = await service.generatePrintableCard(
          profileId: 'test-profile-id',
          format: EmergencyCardFormat.image,
          includePhoto: true,
        );
        
        expect(filePath, endsWith('.png'));
      });

      test('should generate QR code only', () async {
        final filePath = await service.generatePrintableCard(
          profileId: 'test-profile-id',
          format: EmergencyCardFormat.qrCode,
        );
        
        expect(filePath, isNotEmpty);
      });
    });

    group('generateEmergencyQRCode', () {
      test('should generate QR code for emergency info', () async {
        final qrCodePath = await service.generateEmergencyQRCode(
          'test-profile-id',
        );
        
        expect(qrCodePath, isNotEmpty);
        expect(qrCodePath, contains('qr'));
      });

      test('should handle profile without emergency card', () async {
        final qrCodePath = await service.generateEmergencyQRCode(
          'profile-without-card',
        );
        
        expect(qrCodePath, isNotEmpty);
      });

      test('should generate unique QR codes for different profiles', () async {
        final qrCode1 = await service.generateEmergencyQRCode('profile-1');
        final qrCode2 = await service.generateEmergencyQRCode('profile-2');
        
        expect(qrCode1, isNot(equals(qrCode2)));
      });
    });
  });
}