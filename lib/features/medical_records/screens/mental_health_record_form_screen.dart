import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../services/mental_health_record_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/widgets/hb_app_bar.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_card.dart';
import 'dart:developer' as developer;

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
  List<AttachmentResult> _attachments = [];

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
      appBar: HBAppBar.gradient(
        title: 'Mental Health Record',
        gradient: RecordTypeUtils.getGradient('mental_health'),
        actions: [
          HBButton.text(
            onPressed: _isLoading ? null : _saveMentalHealthRecord,
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
            _buildSessionDetailsSection(),
            SizedBox(height: AppSpacing.base),
            _buildAttachmentsSection(),
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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: AppSizes.iconSm),
                SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text('Mental health record saved successfully'),
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
        'Mental health record created successfully for profile: $selectedProfileId',
        name: 'MentalHealthRecordForm',
        level: 800, // INFO level
      );
    } catch (error, stackTrace) {
      // Log detailed error to console
      developer.log(
        'Failed to save mental health record',
        name: 'MentalHealthRecordForm',
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
                  child: Text('Failed to save mental health record. Please try again.'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveMentalHealthRecord(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSessionDetailsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Session Details',
            Icons.psychology,
            RecordTypeUtils.getGradient('mental_health'),
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _titleController,
            label: 'Title',
            hint: 'e.g., Therapy Session - Anxiety Management',
            prefixIcon: Icons.psychology,
            validator: (value) => value?.trim().isEmpty == true ? 'Title is required' : null,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _providerController,
            label: 'Mental Health Provider',
            prefixIcon: Icons.person,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _facilityController,
            label: 'Facility/Practice',
            prefixIcon: Icons.business,
          ),
          SizedBox(height: AppSpacing.base),
          DropdownButtonFormField<String>(
            value: _sessionType,
            decoration: InputDecoration(
              labelText: 'Session Type',
              prefixIcon: const Icon(Icons.category),
              filled: true,
              fillColor: context.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: AppRadii.radiusMd,
                borderSide: BorderSide.none,
              ),
            ),
            items: _sessionTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            onChanged: (value) => setState(() => _sessionType = value!),
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile(
            'Session Date',
            _sessionDate,
            () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _sessionDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _sessionDate = date);
            },
          ),
          SizedBox(height: AppSpacing.base),
          _buildMoodRatingSlider(),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _sessionNotesController,
            label: 'Session Notes',
            minLines: 4,
            maxLines: 6,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _assessmentController,
            label: 'Assessment/Observations',
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _treatmentPlanController,
            label: 'Treatment Plan',
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _medicationsController,
            label: 'Medications/Recommendations',
            minLines: 2,
            maxLines: 4,
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
            RecordTypeUtils.getGradient('mental_health'),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Add therapy notes, assessments, or treatment plans',
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
            maxFiles: 8,
            allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
            maxFileSizeMB: 25,
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

  Widget _buildMoodRatingSlider() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mood Rating',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  gradient: RecordTypeUtils.getGradient('mental_health'),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Text(
                  _moodRating,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: AppTypography.fontWeightBold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Slider(
            value: double.parse(_moodRating),
            min: 1,
            max: 10,
            divisions: 9,
            label: _moodRating,
            onChanged: (value) => setState(() => _moodRating = value.round().toString()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'High',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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