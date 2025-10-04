import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../services/pathology_record_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/widgets/modern_text_field.dart';
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
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: HealthBoxDesignSystem.pathologyGradient,
          ),
        ),
        title: Text(_isEditing ? 'Edit Pathology Report' : 'New Pathology Report'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePathologyRecord,
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
            _buildSpecimenDetailsSection(),
            const SizedBox(height: 16),
            _buildLaboratoryInfoSection(),
            const SizedBox(height: 16),
            _buildFindingsSection(),
            const SizedBox(height: 16),
            _buildDiagnosisSection(),
            const SizedBox(height: 16),
            _buildAttachmentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildModernSection(
      title: 'Basic Information',
      icon: Icons.info_outline,
      children: [
        ModernTextField(
          controller: _titleController,
          labelText: 'Title *',
          hintText: 'e.g., Skin Biopsy Report',
          prefixIcon: const Icon(Icons.assignment),
          focusGradient: HealthBoxDesignSystem.pathologyGradient,
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
          prefixIcon: const Icon(Icons.description),
          focusGradient: HealthBoxDesignSystem.pathologyGradient,
          maxLines: 2,
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

  Widget _buildSpecimenDetailsSection() {
    return _buildModernSection(
      title: 'Specimen Details',
      icon: Icons.biotech,
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Specimen Type *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.biotech),
          ),
          items: _specimenTypes
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: (value) => _specimenTypeController.text = value ?? '',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Specimen type is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _specimenSiteController,
          labelText: 'Specimen Site',
          hintText: 'e.g., Left arm, Abdomen',
          prefixIcon: const Icon(Icons.location_on),
          focusGradient: HealthBoxDesignSystem.pathologyGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _collectionMethodController,
          labelText: 'Collection Method',
          hintText: 'e.g., Punch biopsy, Excision',
          prefixIcon: const Icon(Icons.medical_services),
          focusGradient: HealthBoxDesignSystem.pathologyGradient,
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Collection Date'),
          subtitle: Text(_formatDate(_collectionDate)),
          trailing: const Icon(Icons.calendar_today),
          onTap: () => _selectDate(context, 'collection'),
        ),
      ],
    );
  }

  Widget _buildLaboratoryInfoSection() {
    return _buildModernSection(
      title: 'Laboratory Information',
      icon: Icons.local_hospital,
      children: [
        ModernTextField(
          controller: _pathologistController,
          labelText: 'Pathologist',
          prefixIcon: const Icon(Icons.person),
          focusGradient: HealthBoxDesignSystem.pathologyGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _laboratoryController,
          labelText: 'Laboratory',
          prefixIcon: const Icon(Icons.local_hospital),
          focusGradient: HealthBoxDesignSystem.pathologyGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _referringPhysicianController,
          labelText: 'Referring Physician',
          prefixIcon: const Icon(Icons.person_outline),
          focusGradient: HealthBoxDesignSystem.pathologyGradient,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedUrgency,
          decoration: const InputDecoration(
            labelText: 'Urgency Level',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.priority_high),
          ),
          items: _urgencyLevels
              .map((urgency) => DropdownMenuItem(
                    value: urgency,
                    child: Text(urgency.toUpperCase()),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedUrgency = value!),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Report Date'),
          subtitle: Text(_reportDate != null ? _formatDate(_reportDate!) : 'Not set'),
          trailing: const Icon(Icons.calendar_today),
          onTap: () => _selectDate(context, 'report'),
        ),
      ],
    );
  }

  Widget _buildFindingsSection() {
    return _buildModernSection(
      title: 'Pathological Findings',
      icon: Icons.search,
      children: [
        ModernTextField(
          controller: _grossDescriptionController,
          labelText: 'Gross Description',
          hintText: 'Macroscopic findings',
          prefixIcon: const Icon(Icons.visibility),
          focusGradient: HealthBoxDesignSystem.pathologyGradient,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _microscopicFindingsController,
          labelText: 'Microscopic Findings',
          hintText: 'Histological observations',
          prefixIcon: const Icon(Icons.search),
          focusGradient: HealthBoxDesignSystem.pathologyGradient,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _immunohistochemistryController,
          labelText: 'Immunohistochemistry',
          hintText: 'IHC results',
          prefixIcon: const Icon(Icons.science),
          focusGradient: HealthBoxDesignSystem.pathologyGradient,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _molecularStudiesController,
          labelText: 'Molecular Studies',
          hintText: 'Genetic/molecular analysis',
          prefixIcon: const Icon(Icons.dns),
          focusGradient: HealthBoxDesignSystem.pathologyGradient,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildDiagnosisSection() {
    return _buildModernSection(
      title: 'Diagnosis & Recommendations',
      icon: Icons.medical_information,
      children: [
        ModernTextField(
          controller: _diagnosisController,
          labelText: 'Pathological Diagnosis',
          prefixIcon: const Icon(Icons.medical_information),
          focusGradient: HealthBoxDesignSystem.pathologyGradient,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _stagingGradingController,
          labelText: 'Staging/Grading',
          hintText: 'TNM staging, grade',
          prefixIcon: const Icon(Icons.stairs),
          focusGradient: HealthBoxDesignSystem.pathologyGradient,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Malignant'),
          subtitle: const Text('Check if malignancy is present'),
          value: _isMalignant,
          onChanged: (value) => setState(() => _isMalignant = value),
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _recommendationController,
          labelText: 'Recommendations',
          hintText: 'Further studies, treatment recommendations',
          prefixIcon: const Icon(Icons.recommend),
          focusGradient: HealthBoxDesignSystem.pathologyGradient,
          maxLines: 3,
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
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Pathology record saved successfully'),
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
        'Pathology record created successfully for profile: $selectedProfileId',
        name: 'PathologyRecordForm',
        level: 800, // INFO level
      );
    } catch (error, stackTrace) {
      // Log detailed error to console
      developer.log(
        'Failed to save pathology record',
        name: 'PathologyRecordForm',
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
                  child: Text('Failed to save pathology record. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    return _buildModernSection(
      title: 'Attachments',
      icon: Icons.attach_file,
      children: [
        Text(
          'Add pathology reports, biopsy results, or lab findings',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
          maxFiles: 10,
          allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'tiff'],
          maxFileSizeMB: 50,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildModernSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    LinearGradient? gradient,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sectionGradient = gradient ?? HealthBoxDesignSystem.pathologyGradient;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: sectionGradient.colors.first.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: sectionGradient.colors.first.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(gradient: sectionGradient),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: sectionGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: sectionGradient.colors.first.withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(icon, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...children,
                ],
              ),
            ),
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