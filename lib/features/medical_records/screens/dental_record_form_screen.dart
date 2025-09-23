import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/dental_record_service.dart';
import '../widgets/attachment_picker_widget.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class DentalRecordFormScreen extends ConsumerStatefulWidget {
  final String? profileId;

  const DentalRecordFormScreen({super.key, this.profileId});

  @override
  ConsumerState<DentalRecordFormScreen> createState() => _DentalRecordFormScreenState();
}

class _DentalRecordFormScreenState extends ConsumerState<DentalRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dentistController = TextEditingController();
  final _clinicController = TextEditingController();
  final _procedureController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  DateTime _visitDate = DateTime.now();
  String _visitType = 'Routine Checkup';
  bool _isLoading = false;
  List<File> _selectedFiles = [];

  final List<String> _visitTypes = [
    'Routine Checkup',
    'Cleaning',
    'Filling',
    'Root Canal',
    'Extraction',
    'Crown/Bridge',
    'Orthodontic',
    'Emergency',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dental Record'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveDentalRecord,
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
                    Text('Dental Visit Details', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        hintText: 'e.g., Routine Dental Cleaning',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medical_services),
                      ),
                      validator: (value) => value?.trim().isEmpty == true ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dentistController,
                      decoration: const InputDecoration(
                        labelText: 'Dentist Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _clinicController,
                      decoration: const InputDecoration(
                        labelText: 'Dental Clinic',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _visitType,
                      decoration: const InputDecoration(
                        labelText: 'Visit Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _visitTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      onChanged: (value) => setState(() => _visitType = value!),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Visit Date'),
                      subtitle: Text('${_visitDate.day}/${_visitDate.month}/${_visitDate.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _visitDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => _visitDate = date);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _procedureController,
                      decoration: const InputDecoration(
                        labelText: 'Procedures Performed',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _treatmentController,
                      decoration: const InputDecoration(
                        labelText: 'Treatment Details',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
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
              maxFiles: 10,
              maxFileSizeBytes: 50 * 1024 * 1024,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDentalRecord() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final service = DentalRecordService();
      final selectedProfileId = widget.profileId;
      if (selectedProfileId == null) throw Exception('No profile selected');

      final request = CreateDentalRecordRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        recordDate: _recordDate,
        dentistName: _dentistController.text.trim().isEmpty ? null : _dentistController.text.trim(),
        clinic: _clinicController.text.trim().isEmpty ? null : _clinicController.text.trim(),
        visitDate: _visitDate,
        visitType: _visitType,
        proceduresPerformed: _procedureController.text.trim().isEmpty ? null : _procedureController.text.trim(),
        treatmentDetails: _treatmentController.text.trim().isEmpty ? null : _treatmentController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      await service.createDentalRecord(request);
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(selectedProfileId));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dental record saved successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (kDebugMode) print('Failed to save dental record: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save dental record: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dentistController.dispose();
    _clinicController.dispose();
    _procedureController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}