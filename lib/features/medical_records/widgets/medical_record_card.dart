import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../../shared/animations/common_transitions.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/providers/profile_providers.dart';

class MedicalRecordCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final recordGradient = _getRecordTypeGradient(record.recordType);
    final profileAsync = ref.watch(profileByIdProvider(record.profileId));

    return Hero(
      tag: 'medical_record_${record.id}',
      child: CommonTransitions.fadeSlideIn(
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: recordGradient.colors.first.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: recordGradient.colors.first.withValues(alpha: 0.15),
                offset: const Offset(0, 8),
                blurRadius: 24,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.08),
                offset: const Offset(0, 4),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              23,
            ), // Slightly smaller to fit inside border
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(23),
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Gradient Header Strip
                    _buildGradientHeader(theme, recordGradient, isDark),

                    // Card Content
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Icon Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildIconContainer(recordGradient, isDark),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            record.title,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                  height: 1.2,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        _buildStatusBadge(theme, isDark),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    _buildTypeChip(
                                      theme,
                                      recordGradient,
                                      isDark,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              _buildActionsMenu(context, theme, isDark),
                            ],
                          ),

                          // Profile Info
                          const SizedBox(height: 10),
                          profileAsync.when(
                            data: (profile) => profile != null
                                ? _buildProfileChip(theme, profile, isDark)
                                : const SizedBox.shrink(),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),

                          // Description
                          if (record.description?.isNotEmpty == true) ...[
                            const SizedBox(height: 8),
                            Text(
                              record.description!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          // Metadata Row
                          const SizedBox(height: 10),
                          _buildMetadataRow(theme, isDark),
                        ],
                      ),
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

  Widget _buildGradientHeader(
    ThemeData theme,
    LinearGradient gradient,
    bool isDark,
  ) {
    return Container(height: 6, decoration: BoxDecoration(gradient: gradient));
  }

  Widget _buildStatusBadge(ThemeData theme, bool isDark) {
    if (!record.isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          'Inactive',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTypeChip(ThemeData theme, LinearGradient gradient, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradient.colors.first.withValues(alpha: 0.15),
            gradient.colors.last.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gradient.colors.first.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRecordTypeIcon(record.recordType),
            size: 14,
            color: gradient.colors.first,
          ),
          const SizedBox(width: 6),
          Text(
            _getDisplayName(record.recordType),
            style: theme.textTheme.labelSmall?.copyWith(
              color: gradient.colors.first,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(ThemeData theme, bool isDark) {
    return Row(
      children: [
        // Record Date
        Expanded(
          child: _buildMetadataItem(
            theme,
            isDark,
            icon: Icons.calendar_today,
            label: 'Record Date',
            value: _formatDate(record.recordDate),
          ),
        ),
        Container(
          width: 1,
          height: 32,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          margin: const EdgeInsets.symmetric(horizontal: 12),
        ),
        // Created Date
        Expanded(
          child: _buildMetadataItem(
            theme,
            isDark,
            icon: Icons.access_time,
            label: 'Created',
            value: _formatRelativeDate(record.createdAt),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataItem(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconContainer(LinearGradient gradient, bool isDark) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.35),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        _getRecordTypeIcon(record.recordType),
        size: 22,
        color: Colors.white,
      ),
    );
  }

  Widget _buildProfileChip(ThemeData theme, FamilyMemberProfile profile, bool isDark) {
    final age = _calculateAge(profile.dateOfBirth);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
            : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_rounded,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${profile.firstName} ${profile.lastName} • $age yrs',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  Widget _buildActionsMenu(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
            : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
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
        padding: EdgeInsets.zero,
        icon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        color: theme.colorScheme.surface,
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Edit',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Delete',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRecordTypeIcon(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'prescription':
        return Icons.medication_rounded;
      case 'medication':
        return Icons.medical_services_rounded;
      case 'lab_report':
      case 'lab report':
        return Icons.science_rounded;
      case 'vaccination':
        return Icons.vaccines_rounded;
      case 'allergy':
        return Icons.warning_rounded;
      case 'chronic_condition':
      case 'chronic condition':
        return Icons.health_and_safety_rounded;
      case 'surgical_record':
      case 'surgical record':
        return Icons.medical_services_outlined;
      case 'radiology_record':
      case 'radiology record':
        return Icons.medical_information_rounded;
      case 'pathology_record':
      case 'pathology record':
        return Icons.biotech_rounded;
      case 'discharge_summary':
      case 'discharge summary':
        return Icons.exit_to_app_rounded;
      case 'hospital_admission':
      case 'hospital admission':
        return Icons.local_hospital_rounded;
      case 'dental_record':
      case 'dental record':
        return Icons.healing_rounded;
      case 'mental_health_record':
      case 'mental health record':
        return Icons.psychology_rounded;
      case 'general_record':
      case 'general record':
        return Icons.description_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  String _getDisplayName(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'prescription':
        return 'PRESCRIPTION';
      case 'medication':
        return 'MEDICATION';
      case 'lab_report':
        return 'LAB REPORT';
      case 'vaccination':
        return 'VACCINATION';
      case 'allergy':
        return 'ALLERGY';
      case 'chronic_condition':
        return 'CHRONIC CONDITION';
      case 'surgical_record':
        return 'SURGICAL';
      case 'radiology_record':
        return 'RADIOLOGY';
      case 'pathology_record':
        return 'PATHOLOGY';
      case 'discharge_summary':
        return 'DISCHARGE';
      case 'hospital_admission':
        return 'ADMISSION';
      case 'dental_record':
        return 'DENTAL';
      case 'mental_health_record':
        return 'MENTAL HEALTH';
      case 'general_record':
        return 'GENERAL';
      default:
        return recordType.toUpperCase().replaceAll('_', ' ');
    }
  }

  LinearGradient _getRecordTypeGradient(String recordType) {
    return HealthBoxDesignSystem.getRecordTypeGradient(recordType);
  }
}
