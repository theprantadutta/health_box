import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

enum OCRSource { camera, gallery }

enum OCRType { prescription, medicalReport, labResult, general }

class OCRResult {
  final bool success;
  final String? text;
  final String? error;
  final List<TextBlock>? textBlocks;
  final Map<String, dynamic>? extractedData;
  final double confidence;
  final OCRType type;

  OCRResult({
    required this.success,
    this.text,
    this.error,
    this.textBlocks,
    this.extractedData,
    this.confidence = 0.0,
    required this.type,
  });

  bool get hasText => text != null && text!.isNotEmpty;
  bool get hasStructuredData =>
      extractedData != null && extractedData!.isNotEmpty;
}

class ExtractedMedication {
  final String name;
  final String? dosage;
  final String? frequency;
  final String? duration;
  final String? instructions;
  final double confidence;

  ExtractedMedication({
    required this.name,
    this.dosage,
    this.frequency,
    this.duration,
    this.instructions,
    this.confidence = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'dosage': dosage,
    'frequency': frequency,
    'duration': duration,
    'instructions': instructions,
    'confidence': confidence,
  };
}

class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  final Logger _logger = Logger();
  final ImagePicker _imagePicker = ImagePicker();

  late final TextRecognizer _textRecognizer;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _textRecognizer = TextRecognizer();
      _initialized = true;
      _logger.i('OCR Service initialized successfully');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize OCR service',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<OCRResult> scanFromSource({
    required OCRSource source,
    OCRType type = OCRType.general,
  }) async {
    try {
      await initialize();

      XFile? imageFile;
      switch (source) {
        case OCRSource.camera:
          imageFile = await _imagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1920,
            maxHeight: 1080,
            imageQuality: 85,
          );
          break;
        case OCRSource.gallery:
          imageFile = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1920,
            maxHeight: 1080,
            imageQuality: 85,
          );
          break;
      }

      if (imageFile == null) {
        return OCRResult(
          success: false,
          error: 'No image selected',
          type: type,
        );
      }

      return await scanFromFile(imageFile.path, type: type);
    } catch (e, stackTrace) {
      _logger.e('OCR scan failed', error: e, stackTrace: stackTrace);
      return OCRResult(success: false, error: e.toString(), type: type);
    }
  }

  Future<OCRResult> scanFromFile(
    String imagePath, {
    OCRType type = OCRType.general,
  }) async {
    try {
      await initialize();

      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        return OCRResult(
          success: false,
          error: 'No text found in image',
          type: type,
        );
      }

      // Extract structured data based on OCR type
      Map<String, dynamic>? extractedData;
      double confidence = _calculateOverallConfidence(recognizedText.blocks);

      switch (type) {
        case OCRType.prescription:
          extractedData = await _extractPrescriptionData(recognizedText);
          break;
        case OCRType.medicalReport:
          extractedData = await _extractMedicalReportData(recognizedText);
          break;
        case OCRType.labResult:
          extractedData = await _extractLabResultData(recognizedText);
          break;
        case OCRType.general:
          extractedData = await _extractGeneralData(recognizedText);
          break;
      }

      return OCRResult(
        success: true,
        text: recognizedText.text,
        textBlocks: recognizedText.blocks,
        extractedData: extractedData,
        confidence: confidence,
        type: type,
      );
    } catch (e, stackTrace) {
      _logger.e('OCR processing failed', error: e, stackTrace: stackTrace);
      return OCRResult(success: false, error: e.toString(), type: type);
    }
  }

  Future<OCRResult> scanFromBytes(
    Uint8List imageBytes, {
    OCRType type = OCRType.general,
  }) async {
    try {
      await initialize();

      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: const Size(
            800,
            600,
          ), // Default size - should be actual image size
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 800,
        ),
      );

      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        return OCRResult(
          success: false,
          error: 'No text found in image',
          type: type,
        );
      }

      Map<String, dynamic>? extractedData;
      double confidence = _calculateOverallConfidence(recognizedText.blocks);

      switch (type) {
        case OCRType.prescription:
          extractedData = await _extractPrescriptionData(recognizedText);
          break;
        case OCRType.medicalReport:
          extractedData = await _extractMedicalReportData(recognizedText);
          break;
        case OCRType.labResult:
          extractedData = await _extractLabResultData(recognizedText);
          break;
        case OCRType.general:
          extractedData = await _extractGeneralData(recognizedText);
          break;
      }

      return OCRResult(
        success: true,
        text: recognizedText.text,
        textBlocks: recognizedText.blocks,
        extractedData: extractedData,
        confidence: confidence,
        type: type,
      );
    } catch (e, stackTrace) {
      _logger.e(
        'OCR processing from bytes failed',
        error: e,
        stackTrace: stackTrace,
      );
      return OCRResult(success: false, error: e.toString(), type: type);
    }
  }

  Future<Map<String, dynamic>> _extractPrescriptionData(
    RecognizedText recognizedText,
  ) async {
    final data = <String, dynamic>{};
    final medications = <ExtractedMedication>[];

    // Common prescription patterns
    final medicationPattern = RegExp(
      r'(?:^|\n)\s*([A-Z][a-zA-Z\s]+(?:mg|ML|tablets?|capsules?)?)\s*[\n\-:]?\s*([0-9]+(?:\.[0-9]+)?\s*(?:mg|ML|tablets?|capsules?)?)?',
      multiLine: true,
    );

    final frequencyPattern = RegExp(
      r'(?:take|use|apply)\s+([0-9]+)\s+(?:time[s]?\s+(?:per\s+|a\s+)?(?:day|daily|week|month)|(?:daily|twice\s+daily|morning|evening))',
      caseSensitive: false,
    );

    final text = recognizedText.text;
    final medicationMatches = medicationPattern.allMatches(text);

    for (final match in medicationMatches) {
      final name = match.group(1)?.trim();
      final dosage = match.group(2)?.trim();

      if (name != null && name.length > 2) {
        // Look for frequency information near this medication
        String? frequency;
        final frequencyMatch = frequencyPattern.firstMatch(text);
        if (frequencyMatch != null) {
          frequency = frequencyMatch.group(1);
        }

        medications.add(
          ExtractedMedication(
            name: name,
            dosage: dosage,
            frequency: frequency,
            confidence: 0.7, // Basic confidence score
          ),
        );
      }
    }

    data['medications'] = medications.map((m) => m.toJson()).toList();
    data['rawText'] = text;

    // Extract doctor/clinic information
    final doctorPattern = RegExp(
      r'(?:Dr\.?\s+|Doctor\s+)([A-Z][a-zA-Z\s]+)',
      caseSensitive: false,
    );
    final doctorMatch = doctorPattern.firstMatch(text);
    if (doctorMatch != null) {
      data['prescribedBy'] = doctorMatch.group(1)?.trim();
    }

    // Extract date
    final datePattern = RegExp(
      r'(?:date[:\s]*)?(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})',
      caseSensitive: false,
    );
    final dateMatch = datePattern.firstMatch(text);
    if (dateMatch != null) {
      data['prescriptionDate'] = dateMatch.group(1);
    }

    return data;
  }

  Future<Map<String, dynamic>> _extractMedicalReportData(
    RecognizedText recognizedText,
  ) async {
    final data = <String, dynamic>{};
    final text = recognizedText.text;

    // Extract patient information
    final patientPattern = RegExp(
      r'(?:patient[:\s]+|name[:\s]+)([A-Z][a-zA-Z\s]+)',
      caseSensitive: false,
    );
    final patientMatch = patientPattern.firstMatch(text);
    if (patientMatch != null) {
      data['patientName'] = patientMatch.group(1)?.trim();
    }

    // Extract report type
    final reportTypePattern = RegExp(
      r'(X[-\s]?RAY|MRI|CT\s+SCAN|ULTRASOUND|ECG|EKG|BLOOD\s+TEST|URINE\s+TEST)',
      caseSensitive: false,
    );
    final reportTypeMatch = reportTypePattern.firstMatch(text);
    if (reportTypeMatch != null) {
      data['reportType'] = reportTypeMatch.group(1)?.trim();
    }

    // Extract findings
    final findingsPattern = RegExp(
      r'(?:findings?[:\s]+|impression[:\s]+|diagnosis[:\s]+)([^\n]+(?:\n[^\n]+)*)',
      caseSensitive: false,
    );
    final findingsMatch = findingsPattern.firstMatch(text);
    if (findingsMatch != null) {
      data['findings'] = findingsMatch.group(1)?.trim();
    }

    data['rawText'] = text;
    return data;
  }

  Future<Map<String, dynamic>> _extractLabResultData(
    RecognizedText recognizedText,
  ) async {
    final data = <String, dynamic>{};
    final text = recognizedText.text;
    final results = <Map<String, dynamic>>[];

    // Extract lab values
    final labValuePattern = RegExp(
      r'([A-Z][a-zA-Z\s]+)[\s:]+([0-9]+(?:\.[0-9]+)?)\s*([a-zA-Z/%]+)?(?:\s+\(([0-9\.\-\s]+)\))?',
      multiLine: true,
    );

    final matches = labValuePattern.allMatches(text);
    for (final match in matches) {
      final testName = match.group(1)?.trim();
      final value = match.group(2)?.trim();
      final unit = match.group(3)?.trim();
      final referenceRange = match.group(4)?.trim();

      if (testName != null && value != null) {
        results.add({
          'testName': testName,
          'value': value,
          'unit': unit,
          'referenceRange': referenceRange,
        });
      }
    }

    data['results'] = results;
    data['rawText'] = text;
    return data;
  }

  Future<Map<String, dynamic>> _extractGeneralData(
    RecognizedText recognizedText,
  ) async {
    final data = <String, dynamic>{};
    final text = recognizedText.text;

    // Extract key-value pairs
    final keyValuePattern = RegExp(
      r'([A-Z][a-zA-Z\s]+)[\s:]+([^\n]+)',
      multiLine: true,
    );

    final matches = keyValuePattern.allMatches(text);
    final extractedFields = <String, String>{};

    for (final match in matches) {
      final key = match.group(1)?.trim();
      final value = match.group(2)?.trim();

      if (key != null && value != null && key.length > 2 && value.length > 1) {
        extractedFields[key] = value;
      }
    }

    data['extractedFields'] = extractedFields;
    data['rawText'] = text;
    return data;
  }

  double _calculateOverallConfidence(List<TextBlock> blocks) {
    if (blocks.isEmpty) return 0.0;

    double totalConfidence = 0.0;
    int elementCount = 0;

    for (final block in blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          // ML Kit doesn't provide confidence scores directly in newer versions
          // We'll use text length and character patterns as a proxy
          final text = element.text;
          double confidence = 0.5; // Base confidence

          // Boost confidence for longer, well-formatted text
          if (text.length > 5) confidence += 0.2;
          if (RegExp(r'^[A-Za-z0-9\s\.,:\-]+$').hasMatch(text))
            confidence += 0.2;
          if (text.contains(RegExp(r'[A-Z]'))) confidence += 0.1;

          totalConfidence += confidence;
          elementCount++;
        }
      }
    }

    return elementCount > 0 ? totalConfidence / elementCount : 0.0;
  }

  List<String> getCommonMedications() {
    return [
      'Acetaminophen',
      'Ibuprofen',
      'Aspirin',
      'Amoxicillin',
      'Lisinopril',
      'Simvastatin',
      'Levothyroxine',
      'Metformin',
      'Amlodipine',
      'Omeprazole',
      'Losartan',
      'Albuterol',
      'Hydrochlorothiazide',
      'Gabapentin',
      'Sertraline',
      'Furosemide',
      'Prednisone',
      'Trazodone',
      'Tramadol',
      'Citalopram',
    ];
  }

  List<String> getSuggestions(String query) {
    if (query.length < 2) return [];

    final medications = getCommonMedications();
    return medications
        .where((med) => med.toLowerCase().contains(query.toLowerCase()))
        .take(10)
        .toList();
  }

  Future<bool> isImageSuitableForOCR(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return false;

      final fileSize = await file.length();

      // Check file size (should be reasonable for processing)
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        return false;
      }

      if (fileSize < 1024) {
        // Too small
        return false;
      }

      return true;
    } catch (e) {
      _logger.w('Failed to check image suitability', error: e);
      return false;
    }
  }

  void dispose() {
    if (_initialized) {
      _textRecognizer.close();
      _initialized = false;
    }
  }
}
