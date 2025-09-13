import 'package:flutter/material.dart';
import '../../../data/database/app_database.dart';

class ProfileCard extends StatefulWidget {
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
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isSelected) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final age = _calculateAge(widget.profile.dateOfBirth);
    final ageCategory = _getAgeCategory(age);

    return Hero(
      tag: 'profile_${widget.profile.id}',
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) => Transform.scale(
          scale: _pulseAnimation.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: widget.isSelected ? 4 : 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: widget.isSelected
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: Semantics(
            label:
                'Profile for ${widget.profile.firstName} ${widget.profile.lastName}, age $age',
            hint: 'Tap to view or edit profile details',
            button: true,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row - Avatar, Name, and Actions
                    Row(
                      children: [
                        // Profile Avatar
                        _buildProfileAvatar(theme),
                        const SizedBox(width: 16),

                        // Name and Basic Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Full Name
                              Text(
                                '${widget.profile.firstName} ${widget.profile.lastName}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),

                              // Age and Gender
                              Text(
                                '$age years old • ${widget.profile.gender}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),

                              if (widget.profile.bloodType != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Blood Type: ${widget.profile.bloodType}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Actions Menu
                        if (widget.showActions) _buildActionsMenu(context),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Age Category Badge and Quick Info
                    Row(
                      children: [
                        // Age Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getAgeCategoryColor(ageCategory, theme),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            ageCategory,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Quick Info Icons
                        if (widget.profile.emergencyContact?.isNotEmpty == true)
                          Icon(
                            Icons.emergency,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),

                        if (widget.profile.insuranceInfo?.isNotEmpty ==
                            true) ...[
                          if (widget.profile.emergencyContact?.isNotEmpty ==
                              true)
                            const SizedBox(width: 8),
                          Icon(
                            Icons.medical_services,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),

                    // Physical Information (Height & Weight)
                    if (widget.profile.height != null ||
                        widget.profile.weight != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (widget.profile.height != null) ...[
                            Icon(
                              Icons.height,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.profile.height}cm',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],

                          if (widget.profile.height != null &&
                              widget.profile.weight != null)
                            const SizedBox(width: 16),

                          if (widget.profile.weight != null) ...[
                            Icon(
                              Icons.monitor_weight,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.profile.weight}kg',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],

                    // Selection Indicator
                    if (widget.isSelected) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Selected',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: _getGenderColor(widget.profile.gender, theme),
      child: Text(
        '${widget.profile.firstName.isNotEmpty ? widget.profile.firstName[0] : ''}${widget.profile.lastName.isNotEmpty ? widget.profile.lastName[0] : ''}',
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            widget.onEdit?.call();
            break;
          case 'delete':
            widget.onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [Icon(Icons.edit), SizedBox(width: 12), Text('Edit')],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
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

  String _getAgeCategory(int age) {
    if (age < 13) return 'Child';
    if (age < 20) return 'Teenager';
    if (age < 65) return 'Adult';
    return 'Senior';
  }

  Color _getGenderColor(String gender, ThemeData theme) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Colors.blue.shade600;
      case 'female':
        return Colors.pink.shade400;
      case 'other':
        return Colors.purple.shade400;
      default:
        return theme.colorScheme.primary;
    }
  }

  Color _getAgeCategoryColor(String category, ThemeData theme) {
    switch (category.toLowerCase()) {
      case 'child':
        return Colors.green.shade500;
      case 'teenager':
        return Colors.orange.shade500;
      case 'adult':
        return Colors.blue.shade600;
      case 'senior':
        return Colors.purple.shade500;
      default:
        return theme.colorScheme.primary;
    }
  }
}
