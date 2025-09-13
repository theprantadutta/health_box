import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/profile_providers.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/theme/app_theme.dart';
import '../widgets/profile_card.dart';
import 'profile_form_screen.dart';

class ProfileListScreen extends ConsumerStatefulWidget {
  const ProfileListScreen({super.key});

  @override
  ConsumerState<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends ConsumerState<ProfileListScreen>
    with TickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedGenderFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _staggerController;
  late List<Animation<double>> _staggerAnimations;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _staggerAnimations = List.generate(6, (index) {
      final start = index * 0.1;
      final end = start + 0.6;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final profileNotifier = ref.read(profileNotifierProvider.notifier);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _staggerAnimations[0],
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (_staggerAnimations[0].value * 0.2),
              child: Opacity(
                opacity: _staggerAnimations[0].value,
                child: const Text(
                  'Family Profiles',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black26,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.getHealthContextGradient(
              'heart',
              isDark: isDarkMode,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: _staggerAnimations[0],
            builder: (context, child) {
              return Transform.scale(
                scale: _staggerAnimations[0].value,
                child: IconButton(
                  icon: const Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => _navigateToAddProfile(context),
                  tooltip: 'Add New Profile',
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => profileNotifier.loadProfiles(),
        child: Column(
          children: [
            // Premium Search and Filter Section
            AnimatedBuilder(
              animation: _staggerAnimations[1],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - _staggerAnimations[1].value)),
                  child: Opacity(
                    opacity: _staggerAnimations[1].value,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Premium Search Bar
                          ModernCard(
                            elevation: CardElevation.low,
                            enableFloatingEffect: true,
                            padding: const EdgeInsets.all(4),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search family members...',
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: AppTheme.getHealthContextGradient(
                                    'heart',
                                    isDark: isDarkMode,
                                  ).colors.first,
                                ),
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
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Premium Gender Filter
                          ModernCard(
                            elevation: CardElevation.low,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.getHealthContextGradient(
                                      'heart',
                                      isDark: isDarkMode,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.filter_list_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('Filter by: '),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedGenderFilter,
                                      isExpanded: true,
                                      style: theme.textTheme.bodyMedium,
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
                                                  child: Text(gender),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Profile List Section
            Expanded(child: _buildProfileList(profileState, profileNotifier)),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _staggerAnimations[5],
        builder: (context, child) {
          return Transform.scale(
            scale: _staggerAnimations[5].value,
            child: PremiumButton(
              onPressed: () => _navigateToAddProfile(context),
              style: PremiumButtonStyle.gradient,
              healthContext: 'heart',
              enableParticleEffect: true,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Add Family Member',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileList(ProfileState state, ProfileNotifier notifier) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            AppTheme.getHealthContextGradient(
              'heart',
              isDark: isDarkMode,
            ).colors.first,
          ),
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading profiles',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                notifier.clearError();
                notifier.loadProfiles();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.family_restroom,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No profiles yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first family member profile to get started',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddProfile(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Add First Profile'),
            ),
          ],
        ),
      );
    }

    final filteredProfiles = _filterProfiles(state.profiles);

    if (filteredProfiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No profiles found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredProfiles.length,
      itemBuilder: (context, index) {
        final profile = filteredProfiles[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProfileCard(
            profile: profile,
            isSelected: state.selectedProfile?.id == profile.id,
            onTap: () => _selectProfile(notifier, profile),
            onEdit: () => _navigateToEditProfile(context, profile),
            onDelete: () => _showDeleteConfirmation(context, notifier, profile),
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

  void _selectProfile(ProfileNotifier notifier, FamilyMemberProfile profile) {
    notifier.selectProfile(profile);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected ${profile.firstName} ${profile.lastName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToAddProfile(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ProfileFormScreen()));
  }

  void _navigateToEditProfile(
    BuildContext context,
    FamilyMemberProfile profile,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileFormScreen(profile: profile),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ProfileNotifier notifier,
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
              onPressed: () {
                Navigator.of(context).pop();
                notifier.deleteProfile(profile.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Deleted ${profile.firstName} ${profile.lastName}\'s profile',
                    ),
                  ),
                );
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
