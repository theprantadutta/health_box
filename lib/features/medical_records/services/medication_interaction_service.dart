import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import './medication_service.dart';

/// Service for checking medication interactions
class MedicationInteractionService {
  final MedicationService _medicationService;

  // Static database of common drug interactions
  static final Map<String, List<DrugInteraction>> _interactionDatabase = {
    // Blood thinners
    'warfarin': [
      DrugInteraction(
        drug1: 'warfarin',
        drug2: 'aspirin',
        severity: InteractionSeverity.high,
        description: 'Increased risk of bleeding when taken together',
        recommendation: 'Monitor closely for bleeding. Consider dose adjustment.',
      ),
      DrugInteraction(
        drug1: 'warfarin',
        drug2: 'ibuprofen',
        severity: InteractionSeverity.high,
        description: 'NSAIDs increase bleeding risk with warfarin',
        recommendation: 'Avoid NSAIDs if possible. Use acetaminophen instead.',
      ),
      DrugInteraction(
        drug1: 'warfarin',
        drug2: 'simvastatin',
        severity: InteractionSeverity.medium,
        description: 'Simvastatin may enhance anticoagulant effect',
        recommendation: 'Monitor INR more frequently when starting simvastatin.',
      ),
    ],

    // Blood pressure medications
    'lisinopril': [
      DrugInteraction(
        drug1: 'lisinopril',
        drug2: 'potassium',
        severity: InteractionSeverity.medium,
        description: 'ACE inhibitors can increase potassium levels',
        recommendation: 'Monitor potassium levels regularly.',
      ),
      DrugInteraction(
        drug1: 'lisinopril',
        drug2: 'ibuprofen',
        severity: InteractionSeverity.medium,
        description: 'NSAIDs may reduce effectiveness of ACE inhibitors',
        recommendation: 'Monitor blood pressure. Consider alternative pain relief.',
      ),
    ],

    'metoprolol': [
      DrugInteraction(
        drug1: 'metoprolol',
        drug2: 'insulin',
        severity: InteractionSeverity.medium,
        description: 'Beta-blockers may mask symptoms of low blood sugar',
        recommendation: 'Monitor blood glucose more frequently.',
      ),
      DrugInteraction(
        drug1: 'metoprolol',
        drug2: 'verapamil',
        severity: InteractionSeverity.high,
        description: 'Both drugs slow heart rate and can cause dangerous bradycardia',
        recommendation: 'Avoid combination. Use alternative if possible.',
      ),
    ],

    // Diabetes medications
    'metformin': [
      DrugInteraction(
        drug1: 'metformin',
        drug2: 'contrast dye',
        severity: InteractionSeverity.high,
        description: 'Risk of lactic acidosis with IV contrast',
        recommendation: 'Stop metformin before contrast procedures.',
      ),
    ],

    'insulin': [
      DrugInteraction(
        drug1: 'insulin',
        drug2: 'prednisone',
        severity: InteractionSeverity.medium,
        description: 'Corticosteroids can raise blood sugar levels',
        recommendation: 'Monitor blood glucose closely. May need insulin adjustment.',
      ),
    ],

    // Cholesterol medications
    'simvastatin': [
      DrugInteraction(
        drug1: 'simvastatin',
        drug2: 'clarithromycin',
        severity: InteractionSeverity.high,
        description: 'Increased risk of muscle damage (rhabdomyolysis)',
        recommendation: 'Avoid combination. Use alternative antibiotic.',
      ),
      DrugInteraction(
        drug1: 'simvastatin',
        drug2: 'gemfibrozil',
        severity: InteractionSeverity.high,
        description: 'Significantly increased risk of muscle problems',
        recommendation: 'Avoid combination. Use alternative statin or fibrate.',
      ),
    ],

    // Pain medications
    'aspirin': [
      DrugInteraction(
        drug1: 'aspirin',
        drug2: 'ibuprofen',
        severity: InteractionSeverity.medium,
        description: 'Increased risk of stomach bleeding with multiple NSAIDs',
        recommendation: 'Avoid taking together. Space doses apart.',
      ),
    ],

    'acetaminophen': [
      DrugInteraction(
        drug1: 'acetaminophen',
        drug2: 'warfarin',
        severity: InteractionSeverity.low,
        description: 'High doses may enhance anticoagulant effect',
        recommendation: 'Monitor INR if using high doses regularly.',
      ),
    ],

    // Antidepressants
    'sertraline': [
      DrugInteraction(
        drug1: 'sertraline',
        drug2: 'tramadol',
        severity: InteractionSeverity.high,
        description: 'Risk of serotonin syndrome',
        recommendation: 'Avoid combination. Use alternative pain medication.',
      ),
      DrugInteraction(
        drug1: 'sertraline',
        drug2: 'aspirin',
        severity: InteractionSeverity.medium,
        description: 'SSRIs may increase bleeding risk',
        recommendation: 'Monitor for unusual bleeding.',
      ),
    ],

    // Antibiotics
    'ciprofloxacin': [
      DrugInteraction(
        drug1: 'ciprofloxacin',
        drug2: 'calcium',
        severity: InteractionSeverity.medium,
        description: 'Calcium can reduce absorption of ciprofloxacin',
        recommendation: 'Take ciprofloxacin 2 hours before or 6 hours after calcium.',
      ),
      DrugInteraction(
        drug1: 'ciprofloxacin',
        drug2: 'theophylline',
        severity: InteractionSeverity.high,
        description: 'Ciprofloxacin increases theophylline levels',
        recommendation: 'Monitor theophylline levels closely.',
      ),
    ],
  };

  MedicationInteractionService({
    MedicationService? medicationService,
  }) : _medicationService = medicationService ?? MedicationService();

  // Public Methods

  /// Check for interactions when adding a new medication
  Future<List<MedicationInteractionWarning>> checkInteractionsForNewMedication({
    required String newMedicationName,
    String? profileId,
  }) async {
    try {
      final existingMedications = await _medicationService.getActiveMedications(
        profileId: profileId,
      );

      final warnings = <MedicationInteractionWarning>[];

      for (final medication in existingMedications) {
        final interactions = findInteractions(
          newMedicationName.toLowerCase().trim(),
          medication.medicationName.toLowerCase().trim(),
        );

        for (final interaction in interactions) {
          warnings.add(MedicationInteractionWarning(
            interaction: interaction,
            existingMedication: medication,
            newMedicationName: newMedicationName,
          ));
        }
      }

      // Sort by severity (highest first)
      warnings.sort((a, b) => b.interaction.severity.index.compareTo(a.interaction.severity.index));

      return warnings;
    } catch (e) {
      throw MedicationInteractionServiceException(
        'Failed to check interactions for new medication: ${e.toString()}',
      );
    }
  }

  /// Check for interactions among all current medications
  Future<List<MedicationInteractionWarning>> checkAllCurrentInteractions({
    String? profileId,
  }) async {
    try {
      final medications = await _medicationService.getActiveMedications(
        profileId: profileId,
      );

      final warnings = <MedicationInteractionWarning>[];

      // Check each pair of medications
      for (int i = 0; i < medications.length; i++) {
        for (int j = i + 1; j < medications.length; j++) {
          final medication1 = medications[i];
          final medication2 = medications[j];

          final interactions = findInteractions(
            medication1.medicationName.toLowerCase().trim(),
            medication2.medicationName.toLowerCase().trim(),
          );

          for (final interaction in interactions) {
            warnings.add(MedicationInteractionWarning(
              interaction: interaction,
              existingMedication: medication1,
              secondMedication: medication2,
            ));
          }
        }
      }

      // Sort by severity (highest first)
      warnings.sort((a, b) => b.interaction.severity.index.compareTo(a.interaction.severity.index));

      return warnings;
    } catch (e) {
      throw MedicationInteractionServiceException(
        'Failed to check all current interactions: ${e.toString()}',
      );
    }
  }

  /// Find interactions between two specific drugs
  List<DrugInteraction> findInteractions(String drug1, String drug2) {
    final interactions = <DrugInteraction>[];

    // Normalize drug names (remove common suffixes, trim, lowercase)
    final normalizedDrug1 = _normalizeDrugName(drug1);
    final normalizedDrug2 = _normalizeDrugName(drug2);

    // Check both directions (drug1 with drug2, drug2 with drug1)
    final drug1Interactions = _interactionDatabase[normalizedDrug1] ?? [];
    for (final interaction in drug1Interactions) {
      if (_normalizeDrugName(interaction.drug2) == normalizedDrug2) {
        interactions.add(interaction);
      }
    }

    final drug2Interactions = _interactionDatabase[normalizedDrug2] ?? [];
    for (final interaction in drug2Interactions) {
      if (_normalizeDrugName(interaction.drug1) == normalizedDrug1) {
        interactions.add(interaction);
      }
    }

    return interactions;
  }

  /// Get interaction severity color for UI
  static Color getSeverityColor(InteractionSeverity severity) {
    switch (severity) {
      case InteractionSeverity.high:
        return const Color(0xFFD32F2F); // Red
      case InteractionSeverity.medium:
        return const Color(0xFFF57C00); // Orange
      case InteractionSeverity.low:
        return const Color(0xFFFBC02D); // Yellow
    }
  }

  /// Get interaction severity icon for UI
  static IconData getSeverityIcon(InteractionSeverity severity) {
    switch (severity) {
      case InteractionSeverity.high:
        return Icons.error;
      case InteractionSeverity.medium:
        return Icons.warning;
      case InteractionSeverity.low:
        return Icons.info;
    }
  }

  /// Get human-readable severity label
  static String getSeverityLabel(InteractionSeverity severity) {
    switch (severity) {
      case InteractionSeverity.high:
        return 'High Risk';
      case InteractionSeverity.medium:
        return 'Moderate Risk';
      case InteractionSeverity.low:
        return 'Low Risk';
    }
  }

  /// Check if a medication name exists in the interaction database
  bool hasKnownInteractions(String medicationName) {
    final normalized = _normalizeDrugName(medicationName);
    return _interactionDatabase.containsKey(normalized);
  }

  /// Get all medications that have known interactions with the given medication
  List<String> getMedicationsWithInteractions(String medicationName) {
    final normalized = _normalizeDrugName(medicationName);
    final interactions = _interactionDatabase[normalized] ?? [];
    return interactions.map((i) => i.drug2).toList();
  }

  /// Get statistics about interaction coverage
  InteractionDatabaseStats getInteractionDatabaseStats() {
    final totalMedications = _interactionDatabase.keys.length;
    var totalInteractions = 0;
    var highSeverityCount = 0;
    var mediumSeverityCount = 0;
    var lowSeverityCount = 0;

    for (final interactions in _interactionDatabase.values) {
      totalInteractions += interactions.length;
      for (final interaction in interactions) {
        switch (interaction.severity) {
          case InteractionSeverity.high:
            highSeverityCount++;
            break;
          case InteractionSeverity.medium:
            mediumSeverityCount++;
            break;
          case InteractionSeverity.low:
            lowSeverityCount++;
            break;
        }
      }
    }

    return InteractionDatabaseStats(
      totalMedications: totalMedications,
      totalInteractions: totalInteractions,
      highSeverityCount: highSeverityCount,
      mediumSeverityCount: mediumSeverityCount,
      lowSeverityCount: lowSeverityCount,
    );
  }

  // Private Helper Methods

  String _normalizeDrugName(String drugName) {
    // Remove common suffixes and normalize
    return drugName
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+(mg|mcg|g|ml|tablets?|capsules?)$'), '')
        .replaceAll(RegExp(r'\s+\d+\s*(mg|mcg|g|ml)$'), '')
        .trim();
  }
}

/// Data class for drug interaction information
class DrugInteraction {
  final String drug1;
  final String drug2;
  final InteractionSeverity severity;
  final String description;
  final String recommendation;

  const DrugInteraction({
    required this.drug1,
    required this.drug2,
    required this.severity,
    required this.description,
    required this.recommendation,
  });
}

/// Data class for medication interaction warnings
class MedicationInteractionWarning {
  final DrugInteraction interaction;
  final Medication? existingMedication;
  final Medication? secondMedication;
  final String? newMedicationName;

  const MedicationInteractionWarning({
    required this.interaction,
    this.existingMedication,
    this.secondMedication,
    this.newMedicationName,
  });

  String get primaryMedicationName =>
      existingMedication?.medicationName ?? interaction.drug1;

  String get secondaryMedicationName =>
      secondMedication?.medicationName ?? newMedicationName ?? interaction.drug2;
}

/// Data class for interaction database statistics
class InteractionDatabaseStats {
  final int totalMedications;
  final int totalInteractions;
  final int highSeverityCount;
  final int mediumSeverityCount;
  final int lowSeverityCount;

  const InteractionDatabaseStats({
    required this.totalMedications,
    required this.totalInteractions,
    required this.highSeverityCount,
    required this.mediumSeverityCount,
    required this.lowSeverityCount,
  });
}

/// Interaction severity levels
enum InteractionSeverity {
  low,
  medium,
  high,
}

/// Exception for medication interaction service errors
class MedicationInteractionServiceException implements Exception {
  final String message;

  const MedicationInteractionServiceException(this.message);

  @override
  String toString() => 'MedicationInteractionServiceException: $message';
}