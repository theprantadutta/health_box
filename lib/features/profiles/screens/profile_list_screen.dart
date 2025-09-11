import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/profile_providers.dart';
import '../widgets/profile_card.dart';
import 'profile_form_screen.dart';

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
    final profileState = ref.watch(profileNotifierProvider);
    final profileNotifier = ref.read(profileNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Profiles'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddProfile(context),
            tooltip: 'Add New Profile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => profileNotifier.loadProfiles(),
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search profiles...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Gender Filter
                  Row(
                    children: [
                      const Text('Filter by gender: '),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedGenderFilter,
                          isExpanded: true,
                          items: ['All', 'Male', 'Female', 'Other', 'Unspecified']
                              .map((gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGenderFilter = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Profile List Section
            Expanded(
              child: _buildProfileList(profileState, profileNotifier),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddProfile(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Profile'),
      ),
    );
  }

  Widget _buildProfileList(ProfileState state, ProfileNotifier notifier) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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

  List<FamilyMemberProfile> _filterProfiles(List<FamilyMemberProfile> profiles) {
    var filteredProfiles = profiles;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredProfiles = filteredProfiles.where((profile) {
        final fullName = '${profile.firstName} ${profile.lastName}'.toLowerCase();
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileFormScreen(),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context, FamilyMemberProfile profile) {
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
                    content: Text('Deleted ${profile.firstName} ${profile.lastName}\'s profile'),
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