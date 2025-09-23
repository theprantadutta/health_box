import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/general_record_service.dart';
import '../widgets/attachment_picker_widget.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

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
  List<File> _selectedFiles = [];

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
        title: Text(_isEditing ? 'Edit General Record' : 'New General Record'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveGeneralRecord,
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
            const SizedBox(height: 24),
            _buildCategorySection(),
            const SizedBox(height: 24),
            _buildProviderInfoSection(),
            const SizedBox(height: 24),
            _buildDocumentDetailsSection(),
            const SizedBox(height: 24),
            _buildNotesAndTagsSection(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 24),
            _buildAttachmentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., Insurance Card, Referral Letter',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Additional details about this record',
                border: OutlineInputBorder(),
              ),
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
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
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
            TextFormField(
              controller: _subcategoryController,
              decoration: const InputDecoration(
                labelText: 'Subcategory',
                hintText: 'More specific classification',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subdirectory_arrow_right),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provider Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _providerNameController,
              decoration: const InputDecoration(
                labelText: 'Provider Name',
                hintText: 'Healthcare provider or contact person',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _institutionController,
              decoration: const InputDecoration(
                labelText: 'Institution',
                hintText: 'Hospital, clinic, or organization',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _documentTypeController,
              decoration: const InputDecoration(
                labelText: 'Document Type',
                hintText: 'e.g., PDF, Image, Form',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.insert_drive_file),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _referenceNumberController,
              decoration: const InputDecoration(
                labelText: 'Reference Number',
                hintText: 'ID, case number, or reference',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.confirmation_number),
              ),
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
        ),
      ),
    );
  }

  Widget _buildNotesAndTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _relatedConditionController,
              decoration: const InputDecoration(
                labelText: 'Related Condition',
                hintText: 'Associated medical condition',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Additional notes or comments',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _followUpRequiredController,
              decoration: const InputDecoration(
                labelText: 'Follow-up Required',
                hintText: 'What follow-up actions are needed',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.follow_the_signs),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'Comma-separated tags for organization',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
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
        ),
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

      // Refresh medical records providers
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(selectedProfileId));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('General record saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save general record: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save general record: $e'),
            backgroundColor: Colors.red,
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
    return AttachmentPickerWidget(
      onFilesSelected: (files) {
        setState(() {
          _selectedFiles = files;
        });
      },
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'txt'],
      maxFiles: 15,
      maxFileSizeBytes: 50 * 1024 * 1024,
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