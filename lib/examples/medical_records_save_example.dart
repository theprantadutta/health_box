import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/providers/medical_records_save_providers.dart';
import '../shared/providers/simple_profile_providers.dart';
import '../features/medical_records/services/medication_service.dart';
import '../data/models/medication.dart';

/// Example widget showing how to save medical records
/// This demonstrates the complete flow for saving prescriptions, medications, and lab reports
class MedicalRecordsSaveExample extends ConsumerStatefulWidget {
  const MedicalRecordsSaveExample({super.key});

  @override
  ConsumerState<MedicalRecordsSaveExample> createState() =>
      _MedicalRecordsSaveExampleState();
}

class _MedicalRecordsSaveExampleState
    extends ConsumerState<MedicalRecordsSaveExample> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _titleController = TextEditingController();
  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _doctorController = TextEditingController();
  final _pharmacyController = TextEditingController();

  // Lab report controllers
  final _testNameController = TextEditingController();
  final _testResultsController = TextEditingController();
  final _referenceRangeController = TextEditingController();
  final _labFacilityController = TextEditingController();

  String _selectedRecordType = 'prescription';
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _collectionDate;
  int? _refillsRemaining;
  int? _pillCount;
  bool _isPrescriptionActive = true;
  bool _reminderEnabled = true;
  bool _isCritical = false;
  String _testStatus = 'pending';
  String _medicationStatus = MedicationStatus.active;

  List<TimeOfDay> _reminderTimes = [];

  @override
  void dispose() {
    _titleController.dispose();
    _medicationNameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _instructionsController.dispose();
    _doctorController.dispose();
    _pharmacyController.dispose();
    _testNameController.dispose();
    _testResultsController.dispose();
    _referenceRangeController.dispose();
    _labFacilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedProfile = ref.watch(simpleSelectedProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Medical Records'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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

          return _buildForm(profile.id);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading profile: $error')),
      ),
    );
  }

  Widget _buildForm(String profileId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Record type selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Record Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'prescription',
                          label: Text('Prescription'),
                          icon: Icon(Icons.receipt),
                        ),
                        ButtonSegment(
                          value: 'medication',
                          label: Text('Medication'),
                          icon: Icon(Icons.medication),
                        ),
                        ButtonSegment(
                          value: 'lab_report',
                          label: Text('Lab Report'),
                          icon: Icon(Icons.science),
                        ),
                      ],
                      selected: {_selectedRecordType},
                      onSelectionChanged: (Set<String> selection) {
                        setState(() {
                          _selectedRecordType = selection.first;
                          _clearForm();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Common fields
            _buildCommonFields(),

            const SizedBox(height: 16),

            // Type-specific fields
            if (_selectedRecordType == 'prescription')
              _buildPrescriptionFields(),
            if (_selectedRecordType == 'medication') _buildMedicationFields(),
            if (_selectedRecordType == 'lab_report') _buildLabReportFields(),

            const SizedBox(height: 24),

            // Save button with loading state
            _buildSaveButton(profileId),

            const SizedBox(height: 16),

            // Status messages
            _buildStatusMessages(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter a descriptive title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (_selectedRecordType != 'lab_report')
              Column(
                children: [
                  TextFormField(
                    controller: _medicationNameController,
                    decoration: const InputDecoration(
                      labelText: 'Medication Name *',
                      hintText: 'Enter medication name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Medication name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dosageController,
                          decoration: const InputDecoration(
                            labelText: 'Dosage *',
                            hintText: 'e.g., 10mg',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Dosage is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _frequencyController,
                          decoration: const InputDecoration(
                            labelText: 'Frequency *',
                            hintText: 'e.g., Once daily',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Frequency is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions/Notes',
                hintText: 'Additional instructions or notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prescription Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _doctorController,
              decoration: const InputDecoration(
                labelText: 'Prescribing Doctor',
                hintText: 'Dr. Smith',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pharmacyController,
              decoration: const InputDecoration(
                labelText: 'Pharmacy',
                hintText: 'CVS Pharmacy',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      _startDate == null
                          ? 'Start Date'
                          : 'Start: ${_startDate!.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      _endDate == null
                          ? 'End Date'
                          : 'End: ${_endDate!.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Refills Remaining',
                hintText: '3',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _refillsRemaining = int.tryParse(value);
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Prescription Active'),
              value: _isPrescriptionActive,
              onChanged: (value) {
                setState(() {
                  _isPrescriptionActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medication Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      _startDate == null
                          ? 'Start Date *'
                          : 'Start: ${_startDate!.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      _endDate == null
                          ? 'End Date'
                          : 'End: ${_endDate!.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Pill Count',
                hintText: '30',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _pillCount = int.tryParse(value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _medicationStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: MedicationStatus.allStatuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _medicationStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Reminders'),
              value: _reminderEnabled,
              onChanged: (value) {
                setState(() {
                  _reminderEnabled = value;
                });
              },
            ),
            if (_reminderEnabled) ...[
              const SizedBox(height: 8),
              ListTile(
                title: Text('Reminder Times (${_reminderTimes.length})'),
                subtitle: _reminderTimes.isEmpty
                    ? const Text('No reminder times set')
                    : Text(
                        _reminderTimes
                            .map(
                              (t) =>
                                  '${t.hour}:${t.minute.toString().padLeft(2, '0')}',
                            )
                            .join(', '),
                      ),
                trailing: const Icon(Icons.add),
                onTap: _addReminderTime,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLabReportFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lab Report Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _testNameController,
              decoration: const InputDecoration(
                labelText: 'Test Name *',
                hintText: 'Complete Blood Count',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Test name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _testResultsController,
              decoration: const InputDecoration(
                labelText: 'Test Results',
                hintText: 'Enter test results',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _referenceRangeController,
              decoration: const InputDecoration(
                labelText: 'Reference Range',
                hintText: 'Normal: 4.5-11.0 x10^9/L',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _doctorController,
              decoration: const InputDecoration(
                labelText: 'Ordering Physician',
                hintText: 'Dr. Smith',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _labFacilityController,
              decoration: const InputDecoration(
                labelText: 'Lab Facility',
                hintText: 'Quest Diagnostics',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _testStatus,
              decoration: const InputDecoration(
                labelText: 'Test Status',
                border: OutlineInputBorder(),
              ),
              items: ['pending', 'completed', 'reviewed', 'cancelled'].map((
                status,
              ) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _testStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _collectionDate == null
                    ? 'Collection Date'
                    : 'Collection: ${_collectionDate!.toLocal().toString().split(' ')[0]}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectCollectionDate(context),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Critical Result'),
              value: _isCritical,
              onChanged: (value) {
                setState(() {
                  _isCritical = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(String profileId) {
    return Consumer(
      builder: (context, ref, child) {
        final prescriptionSaveState = ref.watch(prescriptionSaveProvider);
        final medicationSaveState = ref.watch(medicationSaveProvider);
        final labReportSaveState = ref.watch(labReportSaveProvider);

        bool isLoading = false;
        switch (_selectedRecordType) {
          case 'prescription':
            isLoading = prescriptionSaveState.isLoading;
            break;
          case 'medication':
            isLoading = medicationSaveState.isLoading;
            break;
          case 'lab_report':
            isLoading = labReportSaveState.isLoading;
            break;
        }

        return ElevatedButton(
          onPressed: isLoading ? null : () => _saveRecord(profileId),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Saving...'),
                  ],
                )
              : Text(
                  'Save ${_selectedRecordType.replaceAll('_', ' ').toUpperCase()}',
                ),
        );
      },
    );
  }

  Widget _buildStatusMessages() {
    return Consumer(
      builder: (context, ref, child) {
        final prescriptionSaveState = ref.watch(prescriptionSaveProvider);
        final medicationSaveState = ref.watch(medicationSaveProvider);
        final labReportSaveState = ref.watch(labReportSaveProvider);

        SaveState currentState;
        switch (_selectedRecordType) {
          case 'prescription':
            currentState = prescriptionSaveState;
            break;
          case 'medication':
            currentState = medicationSaveState;
            break;
          case 'lab_report':
            currentState = labReportSaveState;
            break;
          default:
            return const SizedBox.shrink();
        }

        if (currentState.error != null) {
          return Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentState.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _clearState(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          );
        }

        if (currentState.successMessage != null) {
          return Card(
            color: Colors.green.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentState.successMessage!,
                          style: const TextStyle(color: Colors.green),
                        ),
                        if (currentState.savedRecordId != null)
                          Text(
                            'Record ID: ${currentState.savedRecordId}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _clearState(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectCollectionDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _collectionDate = picked;
      });
    }
  }

  Future<void> _addReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _reminderTimes.add(picked);
      });
    }
  }

  Future<void> _saveRecord(String profileId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    switch (_selectedRecordType) {
      case 'prescription':
        await _savePrescription(profileId);
        break;
      case 'medication':
        await _saveMedication(profileId);
        break;
      case 'lab_report':
        await _saveLabReport(profileId);
        break;
    }
  }

  Future<void> _savePrescription(String profileId) async {
    final request = MedicalRecordHelpers.createPrescriptionRequest(
      profileId: profileId,
      title: _titleController.text,
      medicationName: _medicationNameController.text,
      dosage: _dosageController.text,
      frequency: _frequencyController.text,
      instructions: _instructionsController.text.isEmpty
          ? null
          : _instructionsController.text,
      prescribingDoctor: _doctorController.text.isEmpty
          ? null
          : _doctorController.text,
      pharmacy: _pharmacyController.text.isEmpty
          ? null
          : _pharmacyController.text,
      startDate: _startDate,
      endDate: _endDate,
      refillsRemaining: _refillsRemaining,
      isPrescriptionActive: _isPrescriptionActive,
    );

    final savedId = await ref
        .read(prescriptionSaveProvider.notifier)
        .savePrescription(request);
    if (savedId != null) {
      _clearForm();
    }
  }

  Future<void> _saveMedication(String profileId) async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start date is required for medications')),
      );
      return;
    }

    final request = MedicalRecordHelpers.createMedicationRequest(
      profileId: profileId,
      title: _titleController.text,
      medicationName: _medicationNameController.text,
      dosage: _dosageController.text,
      frequency: _frequencyController.text,
      schedule: _reminderTimes
          .map((t) => '${t.hour}:${t.minute.toString().padLeft(2, '0')}')
          .toList()
          .toString(),
      instructions: _instructionsController.text.isEmpty
          ? null
          : _instructionsController.text,
      startDate: _startDate!,
      endDate: _endDate,
      reminderEnabled: _reminderEnabled,
      pillCount: _pillCount,
      status: _medicationStatus,
      reminderTimes: _reminderTimes
          .map((t) => MedicationTime(hour: t.hour, minute: t.minute))
          .toList(),
    );

    final savedId = await ref
        .read(medicationSaveProvider.notifier)
        .saveMedication(request);
    if (savedId != null) {
      _clearForm();
    }
  }

  Future<void> _saveLabReport(String profileId) async {
    final request = MedicalRecordHelpers.createLabReportRequest(
      profileId: profileId,
      title: _titleController.text,
      testName: _testNameController.text,
      testResults: _testResultsController.text.isEmpty
          ? null
          : _testResultsController.text,
      referenceRange: _referenceRangeController.text.isEmpty
          ? null
          : _referenceRangeController.text,
      orderingPhysician: _doctorController.text.isEmpty
          ? null
          : _doctorController.text,
      labFacility: _labFacilityController.text.isEmpty
          ? null
          : _labFacilityController.text,
      testStatus: _testStatus,
      collectionDate: _collectionDate,
      isCritical: _isCritical,
    );

    final savedId = await ref
        .read(labReportSaveProvider.notifier)
        .saveLabReport(request);
    if (savedId != null) {
      _clearForm();
    }
  }

  void _clearForm() {
    _titleController.clear();
    _medicationNameController.clear();
    _dosageController.clear();
    _frequencyController.clear();
    _instructionsController.clear();
    _doctorController.clear();
    _pharmacyController.clear();
    _testNameController.clear();
    _testResultsController.clear();
    _referenceRangeController.clear();
    _labFacilityController.clear();

    setState(() {
      _startDate = null;
      _endDate = null;
      _collectionDate = null;
      _refillsRemaining = null;
      _pillCount = null;
      _isPrescriptionActive = true;
      _reminderEnabled = true;
      _isCritical = false;
      _testStatus = 'pending';
      _medicationStatus = MedicationStatus.active;
      _reminderTimes.clear();
    });
  }

  void _clearState() {
    switch (_selectedRecordType) {
      case 'prescription':
        ref.read(prescriptionSaveProvider.notifier).clearState();
        break;
      case 'medication':
        ref.read(medicationSaveProvider.notifier).clearState();
        break;
      case 'lab_report':
        ref.read(labReportSaveProvider.notifier).clearState();
        break;
    }
  }
}
