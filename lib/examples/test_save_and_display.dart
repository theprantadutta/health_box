import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/providers/medical_records_save_providers.dart';
import '../shared/providers/medical_records_providers.dart';
import '../shared/providers/simple_profile_providers.dart';

/// Simple test widget to verify that saving records makes them appear in the records list
class TestSaveAndDisplay extends ConsumerStatefulWidget {
  const TestSaveAndDisplay({super.key});

  @override
  ConsumerState<TestSaveAndDisplay> createState() => _TestSaveAndDisplayState();
}

class _TestSaveAndDisplayState extends ConsumerState<TestSaveAndDisplay> {
  @override
  Widget build(BuildContext context) {
    final selectedProfile = ref.watch(simpleSelectedProfileProvider);
    final allRecords = ref.watch(allMedicalRecordsProvider);
    final prescriptionSaveState = ref.watch(prescriptionSaveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Save & Display'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: selectedProfile.when(
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text(
                'No profile selected. Please create a profile first.',
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Save Status
                if (prescriptionSaveState.isLoading)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Saving prescription...'),
                        ],
                      ),
                    ),
                  ),

                if (prescriptionSaveState.error != null)
                  Card(
                    color: Colors.red.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error: ${prescriptionSaveState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),

                if (prescriptionSaveState.successMessage != null)
                  Card(
                    color: Colors.green.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prescriptionSaveState.successMessage!,
                            style: const TextStyle(color: Colors.green),
                          ),
                          if (prescriptionSaveState.savedRecordId != null)
                            Text(
                              'ID: ${prescriptionSaveState.savedRecordId}',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Test Save Button
                ElevatedButton(
                  onPressed: prescriptionSaveState.isLoading
                      ? null
                      : () => _testSavePrescription(profile.id),
                  child: const Text('Test Save Prescription'),
                ),

                const SizedBox(height: 16),

                // Clear Status Button
                if (prescriptionSaveState.error != null ||
                    prescriptionSaveState.successMessage != null)
                  TextButton(
                    onPressed: () {
                      ref.read(prescriptionSaveProvider.notifier).clearState();
                    },
                    child: const Text('Clear Status'),
                  ),

                const SizedBox(height: 24),

                // Records List
                const Text(
                  'All Medical Records:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: allRecords.when(
                    data: (records) {
                      if (records.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inbox,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No records found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Try saving a prescription to test',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(allMedicalRecordsProvider);
                        },
                        child: ListView.builder(
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final record = records[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getRecordTypeColor(
                                    record.recordType,
                                  ),
                                  child: Icon(
                                    _getRecordTypeIcon(record.recordType),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  record.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Type: ${record.recordType}'),
                                    Text(
                                      'Date: ${record.recordDate.toLocal().toString().split(' ')[0]}',
                                    ),
                                    if (record.description != null)
                                      Text(
                                        record.description!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Text(
                                  record.id.split('_').first,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading records...'),
                        ],
                      ),
                    ),
                    error: (error, stack) => Card(
                      color: Colors.red.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading records: $error',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref.invalidate(allMedicalRecordsProvider);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading profile: $error')),
      ),
    );
  }

  Future<void> _testSavePrescription(String profileId) async {
    final request = MedicalRecordHelpers.createPrescriptionRequest(
      profileId: profileId,
      title: 'Test Prescription ${DateTime.now().millisecondsSinceEpoch}',
      medicationName: 'Test Medication',
      dosage: '10mg',
      frequency: 'Once daily',
      instructions: 'Test prescription created at ${DateTime.now()}',
      prescribingDoctor: 'Dr. Test',
      pharmacy: 'Test Pharmacy',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      refillsRemaining: 3,
    );

    await ref.read(prescriptionSaveProvider.notifier).savePrescription(request);
  }

  Color _getRecordTypeColor(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'prescription':
        return Colors.blue;
      case 'medication':
        return Colors.green;
      case 'lab_report':
        return Colors.orange;
      case 'vaccination':
        return Colors.purple;
      case 'allergy':
        return Colors.red;
      case 'chronic_condition':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getRecordTypeIcon(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'prescription':
        return Icons.receipt;
      case 'medication':
        return Icons.medication;
      case 'lab_report':
        return Icons.science;
      case 'vaccination':
        return Icons.vaccines;
      case 'allergy':
        return Icons.warning;
      case 'chronic_condition':
        return Icons.health_and_safety;
      default:
        return Icons.medical_information;
    }
  }
}
