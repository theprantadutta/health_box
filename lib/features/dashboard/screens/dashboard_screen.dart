import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/profile_providers.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../widgets/upcoming_reminders_widget.dart';
import '../widgets/recent_activity_widget.dart';
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
    final isDarkMode = theme.brightness == Brightness.dark;
    final profileState = ref.watch(profileNotifierProvider);
    final profilesAsync = ref.watch(allProfilesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern Gradient App Bar
          SliverAppBar(
            expandedHeight: AppTheme.isMobile(context) ? 120 : 160,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'HealthBox',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppTheme.isMobile(context) ? 20 : 24,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.getPrimaryGradient(isDarkMode),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                      ],
                    ),
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
                onPressed: () => context.push(AppRoutes.reminders),
                tooltip: 'Notifications',
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content with responsive layout
          SliverPadding(
            padding: AppTheme.getResponsivePadding(context),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Welcome Section
                _buildWelcomeSection(profileState, profilesAsync),
                const SizedBox(height: 24),

                // Quick Actions & Stats Row (Desktop/Tablet)
                if (AppTheme.isDesktop(context) || AppTheme.isTablet(context))
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildQuickActions(),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: _buildStatisticsOverview(),
                      ),
                    ],
                  )
                else ...[
                  // Mobile: Stack vertically
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildStatisticsOverview(),
                ],
                
                const SizedBox(height: 24),

                // Reminders and Activity Row (Desktop/Tablet)
                if (AppTheme.isDesktop(context) || AppTheme.isTablet(context))
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(child: UpcomingRemindersWidget()),
                      const SizedBox(width: 24),
                      const Expanded(child: RecentActivityWidget()),
                    ],
                  )
                else ...[
                  // Mobile: Stack vertically
                  const UpcomingRemindersWidget(),
                  const SizedBox(height: 24),
                  const RecentActivityWidget(),
                ],

                const SizedBox(height: 100), // Space for floating action button
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildWelcomeSection(ProfileState profileState, AsyncValue<List<dynamic>> profilesAsync) {
    final selectedProfile = profileState.selectedProfile;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ModernCard(
      elevation: CardElevation.low,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: selectedProfile != null 
                      ? AppTheme.getSuccessGradient()
                      : AppTheme.getPrimaryGradient(isDarkMode),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  selectedProfile != null ? Icons.waving_hand : Icons.family_restroom,
                  color: Colors.white,
                  size: AppTheme.isMobile(context) ? 24 : 28,
                ),
              ),
              const SizedBox(width: 16),
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
                        fontSize: AppTheme.isMobile(context) ? 20 : 24,
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.getPrimaryGradient(isDarkMode),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.getCardShadow(isDarkMode),
                  ),
                  child: Center(
                    child: Text(
                      '${selectedProfile.firstName[0]}${selectedProfile.lastName[0]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (selectedProfile == null) ...[
            const SizedBox(height: 24),
            profilesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => ModernCard(
                color: theme.colorScheme.errorContainer,
                elevation: CardElevation.none,
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Error loading profiles: $error',
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
              data: (profiles) => profiles.isEmpty
                  ? Column(
                      children: [
                        Text(
                          'No profiles created yet. Add your first family member to get started.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        GradientButton(
                          onPressed: () => context.push(AppRoutes.profiles),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_add, size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Add Family Member'),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select a family member to personalize your dashboard:',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profiles.map((profile) {
                            return GestureDetector(
                              onTap: () {
                                ref.read(profileNotifierProvider.notifier).selectProfile(profile);
                              },
                              child: ModernCard(
                                elevation: CardElevation.low,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: theme.colorScheme.primary,
                                      child: Text(
                                        '${profile.firstName[0]}',
                                        style: TextStyle(
                                          color: theme.colorScheme.onPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${profile.firstName} ${profile.lastName}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final actions = [
      _QuickAction(
        title: 'Add Record',
        subtitle: 'Medical record',
        icon: Icons.medical_information,
        gradient: AppTheme.getPrimaryGradient(isDarkMode),
        onTap: () => context.push(AppRoutes.medicalRecords),
      ),
      _QuickAction(
        title: 'Set Reminder',
        subtitle: 'Medication alert',
        icon: Icons.notifications_active,
        gradient: AppTheme.getWarningGradient(),
        onTap: () => context.push(AppRoutes.reminders),
      ),
      _QuickAction(
        title: 'Scan Document',
        subtitle: 'OCR prescription',
        icon: Icons.document_scanner,
        gradient: AppTheme.getSuccessGradient(),
        onTap: () => context.push(AppRoutes.ocrScan),
      ),
      _QuickAction(
        title: 'Track Vitals',
        subtitle: 'Health metrics',
        icon: Icons.favorite,
        gradient: AppTheme.getErrorGradient(),
        onTap: () => context.push('${AppRoutes.vitalsTracking}?profileId='),
      ),
    ];

    return ModernCard(
      elevation: CardElevation.low,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flash_on,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (AppTheme.isMobile(context))
            // Mobile: 2x2 grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) => _buildQuickActionCard(actions[index]),
            )
          else
            // Desktop/Tablet: Single row
            Row(
              children: actions
                  .map((action) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildQuickActionCard(action),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(_QuickAction action) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: action.gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.getCardShadow(theme.brightness == Brightness.dark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              action.icon,
              color: Colors.white,
              size: AppTheme.isMobile(context) ? 28 : 32,
            ),
            const SizedBox(height: 8),
            Text(
              action.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              action.subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.getPrimaryGradient(isDarkMode),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.getElevatedShadow(isDarkMode),
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showQuickAddDialog(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Quick Add',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildStatisticsOverview() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final profilesAsync = ref.watch(allProfilesProvider);
    final medicalRecordsAsync = ref.watch(allMedicalRecordsProvider);

    final stats = [
      _StatItem(
        label: 'Family Members',
        value: profilesAsync.when(
          loading: () => '-',
          error: (_, __) => '0',
          data: (profiles) => profiles.length.toString(),
        ),
        icon: Icons.family_restroom,
        gradient: AppTheme.getPrimaryGradient(isDarkMode),
      ),
      _StatItem(
        label: 'Medical Records',
        value: medicalRecordsAsync.when(
          loading: () => '-',
          error: (_, __) => '0',
          data: (records) => records.length.toString(),
        ),
        icon: Icons.medical_information,
        gradient: AppTheme.getSuccessGradient(),
      ),
      _StatItem(
        label: 'Active Reminders',
        value: '0', // Will be populated when reminder system is integrated
        icon: Icons.notifications_active,
        gradient: AppTheme.getWarningGradient(),
      ),
      _StatItem(
        label: 'This Month',
        value: '0', // Will show activity count
        icon: Icons.calendar_month,
        gradient: AppTheme.getErrorGradient(),
      ),
    ];

    return ModernCard(
      elevation: CardElevation.low,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics,
                  color: theme.colorScheme.onSecondaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Health Overview',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (AppTheme.isMobile(context))
            // Mobile: 2x2 grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) => _buildStatCard(stats[index]),
            )
          else
            // Desktop/Tablet: Single row
            Row(
              children: stats
                  .map((stat) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: _buildStatCard(stat),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(_StatItem stat) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(AppTheme.isMobile(context) ? 12 : 16),
      decoration: BoxDecoration(
        gradient: stat.gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.getCardShadow(theme.brightness == Brightness.dark),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            stat.icon,
            color: Colors.white,
            size: AppTheme.isMobile(context) ? 28 : 32,
          ),
          const SizedBox(height: 12),
          Text(
            stat.value,
            style: TextStyle(
              fontSize: AppTheme.isMobile(context) ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
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

class _QuickAction {
  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
}