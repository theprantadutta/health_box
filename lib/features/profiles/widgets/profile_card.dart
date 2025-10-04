import 'package:flutter/material.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/animations/common_transitions.dart';

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
    final genderGradient = _getGenderGradient();

    return Hero(
      tag: 'profile_${profile.id}',
      child: CommonTransitions.fadeSlideIn(
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? genderGradient.colors.first.withValues(alpha: 0.3)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? genderGradient.colors.first.withValues(alpha: 0.15)
                    : theme.colorScheme.shadow.withValues(alpha: 0.05),
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
            borderRadius: BorderRadius.circular(23),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(23),
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Gradient Header Strip
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: genderGradient,
                      ),
                    ),

                    // Card Content
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar with gradient
                              _buildModernAvatar(theme, initials, genderGradient, isDark),
                              const SizedBox(width: 12),

                              // Main Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${profile.firstName} ${profile.lastName}',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: theme.colorScheme.onSurface,
                                              height: 1.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isSelected)
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              gradient: HealthBoxDesignSystem.successGradient,
                                              shape: BoxShape.circle,
                                              boxShadow: HealthBoxDesignSystem.coloredShadow(
                                                HealthBoxDesignSystem.successColor,
                                                opacity: 0.3,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    // Age and Gender Row
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        _buildInfoBadge(
                                          theme,
                                          Icons.cake_rounded,
                                          '$age yrs',
                                          genderGradient.colors.first,
                                        ),
                                        _buildInfoBadge(
                                          theme,
                                          Icons.person_rounded,
                                          profile.gender,
                                          theme.colorScheme.secondary,
                                        ),
                                        if (profile.bloodType != null)
                                          _buildInfoBadge(
                                            theme,
                                            Icons.bloodtype_rounded,
                                            profile.bloodType!,
                                            HealthBoxDesignSystem.errorColor,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Action Menu
                              if (showActions) _buildModernActionMenu(theme, isDark),
                            ],
                          ),

                          // Additional Info Tags
                          if (_hasAdditionalInfo()) ...[
                            const SizedBox(height: 10),
                            _buildAdditionalInfoRow(theme, isDark),
                          ],
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

  Widget _buildModernAvatar(
    ThemeData theme,
    String initials,
    LinearGradient gradient,
    bool isDark,
  ) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: HealthBoxDesignSystem.coloredShadow(
          gradient.colors.first,
          opacity: 0.35,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge(ThemeData theme, IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoRow(ThemeData theme, bool isDark) {
    final items = <Widget>[];

    if (profile.height != null || profile.weight != null) {
      items.add(
        Row(
          children: [
            Icon(
              Icons.straighten_rounded,
              size: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              profile.height != null && profile.weight != null
                  ? '${profile.height}cm • ${profile.weight}kg'
                  : profile.height != null
                      ? '${profile.height}cm'
                      : '${profile.weight}kg',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    if (profile.emergencyContact?.isNotEmpty == true) {
      if (items.isNotEmpty) {
        items.add(
          Container(
            width: 3,
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        );
      }
      items.add(
        Row(
          children: [
            Icon(
              Icons.phone_rounded,
              size: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                profile.emergencyContact!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
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

    return Row(
      children: items,
    );
  }


  Widget _buildModernActionMenu(ThemeData theme, bool isDark) {
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
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
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
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
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

  String _getInitials() {
    final first = profile.firstName.isNotEmpty ? profile.firstName[0] : '';
    final last = profile.lastName.isNotEmpty ? profile.lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  LinearGradient _getGenderGradient() {
    switch (profile.gender.toLowerCase()) {
      case 'male':
        return const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        );
      case 'female':
        return const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
    }
  }

  bool _hasAdditionalInfo() {
    return profile.height != null ||
           profile.weight != null ||
           profile.emergencyContact?.isNotEmpty == true;
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
