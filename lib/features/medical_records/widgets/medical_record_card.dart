import 'package:flutter/material.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/animations/common_transitions.dart';
import '../../../shared/theme/app_theme.dart';

class MedicalRecordCard extends StatelessWidget {
  final MedicalRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MedicalRecordCard({
    super.key,
    required this.record,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medicalTheme = _getMedicalThemeForRecordType(record.recordType);
    final themeColor = _getMedicalThemeColor(medicalTheme);

    return Hero(
      tag: 'medical_record_${record.id}',
      child: CommonTransitions.fadeSlideIn(
        child: ModernCard(
          medicalTheme: medicalTheme,
          elevation: CardElevation.low,
          enableHoverEffect: true,
          hoverElevation: CardElevation.medium,
          enablePressEffect: true,
          enableHaptics: true,
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTypeChip(theme, themeColor),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDate(record.recordDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildActionsMenu(context, themeColor),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeColor.withValues(alpha: 0.2),
                          themeColor.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getRecordTypeIcon(record.recordType),
                      size: 20,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (record.description?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            record.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(ThemeData theme, Color themeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor.withValues(alpha: 0.2),
            themeColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.2),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRecordTypeIcon(record.recordType),
            size: 14,
            color: themeColor,
          ),
          const SizedBox(width: 6),
          Text(
            record.recordType,
            style: theme.textTheme.bodySmall?.copyWith(
              color: themeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context, Color themeColor) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: themeColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.more_vert, size: 18, color: themeColor),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18, color: themeColor),
              const SizedBox(width: 12),
              const Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }


  IconData _getRecordTypeIcon(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'prescription':
        return Icons.medication;
      case 'medication':
        return Icons.medical_services;
      case 'lab report':
        return Icons.science;
      default:
        return Icons.description;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get medical theme based on record type
  MedicalCardTheme _getMedicalThemeForRecordType(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'prescription':
        return MedicalCardTheme.primary;
      case 'medication':
        return MedicalCardTheme.success;
      case 'lab report':
        return MedicalCardTheme.warning;
      case 'vaccination':
        return MedicalCardTheme.success;
      case 'allergy':
        return MedicalCardTheme.warning;
      case 'chronic condition':
        return MedicalCardTheme.error;
      default:
        return MedicalCardTheme.neutral;
    }
  }

  /// Get color for medical theme
  Color _getMedicalThemeColor(MedicalCardTheme theme) {
    switch (theme) {
      case MedicalCardTheme.primary:
        return AppTheme.primaryColorLight;
      case MedicalCardTheme.success:
        return AppTheme.successColor;
      case MedicalCardTheme.warning:
        return AppTheme.warningColor;
      case MedicalCardTheme.error:
        return AppTheme.errorColor;
      case MedicalCardTheme.neutral:
        return AppTheme.neutralColorLight;
    }
  }
}
