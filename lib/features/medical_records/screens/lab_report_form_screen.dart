import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/lab_report_service.dart';
import '../widgets/attachment_picker_widget.dart';
import 'dart:io';

class LabReportFormScreen extends ConsumerStatefulWidget {
  final String? profileId;

  const LabReportFormScreen({super.key, this.profileId});

  @override
  ConsumerState<LabReportFormScreen> createState() =>
      _LabReportFormScreenState();
}

class _LabReportFormScreenState extends ConsumerState<LabReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _testNameController = TextEditingController();
  final _resultsController = TextEditingController();
  final _labFacilityController = TextEditingController();
  final _orderingPhysicianController = TextEditingController();
  bool _isLoading = false;
  DateTime? _testDate;
  List<File> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Lab Report'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveLabReport,
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Report Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.science),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _testNameController,
              decoration: const InputDecoration(
                labelText: 'Test Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _resultsController,
              decoration: const InputDecoration(
                labelText: 'Results',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
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

  Future<void> _saveLabReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(labReportServiceProvider);
      final selectedProfileId = widget.profileId;
      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

      final request = CreateLabReportRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        description: _resultsController.text.trim().isEmpty
            ? null
            : _resultsController.text.trim(),
        recordDate: _testDate ?? DateTime.now(),
        testName: _testNameController.text.trim().isEmpty
            ? 'Lab Test'
            : _testNameController.text.trim(),
        testResults: _resultsController.text.trim().isEmpty
            ? null
            : _resultsController.text.trim(),
        labFacility: _labFacilityController.text.trim().isEmpty
            ? null
            : _labFacilityController.text.trim(),
        orderingPhysician: _orderingPhysicianController.text.trim().isEmpty
            ? null
            : _orderingPhysicianController.text.trim(),
        collectionDate: _testDate,
      );

      await service.createLabReport(request);

      // Refresh medical records providers
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(selectedProfileId));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lab report saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save lab report: $e'),
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
}
