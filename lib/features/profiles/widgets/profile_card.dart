import 'package:flutter/material.dart';
import '../../../data/database/app_database.dart';

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
    final age = _calculateAge(profile.dateOfBirth);
    final ageCategory = _getAgeCategory(age);

    return Hero(
      tag: 'profile_${profile.id}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: isSelected ? 4 : 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  )
                : BorderSide.none,
          ),
          child: Semantics(
            label: 'Profile for ${profile.firstName} ${profile.lastName}, age $age',
            hint: 'Tap to view or edit profile details',
            button: true,
            child: InkWell(
              onTap: onTap,
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
                          '${profile.firstName} ${profile.lastName}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        
                        // Age and Gender
                        Text(
                          '$age years old • ${profile.gender}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        
                        if (profile.bloodType != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Blood Type: ${profile.bloodType}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Actions Menu
                  if (showActions) _buildActionsMenu(context),
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
                  if (profile.emergencyContact?.isNotEmpty == true)
                    Icon(
                      Icons.emergency,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  
                  if (profile.insuranceInfo?.isNotEmpty == true) ...[
                    if (profile.emergencyContact?.isNotEmpty == true)
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
              if (profile.height != null || profile.weight != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (profile.height != null) ...[
                      Icon(
                        Icons.height,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${profile.height}cm',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    
                    if (profile.height != null && profile.weight != null)
                      const SizedBox(width: 16),
                    
                    if (profile.weight != null) ...[
                      Icon(
                        Icons.monitor_weight,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${profile.weight}kg',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              
              // Selection Indicator
              if (isSelected) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
    );
  }

  Widget _buildProfileAvatar(ThemeData theme) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: _getGenderColor(profile.gender, theme),
      child: Text(
        '${profile.firstName.isNotEmpty ? profile.firstName[0] : ''}${profile.lastName.isNotEmpty ? profile.lastName[0] : ''}',
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
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 12),
              Text('Edit'),
            ],
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