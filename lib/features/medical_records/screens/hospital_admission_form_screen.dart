import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/hospital_admission_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import 'dart:developer' as developer;

class HospitalAdmissionFormScreen extends ConsumerStatefulWidget {
  final String? profileId;

  const HospitalAdmissionFormScreen({super.key, this.profileId});

  @override
  ConsumerState<HospitalAdmissionFormScreen> createState() => _HospitalAdmissionFormScreenState();
}

class _HospitalAdmissionFormScreenState extends ConsumerState<HospitalAdmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _chiefComplaintController = TextEditingController();
  final _admittingPhysicianController = TextEditingController();
  final _reasonController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  DateTime _admissionDate = DateTime.now();
  String _admissionType = 'Emergency';
  bool _isLoading = false;
  List<AttachmentResult> _attachments = [];

  final List<String> _admissionTypes = ['Emergency', 'Elective', 'Urgent', 'Transfer'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Admission'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveAdmission,
            child: Text(_isLoading ? 'SAVING...' : 'SAVE'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admission Details', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        hintText: 'e.g., Emergency Admission',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                      validator: (value) => value?.trim().isEmpty == true ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hospitalController,
                      decoration: const InputDecoration(
                        labelText: 'Hospital *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) => value?.trim().isEmpty == true ? 'Hospital is required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _admissionType,
                      decoration: const InputDecoration(
                        labelText: 'Admission Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _admissionTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      onChanged: (value) => setState(() => _admissionType = value!),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Admission Date'),
                      subtitle: Text('${_admissionDate.day}/${_admissionDate.month}/${_admissionDate.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _admissionDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => _admissionDate = date);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _chiefComplaintController,
                      decoration: const InputDecoration(
                        labelText: 'Chief Complaint *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.report_problem),
                      ),
                      validator: (value) => value?.trim().isEmpty == true ? 'Chief complaint is required' : null,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Reason for Admission',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _admittingPhysicianController,
                      decoration: const InputDecoration(
                        labelText: 'Admitting Physician',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildAttachmentsSection(),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAdmission() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final service = HospitalAdmissionService();
      final selectedProfileId = widget.profileId;
      if (selectedProfileId == null) throw Exception('No profile selected');

      final request = CreateHospitalAdmissionRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        recordDate: _recordDate,
        hospital: _hospitalController.text.trim(),
        admissionDate: _admissionDate,
        admissionType: _admissionType,
        chiefComplaint: _chiefComplaintController.text.trim(),
        reasonForAdmission: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
        admittingPhysician: _admittingPhysicianController.text.trim().isEmpty ? null : _admittingPhysicianController.text.trim(),
      );

      await service.createHospitalAdmission(request);
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
                  child: Text('Hospital admission saved successfully'),
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
        'Hospital admission created successfully for profile: $selectedProfileId',
        name: 'HospitalAdmissionForm',
        level: 800, // INFO level
      );
    } catch (error, stackTrace) {
      // Log detailed error to console
      developer.log(
        'Failed to save hospital admission',
        name: 'HospitalAdmissionForm',
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
                  child: Text('Failed to save hospital admission. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveAdmission(),
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
              'Add admission records, treatment notes, or hospital documentation',
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
              maxFiles: 8,
              allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
              maxFileSizeMB: 50,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hospitalController.dispose();
    _chiefComplaintController.dispose();
    _admittingPhysicianController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}