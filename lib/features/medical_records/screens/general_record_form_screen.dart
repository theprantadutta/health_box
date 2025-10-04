import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/modern_text_field.dart';
import '../services/general_record_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
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

  // Predefined categories
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
    if (_isEditing) {
      _loadGeneralRecord();
    }
  }

  Future<void> _loadGeneralRecord() async {
    // TODO: Load existing general record data when editing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit General Record' : 'New General Record', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: HealthBoxDesignSystem.medicalGreen,
            boxShadow: [
              BoxShadow(
                color: HealthBoxDesignSystem.medicalGreen.colors.first.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveGeneralRecord,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Text(_isLoading ? 'SAVING...' : 'SAVE'),
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
            _buildCategorySection(),
            const SizedBox(height: 16),
            _buildProviderInfoSection(),
            const SizedBox(height: 16),
            _buildDocumentDetailsSection(),
            const SizedBox(height: 16),
            _buildNotesAndTagsSection(),
            const SizedBox(height: 16),
            _buildSettingsSection(),
            const SizedBox(height: 16),
            _buildAttachmentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildModernSection(
      context: context,
      title: 'Basic Information',
      children: [
        ModernTextField(
          controller: _titleController,
          labelText: 'Title *',
          hintText: 'e.g., Insurance Card, Referral Letter',
          prefixIcon: const Icon(Icons.description),
          focusGradient: HealthBoxDesignSystem.medicalGreen,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _descriptionController,
          labelText: 'Description',
          hintText: 'Additional details about this record',
          focusGradient: HealthBoxDesignSystem.medicalGreen,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Record Date'),
          subtitle: Text(_formatDate(_recordDate)),
          trailing: const Icon(Icons.calendar_today),
          onTap: () => _selectDate(context, 'record'),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return _buildModernSection(
      context: context,
      title: 'Category',
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Category *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: _categories
              .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
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
        const SizedBox(height: 16),
        ModernTextField(
          controller: _subcategoryController,
          labelText: 'Subcategory',
          hintText: 'More specific classification',
          prefixIcon: const Icon(Icons.subdirectory_arrow_right),
          focusGradient: HealthBoxDesignSystem.medicalGreen,
        ),
      ],
    );
  }

  Widget _buildProviderInfoSection() {
    return _buildModernSection(
      context: context,
      title: 'Provider Information',
      children: [
        ModernTextField(
          controller: _providerNameController,
          labelText: 'Provider Name',
          hintText: 'Healthcare provider or contact person',
          prefixIcon: const Icon(Icons.person),
          focusGradient: HealthBoxDesignSystem.medicalGreen,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _institutionController,
          labelText: 'Institution',
          hintText: 'Hospital, clinic, or organization',
          prefixIcon: const Icon(Icons.business),
          focusGradient: HealthBoxDesignSystem.medicalGreen,
        ),
      ],
    );
  }

  Widget _buildDocumentDetailsSection() {
    return _buildModernSection(
      context: context,
      title: 'Document Details',
      children: [
        ModernTextField(
          controller: _documentTypeController,
          labelText: 'Document Type',
          hintText: 'e.g., PDF, Image, Form',
          prefixIcon: const Icon(Icons.insert_drive_file),
          focusGradient: HealthBoxDesignSystem.medicalGreen,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _referenceNumberController,
          labelText: 'Reference Number',
          hintText: 'ID, case number, or reference',
          prefixIcon: const Icon(Icons.confirmation_number),
          focusGradient: HealthBoxDesignSystem.medicalGreen,
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Document Date'),
          subtitle: Text(_documentDate != null
              ? _formatDate(_documentDate!)
              : 'Not set'),
          trailing: const Icon(Icons.calendar_today),
          onTap: () => _selectDate(context, 'document'),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Expiration Date'),
          subtitle: Text(_expirationDate != null
              ? _formatDate(_expirationDate!)
              : 'Not set'),
          trailing: const Icon(Icons.event_busy),
          onTap: () => _selectDate(context, 'expiration'),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Reminder Date'),
          subtitle: Text(_reminderDate != null
              ? _formatDate(_reminderDate!)
              : 'Not set'),
          trailing: const Icon(Icons.alarm),
          onTap: () => _selectDate(context, 'reminder'),
        ),
      ],
    );
  }

  Widget _buildNotesAndTagsSection() {
    return _buildModernSection(
      context: context,
      title: 'Additional Information',
      children: [
        ModernTextField(
          controller: _relatedConditionController,
          labelText: 'Related Condition',
          hintText: 'Associated medical condition',
          prefixIcon: const Icon(Icons.link),
          focusGradient: HealthBoxDesignSystem.medicalGreen,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _notesController,
          labelText: 'Notes',
          hintText: 'Additional notes or comments',
          prefixIcon: const Icon(Icons.note),
          focusGradient: HealthBoxDesignSystem.medicalGreen,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _followUpRequiredController,
          labelText: 'Follow-up Required',
          hintText: 'What follow-up actions are needed',
          prefixIcon: const Icon(Icons.follow_the_signs),
          focusGradient: HealthBoxDesignSystem.medicalGreen,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _tagsController,
          labelText: 'Tags',
          hintText: 'Comma-separated tags for organization',
          prefixIcon: const Icon(Icons.tag),
          focusGradient: HealthBoxDesignSystem.medicalGreen,
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return _buildModernSection(
      context: context,
      title: 'Settings',
      children: [
        SwitchListTile(
          title: const Text('Confidential'),
          subtitle: const Text('Mark as sensitive information'),
          value: _isConfidential,
          onChanged: (value) {
            setState(() => _isConfidential = value);
          },
        ),
        SwitchListTile(
          title: const Text('Requires Action'),
          subtitle: const Text('Mark if follow-up action is needed'),
          value: _requiresAction,
          onChanged: (value) {
            setState(() => _requiresAction = value);
          },
        ),
      ],
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
                  child: Text('General record saved successfully'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }

      // Log success
      developer.log(
        'General record created successfully for profile: $selectedProfileId',
        name: 'GeneralRecordForm',
        level: 800, // INFO level
      );
    } catch (error, stackTrace) {
      // Log detailed error to console
      developer.log(
        'Failed to save general record',
        name: 'GeneralRecordForm',
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
                  child: Text('Failed to save general record. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildModernSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            HealthBoxDesignSystem.medicalGreen.colors.first.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HealthBoxDesignSystem.medicalGreen.colors.first.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: HealthBoxDesignSystem.medicalGreen.colors.first.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: HealthBoxDesignSystem.medicalGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: HealthBoxDesignSystem.medicalGreen.colors.first,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return _buildModernSection(
      context: context,
      title: 'Attachments',
      children: [
        Text(
          'Add any relevant medical documents or files',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
          maxFiles: 15,
          allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'txt'],
          maxFileSizeMB: 50,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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