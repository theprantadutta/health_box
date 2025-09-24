import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../../shared/providers/medical_records_providers.dart';
import '../services/vaccination_service.dart';
import '../../../data/models/vaccination.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';

class VaccinationFormScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final String? vaccinationId;

  const VaccinationFormScreen({
    super.key,
    this.profileId,
    this.vaccinationId,
  });

  @override
  ConsumerState<VaccinationFormScreen> createState() =>
      _VaccinationFormScreenState();
}

class _VaccinationFormScreenState extends ConsumerState<VaccinationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _vaccineNameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _administeredByController = TextEditingController();
  final _doseNumberController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  DateTime _administrationDate = DateTime.now();
  DateTime? _nextDueDate;
  String? _selectedSite;
  String? _selectedManufacturer;
  bool _isComplete = false;
  bool _isLoading = false;
  bool _isEditing = false;
  List<AttachmentResult> _attachments = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.vaccinationId != null;
    if (_isEditing) {
      _loadVaccination();
    }
  }

  Future<void> _loadVaccination() async {
    // TODO: Load existing vaccination data when editing
    // This will be implemented with the vaccination service
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Vaccination' : 'New Vaccination'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveVaccination,
            child: Text(_isLoading ? 'SAVING...' : 'SAVE'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildVaccineDetailsSection(),
            const SizedBox(height: 24),
            _buildAdministrationSection(),
            const SizedBox(height: 24),
            _buildDosageSection(),
            const SizedBox(height: 24),
            _buildAttachmentsSection(),
            const SizedBox(height: 24),
            _buildCompletionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., COVID-19 Vaccination',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vaccines),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Additional notes about this vaccination',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Record Date'),
              subtitle: Text(_formatDate(_recordDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, isRecordDate: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vaccine Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vaccineNameController,
              decoration: const InputDecoration(
                labelText: 'Vaccine Name *',
                hintText: 'e.g., Pfizer-BioNTech COVID-19',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vaccine name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedManufacturer,
              decoration: const InputDecoration(
                labelText: 'Manufacturer',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              items: VaccineManufacturers.allManufacturers
                  .map((manufacturer) => DropdownMenuItem(
                        value: manufacturer,
                        child: Text(manufacturer),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedManufacturer = value;
                  _manufacturerController.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _batchNumberController,
              decoration: const InputDecoration(
                labelText: 'Batch/Lot Number',
                hintText: 'e.g., EJ1685',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdministrationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Administration Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Administration Date'),
              subtitle: Text(_formatDate(_administrationDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, isRecordDate: false),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSite,
              decoration: const InputDecoration(
                labelText: 'Administration Site',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              items: VaccinationSites.allSites
                  .map((site) => DropdownMenuItem(
                        value: site,
                        child: Text(site),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedSite = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _administeredByController,
              decoration: const InputDecoration(
                labelText: 'Administered By',
                hintText: 'Healthcare provider name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDosageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dosage Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _doseNumberController,
              decoration: const InputDecoration(
                labelText: 'Dose Number',
                hintText: 'e.g., 1, 2, 3',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final dose = int.tryParse(value);
                  if (dose == null || dose <= 0) {
                    return 'Dose number must be a positive integer';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Next Due Date'),
              subtitle: Text(_nextDueDate != null
                  ? _formatDate(_nextDueDate!)
                  : 'Not set'),
              trailing: const Icon(Icons.schedule),
              onTap: () => _selectNextDueDate(context),
            ),
            if (_nextDueDate != null)
              TextButton(
                onPressed: () {
                  setState(() => _nextDueDate = null);
                },
                child: const Text('Clear Next Due Date'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completion Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Mark as Complete'),
              subtitle: const Text(
                'Check this if this completes the vaccination series',
              ),
              value: _isComplete,
              onChanged: (value) {
                setState(() => _isComplete = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isRecordDate}) async {
    final initialDate = isRecordDate ? _recordDate : _administrationDate;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (selectedDate != null) {
      setState(() {
        if (isRecordDate) {
          _recordDate = selectedDate;
        } else {
          _administrationDate = selectedDate;
        }
      });
    }
  }

  Future<void> _selectNextDueDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _nextDueDate ?? _administrationDate.add(const Duration(days: 30)),
      firstDate: _administrationDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (selectedDate != null) {
      setState(() => _nextDueDate = selectedDate);
    }
  }

  Future<void> _saveVaccination() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = VaccinationService();
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

      final request = CreateVaccinationRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        recordDate: _recordDate,
        vaccineName: _vaccineNameController.text.trim(),
        manufacturer: _manufacturerController.text.trim().isEmpty
            ? null
            : _manufacturerController.text.trim(),
        batchNumber: _batchNumberController.text.trim().isEmpty
            ? null
            : _batchNumberController.text.trim(),
        administrationDate: _administrationDate,
        administeredBy: _administeredByController.text.trim().isEmpty
            ? null
            : _administeredByController.text.trim(),
        site: _selectedSite,
        nextDueDate: _nextDueDate,
        doseNumber: _doseNumberController.text.trim().isEmpty
            ? null
            : int.tryParse(_doseNumberController.text.trim()),
        isComplete: _isComplete,
      );

      await service.createVaccination(request);

      // Log success
      developer.log(
        'Vaccination created successfully for profile: $selectedProfileId',
        name: 'VaccinationForm',
        level: 800, // INFO level
      );

      // Refresh medical records providers
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(selectedProfileId));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Vaccination saved successfully'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (error, stackTrace) {
      // Log detailed error to console
      developer.log(
        'Failed to save vaccination',
        name: 'VaccinationForm',
        level: 1000, // ERROR level
        error: error,
        stackTrace: stackTrace,
      );

      if (mounted) {
        // Show user-friendly error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Failed to save vaccination. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveVaccination(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildAttachmentsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attachments',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add vaccination cards, certificates, or related documents',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            AttachmentFormWidget(
              initialAttachments: _attachments,
              onAttachmentsChanged: (attachments) {
                setState(() {
                  _attachments = attachments;
                });
              },
              maxFiles: 5,
              allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
              maxFileSizeMB: 25,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _vaccineNameController.dispose();
    _manufacturerController.dispose();
    _batchNumberController.dispose();
    _administeredByController.dispose();
    _doseNumberController.dispose();
    super.dispose();
  }
}