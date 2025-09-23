import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../services/allergy_service.dart';
import '../../../data/models/allergy.dart';
import 'package:flutter/foundation.dart';

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
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveAllergy,
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
            _buildAllergenDetailsSection(),
            const SizedBox(height: 24),
            _buildSeveritySection(),
            const SizedBox(height: 24),
            _buildSymptomsSection(),
            const SizedBox(height: 24),
            _buildReactionDatesSection(),
            const SizedBox(height: 24),
            _buildTreatmentSection(),
            const SizedBox(height: 24),
            _buildStatusSection(),
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
                hintText: 'e.g., Peanut Allergy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warning),
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
                hintText: 'Additional details about this allergy',
                border: OutlineInputBorder(),
              ),
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
        ),
      ),
    );
  }

  Widget _buildAllergenDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Allergen Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _allergenController,
              decoration: const InputDecoration(
                labelText: 'Allergen *',
                hintText: 'e.g., Peanuts, Shellfish, Penicillin',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.eco),
              ),
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
        ),
      ),
    );
  }

  Widget _buildSeveritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Severity Level',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            for (final severity in AllergySeverity.allSeverities)
              RadioListTile<String>(
                title: Text(_getSeverityDisplayName(severity)),
                subtitle: Text(_getSeverityDescription(severity)),
                value: severity,
                groupValue: _selectedSeverity,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSeverity = value);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Symptoms',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
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
        ),
      ),
    );
  }

  Widget _buildReactionDatesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reaction History',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
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
        ),
      ),
    );
  }

  Widget _buildTreatmentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Treatment & Notes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _treatmentController,
              decoration: const InputDecoration(
                labelText: 'Treatment',
                hintText: 'e.g., Antihistamines, EpiPen, Avoidance',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                hintText: 'Any other relevant information',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Allergy Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
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
        ),
      ),
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

      // Refresh medical records providers
      ref.invalidate(allMedicalRecordsProvider);
      ref.invalidate(recordsByProfileIdProvider(selectedProfileId));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Allergy saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save allergy: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save allergy: $e'),
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