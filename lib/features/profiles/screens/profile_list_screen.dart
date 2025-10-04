import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/simple_profile_providers.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/animations/common_transitions.dart';
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
      body: CustomScrollView(
        slivers: [
          // Dashboard-style app bar
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: HealthBoxDesignSystem.medicalBlue,
                boxShadow: [
                  BoxShadow(
                    color: HealthBoxDesignSystem.medicalBlue.colors.first
                        .withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
            title: Text(
              'Family Profiles',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.tune_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                onPressed: _showFilterBottomSheet,
                tooltip: 'Filter Profiles',
              ),
              IconButton(
                icon: Icon(
                  Icons.add_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                onPressed: () => _navigateToAddProfile(context),
                tooltip: 'Add New Profile',
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Profile List
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search profiles...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),

          _buildProfileList(
            profilesAsync,
            selectedProfileAsync,
            theme,
          ),
        ],
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
      loading: () => SliverFillRemaining(
        child: Center(
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
      ),
      error: (error, stack) => SliverFillRemaining(
        child: Center(
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
      ),
      data: (profiles) {
        if (profiles.isEmpty) {
          return SliverFillRemaining(
            child: Center(
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
            ),
          );
        }

        final filteredProfiles = _filterProfiles(profiles);

        if (filteredProfiles.isEmpty) {
          return SliverFillRemaining(
            child: Center(
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
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final profile = filteredProfiles[index];
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
              },
              childCount: filteredProfiles.length,
            ),
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: HealthBoxDesignSystem.medicalPurple,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: HealthBoxDesignSystem.coloredShadow(
                          HealthBoxDesignSystem.medicalPurple.colors.first,
                          opacity: 0.3,
                        ),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter Profiles',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Customize your view',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedGenderFilter = 'All';
                        });
                        context.pop();
                      },
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Filters content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Gender Filter
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Gender',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['All', 'Male', 'Female', 'Other', 'Unspecified']
                          .map((gender) {
                        final isSelected = _selectedGenderFilter == gender;
                        return FilterChip(
                          label: Text(gender),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedGenderFilter = gender;
                            });
                          },
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          selectedColor: theme.colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          checkmarkColor: theme.colorScheme.primary,
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            width: 1,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Apply button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                context.pop();
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
