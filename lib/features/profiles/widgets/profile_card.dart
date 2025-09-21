import 'package:flutter/material.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/theme/design_system.dart';

class ProfileCard extends StatelessWidget {
  final FamilyMemberProfile profile;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ProfileCard({
    super.key,
    required this.profile,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final age = _calculateAge(profile.dateOfBirth);
    final initials = _getInitials();
    final genderColor = _getGenderColor(isDark);

    return Hero(
      tag: 'profile_${profile.id}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.1),
            width: isSelected ? 2 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.15)
                  : (isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.08)),
              offset: const Offset(0, 1),
              blurRadius: isSelected ? 8 : 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Compact Avatar
                  _buildCompactAvatar(theme, initials, genderColor),
                  const SizedBox(width: 12),

                  // Main Info Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          '${profile.firstName} ${profile.lastName}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),

                        // Age and Gender Row
                        Row(
                          children: [
                            Text(
                              '$age years',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              profile.gender,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // Optional Info Tags
                        if (_hasImportantInfo()) ...[
                          const SizedBox(height: 6),
                          _buildInfoTags(theme, isDark),
                        ],
                      ],
                    ),
                  ),

                  // Right Side - Status and Actions
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Selection/Status Indicator
                      if (isSelected)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        )
                      else if (_hasStatusIndicators())
                        _buildStatusDot(theme, isDark),

                      const SizedBox(height: 8),

                      // Actions
                      if (showActions) _buildCompactActionMenu(theme, isDark),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactAvatar(ThemeData theme, String initials, Color genderColor) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            genderColor,
            genderColor.withValues(alpha: 0.85),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }


  String _getInitials() {
    final first = profile.firstName.isNotEmpty ? profile.firstName[0] : '';
    final last = profile.lastName.isNotEmpty ? profile.lastName[0] : '';
    return '$first$last'.toUpperCase();
  }


  Color _getGenderColor(bool isDark) {
    switch (profile.gender.toLowerCase()) {
      case 'male':
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
      case 'female':
        return isDark ? const Color(0xFFF472B6) : const Color(0xFFEC4899);
      default:
        return isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    }
  }

  Widget _buildInfoTags(ThemeData theme, bool isDark) {
    final tags = <Widget>[];

    if (profile.bloodType != null) {
      tags.add(_buildCompactTag(
        theme,
        profile.bloodType!,
        HealthBoxDesignSystem.errorColor,
        isDark,
      ));
    }

    if (profile.height != null && profile.weight != null) {
      tags.add(_buildCompactTag(
        theme,
        '${profile.height}cm • ${profile.weight}kg',
        HealthBoxDesignSystem.accentCyan,
        isDark,
      ));
    } else if (profile.height != null) {
      tags.add(_buildCompactTag(
        theme,
        '${profile.height}cm',
        HealthBoxDesignSystem.accentCyan,
        isDark,
      ));
    } else if (profile.weight != null) {
      tags.add(_buildCompactTag(
        theme,
        '${profile.weight}kg',
        HealthBoxDesignSystem.accentCyan,
        isDark,
      ));
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags,
    );
  }

  Widget _buildCompactTag(ThemeData theme, String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildStatusDot(ThemeData theme, bool isDark) {
    Color dotColor = HealthBoxDesignSystem.successColor;

    if (profile.emergencyContact?.isNotEmpty == true) {
      dotColor = HealthBoxDesignSystem.errorColor;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildCompactActionMenu(ThemeData theme, bool isDark) {
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.more_vert,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                size: 18,
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
                size: 18,
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

  bool _hasImportantInfo() {
    return profile.bloodType != null ||
           profile.height != null ||
           profile.weight != null;
  }

  bool _hasStatusIndicators() {
    return profile.emergencyContact?.isNotEmpty == true ||
           profile.insuranceInfo?.isNotEmpty == true;
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
}
