import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/pathology_record_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import 'dart:developer' as developer;

class PathologyRecordFormScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final String? pathologyRecordId;

  const PathologyRecordFormScreen({
    super.key,
    this.profileId,
    this.pathologyRecordId,
  });

  @override
  ConsumerState<PathologyRecordFormScreen> createState() =>
      _PathologyRecordFormScreenState();
}

class _PathologyRecordFormScreenState
    extends ConsumerState<PathologyRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _specimenTypeController = TextEditingController();
  final _specimenSiteController = TextEditingController();
  final _pathologistController = TextEditingController();
  final _laboratoryController = TextEditingController();
  final _collectionMethodController = TextEditingController();
  final _grossDescriptionController = TextEditingController();
  final _microscopicFindingsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _stagingGradingController = TextEditingController();
  final _immunohistochemistryController = TextEditingController();
  final _molecularStudiesController = TextEditingController();
  final _recommendationController = TextEditingController();
  final _referringPhysicianController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  DateTime _collectionDate = DateTime.now();
  DateTime? _reportDate;
  String _selectedUrgency = 'routine';
  bool _isMalignant = false;
  bool _isLoading = false;
  bool _isEditing = false;
  List<AttachmentResult> _attachments = [];

  final List<String> _urgencyLevels = ['routine', 'urgent', 'stat', 'emergency'];
  final List<String> _specimenTypes = [
    'Biopsy',
    'Cytology',
    'Surgical Specimen',
    'Fine Needle Aspiration',
    'Core Biopsy',
    'Excision',
    'Frozen Section',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.pathologyRecordId != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Pathology Report' : 'New Pathology Report'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePathologyRecord,
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
            _buildSpecimenDetailsSection(),
            const SizedBox(height: 24),
            _buildLaboratoryInfoSection(),
            const SizedBox(height: 24),
            _buildFindingsSection(),
            const SizedBox(height: 24),
            _buildDiagnosisSection(),
            const SizedBox(height: 24),
            _buildAttachmentsSection(),
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
                hintText: 'e.g., Skin Biopsy Report',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assignment),
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
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Record Date'),
              subtitle: Text(_formatDate(_recordDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, 'record'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecimenDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specimen Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Specimen Type *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.biotech),
              ),
              items: _specimenTypes
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => _specimenTypeController.text = value ?? '',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Specimen type is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specimenSiteController,
              decoration: const InputDecoration(
                labelText: 'Specimen Site',
                hintText: 'e.g., Left arm, Abdomen',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _collectionMethodController,
              decoration: const InputDecoration(
                labelText: 'Collection Method',
                hintText: 'e.g., Punch biopsy, Excision',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Collection Date'),
              subtitle: Text(_formatDate(_collectionDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, 'collection'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaboratoryInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laboratory Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pathologistController,
              decoration: const InputDecoration(
                labelText: 'Pathologist',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _laboratoryController,
              decoration: const InputDecoration(
                labelText: 'Laboratory',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _referringPhysicianController,
              decoration: const InputDecoration(
                labelText: 'Referring Physician',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedUrgency,
              decoration: const InputDecoration(
                labelText: 'Urgency Level',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: _urgencyLevels
                  .map((urgency) => DropdownMenuItem(
                        value: urgency,
                        child: Text(urgency.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedUrgency = value!),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Report Date'),
              subtitle: Text(_reportDate != null ? _formatDate(_reportDate!) : 'Not set'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, 'report'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFindingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pathological Findings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _grossDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Gross Description',
                hintText: 'Macroscopic findings',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.visibility),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _microscopicFindingsController,
              decoration: const InputDecoration(
                labelText: 'Microscopic Findings',
                hintText: 'Histological observations',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _immunohistochemistryController,
              decoration: const InputDecoration(
                labelText: 'Immunohistochemistry',
                hintText: 'IHC results',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.science),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _molecularStudiesController,
              decoration: const InputDecoration(
                labelText: 'Molecular Studies',
                hintText: 'Genetic/molecular analysis',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.dns),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnosis & Recommendations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: 'Pathological Diagnosis',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_information),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stagingGradingController,
              decoration: const InputDecoration(
                labelText: 'Staging/Grading',
                hintText: 'TNM staging, grade',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.stairs),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Malignant'),
              subtitle: const Text('Check if malignancy is present'),
              value: _isMalignant,
              onChanged: (value) => setState(() => _isMalignant = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recommendationController,
              decoration: const InputDecoration(
                labelText: 'Recommendations',
                hintText: 'Further studies, treatment recommendations',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.recommend),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, String type) async {
    DateTime? initialDate;
    DateTime? firstDate;
    DateTime? lastDate;

    switch (type) {
      case 'record':
        initialDate = _recordDate;
        firstDate = DateTime(1900);
        lastDate = DateTime.now();
        break;
      case 'collection':
        initialDate = _collectionDate;
        firstDate = DateTime(1900);
        lastDate = DateTime.now();
        break;
      case 'report':
        initialDate = _reportDate ?? _collectionDate;
        firstDate = _collectionDate;
        lastDate = DateTime.now();
        break;
      default:
        return;
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      setState(() {
        switch (type) {
          case 'record':
            _recordDate = selectedDate;
            break;
          case 'collection':
            _collectionDate = selectedDate;
            break;
          case 'report':
            _reportDate = selectedDate;
            break;
        }
      });
    }
  }

  Future<void> _savePathologyRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = PathologyRecordService();
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

      final request = CreatePathologyRecordRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        recordDate: _recordDate,
        specimenType: _specimenTypeController.text.trim(),
        specimenSite: _specimenSiteController.text.trim().isEmpty
            ? null
            : _specimenSiteController.text.trim(),
        pathologist: _pathologistController.text.trim().isEmpty
            ? null
            : _pathologistController.text.trim(),
        laboratory: _laboratoryController.text.trim().isEmpty
            ? null
            : _laboratoryController.text.trim(),
        collectionDate: _collectionDate,
        reportDate: _reportDate,
        collectionMethod: _collectionMethodController.text.trim().isEmpty
            ? null
            : _collectionMethodController.text.trim(),
        grossDescription: _grossDescriptionController.text.trim().isEmpty
            ? null
            : _grossDescriptionController.text.trim(),
        microscopicFindings: _microscopicFindingsController.text.trim().isEmpty
            ? null
            : _microscopicFindingsController.text.trim(),
        diagnosis: _diagnosisController.text.trim().isEmpty
            ? null
            : _diagnosisController.text.trim(),
        stagingGrading: _stagingGradingController.text.trim().isEmpty
            ? null
            : _stagingGradingController.text.trim(),
        immunohistochemistry: _immunohistochemistryController.text.trim().isEmpty
            ? null
            : _immunohistochemistryController.text.trim(),
        molecularStudies: _molecularStudiesController.text.trim().isEmpty
            ? null
            : _molecularStudiesController.text.trim(),
        recommendations: _recommendationController.text.trim().isEmpty
            ? null
            : _recommendationController.text.trim(),
        urgencyLevel: _selectedUrgency,
        isMalignant: _isMalignant,
        referringPhysician: _referringPhysicianController.text.trim().isEmpty
            ? null
            : _referringPhysicianController.text.trim(),
      );

      await service.createPathologyRecord(request);

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
                  child: Text('Pathology record saved successfully'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }

      // Log success
      developer.log(
        'Pathology record created successfully for profile: $selectedProfileId',
        name: 'PathologyRecordForm',
        level: 800, // INFO level
      );
    } catch (error, stackTrace) {
      // Log detailed error to console
      developer.log(
        'Failed to save pathology record',
        name: 'PathologyRecordForm',
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
                  child: Text('Failed to save pathology record. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _savePathologyRecord(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              'Add pathology reports, biopsy results, or lab findings',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
              maxFiles: 10,
              allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'tiff'],
              maxFileSizeMB: 50,
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
    _specimenTypeController.dispose();
    _specimenSiteController.dispose();
    _pathologistController.dispose();
    _laboratoryController.dispose();
    _collectionMethodController.dispose();
    _grossDescriptionController.dispose();
    _microscopicFindingsController.dispose();
    _diagnosisController.dispose();
    _stagingGradingController.dispose();
    _immunohistochemistryController.dispose();
    _molecularStudiesController.dispose();
    _recommendationController.dispose();
    _referringPhysicianController.dispose();
    super.dispose();
  }
}