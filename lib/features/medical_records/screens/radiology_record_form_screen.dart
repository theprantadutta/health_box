import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/radiology_record_service.dart';
import '../../../data/models/radiology_record.dart';
import 'package:flutter/foundation.dart';

class RadiologyRecordFormScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final String? radiologyRecordId;

  const RadiologyRecordFormScreen({
    super.key,
    this.profileId,
    this.radiologyRecordId,
  });

  @override
  ConsumerState<RadiologyRecordFormScreen> createState() =>
      _RadiologyRecordFormScreenState();
}

class _RadiologyRecordFormScreenState
    extends ConsumerState<RadiologyRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _radiologistController = TextEditingController();
  final _facilityController = TextEditingController();
  final _techniqueController = TextEditingController();
  final _contrastController = TextEditingController();
  final _findingsController = TextEditingController();
  final _impressionController = TextEditingController();
  final _recommendationController = TextEditingController();
  final _referringPhysicianController = TextEditingController();
  final _protocolUsedController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  DateTime _studyDate = DateTime.now();
  String _selectedStudyType = RadiologyStudyTypes.xray;
  String? _selectedBodyPart;
  String _selectedUrgency = RadiologyUrgency.routine;
  bool _isNormal = false;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.radiologyRecordId != null;
    if (_isEditing) {
      _loadRadiologyRecord();
    }
  }

  Future<void> _loadRadiologyRecord() async {
    // TODO: Load existing radiology record data when editing
    // This will be implemented with the radiology record service
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Radiology Report' : 'New Radiology Report'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveRadiologyRecord,
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
            _buildStudyDetailsSection(),
            const SizedBox(height: 24),
            _buildClinicalInfoSection(),
            const SizedBox(height: 24),
            _buildFindingsSection(),
            const SizedBox(height: 24),
            _buildTechnicalDetailsSection(),
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
                hintText: 'e.g., Chest X-Ray Report',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assessment),
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
                hintText: 'Additional details about this study',
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

  Widget _buildStudyDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStudyType,
              decoration: const InputDecoration(
                labelText: 'Study Type *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
              ),
              items: RadiologyStudyTypes.allTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedStudyType = value);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Study type is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBodyPart,
              decoration: const InputDecoration(
                labelText: 'Body Part',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.accessibility),
              ),
              items: RadiologyBodyParts.allParts
                  .map((part) => DropdownMenuItem(
                        value: part,
                        child: Text(part),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedBodyPart = value);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Study Date'),
              subtitle: Text(_formatDate(_studyDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, isRecordDate: false),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedUrgency,
              decoration: const InputDecoration(
                labelText: 'Urgency Level',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: RadiologyUrgency.allLevels
                  .map((urgency) => DropdownMenuItem(
                        value: urgency,
                        child: Text(_getUrgencyDisplayName(urgency)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedUrgency = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clinical Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _radiologistController,
              decoration: const InputDecoration(
                labelText: 'Radiologist',
                hintText: 'Interpreting radiologist name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _facilityController,
              decoration: const InputDecoration(
                labelText: 'Facility',
                hintText: 'Where the study was performed',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _referringPhysicianController,
              decoration: const InputDecoration(
                labelText: 'Referring Physician',
                hintText: 'Doctor who ordered the study',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
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
              'Findings & Interpretation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Normal Study'),
              subtitle: const Text('Check if findings are within normal limits'),
              value: _isNormal,
              onChanged: (value) {
                setState(() => _isNormal = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _findingsController,
              decoration: const InputDecoration(
                labelText: 'Findings',
                hintText: 'Detailed radiological findings',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _impressionController,
              decoration: const InputDecoration(
                labelText: 'Impression',
                hintText: 'Radiologist\'s diagnostic impression',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.psychology),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recommendationController,
              decoration: const InputDecoration(
                labelText: 'Recommendations',
                hintText: 'Follow-up recommendations',
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

  Widget _buildTechnicalDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technical Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _techniqueController,
              decoration: const InputDecoration(
                labelText: 'Technique',
                hintText: 'Imaging technique used',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.settings),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contrastController,
              decoration: const InputDecoration(
                labelText: 'Contrast Agent',
                hintText: 'Contrast used (if any)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.colorize),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _protocolUsedController,
              decoration: const InputDecoration(
                labelText: 'Protocol Used',
                hintText: 'Imaging protocol or sequence',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.list),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isRecordDate}) async {
    final initialDate = isRecordDate ? _recordDate : _studyDate;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        if (isRecordDate) {
          _recordDate = selectedDate;
        } else {
          _studyDate = selectedDate;
        }
      });
    }
  }

  Future<void> _saveRadiologyRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = RadiologyRecordService();
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

      final request = CreateRadiologyRecordRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        recordDate: _recordDate,
        studyType: _selectedStudyType,
        bodyPart: _selectedBodyPart,
        radiologist: _radiologistController.text.trim().isEmpty
            ? null
            : _radiologistController.text.trim(),
        facility: _facilityController.text.trim().isEmpty
            ? null
            : _facilityController.text.trim(),
        studyDate: _studyDate,
        technique: _techniqueController.text.trim().isEmpty
            ? null
            : _techniqueController.text.trim(),
        contrast: _contrastController.text.trim().isEmpty
            ? null
            : _contrastController.text.trim(),
        findings: _findingsController.text.trim().isEmpty
            ? null
            : _findingsController.text.trim(),
        impression: _impressionController.text.trim().isEmpty
            ? null
            : _impressionController.text.trim(),
        recommendation: _recommendationController.text.trim().isEmpty
            ? null
            : _recommendationController.text.trim(),
        urgency: _selectedUrgency,
        isNormal: _isNormal,
        referringPhysician: _referringPhysicianController.text.trim().isEmpty
            ? null
            : _referringPhysicianController.text.trim(),
        protocolUsed: _protocolUsedController.text.trim().isEmpty
            ? null
            : _protocolUsedController.text.trim(),
      );

      await service.createRadiologyRecord(request);

      // Refresh medical records providers
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(selectedProfileId));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Radiology record saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save radiology record: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save radiology record: $e'),
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

  String _getUrgencyDisplayName(String urgency) {
    switch (urgency) {
      case RadiologyUrgency.routine:
        return 'Routine';
      case RadiologyUrgency.urgent:
        return 'Urgent';
      case RadiologyUrgency.stat:
        return 'STAT';
      case RadiologyUrgency.emergency:
        return 'Emergency';
      default:
        return urgency;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _radiologistController.dispose();
    _facilityController.dispose();
    _techniqueController.dispose();
    _contrastController.dispose();
    _findingsController.dispose();
    _impressionController.dispose();
    _recommendationController.dispose();
    _referringPhysicianController.dispose();
    _protocolUsedController.dispose();
    super.dispose();
  }
}