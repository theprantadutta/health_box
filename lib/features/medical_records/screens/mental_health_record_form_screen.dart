import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/mental_health_record_service.dart';
import '../widgets/attachment_picker_widget.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class MentalHealthRecordFormScreen extends ConsumerStatefulWidget {
  final String? profileId;

  const MentalHealthRecordFormScreen({super.key, this.profileId});

  @override
  ConsumerState<MentalHealthRecordFormScreen> createState() => _MentalHealthRecordFormScreenState();
}

class _MentalHealthRecordFormScreenState extends ConsumerState<MentalHealthRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _providerController = TextEditingController();
  final _facilityController = TextEditingController();
  final _sessionNotesController = TextEditingController();
  final _assessmentController = TextEditingController();
  final _treatmentPlanController = TextEditingController();
  final _medicationsController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  DateTime _sessionDate = DateTime.now();
  String _sessionType = 'Individual Therapy';
  String _moodRating = '5';
  bool _isLoading = false;
  List<File> _selectedFiles = [];

  final List<String> _sessionTypes = [
    'Individual Therapy',
    'Group Therapy',
    'Psychiatric Evaluation',
    'Medication Management',
    'Crisis Intervention',
    'Assessment',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Record'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMentalHealthRecord,
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
                    Text('Session Details', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        hintText: 'e.g., Therapy Session - Anxiety Management',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.psychology),
                      ),
                      validator: (value) => value?.trim().isEmpty == true ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _providerController,
                      decoration: const InputDecoration(
                        labelText: 'Mental Health Provider',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _facilityController,
                      decoration: const InputDecoration(
                        labelText: 'Facility/Practice',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _sessionType,
                      decoration: const InputDecoration(
                        labelText: 'Session Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _sessionTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      onChanged: (value) => setState(() => _sessionType = value!),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Session Date'),
                      subtitle: Text('${_sessionDate.day}/${_sessionDate.month}/${_sessionDate.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _sessionDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => _sessionDate = date);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Mood Rating (1-10): '),
                        Expanded(
                          child: Slider(
                            value: double.parse(_moodRating),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: _moodRating,
                            onChanged: (value) => setState(() => _moodRating = value.round().toString()),
                          ),
                        ),
                        Text(_moodRating),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sessionNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Session Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _assessmentController,
                      decoration: const InputDecoration(
                        labelText: 'Assessment/Observations',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _treatmentPlanController,
                      decoration: const InputDecoration(
                        labelText: 'Treatment Plan',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _medicationsController,
                      decoration: const InputDecoration(
                        labelText: 'Medications/Recommendations',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
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
              maxFileSizeBytes: 25 * 1024 * 1024,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMentalHealthRecord() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final service = MentalHealthRecordService();
      final selectedProfileId = widget.profileId;
      if (selectedProfileId == null) throw Exception('No profile selected');

      final request = CreateMentalHealthRecordRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        recordDate: _recordDate,
        providerName: _providerController.text.trim().isEmpty ? null : _providerController.text.trim(),
        facility: _facilityController.text.trim().isEmpty ? null : _facilityController.text.trim(),
        sessionDate: _sessionDate,
        sessionType: _sessionType,
        moodRating: int.parse(_moodRating),
        sessionNotes: _sessionNotesController.text.trim().isEmpty ? null : _sessionNotesController.text.trim(),
        assessment: _assessmentController.text.trim().isEmpty ? null : _assessmentController.text.trim(),
        treatmentPlan: _treatmentPlanController.text.trim().isEmpty ? null : _treatmentPlanController.text.trim(),
        medications: _medicationsController.text.trim().isEmpty ? null : _medicationsController.text.trim(),
      );

      await service.createMentalHealthRecord(request);
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(selectedProfileId));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mental health record saved successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (kDebugMode) print('Failed to save mental health record: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save mental health record: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _providerController.dispose();
    _facilityController.dispose();
    _sessionNotesController.dispose();
    _assessmentController.dispose();
    _treatmentPlanController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }
}