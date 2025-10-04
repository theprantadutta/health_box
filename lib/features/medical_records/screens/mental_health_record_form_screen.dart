import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../services/mental_health_record_service.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/widgets/modern_text_field.dart';
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
      appBar: AppBar(
        title: const Text(
          'Mental Health Record',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: HealthBoxDesignSystem.mentalHealthGradient,
            boxShadow: [
              BoxShadow(
                color: HealthBoxDesignSystem.mentalHealthGradient.colors.first
                    .withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMentalHealthRecord,
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
            _buildSessionDetailsSection(),
            const SizedBox(height: 16),
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
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Mental health record saved successfully'),
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
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Failed to save mental health record. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    return _buildModernSection(
      title: 'Session Details',
      children: [
        ModernTextField(
          controller: _titleController,
          labelText: 'Title *',
          hintText: 'e.g., Therapy Session - Anxiety Management',
          prefixIcon: const Icon(Icons.psychology),
          focusGradient: HealthBoxDesignSystem.mentalHealthGradient,
          validator: (value) => value?.trim().isEmpty == true ? 'Title is required' : null,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _providerController,
          labelText: 'Mental Health Provider',
          prefixIcon: const Icon(Icons.person),
          focusGradient: HealthBoxDesignSystem.mentalHealthGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _facilityController,
          labelText: 'Facility/Practice',
          prefixIcon: const Icon(Icons.business),
          focusGradient: HealthBoxDesignSystem.mentalHealthGradient,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _sessionType,
          decoration: const InputDecoration(
            labelText: 'Session Type',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: _sessionTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
          onChanged: (value) => setState(() => _sessionType = value!),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Session Date'),
          subtitle: Text('${_sessionDate.day}/${_sessionDate.month}/${_sessionDate.year}'),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _sessionDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) setState(() => _sessionDate = date);
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Mood Rating (1-10): '),
            Expanded(
              child: Slider(
                value: double.parse(_moodRating),
                min: 1,
                max: 10,
                divisions: 9,
                label: _moodRating,
                onChanged: (value) => setState(() => _moodRating = value.round().toString()),
              ),
            ),
            Text(_moodRating),
          ],
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _sessionNotesController,
          labelText: 'Session Notes',
          maxLines: 4,
          focusGradient: HealthBoxDesignSystem.mentalHealthGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _assessmentController,
          labelText: 'Assessment/Observations',
          maxLines: 3,
          focusGradient: HealthBoxDesignSystem.mentalHealthGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _treatmentPlanController,
          labelText: 'Treatment Plan',
          maxLines: 3,
          focusGradient: HealthBoxDesignSystem.mentalHealthGradient,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _medicationsController,
          labelText: 'Medications/Recommendations',
          maxLines: 2,
          focusGradient: HealthBoxDesignSystem.mentalHealthGradient,
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return _buildModernSection(
      title: 'Attachments',
      subtitle: 'Add therapy notes, assessments, or treatment plans',
      children: [
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
            (gradient ?? HealthBoxDesignSystem.mentalHealthGradient)
                .colors
                .first
                .withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (gradient ?? HealthBoxDesignSystem.mentalHealthGradient)
              .colors
              .first
              .withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (gradient ?? HealthBoxDesignSystem.mentalHealthGradient)
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
              shaderCallback: (bounds) => (gradient ?? HealthBoxDesignSystem.mentalHealthGradient)
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