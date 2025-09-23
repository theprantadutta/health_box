import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/hospital_admission_service.dart';
import '../widgets/attachment_picker_widget.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

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
  List<File> _selectedFiles = [];

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
                      value: _admissionType,
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
            AttachmentPickerWidget(
              onFilesSelected: (files) {
                setState(() {
                  _selectedFiles = files;
                });
              },
              allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
              maxFiles: 8,
              maxFileSizeBytes: 50 * 1024 * 1024,
            ),
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
          const SnackBar(content: Text('Hospital admission saved successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (kDebugMode) print('Failed to save hospital admission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save hospital admission: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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