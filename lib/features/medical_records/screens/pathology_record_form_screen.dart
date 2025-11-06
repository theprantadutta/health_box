import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../services/pathology_record_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/widgets/hb_app_bar.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/widgets/hb_list_tile.dart';
import 'dart:developer' as developer;

class PathologyRecordFormScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final String? pathologyRecordId;

  const PathologyRecordFormScreen({
    super.key,
    this.profileId,
    this.pathologyRecordId,
  });

  @override
  ConsumerState<PathologyRecordFormScreen> createState() =>
      _PathologyRecordFormScreenState();
}

class _PathologyRecordFormScreenState
    extends ConsumerState<PathologyRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _specimenTypeController = TextEditingController();
  final _specimenSiteController = TextEditingController();
  final _pathologistController = TextEditingController();
  final _laboratoryController = TextEditingController();
  final _collectionMethodController = TextEditingController();
  final _grossDescriptionController = TextEditingController();
  final _microscopicFindingsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _stagingGradingController = TextEditingController();
  final _immunohistochemistryController = TextEditingController();
  final _molecularStudiesController = TextEditingController();
  final _recommendationController = TextEditingController();
  final _referringPhysicianController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  DateTime _collectionDate = DateTime.now();
  DateTime? _reportDate;
  String _selectedUrgency = 'routine';
  bool _isMalignant = false;
  bool _isLoading = false;
  bool _isEditing = false;
  List<AttachmentResult> _attachments = [];

  final List<String> _urgencyLevels = ['routine', 'urgent', 'stat', 'emergency'];
  final List<String> _specimenTypes = [
    'Biopsy',
    'Cytology',
    'Surgical Specimen',
    'Fine Needle Aspiration',
    'Core Biopsy',
    'Excision',
    'Frozen Section',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.pathologyRecordId != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HBAppBar.gradient(
        title: _isEditing ? 'Edit Pathology Report' : 'New Pathology Report',
        gradient: RecordTypeUtils.getGradient('pathology'),
        actions: [
          HBButton.text(
            onPressed: _isLoading ? null : _savePathologyRecord,
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
            _buildSpecimenDetailsSection(),
            SizedBox(height: AppSpacing.base),
            _buildLaboratoryInfoSection(),
            SizedBox(height: AppSpacing.base),
            _buildFindingsSection(),
            SizedBox(height: AppSpacing.base),
            _buildDiagnosisSection(),
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
          _buildSectionHeader('Basic Information', Icons.info_outline, RecordTypeUtils.getGradient('pathology')),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _titleController,
            label: 'Title',
            hint: 'e.g., Skin Biopsy Report',
            prefixIcon: Icons.assignment,
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
            prefixIcon: Icons.description,
            minLines: 2,
            maxLines: 4,
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile('Record Date', _recordDate, () => _selectDate(context, 'record')),
        ],
      ),
    );
  }

  Widget _buildSpecimenDetailsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Specimen Details', Icons.biotech, RecordTypeUtils.getGradient('pathology')),
          SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Specimen Type',
              prefixIcon: const Icon(Icons.biotech),
              filled: true,
              fillColor: context.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(borderRadius: AppRadii.radiusMd, borderSide: BorderSide.none),
            ),
            items: _specimenTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            onChanged: (value) => _specimenTypeController.text = value ?? '',
            validator: (value) {
              if (value == null || value.isEmpty) return 'Specimen type is required';
              return null;
            },
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _specimenSiteController,
            label: 'Specimen Site',
            hint: 'e.g., Left arm, Abdomen',
            prefixIcon: Icons.location_on,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _collectionMethodController,
            label: 'Collection Method',
            hint: 'e.g., Punch biopsy, Excision',
            prefixIcon: Icons.medical_services,
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile('Collection Date', _collectionDate, () => _selectDate(context, 'collection')),
        ],
      ),
    );
  }

  Widget _buildLaboratoryInfoSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Laboratory Information', Icons.local_hospital, RecordTypeUtils.getGradient('pathology')),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _pathologistController,
            label: 'Pathologist',
            prefixIcon: Icons.person,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _laboratoryController,
            label: 'Laboratory',
            prefixIcon: Icons.local_hospital,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _referringPhysicianController,
            label: 'Referring Physician',
            prefixIcon: Icons.person_outline,
          ),
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
            items: _urgencyLevels
                .map((urgency) => DropdownMenuItem(value: urgency, child: Text(urgency.toUpperCase())))
                .toList(),
            onChanged: (value) => setState(() => _selectedUrgency = value!),
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile('Report Date', _reportDate, () => _selectDate(context, 'report'), optional: true),
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
          _buildSectionHeader('Pathological Findings', Icons.search, RecordTypeUtils.getGradient('pathology')),
          SizedBox(height: AppSpacing.lg),
          HBTextField.multiline(
            controller: _grossDescriptionController,
            label: 'Gross Description',
            hint: 'Macroscopic findings',
            prefixIcon: Icons.visibility,
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _microscopicFindingsController,
            label: 'Microscopic Findings',
            hint: 'Histological observations',
            prefixIcon: Icons.search,
            minLines: 4,
            maxLines: 6,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _immunohistochemistryController,
            label: 'Immunohistochemistry',
            hint: 'IHC results',
            prefixIcon: Icons.science,
            minLines: 2,
            maxLines: 4,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _molecularStudiesController,
            label: 'Molecular Studies',
            hint: 'Genetic/molecular analysis',
            prefixIcon: Icons.dns,
            minLines: 2,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Diagnosis & Recommendations', Icons.medical_information, RecordTypeUtils.getGradient('pathology')),
          SizedBox(height: AppSpacing.lg),
          HBTextField.multiline(
            controller: _diagnosisController,
            label: 'Pathological Diagnosis',
            prefixIcon: Icons.medical_information,
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _stagingGradingController,
            label: 'Staging/Grading',
            hint: 'TNM staging, grade',
            prefixIcon: Icons.stairs,
            minLines: 2,
            maxLines: 4,
          ),
          SizedBox(height: AppSpacing.base),
          HBListTile.switchTile(
            title: 'Malignant',
            subtitle: 'Check if malignancy is present',
            icon: Icons.warning,
            value: _isMalignant,
            onChanged: (value) => setState(() => _isMalignant = value),
            iconColor: AppColors.error,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _recommendationController,
            label: 'Recommendations',
            hint: 'Further studies, treatment recommendations',
            prefixIcon: Icons.recommend,
            minLines: 3,
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, String type) async {
    DateTime? initialDate;
    DateTime? firstDate;
    DateTime? lastDate;

    switch (type) {
      case 'record':
        initialDate = _recordDate;
        firstDate = DateTime(1900);
        lastDate = DateTime.now();
        break;
      case 'collection':
        initialDate = _collectionDate;
        firstDate = DateTime(1900);
        lastDate = DateTime.now();
        break;
      case 'report':
        initialDate = _reportDate ?? _collectionDate;
        firstDate = _collectionDate;
        lastDate = DateTime.now();
        break;
      default:
        return;
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      setState(() {
        switch (type) {
          case 'record':
            _recordDate = selectedDate;
            break;
          case 'collection':
            _collectionDate = selectedDate;
            break;
          case 'report':
            _reportDate = selectedDate;
            break;
        }
      });
    }
  }

  Future<void> _savePathologyRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = PathologyRecordService();
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

      final request = CreatePathologyRecordRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        recordDate: _recordDate,
        specimenType: _specimenTypeController.text.trim(),
        specimenSite: _specimenSiteController.text.trim().isEmpty
            ? null
            : _specimenSiteController.text.trim(),
        pathologist: _pathologistController.text.trim().isEmpty
            ? null
            : _pathologistController.text.trim(),
        laboratory: _laboratoryController.text.trim().isEmpty
            ? null
            : _laboratoryController.text.trim(),
        collectionDate: _collectionDate,
        reportDate: _reportDate,
        collectionMethod: _collectionMethodController.text.trim().isEmpty
            ? null
            : _collectionMethodController.text.trim(),
        grossDescription: _grossDescriptionController.text.trim().isEmpty
            ? null
            : _grossDescriptionController.text.trim(),
        microscopicFindings: _microscopicFindingsController.text.trim().isEmpty
            ? null
            : _microscopicFindingsController.text.trim(),
        diagnosis: _diagnosisController.text.trim().isEmpty
            ? null
            : _diagnosisController.text.trim(),
        stagingGrading: _stagingGradingController.text.trim().isEmpty
            ? null
            : _stagingGradingController.text.trim(),
        immunohistochemistry: _immunohistochemistryController.text.trim().isEmpty
            ? null
            : _immunohistochemistryController.text.trim(),
        molecularStudies: _molecularStudiesController.text.trim().isEmpty
            ? null
            : _molecularStudiesController.text.trim(),
        recommendations: _recommendationController.text.trim().isEmpty
            ? null
            : _recommendationController.text.trim(),
        urgencyLevel: _selectedUrgency,
        isMalignant: _isMalignant,
        referringPhysician: _referringPhysicianController.text.trim().isEmpty
            ? null
            : _referringPhysicianController.text.trim(),
      );

      await service.createPathologyRecord(request);

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
                const Expanded(child: Text('Pathology record saved successfully')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
          ),
        );
      }

      developer.log('Pathology record created successfully for profile: $selectedProfileId',
        name: 'PathologyRecordForm', level: 800);
    } catch (error, stackTrace) {
      developer.log('Failed to save pathology record',
        name: 'PathologyRecordForm', level: 1000, error: error, stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: AppSizes.iconSm),
                SizedBox(width: AppSpacing.sm),
                const Expanded(child: Text('Failed to save pathology record. Please try again.')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _savePathologyRecord(),
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
          _buildSectionHeader('Attachments', Icons.attach_file, RecordTypeUtils.getGradient('pathology')),
          SizedBox(height: AppSpacing.sm),
          Text('Add pathology reports, biopsy results, or lab findings',
            style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
          SizedBox(height: AppSpacing.base),
          AttachmentFormWidget(
            initialAttachments: _attachments,
            onAttachmentsChanged: (attachments) {
              setState(() => _attachments = attachments);
            },
            maxFiles: 10,
            allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'tiff'],
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

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap, {bool optional = false}) {
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
                  Text(
                    date != null ? '${date.day}/${date.month}/${date.year}' : (optional ? 'Not set' : 'Select date'),
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: date != null ? context.colorScheme.onSurface : context.colorScheme.onSurfaceVariant)),
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
    _specimenTypeController.dispose();
    _specimenSiteController.dispose();
    _pathologistController.dispose();
    _laboratoryController.dispose();
    _collectionMethodController.dispose();
    _grossDescriptionController.dispose();
    _microscopicFindingsController.dispose();
    _diagnosisController.dispose();
    _stagingGradingController.dispose();
    _immunohistochemistryController.dispose();
    _molecularStudiesController.dispose();
    _recommendationController.dispose();
    _referringPhysicianController.dispose();
    super.dispose();
  }
}
