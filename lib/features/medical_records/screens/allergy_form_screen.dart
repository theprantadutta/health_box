import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../../shared/providers/medical_records_providers.dart';
import '../services/allergy_service.dart';
import '../../../data/models/allergy.dart';
import '../../../shared/widgets/attachment_form_widget.dart';
import '../../../shared/services/attachment_service.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/modern_text_field.dart';

class AllergyFormScreen extends ConsumerStatefulWidget {
  final String? profileId;
  final String? allergyId;

  const AllergyFormScreen({
    super.key,
    this.profileId,
    this.allergyId,
  });

  @override
  ConsumerState<AllergyFormScreen> createState() => _AllergyFormScreenState();
}

class _AllergyFormScreenState extends ConsumerState<AllergyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _allergenController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _recordDate = DateTime.now();
  String _selectedSeverity = AllergySeverity.mild;
  Set<String> _selectedSymptoms = <String>{};
  bool _isAllergyActive = true;
  DateTime? _firstReaction;
  DateTime? _lastReaction;
  bool _isLoading = false;
  bool _isEditing = false;
  List<AttachmentResult> _attachments = [];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.allergyId != null;
    if (_isEditing) {
      _loadAllergy();
    }
  }

  Future<void> _loadAllergy() async {
    // TODO: Load existing allergy data when editing
    // This will be implemented with the allergy service
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Allergy' : 'New Allergy'),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: HealthBoxDesignSystem.allergyGradient,
            boxShadow: [
              BoxShadow(
                color: HealthBoxDesignSystem.allergyGradient.colors.first.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveAllergy,
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
            _buildAllergenDetailsSection(),
            const SizedBox(height: 16),
            _buildSeveritySection(),
            const SizedBox(height: 16),
            _buildSymptomsSection(),
            const SizedBox(height: 16),
            _buildReactionDatesSection(),
            const SizedBox(height: 16),
            _buildTreatmentSection(),
            const SizedBox(height: 16),
            _buildAttachmentsSection(),
            const SizedBox(height: 16),
            _buildStatusSection(),
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
          hintText: 'e.g., Peanut Allergy',
          prefixIcon: const Icon(Icons.warning),
          focusGradient: HealthBoxDesignSystem.allergyGradient,
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
          hintText: 'Additional details about this allergy',
          focusGradient: HealthBoxDesignSystem.allergyGradient,
          maxLines: 3,
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

  Widget _buildAllergenDetailsSection() {
    return _buildModernSection(
      title: 'Allergen Details',
      icon: Icons.eco,
      children: [
        ModernTextField(
          controller: _allergenController,
          labelText: 'Allergen *',
          hintText: 'e.g., Peanuts, Shellfish, Penicillin',
          prefixIcon: const Icon(Icons.eco),
          focusGradient: HealthBoxDesignSystem.allergyGradient,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Allergen is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Common Allergen Types',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: AllergenTypes.allTypes.map((type) {
            return FilterChip(
              label: Text(type),
              selected: false,
              onSelected: (selected) {
                if (selected) {
                  _allergenController.text = type;
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSeveritySection() {
    return _buildModernSection(
      title: 'Severity Level',
      icon: Icons.emergency,
      children: [
        SegmentedButton<String>(
          segments: AllergySeverity.allSeverities
              .map((severity) => ButtonSegment<String>(
                    value: severity,
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_getSeverityDisplayName(severity)),
                        Text(
                          _getSeverityDescription(severity),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ))
              .toList(),
          selected: {_selectedSeverity},
          onSelectionChanged: (Set<String> selection) {
            if (selection.isNotEmpty) {
              setState(() => _selectedSeverity = selection.first);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSymptomsSection() {
    return _buildModernSection(
      title: 'Symptoms',
      icon: Icons.health_and_safety,
      children: [
        Text(
          'Select all symptoms you experience:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: AllergySymptoms.allSymptoms.map((symptom) {
            return FilterChip(
              label: Text(symptom),
              selected: _selectedSymptoms.contains(symptom),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSymptoms.add(symptom);
                  } else {
                    _selectedSymptoms.remove(symptom);
                  }
                });
              },
            );
          }).toList(),
        ),
        if (_selectedSymptoms.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one symptom',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReactionDatesSection() {
    return _buildModernSection(
      title: 'Reaction History',
      icon: Icons.history,
      children: [
        ListTile(
          title: const Text('First Reaction'),
          subtitle: Text(_firstReaction != null
              ? _formatDate(_firstReaction!)
              : 'Not set'),
          trailing: const Icon(Icons.history),
          onTap: () => _selectReactionDate(context, isFirst: true),
        ),
        ListTile(
          title: const Text('Last Reaction'),
          subtitle: Text(_lastReaction != null
              ? _formatDate(_lastReaction!)
              : 'Not set'),
          trailing: const Icon(Icons.access_time),
          onTap: () => _selectReactionDate(context, isFirst: false),
        ),
        if (_firstReaction != null || _lastReaction != null)
          TextButton(
            onPressed: () {
              setState(() {
                _firstReaction = null;
                _lastReaction = null;
              });
            },
            child: const Text('Clear Reaction Dates'),
          ),
      ],
    );
  }

  Widget _buildTreatmentSection() {
    return _buildModernSection(
      title: 'Treatment & Notes',
      icon: Icons.medical_services,
      children: [
        ModernTextField(
          controller: _treatmentController,
          labelText: 'Treatment',
          hintText: 'e.g., Antihistamines, EpiPen, Avoidance',
          prefixIcon: const Icon(Icons.medical_services),
          focusGradient: HealthBoxDesignSystem.allergyGradient,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        ModernTextField(
          controller: _notesController,
          labelText: 'Additional Notes',
          hintText: 'Any other relevant information',
          prefixIcon: const Icon(Icons.note),
          focusGradient: HealthBoxDesignSystem.allergyGradient,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return _buildModernSection(
      title: 'Attachments',
      icon: Icons.attach_file,
      children: [
        Text(
          'Add allergy test results, medical reports, or related documents',
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
          maxFiles: 5,
          allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
          maxFileSizeMB: 25,
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return _buildModernSection(
      title: 'Allergy Status',
      icon: Icons.toggle_on,
      children: [
        SwitchListTile(
          title: const Text('Active Allergy'),
          subtitle: const Text(
            'Uncheck if this allergy is no longer active',
          ),
          value: _isAllergyActive,
          onChanged: (value) {
            setState(() => _isAllergyActive = value);
          },
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isRecordDate}) async {
    final initialDate = isRecordDate ? _recordDate : DateTime.now();
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
        }
      });
    }
  }

  Future<void> _selectReactionDate(BuildContext context,
      {required bool isFirst}) async {
    final initialDate = isFirst
        ? (_firstReaction ?? DateTime.now())
        : (_lastReaction ?? _firstReaction ?? DateTime.now());

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        if (isFirst) {
          _firstReaction = selectedDate;
          // Ensure last reaction is not before first reaction
          if (_lastReaction != null && _lastReaction!.isBefore(selectedDate)) {
            _lastReaction = null;
          }
        } else {
          _lastReaction = selectedDate;
          // Ensure first reaction is not after last reaction
          if (_firstReaction != null && _firstReaction!.isAfter(selectedDate)) {
            _firstReaction = null;
          }
        }
      });
    }
  }

  Future<void> _saveAllergy() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one symptom'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = AllergyService();
      final selectedProfileId = widget.profileId;

      if (selectedProfileId == null) {
        throw Exception('No profile selected');
      }

      final request = CreateAllergyRequest(
        profileId: selectedProfileId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        recordDate: _recordDate,
        allergen: _allergenController.text.trim(),
        severity: _selectedSeverity,
        symptoms: _selectedSymptoms.toList(),
        treatment: _treatmentController.text.trim().isEmpty
            ? null
            : _treatmentController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isAllergyActive: _isAllergyActive,
        firstReaction: _firstReaction,
        lastReaction: _lastReaction,
      );

      await service.createAllergy(request);

      // Log success
      developer.log(
        'Allergy created successfully for profile: $selectedProfileId',
        name: 'AllergyForm',
        level: 800, // INFO level
      );

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
                  child: Text('Allergy saved successfully'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (error, stackTrace) {
      // Log detailed error to console
      developer.log(
        'Failed to save allergy',
        name: 'AllergyForm',
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
                  child: Text('Failed to save allergy. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveAllergy(),
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

  String _getSeverityDisplayName(String severity) {
    switch (severity) {
      case AllergySeverity.mild:
        return 'Mild';
      case AllergySeverity.moderate:
        return 'Moderate';
      case AllergySeverity.severe:
        return 'Severe';
      case AllergySeverity.lifeThreatening:
        return 'Life-threatening';
      default:
        return severity;
    }
  }

  String _getSeverityDescription(String severity) {
    switch (severity) {
      case AllergySeverity.mild:
        return 'Minor discomfort, manageable symptoms';
      case AllergySeverity.moderate:
        return 'Noticeable symptoms that may require treatment';
      case AllergySeverity.severe:
        return 'Significant symptoms requiring medical attention';
      case AllergySeverity.lifeThreatening:
        return 'Anaphylaxis or other life-threatening reactions';
      default:
        return '';
    }
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
    final sectionGradient = gradient ?? HealthBoxDesignSystem.allergyGradient;

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
    _allergenController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}