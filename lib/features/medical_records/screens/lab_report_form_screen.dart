import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../../shared/providers/medical_records_providers.dart';
import '../services/lab_report_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/modern_text_field.dart';

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
            _buildBasicInfoSection(),
            const SizedBox(height: 16),
            _buildTestDetailsSection(),
            const SizedBox(height: 16),
            _buildAttachmentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildModernSection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      children: [
        ModernTextField(
          controller: _titleController,
          labelText: 'Report Title *',
          hintText: 'e.g., Blood Test Results',
          prefixIcon: const Icon(Icons.science),
          focusGradient: HealthBoxDesignSystem.labReportGradient,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Report title is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTestDetailsSection() {
    return _buildModernSection(
      title: 'Test Details',
      icon: Icons.biotech,
      children: [
        ModernTextField(
          controller: _testNameController,
          labelText: 'Test Name *',
          hintText: 'e.g., Complete Blood Count (CBC)',
          prefixIcon: const Icon(Icons.medical_services),
          focusGradient: HealthBoxDesignSystem.labReportGradient,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Test name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _resultsController,
          labelText: 'Results',
          hintText: 'Enter test results and findings',
          prefixIcon: const Icon(Icons.description),
          focusGradient: HealthBoxDesignSystem.labReportGradient,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _labFacilityController,
          labelText: 'Lab Facility',
          hintText: 'Name of the laboratory',
          prefixIcon: const Icon(Icons.business),
          focusGradient: HealthBoxDesignSystem.labReportGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _orderingPhysicianController,
          labelText: 'Ordering Physician',
          hintText: 'Doctor who ordered the test',
          prefixIcon: const Icon(Icons.person),
          focusGradient: HealthBoxDesignSystem.labReportGradient,
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return _buildModernSection(
      title: 'Attachments',
      icon: Icons.attach_file,
      children: [
        Text(
          'Add lab reports, test results, or related documents',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
          allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
          maxFileSizeMB: 50,
        ),
      ],
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

  Widget _buildModernSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    LinearGradient? gradient,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sectionGradient = gradient ?? HealthBoxDesignSystem.labReportGradient;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: sectionGradient.colors.first.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: sectionGradient.colors.first.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(gradient: sectionGradient),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: sectionGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: sectionGradient.colors.first.withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(icon, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _testNameController.dispose();
    _resultsController.dispose();
    _labFacilityController.dispose();
    _orderingPhysicianController.dispose();
    super.dispose();
  }
}
