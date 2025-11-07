import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/simple_profile_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_loading.dart';
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

    return Scaffold(
      backgroundColor: context.colorScheme.surfaceContainerLowest,
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
                boxShadow: AppElevation.coloredShadow(
                  HealthBoxDesignSystem.medicalBlue.colors.first,
                  opacity: 0.3,
                ),
              ),
            ),
            title: Text(
              'Family Profiles',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: AppTypography.fontWeightBold,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                ),
                onPressed: _showFilterBottomSheet,
                tooltip: 'Filter Profiles',
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                ),
                onPressed: () => _navigateToAddProfile(context),
                tooltip: 'Add New Profile',
              ),
              SizedBox(width: AppSpacing.sm),
            ],
          ),

          // Profile List
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.base),
              child: HBTextField.filled(
                controller: _searchController,
                hint: 'Search profiles...',
                prefix: Icon(
                  Icons.search_rounded,
                  color: context.colorScheme.primary,
                  size: AppSizes.iconSm,
                ),
                suffix: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: context.colorScheme.onSurfaceVariant,
                          size: AppSizes.iconSm,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
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
  ) {
    return profilesAsync.when(
      loading: () => const SliverFillRemaining(
        child: HBLoading.circular(),
      ),
      error: (error, stack) => SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: context.responsivePadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: AppSizes.iconXl * 1.5,
                  color: AppColors.error,
                ),
                SizedBox(height: AppSpacing.base),
                Text(
                  'Error loading profiles',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: AppTypography.fontWeightBold,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppSpacing.base),
                HBButton.primary(
                  text: 'Retry',
                  icon: Icons.refresh,
                  onPressed: () {
                    ref.invalidate(simpleProfilesProvider);
                    ref.invalidate(simpleSelectedProfileProvider);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      data: (profiles) {
        if (profiles.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: context.responsivePadding * 2,
                child: HBCard.elevated(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.base),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.family_restroom_rounded,
                          size: AppSizes.iconXl,
                          color: AppColors.success,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      Text(
                        'No profiles yet',
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: AppTypography.fontWeightBold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Add your first family member profile to get started with managing your family\'s health',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      HBButton.primary(
                        text: 'Add First Profile',
                        icon: Icons.person_add_rounded,
                        onPressed: () => _navigateToAddProfile(context),
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
              child: Padding(
                padding: context.responsivePadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: AppSizes.iconXl * 1.5,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: AppSpacing.base),
                    Text(
                      'No profiles found',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: AppTypography.fontWeightBold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Try adjusting your search or filters',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.sm,
            AppSpacing.base,
            96,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final profile = filteredProfiles[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.base),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
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
                margin: EdgeInsets.only(
                  top: AppSpacing.md,
                  bottom: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.base,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm + 2),
                      decoration: BoxDecoration(
                        gradient: HealthBoxDesignSystem.medicalPurple,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        boxShadow: AppElevation.coloredShadow(
                          HealthBoxDesignSystem.medicalPurple.colors.first,
                          opacity: 0.3,
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: AppSizes.iconMd,
                      ),
                    ),
                    SizedBox(width: AppSpacing.base),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter Profiles',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: AppTypography.fontWeightBold,
                            ),
                          ),
                          Text(
                            'Customize your view',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    HBButton.text(
                      text: 'Reset',
                      onPressed: () {
                        setState(() {
                          _selectedGenderFilter = 'All';
                        });
                        context.pop();
                      },
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Filters content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(AppSpacing.xl),
                  children: [
                    // Gender Filter
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: AppSizes.iconSm,
                          color: context.colorScheme.primary,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Gender',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: AppTypography.fontWeightBold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
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
                          backgroundColor: context.colorScheme.surfaceContainerHighest,
                          selectedColor: context.colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? context.colorScheme.primary
                                : context.colorScheme.onSurface,
                            fontWeight: isSelected
                                ? AppTypography.fontWeightSemiBold
                                : AppTypography.fontWeightMedium,
                          ),
                          checkmarkColor: context.colorScheme.primary,
                          side: BorderSide(
                            color: isSelected
                                ? context.colorScheme.primary
                                : context.colorScheme.outlineVariant,
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
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: HBButton.primary(
                    text: 'Apply Filters',
                    onPressed: () => context.pop(),
                    isExpanded: true,
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
            HBButton.text(
              text: 'Cancel',
              onPressed: () => context.pop(),
            ),
            HBButton.text(
              text: 'Delete',
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
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              textColor: AppColors.error,
            ),
          ],
        );
      },
    );
  }
}
