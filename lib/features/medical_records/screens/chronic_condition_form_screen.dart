import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/chronic_condition_service.dart';
import '../../../data/models/chronic_condition.dart';
import 'package:flutter/foundation.dart';

class ChronicConditionFormScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final String? conditionId;

  const ChronicConditionFormScreen({
    super.key,
    this.profileId,
    this.conditionId,
  });

  @override
  ConsumerState<ChronicConditionFormScreen> createState() =>
      _ChronicConditionFormScreenState();
}

class _ChronicConditionFormScreenState
    extends ConsumerState<ChronicConditionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _conditionNameController = TextEditingController();
  final _diagnosingProviderController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _managementPlanController = TextEditingController();
  final _medicationsController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  DateTime _diagnosisDate = DateTime.now();
  String _selectedSeverity = ConditionSeverity.mild;
  String _selectedStatus = ConditionStatus.active;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.conditionId != null;
    if (_isEditing) {
      _loadChronicCondition();
    }
  }

  Future<void> _loadChronicCondition() async {
    // TODO: Load existing chronic condition data when editing
    // This will be implemented with the chronic condition service
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Chronic Condition' : 'New Chronic Condition'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChronicCondition,
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
            _buildConditionDetailsSection(),
            const SizedBox(height: 24),
            _buildDiagnosisSection(),
            const SizedBox(height: 24),
            _buildSeverityAndStatusSection(),
            const SizedBox(height: 24),
            _buildTreatmentSection(),
            const SizedBox(height: 24),
            _buildManagementSection(),
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
                hintText: 'e.g., Type 2 Diabetes Management',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_information),
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
                hintText: 'Additional details about this condition',
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

  Widget _buildConditionDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Condition Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _conditionNameController,
              decoration: const InputDecoration(
                labelText: 'Condition Name *',
                hintText: 'e.g., Type 2 Diabetes, Hypertension',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Condition name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Common Condition Categories',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: ConditionCategories.allCategories.map((category) {
                return FilterChip(
                  label: Text(category),
                  selected: false,
                  onSelected: (selected) {
                    if (selected) {
                      // This could be enhanced to auto-suggest condition names
                      // based on the selected category
                    }
                  },
                );
              }).toList(),
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
              'Diagnosis Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Diagnosis Date'),
              subtitle: Text(_formatDate(_diagnosisDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, isRecordDate: false),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _diagnosingProviderController,
              decoration: const InputDecoration(
                labelText: 'Diagnosing Healthcare Provider',
                hintText: 'e.g., Dr. Smith, Cardiology',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityAndStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Severity & Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Severity Level',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            for (final severity in ConditionSeverity.allSeverities)
              RadioListTile<String>(
                title: Text(_getSeverityDisplayName(severity)),
                subtitle: Text(_getSeverityDescription(severity)),
                value: severity,
                groupValue: _selectedSeverity,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSeverity = value);
                  }
                },
              ),
            const SizedBox(height: 16),
            Text(
              'Current Status',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            for (final status in ConditionStatus.allStatuses)
              RadioListTile<String>(
                title: Text(_getStatusDisplayName(status)),
                subtitle: Text(_getStatusDescription(status)),
                value: status,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Treatment Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _treatmentController,
              decoration: const InputDecoration(
                labelText: 'Current Treatment',
                hintText: 'e.g., Metformin 500mg twice daily',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _medicationsController,
              decoration: const InputDecoration(
                labelText: 'Related Medications',
                hintText: 'List medications related to this condition',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_pharmacy),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Management Plan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _managementPlanController,
              decoration: const InputDecoration(
                labelText: 'Management Plan',
                hintText: 'Diet, exercise, monitoring guidelines, etc.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assignment),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isRecordDate}) async {
    final initialDate = isRecordDate ? _recordDate : _diagnosisDate;
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
          _diagnosisDate = selectedDate;
        }
      });
    }
  }

  Future<void> _saveChronicCondition() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ChronicConditionService();
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

      final request = CreateChronicConditionRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        recordDate: _recordDate,
        conditionName: _conditionNameController.text.trim(),
        diagnosisDate: _diagnosisDate,
        diagnosingProvider: _diagnosingProviderController.text.trim().isEmpty
            ? null
            : _diagnosingProviderController.text.trim(),
        severity: _selectedSeverity,
        status: _selectedStatus,
        treatment: _treatmentController.text.trim().isEmpty
            ? null
            : _treatmentController.text.trim(),
        managementPlan: _managementPlanController.text.trim().isEmpty
            ? null
            : _managementPlanController.text.trim(),
        relatedMedications: _medicationsController.text.trim().isEmpty
            ? null
            : _medicationsController.text.trim(),
      );

      await service.createChronicCondition(request);

      // Refresh medical records providers
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(selectedProfileId));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chronic condition saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save chronic condition: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save chronic condition: $e'),
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

  String _getSeverityDisplayName(String severity) {
    switch (severity) {
      case ConditionSeverity.mild:
        return 'Mild';
      case ConditionSeverity.moderate:
        return 'Moderate';
      case ConditionSeverity.severe:
        return 'Severe';
      default:
        return severity;
    }
  }

  String _getSeverityDescription(String severity) {
    switch (severity) {
      case ConditionSeverity.mild:
        return 'Minimal impact on daily activities';
      case ConditionSeverity.moderate:
        return 'Some limitation on daily activities';
      case ConditionSeverity.severe:
        return 'Significant impact on daily activities';
      default:
        return '';
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case ConditionStatus.active:
        return 'Active';
      case ConditionStatus.managed:
        return 'Managed';
      case ConditionStatus.resolved:
        return 'Resolved';
      default:
        return status;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case ConditionStatus.active:
        return 'Currently experiencing symptoms or requiring treatment';
      case ConditionStatus.managed:
        return 'Under control with current treatment plan';
      case ConditionStatus.resolved:
        return 'No longer active or requiring treatment';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _conditionNameController.dispose();
    _diagnosingProviderController.dispose();
    _treatmentController.dispose();
    _managementPlanController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }
}