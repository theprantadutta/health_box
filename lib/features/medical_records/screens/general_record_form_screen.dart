import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../services/general_record_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/widgets/hb_app_bar.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/widgets/hb_list_tile.dart';
import 'dart:developer' as developer;

class GeneralRecordFormScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final String? generalRecordId;

  const GeneralRecordFormScreen({
    super.key,
    this.profileId,
    this.generalRecordId,
  });

  @override
  ConsumerState<GeneralRecordFormScreen> createState() =>
      _GeneralRecordFormScreenState();
}

class _GeneralRecordFormScreenState
    extends ConsumerState<GeneralRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _providerNameController = TextEditingController();
  final _institutionController = TextEditingController();
  final _documentTypeController = TextEditingController();
  final _referenceNumberController = TextEditingController();
  final _relatedConditionController = TextEditingController();
  final _notesController = TextEditingController();
  final _followUpRequiredController = TextEditingController();
  final _tagsController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  DateTime? _documentDate;
  DateTime? _expirationDate;
  DateTime? _reminderDate;
  bool _isConfidential = false;
  bool _requiresAction = false;
  bool _isLoading = false;
  bool _isEditing = false;
  List<AttachmentResult> _attachments = [];

  final List<String> _categories = [
    'Insurance Documents',
    'Consent Forms',
    'Referrals',
    'Test Results',
    'Medical Reports',
    'Treatment Plans',
    'Emergency Information',
    'Legal Documents',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.generalRecordId != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HBAppBar.gradient(
        title: _isEditing ? 'Edit General Record' : 'New General Record',
        gradient: HealthBoxDesignSystem.medicalGreen,
        actions: [
          HBButton.text(
            onPressed: _isLoading ? null : _saveGeneralRecord,
            child: Text(_isLoading ? 'SAVING...' : 'SAVE', style: const TextStyle(color: Colors.white)),
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
            _buildCategorySection(),
            SizedBox(height: AppSpacing.base),
            _buildProviderInfoSection(),
            SizedBox(height: AppSpacing.base),
            _buildDocumentDetailsSection(),
            SizedBox(height: AppSpacing.base),
            _buildNotesAndTagsSection(),
            SizedBox(height: AppSpacing.base),
            _buildSettingsSection(),
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
          _buildSectionHeader('Basic Information', Icons.description, HealthBoxDesignSystem.medicalGreen),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _titleController,
            label: 'Title',
            hint: 'e.g., Insurance Card, Referral Letter',
            prefixIcon: Icons.description,
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
            hint: 'Additional details about this record',
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile('Record Date', _recordDate, () => _selectDate(context, 'record')),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Category', Icons.category, HealthBoxDesignSystem.medicalGreen),
          SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Category',
              prefixIcon: const Icon(Icons.category),
              filled: true,
              fillColor: context.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(borderRadius: AppRadii.radiusMd, borderSide: BorderSide.none),
            ),
            items: _categories
                .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                .toList(),
            onChanged: (value) {
              setState(() => _categoryController.text = value ?? '');
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Category is required';
              }
              return null;
            },
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _subcategoryController,
            label: 'Subcategory',
            hint: 'More specific classification',
            prefixIcon: Icons.subdirectory_arrow_right,
          ),
        ],
      ),
    );
  }

  Widget _buildProviderInfoSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Provider Information', Icons.person, HealthBoxDesignSystem.medicalGreen),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _providerNameController,
            label: 'Provider Name',
            hint: 'Healthcare provider or contact person',
            prefixIcon: Icons.person,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _institutionController,
            label: 'Institution',
            hint: 'Hospital, clinic, or organization',
            prefixIcon: Icons.business,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentDetailsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Document Details', Icons.insert_drive_file, HealthBoxDesignSystem.medicalGreen),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _documentTypeController,
            label: 'Document Type',
            hint: 'e.g., PDF, Image, Form',
            prefixIcon: Icons.insert_drive_file,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _referenceNumberController,
            label: 'Reference Number',
            hint: 'ID, case number, or reference',
            prefixIcon: Icons.confirmation_number,
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile('Document Date', _documentDate, () => _selectDate(context, 'document'), optional: true),
          SizedBox(height: AppSpacing.base),
          _buildDateTile('Expiration Date', _expirationDate, () => _selectDate(context, 'expiration'), optional: true),
          SizedBox(height: AppSpacing.base),
          _buildDateTile('Reminder Date', _reminderDate, () => _selectDate(context, 'reminder'), optional: true),
        ],
      ),
    );
  }

  Widget _buildNotesAndTagsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Additional Information', Icons.note, HealthBoxDesignSystem.medicalGreen),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _relatedConditionController,
            label: 'Related Condition',
            hint: 'Associated medical condition',
            prefixIcon: Icons.link,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _notesController,
            label: 'Notes',
            hint: 'Additional notes or comments',
            prefixIcon: Icons.note,
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _followUpRequiredController,
            label: 'Follow-up Required',
            hint: 'What follow-up actions are needed',
            prefixIcon: Icons.follow_the_signs,
            minLines: 2,
            maxLines: 4,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.filled(
            controller: _tagsController,
            label: 'Tags',
            hint: 'Comma-separated tags for organization',
            prefixIcon: Icons.tag,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Settings', Icons.settings, HealthBoxDesignSystem.medicalGreen),
          SizedBox(height: AppSpacing.lg),
          HBListTile.switchTile(
            title: 'Confidential',
            subtitle: 'Mark as sensitive information',
            icon: Icons.security,
            value: _isConfidential,
            onChanged: (value) => setState(() => _isConfidential = value),
            iconColor: AppColors.warning,
          ),
          SizedBox(height: AppSpacing.sm),
          HBListTile.switchTile(
            title: 'Requires Action',
            subtitle: 'Mark if follow-up action is needed',
            icon: Icons.flag,
            value: _requiresAction,
            onChanged: (value) => setState(() => _requiresAction = value),
            iconColor: AppColors.error,
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
      case 'document':
        initialDate = _documentDate ?? DateTime.now();
        firstDate = DateTime(1900);
        lastDate = DateTime.now();
        break;
      case 'expiration':
        initialDate = _expirationDate ?? DateTime.now().add(const Duration(days: 365));
        firstDate = DateTime.now();
        lastDate = DateTime.now().add(const Duration(days: 365 * 10));
        break;
      case 'reminder':
        initialDate = _reminderDate ?? DateTime.now().add(const Duration(days: 30));
        firstDate = DateTime.now();
        lastDate = DateTime.now().add(const Duration(days: 365 * 5));
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
          case 'document':
            _documentDate = selectedDate;
            break;
          case 'expiration':
            _expirationDate = selectedDate;
            break;
          case 'reminder':
            _reminderDate = selectedDate;
            break;
        }
      });
    }
  }

  Future<void> _saveGeneralRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = GeneralRecordService();
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

      final request = CreateGeneralRecordRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        recordDate: _recordDate,
        category: _categoryController.text.trim(),
        subcategory: _subcategoryController.text.trim().isEmpty
            ? null
            : _subcategoryController.text.trim(),
        providerName: _providerNameController.text.trim().isEmpty
            ? null
            : _providerNameController.text.trim(),
        institution: _institutionController.text.trim().isEmpty
            ? null
            : _institutionController.text.trim(),
        documentDate: _documentDate,
        documentType: _documentTypeController.text.trim().isEmpty
            ? null
            : _documentTypeController.text.trim(),
        referenceNumber: _referenceNumberController.text.trim().isEmpty
            ? null
            : _referenceNumberController.text.trim(),
        relatedCondition: _relatedConditionController.text.trim().isEmpty
            ? null
            : _relatedConditionController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        followUpRequired: _followUpRequiredController.text.trim().isEmpty
            ? null
            : _followUpRequiredController.text.trim(),
        expirationDate: _expirationDate,
        reminderDate: _reminderDate,
        tags: _tagsController.text.trim().isEmpty
            ? null
            : _tagsController.text.trim(),
        isConfidential: _isConfidential,
        requiresAction: _requiresAction,
      );

      await service.createGeneralRecord(request);

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
                const Expanded(child: Text('General record saved successfully')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
          ),
        );
      }

      developer.log('General record created successfully for profile: $selectedProfileId',
        name: 'GeneralRecordForm', level: 800);
    } catch (error, stackTrace) {
      developer.log('Failed to save general record',
        name: 'GeneralRecordForm', level: 1000, error: error, stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: AppSizes.iconSm),
                SizedBox(width: AppSpacing.sm),
                const Expanded(child: Text('Failed to save general record. Please try again.')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveGeneralRecord(),
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

  Widget _buildAttachmentsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Attachments', Icons.attach_file, HealthBoxDesignSystem.medicalGreen),
          SizedBox(height: AppSpacing.sm),
          Text('Add any relevant medical documents or files',
            style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
          SizedBox(height: AppSpacing.base),
          AttachmentFormWidget(
            initialAttachments: _attachments,
            onAttachmentsChanged: (attachments) {
              setState(() => _attachments = attachments);
            },
            maxFiles: 15,
            allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'txt'],
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
    _categoryController.dispose();
    _subcategoryController.dispose();
    _providerNameController.dispose();
    _institutionController.dispose();
    _documentTypeController.dispose();
    _referenceNumberController.dispose();
    _relatedConditionController.dispose();
    _notesController.dispose();
    _followUpRequiredController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
