import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../../shared/providers/medical_records_providers.dart';
import '../services/lab_report_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/theme/design_system.dart';

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
  List<AttachmentResult> _attachments = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Lab Report'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: HealthBoxDesignSystem.labReportGradient,
          ),
        ),
        elevation: 0,
        shadowColor: HealthBoxDesignSystem.labReportGradient.colors.last.withValues(alpha: 0.3),
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
            AttachmentFormWidget(
              initialAttachments: _attachments,
              onAttachmentsChanged: (attachments) {
                setState(() {
                  _attachments = attachments;
                });
              },
              maxFiles: 10,
              allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
              maxFileSizeMB: 50,
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

      // Log success
      developer.log(
        'Lab report created successfully for profile: $selectedProfileId',
        name: 'LabReportForm',
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
                  child: Text('Lab report saved successfully'),
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
        'Failed to save lab report',
        name: 'LabReportForm',
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
                  child: Text('Failed to save lab report. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveLabReport(),
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
}
