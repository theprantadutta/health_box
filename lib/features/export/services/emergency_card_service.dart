import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/profile_dao.dart';
import '../../medical_records/services/medical_records_service.dart';

/// Service for generating emergency medical cards in PDF format
class EmergencyCardService {
  final ProfileDao _profileDao;
  final MedicalRecordsService _medicalRecordsService;

  EmergencyCardService({
    ProfileDao? profileDao,
    MedicalRecordsService? medicalRecordsService,
  })  : _profileDao = profileDao ?? ProfileDao(AppDatabase.instance),
        _medicalRecordsService = medicalRecordsService ?? MedicalRecordsService();

  /// Generate emergency card for a family member profile
  Future<String> generateEmergencyCard(String profileId, {
    bool includeQRCode = true,
    bool includeMedications = true,
    bool includeAllergies = true,
    bool includeConditions = true,
    String? customNotes,
  }) async {
    try {
      // Get profile data
      final profile = await _profileDao.getProfileById(profileId);
      if (profile == null) {
        throw EmergencyCardException('Profile not found: $profileId');
      }

      // Get medical data
      final emergencyData = await _gatherEmergencyData(
        profileId, 
        includeMedications: includeMedications,
        includeAllergies: includeAllergies,
        includeConditions: includeConditions,
      );

      // Create PDF
      final pdf = pw.Document();
      
      // Generate QR code data if requested
      String? qrCodeData;
      if (includeQRCode) {
        qrCodeData = _generateQRCodeData(profile, emergencyData);
      }

      // Add page to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => _buildEmergencyCard(
            context,
            profile,
            emergencyData,
            qrCodeData: qrCodeData,
            customNotes: customNotes,
          ),
        ),
      );

      // Save PDF
      final output = await _savePDF(pdf, profileId);
      return output;
    } catch (e) {
      throw EmergencyCardException('Failed to generate emergency card: ${e.toString()}');
    }
  }

  /// Generate QR code as image bytes
  Future<Uint8List> generateQRCodeImage(String profileId, {
    double size = 200.0,
  }) async {
    try {
      final profile = await _profileDao.getProfileById(profileId);
      if (profile == null) {
        throw EmergencyCardException('Profile not found: $profileId');
      }

      final emergencyData = await _gatherEmergencyData(profileId);
      final qrData = _generateQRCodeData(profile, emergencyData);

      // Create QR code painter
      final qrPainter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xFF000000),
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF000000),
        ),
      );

      // Convert to image bytes
      final picture = qrPainter.toPicture(size);
      final image = await picture.toImage(size.toInt(), size.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return bytes!.buffer.asUint8List();
    } catch (e) {
      throw EmergencyCardException('Failed to generate QR code: ${e.toString()}');
    }
  }

  /// Create or update emergency card configuration
  Future<String> saveEmergencyCardConfig(EmergencyCardConfig config) async {
    try {
      final cardId = config.id ?? 'emergency_card_${const Uuid().v4()}';
      
      final emergencyCard = EmergencyCardsCompanion(
        id: Value(cardId),
        profileId: Value(config.profileId),
        criticalAllergies: Value(jsonEncode(config.criticalAllergies)),
        currentMedications: Value(jsonEncode(config.currentMedications)),
        medicalConditions: Value(jsonEncode(config.medicalConditions)),
        emergencyContact: Value(config.emergencyContact),
        secondaryContact: Value(config.secondaryContact),
        insuranceInfo: Value(config.insuranceInfo),
        additionalNotes: Value(config.additionalNotes),
        lastUpdated: Value(DateTime.now()),
        isActive: Value(config.isActive),
      );

      if (config.id != null) {
        // Update existing
        await (AppDatabase.instance.update(AppDatabase.instance.emergencyCards)
              ..where((card) => card.id.equals(config.id!)))
            .write(emergencyCard);
      } else {
        // Create new
        await AppDatabase.instance.into(AppDatabase.instance.emergencyCards).insert(emergencyCard);
      }

      return cardId;
    } catch (e) {
      throw EmergencyCardException('Failed to save emergency card config: ${e.toString()}');
    }
  }

  /// Get emergency card configuration for a profile
  Future<EmergencyCardConfig?> getEmergencyCardConfig(String profileId) async {
    try {
      final query = AppDatabase.instance.select(AppDatabase.instance.emergencyCards)
        ..where((card) => card.profileId.equals(profileId) & card.isActive.equals(true))
        ..orderBy([(card) => OrderingTerm(expression: card.lastUpdated, mode: OrderingMode.desc)])
        ..limit(1);

      final card = await query.getSingleOrNull();
      if (card == null) return null;

      return EmergencyCardConfig(
        id: card.id,
        profileId: card.profileId,
        criticalAllergies: _parseJsonList(card.criticalAllergies),
        currentMedications: _parseJsonList(card.currentMedications),
        medicalConditions: _parseJsonList(card.medicalConditions),
        emergencyContact: card.emergencyContact,
        secondaryContact: card.secondaryContact,
        insuranceInfo: card.insuranceInfo,
        additionalNotes: card.additionalNotes,
        isActive: card.isActive,
        lastUpdated: card.lastUpdated,
      );
    } catch (e) {
      throw EmergencyCardException('Failed to get emergency card config: ${e.toString()}');
    }
  }

  /// Delete emergency card configuration
  Future<bool> deleteEmergencyCardConfig(String configId) async {
    try {
      final result = await (AppDatabase.instance.delete(AppDatabase.instance.emergencyCards)
            ..where((card) => card.id.equals(configId)))
          .go();
      return result > 0;
    } catch (e) {
      throw EmergencyCardException('Failed to delete emergency card config: ${e.toString()}');
    }
  }

  // Private Methods

  Future<EmergencyData> _gatherEmergencyData(
    String profileId, {
    bool includeMedications = true,
    bool includeAllergies = true,
    bool includeConditions = true,
  }) async {
    final medications = includeMedications
        ? await _medicalRecordsService.searchRecords(profileId: profileId, recordType: 'medication')
        : <MedicalRecord>[];

    final allergies = includeAllergies
        ? await _medicalRecordsService.searchRecords(profileId: profileId, recordType: 'allergy')
        : <MedicalRecord>[];

    final conditions = includeConditions
        ? await _medicalRecordsService.searchRecords(profileId: profileId, recordType: 'chronic_condition')
        : <MedicalRecord>[];

    return EmergencyData(
      medications: medications,
      allergies: allergies,
      conditions: conditions,
    );
  }

  String _generateQRCodeData(FamilyMemberProfile profile, EmergencyData data) {
    final qrData = {
      'type': 'emergency_medical_card',
      'version': '1.0',
      'profile': {
        'name': '${profile.firstName} ${profile.lastName}',
        'dob': profile.dateOfBirth.toIso8601String().split('T')[0],
        'gender': profile.gender,
        'bloodType': profile.bloodType,
        'emergency_contact': profile.emergencyContact,
      },
      'medical': {
        'critical_allergies': data.allergies
            .take(5) // Take first 5 allergies as they're likely most important
            .map((a) => a.title)
            .toList(),
        'current_medications': data.medications
            .where((m) => m.isActive)
            .take(5) // Limit to prevent QR code from being too complex
            .map((m) => m.title)
            .toList(),
        'conditions': data.conditions
            .take(3) // Limit critical conditions
            .map((c) => c.title)
            .toList(),
      },
      'generated': DateTime.now().toIso8601String(),
    };

    return jsonEncode(qrData);
  }

  pw.Widget _buildEmergencyCard(
    pw.Context context,
    FamilyMemberProfile profile,
    EmergencyData data, {
    String? qrCodeData,
    String? customNotes,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildHeader(profile),
        pw.SizedBox(height: 20),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildPersonalInfo(profile),
                  pw.SizedBox(height: 20),
                  _buildEmergencyContacts(profile),
                  pw.SizedBox(height: 20),
                  _buildCriticalAllergies(data.allergies),
                  pw.SizedBox(height: 20),
                  _buildCurrentMedications(data.medications),
                  pw.SizedBox(height: 20),
                  _buildMedicalConditions(data.conditions),
                  if (customNotes != null) ...[
                    pw.SizedBox(height: 20),
                    _buildCustomNotes(customNotes),
                  ],
                ],
              ),
            ),
            if (qrCodeData != null) ...[
              pw.SizedBox(width: 20),
              pw.Expanded(
                flex: 1,
                child: _buildQRCodeSection(qrCodeData),
              ),
            ],
          ],
        ),
        pw.Spacer(),
        _buildFooter(),
      ],
    );
  }

  pw.Widget _buildHeader(FamilyMemberProfile profile) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.red,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'EMERGENCY MEDICAL CARD',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${profile.firstName} ${profile.lastName}',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPersonalInfo(FamilyMemberProfile profile) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PERSONAL INFORMATION',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red,
            ),
          ),
          pw.SizedBox(height: 8),
          _buildInfoRow('Date of Birth:', _formatDate(profile.dateOfBirth)),
          _buildInfoRow('Gender:', profile.gender),
          if (profile.bloodType != null)
            _buildInfoRow('Blood Type:', profile.bloodType!),
          if (profile.height != null)
            _buildInfoRow('Height:', '${profile.height}cm'),
          if (profile.weight != null)
            _buildInfoRow('Weight:', '${profile.weight}kg'),
        ],
      ),
    );
  }

  pw.Widget _buildEmergencyContacts(FamilyMemberProfile profile) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'EMERGENCY CONTACTS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red,
            ),
          ),
          pw.SizedBox(height: 8),
          if (profile.emergencyContact != null)
            pw.Text(profile.emergencyContact!, style: const pw.TextStyle(fontSize: 12)),
          if (profile.insuranceInfo != null) ...[
            pw.SizedBox(height: 4),
            _buildInfoRow('Insurance:', profile.insuranceInfo!),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildCriticalAllergies(List<MedicalRecord> allergies) {
    final criticalAllergies = allergies; // Use all allergies as critical

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.red),
        borderRadius: pw.BorderRadius.circular(4),
        color: PdfColors.red50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CRITICAL ALLERGIES',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red,
            ),
          ),
          pw.SizedBox(height: 8),
          if (criticalAllergies.isEmpty)
            pw.Text('None reported', style: const pw.TextStyle(fontSize: 12))
          else
            ...criticalAllergies.map((allergy) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: [
                  pw.Text('• ', style: pw.TextStyle(fontSize: 12, color: PdfColors.red)),
                  pw.Expanded(
                    child: pw.Text(
                      allergy.title,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  pw.Widget _buildCurrentMedications(List<MedicalRecord> medications) {
    final activeMedications = medications.where((m) => m.isActive).toList();

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CURRENT MEDICATIONS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red,
            ),
          ),
          pw.SizedBox(height: 8),
          if (activeMedications.isEmpty)
            pw.Text('None reported', style: const pw.TextStyle(fontSize: 12))
          else
            ...activeMedications.take(10).map((medication) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: [
                  pw.Text('• ', style: const pw.TextStyle(fontSize: 12)),
                  pw.Expanded(
                    child: pw.Text(
                      medication.title,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  pw.Widget _buildMedicalConditions(List<MedicalRecord> conditions) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'MEDICAL CONDITIONS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red,
            ),
          ),
          pw.SizedBox(height: 8),
          if (conditions.isEmpty)
            pw.Text('None reported', style: const pw.TextStyle(fontSize: 12))
          else
            ...conditions.take(8).map((condition) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: [
                  pw.Text('• ', style: const pw.TextStyle(fontSize: 12)),
                  pw.Expanded(
                    child: pw.Text(
                      condition.title,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  pw.Widget _buildCustomNotes(String notes) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ADDITIONAL NOTES',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(notes, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  pw.Widget _buildQRCodeSection(String qrData) {
    return pw.Column(
      children: [
        pw.Container(
          width: 150,
          height: 150,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Center(
            child: pw.Text(
              'QR CODE\n(Scan for digital access)',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Scan with phone camera for digital access to emergency information',
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Generated by HealthBox Mobile App',
            style: const pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated on: ${_formatDate(DateTime.now())} - Keep this card with you at all times',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Future<String> _savePDF(pw.Document pdf, String profileId) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'emergency_card_${profileId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$fileName');
    
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);
    
    return file.path;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<String> _parseJsonList(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded.cast<String>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

// Data Classes

class EmergencyData {
  final List<MedicalRecord> medications;
  final List<MedicalRecord> allergies;
  final List<MedicalRecord> conditions;

  const EmergencyData({
    required this.medications,
    required this.allergies,
    required this.conditions,
  });
}

class EmergencyCardConfig {
  final String? id;
  final String profileId;
  final List<String> criticalAllergies;
  final List<String> currentMedications;
  final List<String> medicalConditions;
  final String? emergencyContact;
  final String? secondaryContact;
  final String? insuranceInfo;
  final String? additionalNotes;
  final bool isActive;
  final DateTime? lastUpdated;

  const EmergencyCardConfig({
    this.id,
    required this.profileId,
    this.criticalAllergies = const [],
    this.currentMedications = const [],
    this.medicalConditions = const [],
    this.emergencyContact,
    this.secondaryContact,
    this.insuranceInfo,
    this.additionalNotes,
    this.isActive = true,
    this.lastUpdated,
  });
}

// Exceptions

class EmergencyCardException implements Exception {
  final String message;

  const EmergencyCardException(this.message);

  @override
  String toString() => 'EmergencyCardException: $message';
}