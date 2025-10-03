import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../data/models/medication_batch.dart';
import '../services/medication_batch_service.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/modern_card.dart';

class BatchCardWidget extends StatefulWidget {
  final MedicationBatche batch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BatchCardWidget({
    super.key,
    required this.batch,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<BatchCardWidget> createState() => _BatchCardWidgetState();
}

class _BatchCardWidgetState extends State<BatchCardWidget> {
  final MedicationBatchService _batchService = MedicationBatchService();
  List<Medication> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      final medications = await _batchService.getMedicationsInBatch(widget.batch.id);
      if (mounted) {
        setState(() {
          _medications = medications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getTimingDescription() {
    final timingDetails = _batchService.parseTimingDetails(
      widget.batch.timingType,
      widget.batch.timingDetails,
    );

    switch (widget.batch.timingType) {
      case MedicationBatchTimingType.afterMeal:
        if (timingDetails != null) {
          final mealTiming = MealTimingDetails.fromJson(timingDetails);
          return '${mealTiming.minutesAfterBefore} min after ${MealType.getDisplayName(mealTiming.mealType)}';
        }
        return 'After meal';

      case MedicationBatchTimingType.beforeMeal:
        if (timingDetails != null) {
          final mealTiming = MealTimingDetails.fromJson(timingDetails);
          return '${mealTiming.minutesAfterBefore} min before ${MealType.getDisplayName(mealTiming.mealType)}';
        }
        return 'Before meal';

      case MedicationBatchTimingType.fixedTime:
        if (timingDetails != null) {
          final fixedTiming = FixedTimeDetails.fromJson(timingDetails);
          return 'At ${fixedTiming.times.join(', ')}';
        }
        return 'Fixed time';

      case MedicationBatchTimingType.interval:
        if (timingDetails != null) {
          final intervalTiming = IntervalTimingDetails.fromJson(timingDetails);
          return 'Every ${intervalTiming.intervalHours} hours';
        }
        return 'Interval';

      case MedicationBatchTimingType.asNeeded:
        return 'As needed';

      default:
        return MedicationBatchTimingType.getDisplayName(widget.batch.timingType);
    }
  }

  Color _getTimingColor() {
    switch (widget.batch.timingType) {
      case MedicationBatchTimingType.afterMeal:
      case MedicationBatchTimingType.beforeMeal:
        return Colors.orange;
      case MedicationBatchTimingType.fixedTime:
        return Colors.blue;
      case MedicationBatchTimingType.interval:
        return Colors.green;
      case MedicationBatchTimingType.asNeeded:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getTimingIcon() {
    switch (widget.batch.timingType) {
      case MedicationBatchTimingType.afterMeal:
      case MedicationBatchTimingType.beforeMeal:
        return Icons.restaurant;
      case MedicationBatchTimingType.fixedTime:
        return Icons.schedule;
      case MedicationBatchTimingType.interval:
        return Icons.repeat;
      case MedicationBatchTimingType.asNeeded:
        return Icons.healing;
      default:
        return Icons.medication;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timingColor = _getTimingColor();

    // Create gradient from timing color
    final timingGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [timingColor, timingColor.withValues(alpha: 0.7)],
    );

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: CardElevation.low,
      onTap: widget.onEdit,
      enableHoverEffect: true,
      hoverElevation: CardElevation.medium,
      enablePressEffect: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: timingGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: HealthBoxDesignSystem.coloredShadow(timingColor, opacity: 0.3),
                ),
                child: Icon(
                  _getTimingIcon(),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.batch.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getTimingDescription(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: timingColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          widget.onEdit();
                          break;
                        case 'delete':
                          widget.onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
            ],
          ),
          // Description
          if (widget.batch.description != null && widget.batch.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.batch.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
          // Medications
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.medication,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                _isLoading
                    ? 'Loading medications...'
                    : _medications.isEmpty
                        ? 'No medications assigned'
                        : '${_medications.length} medication${_medications.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          // Medication list (if any)
          if (!_isLoading && _medications.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _medications.take(3).map((med) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: timingGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    med.medicationName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList()
                ..addAll(_medications.length > 3
                    ? [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outline.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${_medications.length - 3} more',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ]
                    : []),
            ),
          ],
        ],
      ),
    );
  }
}