import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../services/discharge_summary_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/widgets/hb_app_bar.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_card.dart';
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
      appBar: HBAppBar.gradient(
        title: 'Discharge Summary',
        gradient: HealthBoxDesignSystem.medicalPurple,
        actions: [
          HBButton.text(
            onPressed: _isLoading ? null : _saveDischargeSummary,
            child: Text(
              _isLoading ? 'SAVING...' : 'SAVE',
              style: const TextStyle(color: Colors.white),
            ),
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
            _buildHospitalStaySection(),
            SizedBox(height: AppSpacing.base),
            _buildDiagnosesSection(),
            SizedBox(height: AppSpacing.base),
            _buildDischargeDetailsSection(),
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
          _buildSectionHeader('Basic Information', Icons.exit_to_app, HealthBoxDesignSystem.medicalPurple),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _titleController,
            label: 'Title',
            hint: 'e.g., Hospital Discharge Summary',
            prefixIcon: Icons.exit_to_app,
            validator: (value) => value?.trim().isEmpty == true ? 'Title is required' : null,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _descriptionController,
            label: 'Description',
            minLines: 2,
            maxLines: 4,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _hospitalController,
            label: 'Hospital/Facility',
            prefixIcon: Icons.local_hospital,
            validator: (value) => value?.trim().isEmpty == true ? 'Hospital is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalStaySection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Hospital Stay', Icons.hotel, HealthBoxDesignSystem.medicalPurple),
          SizedBox(height: AppSpacing.lg),
          _buildDateTile('Admission Date', _admissionDate, () => _selectDate(context, 'admission')),
          SizedBox(height: AppSpacing.base),
          _buildDateTile('Discharge Date', _dischargeDate, () => _selectDate(context, 'discharge')),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _attendingPhysicianController,
            label: 'Attending Physician',
            prefixIcon: Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosesSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Diagnoses & Course', Icons.medical_information, HealthBoxDesignSystem.medicalPurple),
          SizedBox(height: AppSpacing.lg),
          HBTextField.multiline(
            controller: _primaryDiagnosisController,
            label: 'Primary Diagnosis',
            prefixIcon: Icons.medical_information,
            validator: (value) => value?.trim().isEmpty == true ? 'Primary diagnosis is required' : null,
            minLines: 2,
            maxLines: 4,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _secondaryDiagnosesController,
            label: 'Secondary Diagnoses',
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _hospitalCourseController,
            label: 'Hospital Course',
            hint: 'Summary of treatment and progress',
            minLines: 4,
            maxLines: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildDischargeDetailsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Discharge Details', Icons.home, HealthBoxDesignSystem.medicalPurple),
          SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            value: _dischargeDisposition,
            decoration: InputDecoration(
              labelText: 'Discharge Disposition',
              prefixIcon: const Icon(Icons.home),
              filled: true,
              fillColor: context.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(borderRadius: AppRadii.radiusMd, borderSide: BorderSide.none),
            ),
            items: _dispositions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (value) => setState(() => _dischargeDisposition = value!),
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _dischargeConditionController,
            label: 'Condition at Discharge',
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _dischargeMedicationsController,
            label: 'Discharge Medications',
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _followUpInstructionsController,
            label: 'Follow-up Instructions',
            minLines: 4,
            maxLines: 6,
          ),
        ],
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
                const Icon(Icons.check_circle_outline, color: Colors.white, size: AppSizes.iconSm),
                SizedBox(width: AppSpacing.sm),
                const Expanded(child: Text('Discharge summary saved successfully')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
          ),
        );
      }

      developer.log('Discharge summary created successfully for profile: $selectedProfileId',
        name: 'DischargeSummaryForm', level: 800);
    } catch (error, stackTrace) {
      developer.log('Failed to save discharge summary',
        name: 'DischargeSummaryForm', level: 1000, error: error, stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: AppSizes.iconSm),
                SizedBox(width: AppSpacing.sm),
                const Expanded(child: Text('Failed to save discharge summary. Please try again.')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
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
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Attachments', Icons.attach_file, HealthBoxDesignSystem.medicalPurple),
          SizedBox(height: AppSpacing.sm),
          Text('Add discharge papers, care instructions, or follow-up notes',
            style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
          SizedBox(height: AppSpacing.base),
          AttachmentFormWidget(
            initialAttachments: _attachments,
            onAttachmentsChanged: (attachments) {
              setState(() => _attachments = attachments);
            },
            maxFiles: 12,
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
            boxShadow: AppElevation.coloredShadow(gradient.colors.first, opacity: 0.3),
          ),
          child: Icon(icon, size: AppSizes.iconMd, color: Colors.white),
        ),
        SizedBox(width: AppSpacing.md),
        Text(title, style: context.textTheme.titleMedium?.copyWith(
          fontWeight: AppTypography.fontWeightSemiBold,
          color: context.colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildDateTile(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.radiusMd,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: AppRadii.radiusMd,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: context.colorScheme.onSurfaceVariant, size: AppSizes.iconMd),
            SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant)),
                  Text('${date.day}/${date.month}/${date.year}',
                    style: context.textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurface)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

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
