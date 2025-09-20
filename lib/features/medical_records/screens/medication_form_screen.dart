import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/medication_service.dart';
import 'package:flutter/foundation.dart';

class MedicationFormScreen extends ConsumerStatefulWidget {
  final String? profileId;

  const MedicationFormScreen({super.key, this.profileId});

  @override
  ConsumerState<MedicationFormScreen> createState() =>
      _MedicationFormScreenState();
}

class _MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Medication'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMedication,
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Medication Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _frequencyController,
              decoration: const InputDecoration(
                labelText: 'Frequency *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.notifications, size: 48),
                    const SizedBox(height: 8),
                    const Text('Reminder Setup'),
                    const SizedBox(height: 8),
                    Text(
                      'Medication reminders will be implemented with the notification service in Phase 3.9',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(medicationServiceProvider);
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

      final request = CreateMedicationRequest(
        profileId: selectedProfileId,
        title: _nameController.text.trim(),
        description:
            '${_dosageController.text.trim()} - ${_frequencyController.text.trim()}',
        recordDate: DateTime.now(),
        medicationName: _nameController.text.trim(),
        dosage: _dosageController.text.trim().isEmpty
            ? 'As prescribed'
            : _dosageController.text.trim(),
        frequency: _frequencyController.text.trim().isEmpty
            ? 'As needed'
            : _frequencyController.text.trim(),
        schedule: _frequencyController.text.trim().isEmpty
            ? 'Daily'
            : _frequencyController.text.trim(),
        startDate: DateTime.now(),
        reminderEnabled: false,
        status: 'active',
        reminderTimes: [],
      );

      await service.createMedication(request);

      // Refresh medical records providers
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(selectedProfileId));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medication saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save medication: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save medication: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
