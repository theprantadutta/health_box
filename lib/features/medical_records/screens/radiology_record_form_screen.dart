import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/radiology_record_service.dart';
import '../../../data/models/radiology_record.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/modern_text_field.dart';
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
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Radiology Report' : 'New Radiology Report'),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: HealthBoxDesignSystem.radiologyGradient,
            boxShadow: [
              BoxShadow(
                color: HealthBoxDesignSystem.radiologyGradient.colors.first.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveRadiologyRecord,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
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
            _buildStudyDetailsSection(),
            const SizedBox(height: 16),
            _buildClinicalInfoSection(),
            const SizedBox(height: 16),
            _buildFindingsSection(),
            const SizedBox(height: 16),
            _buildTechnicalDetailsSection(),
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
      children: [
        ModernTextField(
          controller: _titleController,
          labelText: 'Title *',
          hintText: 'e.g., Chest X-Ray Report',
          prefixIcon: const Icon(Icons.assessment),
          focusGradient: HealthBoxDesignSystem.radiologyGradient,
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
          hintText: 'Additional details about this study',
          maxLines: 3,
          focusGradient: HealthBoxDesignSystem.radiologyGradient,
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Record Date'),
          subtitle: Text(_formatDate(_recordDate)),
          trailing: const Icon(Icons.calendar_today),
          onTap: () => _selectDate(context, isRecordDate: true),
        ),
      ],
    );
  }

  Widget _buildStudyDetailsSection() {
    return _buildModernSection(
      title: 'Study Details',
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedStudyType,
          decoration: const InputDecoration(
            labelText: 'Study Type *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.medical_services),
          ),
          items: RadiologyStudyTypes.allTypes
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedStudyType = value);
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Study type is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedBodyPart,
          decoration: const InputDecoration(
            labelText: 'Body Part',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.accessibility),
          ),
          items: RadiologyBodyParts.allParts
              .map((part) => DropdownMenuItem(
                    value: part,
                    child: Text(part),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() => _selectedBodyPart = value);
          },
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Study Date'),
          subtitle: Text(_formatDate(_studyDate)),
          trailing: const Icon(Icons.calendar_today),
          onTap: () => _selectDate(context, isRecordDate: false),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedUrgency,
          decoration: const InputDecoration(
            labelText: 'Urgency Level',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.priority_high),
          ),
          items: RadiologyUrgency.allLevels
              .map((urgency) => DropdownMenuItem(
                    value: urgency,
                    child: Text(_getUrgencyDisplayName(urgency)),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedUrgency = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildClinicalInfoSection() {
    return _buildModernSection(
      title: 'Clinical Information',
      children: [
        ModernTextField(
          controller: _radiologistController,
          labelText: 'Radiologist',
          hintText: 'Interpreting radiologist name',
          prefixIcon: const Icon(Icons.person),
          focusGradient: HealthBoxDesignSystem.radiologyGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _facilityController,
          labelText: 'Facility',
          hintText: 'Where the study was performed',
          prefixIcon: const Icon(Icons.local_hospital),
          focusGradient: HealthBoxDesignSystem.radiologyGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _referringPhysicianController,
          labelText: 'Referring Physician',
          hintText: 'Doctor who ordered the study',
          prefixIcon: const Icon(Icons.person_outline),
          focusGradient: HealthBoxDesignSystem.radiologyGradient,
        ),
      ],
    );
  }

  Widget _buildFindingsSection() {
    return _buildModernSection(
      title: 'Findings & Interpretation',
      children: [
        SwitchListTile(
          title: const Text('Normal Study'),
          subtitle: const Text('Check if findings are within normal limits'),
          value: _isNormal,
          onChanged: (value) {
            setState(() => _isNormal = value);
          },
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _findingsController,
          labelText: 'Findings',
          hintText: 'Detailed radiological findings',
          prefixIcon: const Icon(Icons.search),
          maxLines: 4,
          focusGradient: HealthBoxDesignSystem.radiologyGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _impressionController,
          labelText: 'Impression',
          hintText: 'Radiologist\'s diagnostic impression',
          prefixIcon: const Icon(Icons.psychology),
          maxLines: 3,
          focusGradient: HealthBoxDesignSystem.radiologyGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _recommendationController,
          labelText: 'Recommendations',
          hintText: 'Follow-up recommendations',
          prefixIcon: const Icon(Icons.recommend),
          maxLines: 3,
          focusGradient: HealthBoxDesignSystem.radiologyGradient,
        ),
      ],
    );
  }

  Widget _buildTechnicalDetailsSection() {
    return _buildModernSection(
      title: 'Technical Details',
      children: [
        ModernTextField(
          controller: _techniqueController,
          labelText: 'Technique',
          hintText: 'Imaging technique used',
          prefixIcon: const Icon(Icons.settings),
          maxLines: 2,
          focusGradient: HealthBoxDesignSystem.radiologyGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _contrastController,
          labelText: 'Contrast Agent',
          hintText: 'Contrast used (if any)',
          prefixIcon: const Icon(Icons.colorize),
          focusGradient: HealthBoxDesignSystem.radiologyGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _protocolUsedController,
          labelText: 'Protocol Used',
          hintText: 'Imaging protocol or sequence',
          prefixIcon: const Icon(Icons.list),
          maxLines: 2,
          focusGradient: HealthBoxDesignSystem.radiologyGradient,
        ),
      ],
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
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Radiology record saved successfully'),
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
        'Radiology record created successfully for profile: $selectedProfileId',
        name: 'RadiologyRecordForm',
        level: 800, // INFO level
      );
    } catch (error, stackTrace) {
      // Log detailed error to console
      developer.log(
        'Failed to save radiology record',
        name: 'RadiologyRecordForm',
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
                  child: Text('Failed to save radiology record. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    return _buildModernSection(
      title: 'Attachments',
      subtitle: 'Add imaging results, radiologist reports, or scan images',
      children: [
        AttachmentFormWidget(
          initialAttachments: _attachments,
          onAttachmentsChanged: (attachments) {
            setState(() {
              _attachments = attachments;
            });
          },
          maxFiles: 10,
          allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'dicom'],
          maxFileSizeMB: 50,
        ),
      ],
    );
  }

  Widget _buildModernSection({
    required String title,
    String? subtitle,
    required List<Widget> children,
    Gradient? gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            (gradient ?? HealthBoxDesignSystem.radiologyGradient)
                .colors
                .first
                .withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (gradient ?? HealthBoxDesignSystem.radiologyGradient)
              .colors
              .first
              .withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (gradient ?? HealthBoxDesignSystem.radiologyGradient)
                .colors
                .first
                .withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => (gradient ?? HealthBoxDesignSystem.radiologyGradient)
                  .createShader(bounds),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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