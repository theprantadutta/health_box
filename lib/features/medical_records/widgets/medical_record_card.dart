import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';
import '../../../shared/animations/common_transitions.dart';
import '../../../shared/widgets/modern_card.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final medicalTheme = _getMedicalThemeForRecordType(record.recordType);
    final themeColor = _getMedicalThemeColor(medicalTheme, context);

    return Hero(
      tag: 'medical_record_${record.id}',
      child: CommonTransitions.fadeSlideIn(
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.15),
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row with Type Badge and Actions
                    Row(
                      children: [
                        _buildTypeChip(theme, themeColor, isDark),
                        const Spacer(),
                        _buildDateChip(theme, isDark),
                        const SizedBox(width: 12),
                        _buildActionsMenu(context, theme, isDark),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Content Row with Icon and Text
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIconContainer(themeColor, isDark),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildContentSection(theme, isDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(ThemeData theme, Color themeColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRecordTypeIcon(record.recordType),
            size: 16,
            color: themeColor,
          ),
          const SizedBox(width: 8),
          Text(
            _getDisplayName(record.recordType),
            style: theme.textTheme.labelMedium?.copyWith(
              color: themeColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _formatDate(record.recordDate),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildIconContainer(Color themeColor, bool isDark) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        _getRecordTypeIcon(record.recordType),
        size: 24,
        color: themeColor,
      ),
    );
  }

  Widget _buildContentSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          record.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (record.description?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(
            record.description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildActionsMenu(BuildContext context, ThemeData theme, bool isDark) {
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.more_vert,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      color: theme.colorScheme.surface,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Edit',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 12),
              Text(
                'Delete',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
      case 'lab_report':
      case 'lab report':
        return Icons.science;
      case 'vaccination':
        return Icons.vaccines;
      case 'allergy':
        return Icons.warning;
      case 'chronic_condition':
        return Icons.health_and_safety;
      default:
        return Icons.description;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getDisplayName(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'prescription':
        return 'Prescription';
      case 'medication':
        return 'Medication';
      case 'lab_report':
        return 'Lab Report';
      case 'vaccination':
        return 'Vaccination';
      case 'allergy':
        return 'Allergy';
      case 'chronic_condition':
        return 'Chronic Condition';
      default:
        return recordType.split('_').map((word) => 
          word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
        ).join(' ');
    }
  }

  /// Get medical theme based on record type
  MedicalCardTheme _getMedicalThemeForRecordType(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'prescription':
        return MedicalCardTheme.primary;
      case 'medication':
        return MedicalCardTheme.success;
      case 'lab_report':
      case 'lab report':
        return MedicalCardTheme.warning;
      case 'vaccination':
        return MedicalCardTheme.success;
      case 'allergy':
        return MedicalCardTheme.warning;
      case 'chronic_condition':
      case 'chronic condition':
        return MedicalCardTheme.error;
      default:
        return MedicalCardTheme.neutral;
    }
  }

  /// Get color for medical theme with better contrast
  Color _getMedicalThemeColor(MedicalCardTheme theme, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (theme) {
      case MedicalCardTheme.primary:
        return colorScheme.primary;
      case MedicalCardTheme.info:
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
      case MedicalCardTheme.secondary:
        return colorScheme.secondary;
      case MedicalCardTheme.success:
        return isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
      case MedicalCardTheme.warning:
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
      case MedicalCardTheme.error:
        return isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
      case MedicalCardTheme.neutral:
        return isDark ? colorScheme.onSurfaceVariant : colorScheme.outline;
      case MedicalCardTheme.tertiary:
        return colorScheme.tertiary;
    }
  }
}
