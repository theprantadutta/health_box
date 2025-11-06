import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/radiology_record_service.dart';
import '../../../data/models/radiology_record.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_app_bar.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/widgets/hb_list_tile.dart';
import 'dart:developer' as developer;

class RadiologyRecordFormScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final String? radiologyRecordId;

  const RadiologyRecordFormScreen({
    super.key,
    this.profileId,
    this.radiologyRecordId,
  });

  @override
  ConsumerState<RadiologyRecordFormScreen> createState() =>
      _RadiologyRecordFormScreenState();
}

class _RadiologyRecordFormScreenState
    extends ConsumerState<RadiologyRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _radiologistController = TextEditingController();
  final _facilityController = TextEditingController();
  final _techniqueController = TextEditingController();
  final _contrastController = TextEditingController();
  final _findingsController = TextEditingController();
  final _impressionController = TextEditingController();
  final _recommendationController = TextEditingController();
  final _referringPhysicianController = TextEditingController();
  final _protocolUsedController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  DateTime _studyDate = DateTime.now();
  String _selectedStudyType = RadiologyStudyTypes.xray;
  String? _selectedBodyPart;
  String _selectedUrgency = RadiologyUrgency.routine;
  bool _isNormal = false;
  bool _isLoading = false;
  bool _isEditing = false;
  List<AttachmentResult> _attachments = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.radiologyRecordId != null;
    if (_isEditing) {
      _loadRadiologyRecord();
    }
  }

  Future<void> _loadRadiologyRecord() async {
    // TODO: Load existing radiology record data when editing
    // This will be implemented with the radiology record service
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HBAppBar.gradient(
        title: _isEditing ? 'Edit Radiology Report' : 'New Radiology Report',
        gradient: RecordTypeUtils.getGradient('radiology'),
        actions: [
          HBButton.text(
            onPressed: _isLoading ? null : _saveRadiologyRecord,
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
            _buildStudyDetailsSection(),
            SizedBox(height: AppSpacing.base),
            _buildClinicalInfoSection(),
            SizedBox(height: AppSpacing.base),
            _buildFindingsSection(),
            SizedBox(height: AppSpacing.base),
            _buildTechnicalDetailsSection(),
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
          _buildSectionHeader('Basic Information', Icons.assessment, RecordTypeUtils.getGradient('radiology')),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _titleController,
            label: 'Title',
            hint: 'e.g., Chest X-Ray Report',
            prefixIcon: Icons.assessment,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Additional details about this study',
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile('Record Date', _recordDate, () => _selectDate(context, isRecordDate: true)),
        ],
      ),
    );
  }

  Widget _buildStudyDetailsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Study Details', Icons.medical_services, RecordTypeUtils.getGradient('radiology')),
          SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            value: _selectedStudyType,
            decoration: InputDecoration(
              labelText: 'Study Type',
              prefixIcon: const Icon(Icons.medical_services),
              filled: true,
              fillColor: context.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(borderRadius: AppRadii.radiusMd, borderSide: BorderSide.none),
            ),
            items: RadiologyStudyTypes.allTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedStudyType = value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) return 'Study type is required';
              return null;
            },
          ),
          SizedBox(height: AppSpacing.base),
          DropdownButtonFormField<String>(
            value: _selectedBodyPart,
            decoration: InputDecoration(
              labelText: 'Body Part',
              prefixIcon: const Icon(Icons.accessibility),
              filled: true,
              fillColor: context.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(borderRadius: AppRadii.radiusMd, borderSide: BorderSide.none),
            ),
            items: RadiologyBodyParts.allParts
                .map((part) => DropdownMenuItem(value: part, child: Text(part)))
                .toList(),
            onChanged: (value) => setState(() => _selectedBodyPart = value),
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile('Study Date', _studyDate, () => _selectDate(context, isRecordDate: false)),
          SizedBox(height: AppSpacing.base),
          DropdownButtonFormField<String>(
            value: _selectedUrgency,
            decoration: InputDecoration(
              labelText: 'Urgency Level',
              prefixIcon: const Icon(Icons.priority_high),
              filled: true,
              fillColor: context.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(borderRadius: AppRadii.radiusMd, borderSide: BorderSide.none),
            ),
            items: RadiologyUrgency.allLevels
                .map((urgency) => DropdownMenuItem(value: urgency, child: Text(_getUrgencyDisplayName(urgency))))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedUrgency = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalInfoSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Clinical Information', Icons.person, RecordTypeUtils.getGradient('radiology')),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _radiologistController,
            label: 'Radiologist',
            hint: 'Interpreting radiologist name',
            prefixIcon: Icons.person,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _facilityController,
            label: 'Facility',
            hint: 'Where the study was performed',
            prefixIcon: Icons.local_hospital,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _referringPhysicianController,
            label: 'Referring Physician',
            hint: 'Doctor who ordered the study',
            prefixIcon: Icons.person_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildFindingsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Findings & Interpretation', Icons.search, RecordTypeUtils.getGradient('radiology')),
          SizedBox(height: AppSpacing.lg),
          HBListTile.switchTile(
            title: 'Normal Study',
            subtitle: 'Check if findings are within normal limits',
            icon: Icons.check_circle,
            value: _isNormal,
            onChanged: (value) => setState(() => _isNormal = value),
            iconColor: AppColors.success,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _findingsController,
            label: 'Findings',
            hint: 'Detailed radiological findings',
            prefixIcon: Icons.search,
            minLines: 4,
            maxLines: 6,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _impressionController,
            label: 'Impression',
            hint: 'Radiologist\'s diagnostic impression',
            prefixIcon: Icons.psychology,
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _recommendationController,
            label: 'Recommendations',
            hint: 'Follow-up recommendations',
            prefixIcon: Icons.recommend,
            minLines: 3,
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalDetailsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Technical Details', Icons.settings, RecordTypeUtils.getGradient('radiology')),
          SizedBox(height: AppSpacing.lg),
          HBTextField.multiline(
            controller: _techniqueController,
            label: 'Technique',
            hint: 'Imaging technique used',
            prefixIcon: Icons.settings,
            minLines: 2,
            maxLines: 4,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _contrastController,
            label: 'Contrast Agent',
            hint: 'Contrast used (if any)',
            prefixIcon: Icons.colorize,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _protocolUsedController,
            label: 'Protocol Used',
            hint: 'Imaging protocol or sequence',
            prefixIcon: Icons.list,
            minLines: 2,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isRecordDate}) async {
    final initialDate = isRecordDate ? _recordDate : _studyDate;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        if (isRecordDate) {
          _recordDate = selectedDate;
        } else {
          _studyDate = selectedDate;
        }
      });
    }
  }

  Future<void> _saveRadiologyRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = RadiologyRecordService();
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

      final request = CreateRadiologyRecordRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        recordDate: _recordDate,
        studyType: _selectedStudyType,
        bodyPart: _selectedBodyPart,
        radiologist: _radiologistController.text.trim().isEmpty
            ? null
            : _radiologistController.text.trim(),
        facility: _facilityController.text.trim().isEmpty
            ? null
            : _facilityController.text.trim(),
        studyDate: _studyDate,
        technique: _techniqueController.text.trim().isEmpty
            ? null
            : _techniqueController.text.trim(),
        contrast: _contrastController.text.trim().isEmpty
            ? null
            : _contrastController.text.trim(),
        findings: _findingsController.text.trim().isEmpty
            ? null
            : _findingsController.text.trim(),
        impression: _impressionController.text.trim().isEmpty
            ? null
            : _impressionController.text.trim(),
        recommendation: _recommendationController.text.trim().isEmpty
            ? null
            : _recommendationController.text.trim(),
        urgency: _selectedUrgency,
        isNormal: _isNormal,
        referringPhysician: _referringPhysicianController.text.trim().isEmpty
            ? null
            : _referringPhysicianController.text.trim(),
        protocolUsed: _protocolUsedController.text.trim().isEmpty
            ? null
            : _protocolUsedController.text.trim(),
      );

      await service.createRadiologyRecord(request);

      // Refresh medical records providers
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
                const Expanded(child: Text('Radiology record saved successfully')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
          ),
        );
      }

      developer.log('Radiology record created successfully for profile: $selectedProfileId',
        name: 'RadiologyRecordForm', level: 800);
    } catch (error, stackTrace) {
      developer.log('Failed to save radiology record',
        name: 'RadiologyRecordForm', level: 1000, error: error, stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: AppSizes.iconSm),
                SizedBox(width: AppSpacing.sm),
                const Expanded(child: Text('Failed to save radiology record. Please try again.')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveRadiologyRecord(),
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

  String _getUrgencyDisplayName(String urgency) {
    switch (urgency) {
      case RadiologyUrgency.routine:
        return 'Routine';
      case RadiologyUrgency.urgent:
        return 'Urgent';
      case RadiologyUrgency.stat:
        return 'STAT';
      case RadiologyUrgency.emergency:
        return 'Emergency';
      default:
        return urgency;
    }
  }

  Widget _buildAttachmentsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Attachments', Icons.attach_file, RecordTypeUtils.getGradient('radiology')),
          SizedBox(height: AppSpacing.sm),
          Text('Add imaging results, radiologist reports, or scan images',
            style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
          SizedBox(height: AppSpacing.base),
          AttachmentFormWidget(
            initialAttachments: _attachments,
            onAttachmentsChanged: (attachments) {
              setState(() => _attachments = attachments);
            },
            maxFiles: 10,
            allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'dicom'],
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
    _radiologistController.dispose();
    _facilityController.dispose();
    _techniqueController.dispose();
    _contrastController.dispose();
    _findingsController.dispose();
    _impressionController.dispose();
    _recommendationController.dispose();
    _referringPhysicianController.dispose();
    _protocolUsedController.dispose();
    super.dispose();
  }
}
