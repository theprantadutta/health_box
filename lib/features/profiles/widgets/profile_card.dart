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
    final genderIcon = _getGenderIcon();
    final genderColor = _getGenderColor(isDark);

    return Hero(
      tag: 'profile_${profile.id}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : (isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.15)),
              offset: const Offset(0, 2),
              blurRadius: isSelected ? 12 : 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header Row: Avatar, Name, Age, Actions
                  Row(
                    children: [
                      // Enhanced Avatar
                      _buildAvatar(theme, initials, genderColor, isDark),
                      const SizedBox(width: 16),

                      // Name and Age
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${profile.firstName} ${profile.lastName}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            _buildAgeChip(theme, age, isDark),
                          ],
                        ),
                      ),

                      // Action Menu
                      if (showActions) _buildActionMenu(theme, isDark),

                      // Selection Indicator
                      if (isSelected) ...[
                        const SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Info Section
                  _buildInfoSection(theme, genderIcon, genderColor, isDark),

                  // Status Indicators
                  if (_hasStatusIndicators()) ...[
                    const SizedBox(height: 16),
                    _buildStatusIndicators(theme, isDark),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, String initials, Color genderColor, bool isDark) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            genderColor,
            genderColor.withValues(alpha: 0.8),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: genderColor.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildAgeChip(ThemeData theme, int age, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
            : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cake_outlined,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            '$age years old',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(ThemeData theme, bool isDark) {
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

  Widget _buildInfoSection(ThemeData theme, IconData genderIcon, Color genderColor, bool isDark) {
    return Row(
      children: [
        // Gender Info
        Expanded(
          child: _buildInfoChip(
            theme,
            genderIcon,
            profile.gender,
            genderColor,
            isDark,
          ),
        ),

        if (profile.bloodType != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoChip(
              theme,
              Icons.bloodtype,
              profile.bloodType!,
              HealthBoxDesignSystem.errorColor,
              isDark,
            ),
          ),
        ],

        // Physical Info
        if (profile.height != null || profile.weight != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _buildInfoChip(
              theme,
              Icons.straighten,
              [
                if (profile.height != null) '${profile.height}cm',
                if (profile.weight != null) '${profile.weight}kg',
              ].join(' / '),
              HealthBoxDesignSystem.accentCyan,
              isDark,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip(ThemeData theme, IconData icon, String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicators(ThemeData theme, bool isDark) {
    return Row(
      children: [
        if (profile.emergencyContact?.isNotEmpty == true)
          _buildStatusIndicator(
            theme,
            Icons.emergency,
            'Emergency Contact',
            HealthBoxDesignSystem.errorColor,
            isDark,
          ),
        if (profile.emergencyContact?.isNotEmpty == true && profile.insuranceInfo?.isNotEmpty == true)
          const SizedBox(width: 12),
        if (profile.insuranceInfo?.isNotEmpty == true)
          _buildStatusIndicator(
            theme,
            Icons.medical_services,
            'Insurance Info',
            HealthBoxDesignSystem.successColor,
            isDark,
          ),
      ],
    );
  }

  Widget _buildStatusIndicator(ThemeData theme, IconData icon, String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials() {
    final first = profile.firstName.isNotEmpty ? profile.firstName[0] : '';
    final last = profile.lastName.isNotEmpty ? profile.lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  IconData _getGenderIcon() {
    switch (profile.gender.toLowerCase()) {
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      default:
        return Icons.person;
    }
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
