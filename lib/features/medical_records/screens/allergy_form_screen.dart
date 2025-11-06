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
import '../../../shared/widgets/hb_app_bar.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/widgets/hb_chip.dart';
import '../../../shared/widgets/hb_list_tile.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HBAppBar.gradient(
        title: _isEditing ? 'Edit Allergy' : 'New Allergy',
        gradient: RecordTypeUtils.getGradient('allergy'),
        actions: [
          HBButton.text(
            onPressed: _isLoading ? null : _saveAllergy,
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
            _buildAllergenDetailsSection(),
            SizedBox(height: AppSpacing.base),
            _buildSeveritySection(),
            SizedBox(height: AppSpacing.base),
            _buildSymptomsSection(),
            SizedBox(height: AppSpacing.base),
            _buildReactionDatesSection(),
            SizedBox(height: AppSpacing.base),
            _buildTreatmentSection(),
            SizedBox(height: AppSpacing.base),
            _buildAttachmentsSection(),
            SizedBox(height: AppSpacing.base),
            _buildStatusSection(),
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
          _buildSectionHeader(
            'Basic Information',
            Icons.info_outline,
            RecordTypeUtils.getGradient('allergy'),
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _titleController,
            label: 'Title',
            hint: 'e.g., Peanut Allergy',
            prefixIcon: Icons.warning,
            validator: HBValidators.required,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Additional details about this allergy',
            minLines: 3,
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile('Record Date', _recordDate, () => _selectDate(context, isRecordDate: true)),
        ],
      ),
    );
  }

  Widget _buildAllergenDetailsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Allergen Details',
            Icons.eco,
            AppColors.warningGradient,
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.filled(
            controller: _allergenController,
            label: 'Allergen',
            hint: 'e.g., Peanuts, Shellfish, Penicillin',
            prefixIcon: Icons.eco,
            validator: HBValidators.required,
          ),
          SizedBox(height: AppSpacing.base),
          Text(
            'Common Allergen Types',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: AppTypography.fontWeightMedium,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: AllergenTypes.allTypes.map((type) {
              return HBChip.filter(
                label: type,
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
      ),
    );
  }

  Widget _buildSeveritySection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Severity Level',
            Icons.emergency,
            AppColors.errorGradient,
          ),
          SizedBox(height: AppSpacing.base),
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
                            style: context.textTheme.bodySmall,
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
      ),
    );
  }

  Widget _buildSymptomsSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Symptoms',
            Icons.health_and_safety,
            AppColors.secondaryGradient,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Select all symptoms you experience:',
            style: context.textTheme.bodyMedium,
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: AllergySymptoms.allSymptoms.map((symptom) {
              return HBChip.filter(
                label: symptom,
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
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Please select at least one symptom',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReactionDatesSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Reaction History',
            Icons.history,
            AppColors.primaryGradient,
          ),
          SizedBox(height: AppSpacing.lg),
          _buildDateTile(
            'First Reaction',
            _firstReaction,
            () => _selectReactionDate(context, isFirst: true),
            optional: true,
          ),
          SizedBox(height: AppSpacing.base),
          _buildDateTile(
            'Last Reaction',
            _lastReaction,
            () => _selectReactionDate(context, isFirst: false),
            optional: true,
          ),
          if (_firstReaction != null || _lastReaction != null) ...[
            SizedBox(height: AppSpacing.sm),
            HBButton.text(
              onPressed: () {
                setState(() {
                  _firstReaction = null;
                  _lastReaction = null;
                });
              },
              child: const Text('Clear Reaction Dates'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTreatmentSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Treatment & Notes',
            Icons.medical_services,
            AppColors.successGradient,
          ),
          SizedBox(height: AppSpacing.lg),
          HBTextField.multiline(
            controller: _treatmentController,
            label: 'Treatment',
            hint: 'e.g., Antihistamines, EpiPen, Avoidance',
            minLines: 2,
            maxLines: 3,
          ),
          SizedBox(height: AppSpacing.base),
          HBTextField.multiline(
            controller: _notesController,
            label: 'Additional Notes',
            hint: 'Any other relevant information',
            minLines: 3,
            maxLines: 5,
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
            AppColors.secondaryGradient,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Add allergy test results, medical reports, or related documents',
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
            maxFiles: 5,
            allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
            maxFileSizeMB: 25,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Allergy Status',
            Icons.toggle_on,
            AppColors.primaryGradient,
          ),
          SizedBox(height: AppSpacing.base),
          HBListTile.switchTile(
            title: 'Active Allergy',
            subtitle: 'Uncheck if this allergy is no longer active',
            icon: Icons.warning,
            value: _isAllergyActive,
            onChanged: (value) {
              setState(() => _isAllergyActive = value);
            },
            iconColor: AppColors.warning,
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
            Icon(
              Icons.calendar_today,
              color: context.colorScheme.onSurfaceVariant,
              size: AppSizes.iconMd,
            ),
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
                    date != null ? _formatDate(date) : (optional ? 'Not set' : 'Select date'),
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: date != null ? context.colorScheme.onSurface : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isRecordDate}) async {
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

  Future<void> _selectReactionDate(BuildContext context, {required bool isFirst}) async {
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
          if (_lastReaction != null && _lastReaction!.isBefore(selectedDate)) {
            _lastReaction = null;
          }
        } else {
          _lastReaction = selectedDate;
          if (_firstReaction != null && _firstReaction!.isAfter(selectedDate)) {
            _firstReaction = null;
          }
        }
      });
    }
  }

  Future<void> _saveAllergy() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.white, size: 20),
              SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text('Please fill in all required fields'),
              ),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
        ),
      );
      return;
    }

    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.white, size: 20),
              SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text('Please select at least one symptom'),
              ),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
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

      developer.log(
        'Allergy created successfully for profile: $selectedProfileId',
        name: 'AllergyForm',
        level: 800,
      );

      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(selectedProfileId));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text('Allergy saved successfully'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
          ),
        );
      }
    } catch (error, stackTrace) {
      developer.log(
        'Failed to save allergy',
        name: 'AllergyForm',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text('Failed to save allergy. Please try again.'),
                ),
              ],
            ),
            backgroundColor: context.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.radiusMd),
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
        return 'Minor discomfort';
      case AllergySeverity.moderate:
        return 'Requires treatment';
      case AllergySeverity.severe:
        return 'Medical attention';
      case AllergySeverity.lifeThreatening:
        return 'Anaphylaxis risk';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
