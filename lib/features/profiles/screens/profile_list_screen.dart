import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/simple_profile_providers.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/animations/common_transitions.dart';
import '../../../shared/animations/stagger_animations.dart';
import '../../../shared/animations/micro_interactions.dart';
import '../../../shared/navigation/app_router.dart';
import '../widgets/profile_card.dart';

class ProfileListScreen extends ConsumerStatefulWidget {
  const ProfileListScreen({super.key});

  @override
  ConsumerState<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends ConsumerState<ProfileListScreen> {
  String _searchQuery = '';
  String _selectedGenderFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(simpleProfilesProvider);
    final selectedProfileAsync = ref.watch(simpleSelectedProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Family Profiles',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_rounded,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            onPressed: () => _navigateToAddProfile(context),
            tooltip: 'Add New Profile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(simpleProfilesProvider);
          ref.invalidate(simpleSelectedProfileProvider);
        },
        child: Column(
          children: [
            // Search and Filter Section with premium design
            CommonTransitions.fadeSlideIn(
              child: ModernCard(
                elevation: CardElevation.low,
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Premium Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Profiles',
                        hintText: 'Search by name...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.primaryColorLight,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    // Premium Gender Filter
                    Row(
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filter by gender:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedGenderFilter,
                              isExpanded: true,
                              underline: const SizedBox.shrink(),
                              items:
                                  [
                                        'All',
                                        'Male',
                                        'Female',
                                        'Other',
                                        'Unspecified',
                                      ]
                                      .map(
                                        (gender) => DropdownMenuItem(
                                          value: gender,
                                          child: Text(
                                            gender,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGenderFilter = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Profile List Section
            Expanded(
              child: _buildProfileList(
                profilesAsync,
                selectedProfileAsync,
                theme,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddProfile(context),
        tooltip: 'Add New Profile',
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: const Text(
          'Add Profile',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildProfileList(
    AsyncValue<List<FamilyMemberProfile>> profilesAsync,
    AsyncValue<FamilyMemberProfile?> selectedProfileAsync,
    ThemeData theme,
  ) {
    return profilesAsync.when(
      loading: () => Center(
        child: CommonTransitions.fadeSlideIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MicroInteractions.breathingDots(
                color: AppTheme.primaryColorLight,
                dotCount: 3,
                dotSize: 12.0,
              ),
              const SizedBox(height: 24),
              Text(
                'Loading profiles...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error loading profiles',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(simpleProfilesProvider);
                ref.invalidate(simpleSelectedProfileProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (profiles) {
        if (profiles.isEmpty) {
          return Center(
            child: CommonTransitions.fadeSlideIn(
              child: ModernCard(
                medicalTheme: MedicalCardTheme.success,
                elevation: CardElevation.low,
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.family_restroom_rounded,
                        size: 48,
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No profiles yet',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add your first family member profile to get started with managing your family\'s health',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    HealthButton(
                      onPressed: () => _navigateToAddProfile(context),
                      medicalTheme: MedicalButtonTheme.success,
                      size: HealthButtonSize.medium,
                      enableHoverEffect: true,
                      enablePressEffect: true,
                      enableHaptics: true,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_add_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Add First Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final filteredProfiles = _filterProfiles(profiles);

        if (filteredProfiles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No profiles found',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filters',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: StaggerAnimations.staggeredList(
            children: filteredProfiles.map((profile) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: selectedProfileAsync.when(
                  loading: () => ProfileCard(
                    profile: profile,
                    isSelected: false,
                    onTap: () => _selectProfile(profile),
                    onEdit: () => _navigateToEditProfile(context, profile),
                    onDelete: () => _showDeleteConfirmation(context, profile),
                  ),
                  error: (_, __) => ProfileCard(
                    profile: profile,
                    isSelected: false,
                    onTap: () => _selectProfile(profile),
                    onEdit: () => _navigateToEditProfile(context, profile),
                    onDelete: () => _showDeleteConfirmation(context, profile),
                  ),
                  data: (selectedProfile) => ProfileCard(
                    profile: profile,
                    isSelected: selectedProfile?.id == profile.id,
                    onTap: () => _selectProfile(profile),
                    onEdit: () => _navigateToEditProfile(context, profile),
                    onDelete: () => _showDeleteConfirmation(context, profile),
                  ),
                ),
              );
            }).toList(),
            staggerDelay: AppTheme.microDuration,
            direction: StaggerDirection.bottomToTop,
            animationType: StaggerAnimationType.fadeSlide,
          ),
        );
      },
    );
  }

  List<FamilyMemberProfile> _filterProfiles(
    List<FamilyMemberProfile> profiles,
  ) {
    var filteredProfiles = profiles;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredProfiles = filteredProfiles.where((profile) {
        final fullName = '${profile.firstName} ${profile.lastName}'
            .toLowerCase();
        return fullName.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply gender filter
    if (_selectedGenderFilter != 'All') {
      filteredProfiles = filteredProfiles.where((profile) {
        return profile.gender == _selectedGenderFilter;
      }).toList();
    }

    return filteredProfiles;
  }

  void _selectProfile(FamilyMemberProfile profile) {
    ref.read(setSelectedProfileProvider).call(profile.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected ${profile.firstName} ${profile.lastName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToAddProfile(BuildContext context) {
    context.push(AppRoutes.profileForm);
  }

  void _navigateToEditProfile(
    BuildContext context,
    FamilyMemberProfile profile,
  ) {
    context.push(AppRoutes.profileForm, extra: profile);
  }

  void _showDeleteConfirmation(
    BuildContext context,
    FamilyMemberProfile profile,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Profile'),
          content: Text(
            'Are you sure you want to delete ${profile.firstName} ${profile.lastName}\'s profile? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final profileService = ref.read(simpleProfileServiceProvider);
                  await profileService.deleteProfile(profile.id);
                  // Invalidate providers to refresh data
                  ref.invalidate(simpleProfilesProvider);
                  ref.invalidate(simpleSelectedProfileProvider);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Deleted ${profile.firstName} ${profile.lastName}\'s profile',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting profile: $e'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
