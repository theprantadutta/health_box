import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/discharge_summary_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import 'dart:developer' as developer;

class DischargeSummaryFormScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final String? dischargeSummaryId;

  const DischargeSummaryFormScreen({
    super.key,
    this.profileId,
    this.dischargeSummaryId,
  });

  @override
  ConsumerState<DischargeSummaryFormScreen> createState() =>
      _DischargeSummaryFormScreenState();
}

class _DischargeSummaryFormScreenState
    extends ConsumerState<DischargeSummaryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _attendingPhysicianController = TextEditingController();
  final _primaryDiagnosisController = TextEditingController();
  final _secondaryDiagnosesController = TextEditingController();
  final _hospitalCourseController = TextEditingController();
  final _dischargeMedicationsController = TextEditingController();
  final _followUpInstructionsController = TextEditingController();
  final _dischargeConditionController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  DateTime _admissionDate = DateTime.now();
  DateTime _dischargeDate = DateTime.now();
  String _dischargeDisposition = 'Home';
  bool _isLoading = false;
  List<AttachmentResult> _attachments = [];

  final List<String> _dispositions = [
    'Home',
    'Home with Services',
    'Skilled Nursing Facility',
    'Rehabilitation Facility',
    'Another Hospital',
    'Hospice',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discharge Summary'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveDischargeSummary,
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
            _buildHospitalStaySection(),
            const SizedBox(height: 24),
            _buildDiagnosesSection(),
            const SizedBox(height: 24),
            _buildDischargeDetailsSection(),
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
            Text('Basic Information', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., Hospital Discharge Summary',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.exit_to_app),
              ),
              validator: (value) => value?.trim().isEmpty == true ? 'Title is required' : null,
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
            TextFormField(
              controller: _hospitalController,
              decoration: const InputDecoration(
                labelText: 'Hospital/Facility *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
              validator: (value) => value?.trim().isEmpty == true ? 'Hospital is required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalStaySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hospital Stay', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Admission Date'),
              subtitle: Text(_formatDate(_admissionDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, 'admission'),
            ),
            ListTile(
              title: const Text('Discharge Date'),
              subtitle: Text(_formatDate(_dischargeDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, 'discharge'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _attendingPhysicianController,
              decoration: const InputDecoration(
                labelText: 'Attending Physician',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Diagnoses & Course', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _primaryDiagnosisController,
              decoration: const InputDecoration(
                labelText: 'Primary Diagnosis *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_information),
              ),
              validator: (value) => value?.trim().isEmpty == true ? 'Primary diagnosis is required' : null,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _secondaryDiagnosesController,
              decoration: const InputDecoration(
                labelText: 'Secondary Diagnoses',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hospitalCourseController,
              decoration: const InputDecoration(
                labelText: 'Hospital Course',
                hintText: 'Summary of treatment and progress',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDischargeDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Discharge Details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _dischargeDisposition,
              decoration: const InputDecoration(
                labelText: 'Discharge Disposition',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              items: _dispositions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (value) => setState(() => _dischargeDisposition = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dischargeConditionController,
              decoration: const InputDecoration(
                labelText: 'Condition at Discharge',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dischargeMedicationsController,
              decoration: const InputDecoration(
                labelText: 'Discharge Medications',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _followUpInstructionsController,
              decoration: const InputDecoration(
                labelText: 'Follow-up Instructions',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, String type) async {
    final initialDate = type == 'admission' ? _admissionDate : _dischargeDate;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        if (type == 'admission') {
          _admissionDate = selectedDate;
        } else {
          _dischargeDate = selectedDate;
        }
      });
    }
  }

  Future<void> _saveDischargeSummary() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = DischargeSummaryService();
      final selectedProfileId = widget.profileId;
      if (selectedProfileId == null) throw Exception('No profile selected');

      final request = CreateDischargeSummaryRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        recordDate: _recordDate,
        hospital: _hospitalController.text.trim(),
        admissionDate: _admissionDate,
        dischargeDate: _dischargeDate,
        attendingPhysician: _attendingPhysicianController.text.trim().isEmpty ? null : _attendingPhysicianController.text.trim(),
        primaryDiagnosis: _primaryDiagnosisController.text.trim(),
        secondaryDiagnoses: _secondaryDiagnosesController.text.trim().isEmpty ? null : _secondaryDiagnosesController.text.trim(),
        hospitalCourse: _hospitalCourseController.text.trim().isEmpty ? null : _hospitalCourseController.text.trim(),
        dischargeDisposition: _dischargeDisposition,
        dischargeCondition: _dischargeConditionController.text.trim().isEmpty ? null : _dischargeConditionController.text.trim(),
        dischargeMedications: _dischargeMedicationsController.text.trim().isEmpty ? null : _dischargeMedicationsController.text.trim(),
        followUpInstructions: _followUpInstructionsController.text.trim().isEmpty ? null : _followUpInstructionsController.text.trim(),
      );

      await service.createDischargeSummary(request);

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
                  child: Text('Discharge summary saved successfully'),
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
        'Discharge summary created successfully for profile: $selectedProfileId',
        name: 'DischargeSummaryForm',
        level: 800, // INFO level
      );
    } catch (error, stackTrace) {
      // Log detailed error to console
      developer.log(
        'Failed to save discharge summary',
        name: 'DischargeSummaryForm',
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
                  child: Text('Failed to save discharge summary. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveDischargeSummary(),
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
              'Add discharge papers, care instructions, or follow-up notes',
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
              maxFiles: 12,
              allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
              maxFileSizeMB: 50,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hospitalController.dispose();
    _attendingPhysicianController.dispose();
    _primaryDiagnosisController.dispose();
    _secondaryDiagnosesController.dispose();
    _hospitalCourseController.dispose();
    _dischargeMedicationsController.dispose();
    _followUpInstructionsController.dispose();
    _dischargeConditionController.dispose();
    super.dispose();
  }
}