import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../../shared/providers/medical_records_providers.dart';
import '../services/lab_report_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_app_bar.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_card.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HBAppBar.gradient(
        title: 'New Lab Report',
        gradient: RecordTypeUtils.getGradient('lab_report'),
        actions: [
          HBButton.text(
            onPressed: _isLoading ? null : _saveLabReport,
            child: const Text('SAVE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(context.responsivePadding),
          children: [
            _buildBasicInfoSection(),
            SizedBox(height: AppSpacing.base),
            _buildTestDetailsSection(),
            SizedBox(height: AppSpacing.base),
            _buildAttachmentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Basic Information',
            Icons.info_outline,
            RecordTypeUtils.getGradient('lab_report'),
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _titleController,
            label: 'Report Title',
            hint: 'e.g., Blood Test Results',
            prefixIcon: Icons.science,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Report title is required';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateField('Test Date', _testDate, (date) {
            setState(() => _testDate = date);
          }),
        ],
      ),
    );
  }

  Widget _buildTestDetailsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Test Details',
            Icons.biotech,
            AppColors.successGradient,
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _testNameController,
            label: 'Test Name',
            hint: 'e.g., Complete Blood Count (CBC)',
            prefixIcon: Icons.medical_services,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Test name is required';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _resultsController,
            label: 'Results',
            hint: 'Enter test results and findings',
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _labFacilityController,
            label: 'Lab Facility',
            hint: 'Name of the laboratory',
            prefixIcon: Icons.business,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _orderingPhysicianController,
            label: 'Ordering Physician',
            hint: 'Doctor who ordered the test',
            prefixIcon: Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Attachments',
            Icons.attach_file,
            AppColors.secondaryGradient,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Add lab reports, test results, or related documents',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.base),
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
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Gradient gradient) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadii.md),
            boxShadow: AppElevation.coloredShadow(
              gradient.colors.first,
              opacity: 0.3,
            ),
          ),
          child: Icon(icon, size: AppSizes.iconMd, color: Colors.white),
        ),
        SizedBox(width: AppSpacing.md),
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: AppTypography.fontWeightSemiBold,
            color: context.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? date,
    ValueChanged<DateTime> onChanged,
  ) {
    return InkWell(
      onTap: () => _selectDate(onChanged),
      borderRadius: AppRadii.radiusMd,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          filled: true,
          fillColor: context.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: AppRadii.radiusMd,
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
        ),
        child: Text(
          date != null
              ? '${date.day}/${date.month}/${date.year}'
              : 'Select date',
          style: date != null
              ? null
              : TextStyle(color: context.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }

  Future<void> _selectDate(ValueChanged<DateTime> onChanged) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) onChanged(picked);
  }

  Future<void> _saveLabReport() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.white, size: 20),
              SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text('Please fill in all required fields'),
              ),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
        ),
      );
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

      developer.log(
        'Lab report created successfully for profile: $selectedProfileId',
        name: 'LabReportForm',
        level: 800,
      );

      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(selectedProfileId));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text('Lab report saved successfully'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
          ),
        );
      }
    } catch (error, stackTrace) {
      developer.log(
        'Failed to save lab report',
        name: 'LabReportForm',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text('Failed to save lab report. Please try again.'),
                ),
              ],
            ),
            backgroundColor: context.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
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
