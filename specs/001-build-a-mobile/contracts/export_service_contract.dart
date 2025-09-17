// Export Service Contract - Data export and emergency cards
// Corresponds to FR-006: System MUST generate emergency medical cards
// Corresponds to FR-007: Users MUST be able to export medical data
// Corresponds to FR-008: System MUST support import of previously exported data

import 'shared_models.dart';

abstract class ExportServiceContract {
  // Export medical data for profile
  // Returns: file path of exported data on success
  Future<String> exportProfileData({
    required String profileId,
    required ExportFormat format,
    List<String>? recordTypes, // null = all types
    DateTime? fromDate,
    DateTime? toDate,
    bool includeAttachments = true,
    String? password, // for encrypted exports
  });

  // Export all profiles
  // Returns: file path of exported data
  Future<String> exportAllProfiles({
    required ExportFormat format,
    List<String>? recordTypes,
    DateTime? fromDate,
    DateTime? toDate,
    bool includeAttachments = true,
    String? password,
  });

  // Generate emergency medical card
  // Returns: file path of generated emergency card
  Future<String> generateEmergencyCard({
    required String profileId,
    required EmergencyCardFormat format,
    bool includePhoto = false,
    List<String>? additionalFields,
  });

  // Import medical data
  // Returns: ImportResult with details of imported records
  Future<ImportResult> importData({
    required String filePath,
    String? password, // for encrypted imports
    ImportOptions? options,
  });

  // Validate import file
  // Returns: ImportValidation with file details and issues
  Future<ImportValidation> validateImportFile({
    required String filePath,
    String? password,
  });

  // Get export history
  Future<List<ExportHistoryEntry>> getExportHistory({int limit = 50});

  // Share exported file
  // Returns: true on successful share
  Future<bool> shareExportedFile({
    required String filePath,
    String? shareTitle,
    String? shareText,
  });

  // Delete exported file
  Future<bool> deleteExportedFile(String filePath);
}

// Emergency card specific operations
abstract class EmergencyCardServiceContract {
  // Create/update emergency card for profile
  Future<String> createEmergencyCard({
    required String profileId,
    List<String>? criticalAllergies,
    List<String>? currentMedications,
    List<String>? medicalConditions,
    String? emergencyContact,
    String? secondaryContact,
    String? insuranceInfo,
    String? additionalNotes,
  });

  // Get emergency card data
  Future<EmergencyCard?> getEmergencyCard(String profileId);

  // Generate printable emergency card
  Future<String> generatePrintableCard({
    required String profileId,
    required EmergencyCardFormat format,
    bool includeQRCode = true,
    bool includePhoto = false,
  });

  // Generate QR code with emergency info
  Future<String> generateEmergencyQRCode(String profileId);
}

enum ExportFormat {
  pdf, // PDF report with formatting
  csv, // Comma-separated values
  json, // JSON with full data structure
  encryptedZip, // Encrypted ZIP archive
  plainZip, // Unencrypted ZIP archive
}

enum EmergencyCardFormat {
  pdfCard, // Credit card sized PDF
  pdfFull, // Full page PDF with details
  image, // PNG image for phone wallpaper
  qrCode, // QR code only
}

class ImportResult {
  final bool success;
  final int profilesImported;
  final int recordsImported;
  final int filesImported;
  final List<String> errors;
  final List<String> warnings;
  final List<String> skippedRecords;

  ImportResult({
    required this.success,
    required this.profilesImported,
    required this.recordsImported,
    required this.filesImported,
    required this.errors,
    required this.warnings,
    required this.skippedRecords,
  });
}

class ImportOptions {
  final bool mergeExistingProfiles;
  final bool skipDuplicateRecords;
  final bool importAttachments;
  final bool updateExistingRecords;

  ImportOptions({
    this.mergeExistingProfiles = false,
    this.skipDuplicateRecords = true,
    this.importAttachments = true,
    this.updateExistingRecords = false,
  });
}

class ImportValidation {
  final bool isValid;
  final String fileFormat;
  final int estimatedProfiles;
  final int estimatedRecords;
  final int estimatedFiles;
  final List<String> issues;
  final bool requiresPassword;

  ImportValidation({
    required this.isValid,
    required this.fileFormat,
    required this.estimatedProfiles,
    required this.estimatedRecords,
    required this.estimatedFiles,
    required this.issues,
    required this.requiresPassword,
  });
}

class ExportHistoryEntry {
  final String id;
  final DateTime timestamp;
  final String profileId;
  final ExportFormat format;
  final String filePath;
  final int recordCount;
  final bool includeAttachments;

  ExportHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.profileId,
    required this.format,
    required this.filePath,
    required this.recordCount,
    required this.includeAttachments,
  });
}
