import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/profile_providers.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/prescription_service.dart';

class PrescriptionFormScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final Prescription? prescription;

  const PrescriptionFormScreen({super.key, this.profileId, this.prescription});

  @override
  ConsumerState<PrescriptionFormScreen> createState() =>
      _PrescriptionFormScreenState();
}

class _PrescriptionFormScreenState
    extends ConsumerState<PrescriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _doctorController = TextEditingController();
  final _pharmacyController = TextEditingController();
  final _refillsController = TextEditingController();

  DateTime? _recordDate;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedProfileId;
  bool _isActive = true;
  bool _isLoading = false;

  bool get _isEditing => widget.prescription != null;

  @override
  void initState() {
    super.initState();
    _selectedProfileId = widget.profileId;
    _initializeFields();
  }

  void _initializeFields() {
    if (_isEditing) {
      final prescription = widget.prescription!;
      _titleController.text = prescription.title;
      _descriptionController.text = prescription.description ?? '';
      _medicationNameController.text = prescription.medicationName ?? '';
      _dosageController.text = prescription.dosage ?? '';
      _frequencyController.text = prescription.frequency ?? '';
      _instructionsController.text = prescription.instructions ?? '';
      _doctorController.text = prescription.prescribingDoctor ?? '';
      _pharmacyController.text = prescription.pharmacy ?? '';
      _refillsController.text = prescription.refillsRemaining?.toString() ?? '';
      _recordDate = prescription.recordDate;
      _startDate = prescription.startDate;
      _endDate = prescription.endDate;
      _selectedProfileId = prescription.profileId;
      _isActive = prescription.isPrescriptionActive;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _medicationNameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _instructionsController.dispose();
    _doctorController.dispose();
    _pharmacyController.dispose();
    _refillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(allProfilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Prescription' : 'New Prescription'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(onPressed: _savePrescription, child: const Text('SAVE')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Selection
            if (!_isEditing) _buildProfileSelection(profilesAsync),

            // Basic Information
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) =>
                  value?.trim().isEmpty == true ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            _buildDateField('Record Date *', _recordDate, (date) {
              setState(() => _recordDate = date);
            }),

            const SizedBox(height: 24),

            // Medication Information
            _buildSectionHeader('Medication Information'),
            const SizedBox(height: 16),

            TextFormField(
              controller: _medicationNameController,
              decoration: const InputDecoration(
                labelText: 'Medication Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
              validator: (value) => value?.trim().isEmpty == true
                  ? 'Medication name is required'
                  : null,
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
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    validator: (value) => value?.trim().isEmpty == true
                        ? 'Dosage is required'
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _frequencyController,
                    decoration: const InputDecoration(
                      labelText: 'Frequency *',
                      hintText: 'e.g., Twice daily',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    validator: (value) => value?.trim().isEmpty == true
                        ? 'Frequency is required'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions',
                hintText: 'Take with food, etc.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Prescription Details
            _buildSectionHeader('Prescription Details'),
            const SizedBox(height: 16),

            TextFormField(
              controller: _doctorController,
              decoration: const InputDecoration(
                labelText: 'Prescribing Doctor',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_pin_circle),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _pharmacyController,
              decoration: const InputDecoration(
                labelText: 'Pharmacy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_pharmacy),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildDateField('Start Date', _startDate, (date) {
                    setState(() => _startDate = date);
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField('End Date', _endDate, (date) {
                    setState(() => _endDate = date);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _refillsController,
                    decoration: const InputDecoration(
                      labelText: 'Refills Remaining',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.repeat),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Active'),
                    subtitle: const Text('Is prescription active?'),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _savePrescription,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(_isEditing ? 'Save Changes' : 'Add Prescription'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSelection(
    AsyncValue<List<FamilyMemberProfile>> profilesAsync,
  ) {
    return profilesAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error loading profiles: $error'),
      data: (profiles) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Select Profile'),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Family Member *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _selectedProfileId,
                isExpanded: true,
                hint: const Text('Select family member'),
                items: profiles
                    .map(
                      (profile) => DropdownMenuItem<String?>(
                        value: profile.id,
                        child: Text('${profile.firstName} ${profile.lastName}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedProfileId = value),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? date,
    ValueChanged<DateTime> onChanged,
  ) {
    return InkWell(
      onTap: () => _selectDate(onChanged),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          date != null
              ? '${date.day}/${date.month}/${date.year}'
              : 'Select date',
          style: date != null
              ? null
              : TextStyle(color: Theme.of(context).hintColor),
        ),
      ),
    );
  }

  Future<void> _selectDate(ValueChanged<DateTime> onChanged) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onChanged(picked);
  }

  Future<void> _savePrescription() async {
    if (!_formKey.currentState!.validate() ||
        _recordDate == null ||
        _selectedProfileId == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(prescriptionServiceProvider);
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

      if (_isEditing && widget.prescription != null) {
        // Update existing prescription
        final request = UpdatePrescriptionRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          dosage: _dosageController.text.trim().isEmpty
              ? null
              : _dosageController.text.trim(),
          prescribingDoctor: _doctorController.text.trim().isEmpty
              ? null
              : _doctorController.text.trim(),
          pharmacy: _pharmacyController.text.trim().isEmpty
              ? null
              : _pharmacyController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          refillsRemaining: _refillsController.text.trim().isEmpty
              ? null
              : int.tryParse(_refillsController.text.trim()),
        );

        await service.updatePrescription(widget.prescription!.id, request);
      } else {
        // Create new prescription
        final request = CreatePrescriptionRequest(
          profileId: selectedProfileId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          recordDate: _startDate ?? DateTime.now(),
          medicationName: _medicationNameController.text.trim(),
          dosage: _dosageController.text.trim(),
          frequency: _frequencyController.text.trim(),
          instructions: _instructionsController.text.trim().isEmpty
              ? null
              : _instructionsController.text.trim(),
          prescribingDoctor: _doctorController.text.trim().isEmpty
              ? null
              : _doctorController.text.trim(),
          pharmacy: _pharmacyController.text.trim().isEmpty
              ? null
              : _pharmacyController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          refillsRemaining: _refillsController.text.trim().isEmpty
              ? null
              : int.tryParse(_refillsController.text.trim()),
          isPrescriptionActive: true,
        );

        await service.createPrescription(request);
      }

      // Refresh medical records providers
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(selectedProfileId));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Prescription updated successfully'
                  : 'Prescription created successfully',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
