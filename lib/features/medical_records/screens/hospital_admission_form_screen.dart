import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../services/hospital_admission_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/widgets/hb_app_bar.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_card.dart';
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
      appBar: HBAppBar.gradient(
        title: 'Hospital Admission',
        gradient: HealthBoxDesignSystem.medicalBlue,
        actions: [
          HBButton.text(
            onPressed: _isLoading ? null : _saveAdmission,
            child: Text(_isLoading ? 'SAVING...' : 'SAVE', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(context.responsivePadding),
          children: [
            _buildAdmissionDetailsSection(),
            SizedBox(height: AppSpacing.base),
            _buildAttachmentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdmissionDetailsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Admission Details', Icons.local_hospital, HealthBoxDesignSystem.medicalBlue),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _titleController,
            label: 'Title',
            hint: 'e.g., Emergency Admission',
            prefixIcon: Icons.local_hospital,
            validator: (value) => value?.trim().isEmpty == true ? 'Title is required' : null,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _hospitalController,
            label: 'Hospital',
            prefixIcon: Icons.business,
            validator: (value) => value?.trim().isEmpty == true ? 'Hospital is required' : null,
          ),
          SizedBox(height: AppSpacing.base),
          DropdownButtonFormField<String>(
            value: _admissionType,
            decoration: InputDecoration(
              labelText: 'Admission Type',
              prefixIcon: const Icon(Icons.category),
              filled: true,
              fillColor: context.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(borderRadius: AppRadii.radiusMd, borderSide: BorderSide.none),
            ),
            items: _admissionTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            onChanged: (value) => setState(() => _admissionType = value!),
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile('Admission Date', _admissionDate, () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _admissionDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) setState(() => _admissionDate = date);
          }),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _chiefComplaintController,
            label: 'Chief Complaint',
            prefixIcon: Icons.report_problem,
            validator: (value) => value?.trim().isEmpty == true ? 'Chief complaint is required' : null,
            minLines: 2,
            maxLines: 4,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _reasonController,
            label: 'Reason for Admission',
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _admittingPhysicianController,
            label: 'Admitting Physician',
            prefixIcon: Icons.person,
          ),
        ],
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
                const Icon(Icons.check_circle_outline, color: Colors.white, size: AppSizes.iconSm),
                SizedBox(width: AppSpacing.sm),
                const Expanded(child: Text('Hospital admission saved successfully')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
          ),
        );
      }

      developer.log('Hospital admission created successfully for profile: $selectedProfileId',
        name: 'HospitalAdmissionForm', level: 800);
    } catch (error, stackTrace) {
      developer.log('Failed to save hospital admission',
        name: 'HospitalAdmissionForm', level: 1000, error: error, stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: AppSizes.iconSm),
                SizedBox(width: AppSpacing.sm),
                const Expanded(child: Text('Failed to save hospital admission. Please try again.')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
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
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Attachments', Icons.attach_file, HealthBoxDesignSystem.medicalBlue),
          SizedBox(height: AppSpacing.sm),
          Text('Add admission records, treatment notes, or hospital documentation',
            style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
          SizedBox(height: AppSpacing.base),
          AttachmentFormWidget(
            initialAttachments: _attachments,
            onAttachmentsChanged: (attachments) {
              setState(() => _attachments = attachments);
            },
            maxFiles: 8,
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
    _hospitalController.dispose();
    _chiefComplaintController.dispose();
    _admittingPhysicianController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}
