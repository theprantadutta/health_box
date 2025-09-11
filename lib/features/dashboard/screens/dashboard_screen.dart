import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/profile_providers.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../widgets/upcoming_reminders_widget.dart';
import '../widgets/recent_activity_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../../profiles/screens/profile_list_screen.dart';
import '../../medical_records/screens/medical_record_list_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileNotifierProvider.notifier).loadProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(profileNotifierProvider);
    final profilesAsync = ref.watch(allProfilesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'HealthBox',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _showSearchDialog(context),
                tooltip: 'Search',
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification center - Coming in Phase 3.9'),
                    ),
                  );
                },
                tooltip: 'Notifications',
              ),
            ],
          ),

          // Welcome Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _buildWelcomeSection(profileState, profilesAsync),
            ),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const QuickActionsWidget(),
            ),
          ),

          // Upcoming Reminders
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const UpcomingRemindersWidget(),
            ),
          ),

          // Recent Activity
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const RecentActivityWidget(),
            ),
          ),

          // Statistics Overview
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _buildStatisticsOverview(),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 80), // Space for floating action button
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Quick Add'),
      ),
    );
  }

  Widget _buildWelcomeSection(ProfileState profileState, AsyncValue<List<dynamic>> profilesAsync) {
    final selectedProfile = profileState.selectedProfile;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selectedProfile != null ? Icons.waving_hand : Icons.family_restroom,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedProfile != null
                            ? 'Welcome back, ${selectedProfile.firstName}!'
                            : 'Welcome to HealthBox',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedProfile != null
                            ? 'Managing health for ${selectedProfile.firstName} ${selectedProfile.lastName}'
                            : 'Your family\'s health management hub',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedProfile != null)
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      '${selectedProfile.firstName[0]}${selectedProfile.lastName[0]}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (selectedProfile == null) ...[
              const SizedBox(height: 16),
              profilesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error loading profiles: $error'),
                data: (profiles) => profiles.isEmpty
                    ? Column(
                        children: [
                          const Text('No profiles created yet. Add your first family member to get started.'),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ProfileListScreen(),
                              ),
                            ),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Family Member'),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          const Text('Select a family member to personalize your dashboard:'),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: profiles.length,
                              itemBuilder: (context, index) {
                                final profile = profiles[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: ActionChip(
                                    avatar: CircleAvatar(
                                      backgroundColor: theme.colorScheme.primary,
                                      child: Text(
                                        '${profile.firstName[0]}',
                                        style: TextStyle(
                                          color: theme.colorScheme.onPrimary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    label: Text('${profile.firstName} ${profile.lastName}'),
                                    onPressed: () {
                                      ref.read(profileNotifierProvider.notifier).selectProfile(profile);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsOverview() {
    final theme = Theme.of(context);
    final profilesAsync = ref.watch(allProfilesProvider);
    final medicalRecordsAsync = ref.watch(allMedicalRecordsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Family Members',
                    profilesAsync.when(
                      loading: () => '-',
                      error: (_, __) => '0',
                      data: (profiles) => profiles.length.toString(),
                    ),
                    Icons.family_restroom,
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Medical Records',
                    medicalRecordsAsync.when(
                      loading: () => '-',
                      error: (_, __) => '0',
                      data: (records) => records.length.toString(),
                    ),
                    Icons.medical_information,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Active Reminders',
                    '0', // Will be populated when reminder system is integrated
                    Icons.notifications_active,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'This Month',
                    '0', // Will show activity count
                    Icons.calendar_month,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search medical records, profiles...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Global search will be available in Phase 3.8 with the SearchService implementation.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showQuickAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Add',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Add Family Member'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_information),
              title: const Text('Add Medical Record'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MedicalRecordListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.medication),
              title: const Text('Add Medication'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigate to medication form - T057 already implemented'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Set Reminder'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reminder forms coming in Phase 3.9'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}