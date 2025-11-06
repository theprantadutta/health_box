import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/dental_record_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_app_bar.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_card.dart';
import 'dart:developer' as developer;

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
  List<AttachmentResult> _attachments = [];

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
      appBar: HBAppBar.gradient(
        title: 'Dental Record',
        gradient: RecordTypeUtils.getGradient('dental'),
        actions: [
          HBButton.text(
            onPressed: _isLoading ? null : _saveDentalRecord,
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
            _buildDentalVisitSection(),
            SizedBox(height: AppSpacing.base),
            _buildAttachmentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDentalVisitSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Dental Visit Details',
            Icons.medical_services,
            RecordTypeUtils.getGradient('dental'),
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _titleController,
            label: 'Title',
            hint: 'e.g., Routine Dental Cleaning',
            prefixIcon: Icons.medical_services,
            validator: (value) => value?.trim().isEmpty == true ? 'Title is required' : null,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _dentistController,
            label: 'Dentist Name',
            prefixIcon: Icons.person,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _clinicController,
            label: 'Dental Clinic',
            prefixIcon: Icons.business,
          ),
          SizedBox(height: AppSpacing.base),
          DropdownButtonFormField<String>(
            value: _visitType,
            decoration: InputDecoration(
              labelText: 'Visit Type',
              prefixIcon: const Icon(Icons.category),
              filled: true,
              fillColor: context.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: AppRadii.radiusMd,
                borderSide: BorderSide.none,
              ),
            ),
            items: _visitTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            onChanged: (value) => setState(() => _visitType = value!),
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile(
            'Visit Date',
            _visitDate,
            () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _visitDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _visitDate = date);
            },
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _procedureController,
            label: 'Procedures Performed',
            prefixIcon: Icons.healing,
            minLines: 2,
            maxLines: 4,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _treatmentController,
            label: 'Treatment Details',
            prefixIcon: Icons.description,
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _notesController,
            label: 'Additional Notes',
            prefixIcon: Icons.note,
            minLines: 3,
            maxLines: 5,
          ),
        ],
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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: AppSizes.iconSm),
                SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text('Dental record saved successfully'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
          ),
        );
      }

      // Log success
      developer.log(
        'Dental record created successfully for profile: $selectedProfileId',
        name: 'DentalRecordForm',
        level: 800, // INFO level
      );
    } catch (error, stackTrace) {
      // Log detailed error to console
      developer.log(
        'Failed to save dental record',
        name: 'DentalRecordForm',
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
                const Icon(Icons.error_outline, color: Colors.white, size: AppSizes.iconSm),
                SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text('Failed to save dental record. Please try again.'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveDentalRecord(),
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
          _buildSectionHeader(
            'Attachments',
            Icons.attach_file,
            RecordTypeUtils.getGradient('dental'),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Add dental X-rays, treatment notes, or dental reports',
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
                  Text(
                    label,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
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
    _dentistController.dispose();
    _clinicController.dispose();
    _procedureController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}