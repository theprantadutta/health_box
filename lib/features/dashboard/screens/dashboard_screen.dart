import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/simple_profile_providers.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/navigation/app_router.dart';
import '../widgets/upcoming_reminders_widget.dart';
import '../widgets/recent_activity_widget.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/animations/stagger_animations.dart';
import '../../../shared/animations/common_transitions.dart';
import '../../../shared/theme/app_theme.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profilesAsync = ref.watch(simpleProfilesProvider);
    final selectedProfileAsync = ref.watch(simpleSelectedProfileProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh the simple providers
          ref.invalidate(simpleProfilesProvider);
          ref.invalidate(simpleSelectedProfileProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Premium gradient app bar
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: theme.colorScheme.primary,
              surfaceTintColor: Colors.transparent,
              title: Text(
                'HealthBox',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.search_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  onPressed: () => _showSearchDialog(context),
                  tooltip: 'Search',
                ),
                IconButton(
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  onPressed: () => context.push(AppRoutes.reminders),
                  tooltip: 'Notifications',
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Main content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Hero section - welcome
                  _buildHeroSection(selectedProfileAsync, profilesAsync),
                  const SizedBox(height: 20),

                  // Statistics overview
                  _buildStatsSection(),
                  const SizedBox(height: 20),

                  // Quick actions
                  _buildQuickActionsSection(),
                  const SizedBox(height: 20),

                  // Activity section
                  _buildActivitySection(),

                  const SizedBox(height: 120), // FAB space
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeroSection(
    AsyncValue<FamilyMemberProfile?> selectedProfileAsync,
    AsyncValue<List<FamilyMemberProfile>> profilesAsync,
  ) {
    final theme = Theme.of(context);

    return selectedProfileAsync.when(
      loading: () => CommonTransitions.fadeIn(
        child: ModernCard(
          medicalTheme: MedicalCardTheme.primary,
          elevation: CardElevation.low,
          padding: const EdgeInsets.all(24),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Loading...'),
              SizedBox(height: 20),
              Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
      error: (error, stack) => CommonTransitions.fadeSlideIn(
        child: ModernCard(
          medicalTheme: MedicalCardTheme.primary,
          elevation: CardElevation.medium,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'HealthBox',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your family\'s health management hub',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (selectedProfile) => CommonTransitions.fadeSlideIn(
        child: ModernCard(
          medicalTheme: MedicalCardTheme.primary,
          elevation: CardElevation.medium,
          enableHoverEffect: true,
          padding: const EdgeInsets.all(24),
          enablePressEffect: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedProfile != null
                              ? 'Welcome back,'
                              : 'Welcome to',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedProfile != null
                              ? selectedProfile.firstName
                              : 'HealthBox',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedProfile != null
                              ? 'Managing health for ${selectedProfile.firstName} ${selectedProfile.lastName}'
                              : 'Your family\'s health management hub',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedProfile != null)
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${selectedProfile.firstName[0]}${selectedProfile.lastName[0]}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () =>
                              _showProfileSelector(context, profilesAsync),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.swap_horiz_rounded,
                              color: theme.colorScheme.onPrimaryContainer,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              if (selectedProfile == null) ...[
                const SizedBox(height: 24),
                profilesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Error loading profiles',
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  data: (profiles) => profiles.isEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Get started by adding your first family member',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            HealthButton(
                              onPressed: () => context.push(AppRoutes.profiles),
                              medicalTheme: MedicalButtonTheme.primary,
                              size: HealthButtonSize.medium,
                              enableHoverEffect: true,
                              enablePressEffect: true,
                              enableHaptics: true,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.person_add_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Add Family Member',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select a family member:',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: profiles.map((profile) {
                                return InkWell(
                                  onTap: () {
                                    ref
                                        .read(setSelectedProfileProvider)
                                        .call(profile.id);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.colorScheme.outline
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: theme
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.1),
                                          child: Text(
                                            profile.firstName[0],
                                            style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${profile.firstName} ${profile.lastName}',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
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
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final theme = Theme.of(context);
    final profilesAsync = ref.watch(simpleProfilesProvider);
    final medicalRecordsAsync = ref.watch(allMedicalRecordsProvider);

    final stats = [
      _StatItem(
        label: 'Family Members',
        value: profilesAsync.when(
          loading: () => '-',
          error: (_, __) => '0',
          data: (profiles) => profiles.length.toString(),
        ),
        icon: Icons.people_rounded,
        color: const Color(0xFF6366F1), // Indigo
      ),
      _StatItem(
        label: 'Medical Records',
        value: medicalRecordsAsync.when(
          loading: () => '-',
          error: (_, __) => '0',
          data: (records) => records.length.toString(),
        ),
        icon: Icons.description_rounded,
        color: const Color(0xFF059669), // Emerald
      ),
      _StatItem(
        label: 'Active Reminders',
        value: '0',
        icon: Icons.notifications_active_rounded,
        color: const Color(0xFFF59E0B), // Amber
      ),
      _StatItem(
        label: 'This Month',
        value: '0',
        icon: Icons.calendar_today_rounded,
        color: const Color(0xFFEF4444), // Red
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCard(stats[0])),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(stats[1])),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard(stats[2])),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(stats[3])),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(_StatItem stat) {
    final theme = Theme.of(context);

    return ModernCard(
      elevation: CardElevation.low,
      enableHoverEffect: true,
      hoverElevation: CardElevation.medium,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(stat.icon, color: stat.color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stat.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  stat.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    final theme = Theme.of(context);

    final actions = [
      _QuickAction(
        title: 'Add Record',
        icon: Icons.medical_information_rounded,
        color: const Color(0xFF8B5CF6), // Purple
        onTap: () {
          print('Add Record clicked');
          context.push(AppRoutes.medicalRecords);
        },
      ),
      _QuickAction(
        title: 'Set Reminder',
        icon: Icons.alarm_add_rounded,
        color: const Color(0xFF06B6D4), // Cyan
        onTap: () {
          print('Set Reminder clicked');
          context.push(AppRoutes.reminders);
        },
      ),
      _QuickAction(
        title: 'Scan Document',
        icon: Icons.document_scanner_rounded,
        color: const Color(0xFFF97316), // Orange
        onTap: () {
          print('Scan Document clicked');
          context.push(AppRoutes.ocrScan);
        },
      ),
      _QuickAction(
        title: 'Track Vitals',
        icon: Icons.favorite_rounded,
        color: const Color(0xFFEC4899), // Pink
        onTap: () {
          print('Track Vitals clicked');
          _handleQuickVitalsNavigation(context);
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        StaggerAnimations.staggeredGrid(
          children: actions.map((action) => _buildActionCard(action)).toList(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          staggerDelay: AppTheme.microDuration,
        ),
      ],
    );
  }

  Widget _buildActionCard(_QuickAction action) {
    final theme = Theme.of(context);

    return ModernCard(
      elevation: CardElevation.low,
      enableHoverEffect: true,
      hoverElevation: CardElevation.medium,
      padding: const EdgeInsets.all(14),
      onTap: action.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(action.icon, color: action.color, size: 22),
          ),
          Text(
            action.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        // Reminders and Recent Activity with consistent design
        CommonTransitions.fadeSlideIn(
          direction: const Offset(0, 40),
          child: ModernCard(
            elevation: CardElevation.low,
            enableHoverEffect: true,
            hoverElevation: CardElevation.medium,
            padding: const EdgeInsets.all(20),
            child: const UpcomingRemindersWidget(),
          ),
        ),
        const SizedBox(height: 16),
        CommonTransitions.fadeSlideIn(
          direction: const Offset(0, 40),
          child: ModernCard(
            elevation: CardElevation.low,
            enableHoverEffect: true,
            hoverElevation: CardElevation.medium,
            padding: const EdgeInsets.all(20),
            child: const RecentActivityWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickAddDialog(context),
      tooltip: 'Quick Add',
      icon: const Icon(Icons.add_rounded, size: 20),
      label: const Text(
        'Quick Add',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Search'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search medical records, profiles...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Global search will be available in a future update.'),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Quick Add',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              _buildQuickAddOption(
                context,
                Icons.person_add_rounded,
                'Add Family Member',
                () {
                  Navigator.of(context).pop();
                  context.push(AppRoutes.profiles);
                },
              ),
              _buildQuickAddOption(
                context,
                Icons.medical_information_rounded,
                'Add Medical Record',
                () {
                  Navigator.of(context).pop();
                  context.push(AppRoutes.medicalRecords);
                },
              ),
              _buildQuickAddOption(
                context,
                Icons.medication_rounded,
                'Add Medication',
                () {
                  Navigator.of(context).pop();
                  context.push(AppRoutes.medicalRecords);
                },
              ),
              _buildQuickAddOption(
                context,
                Icons.alarm_add_rounded,
                'Set Reminder',
                () {
                  Navigator.of(context).pop();
                  context.push(AppRoutes.reminders);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileSelector(
    BuildContext context,
    AsyncValue<List<dynamic>> profilesAsync,
  ) {
    profilesAsync.when(
      loading: () {},
      error: (_, __) {},
      data: (profiles) {
        if (profiles.isEmpty) return;

        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Select Profile',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                ...profiles.map(
                  (profile) => _buildProfileOption(context, profile),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    FamilyMemberProfile profile,
  ) {
    final theme = Theme.of(context);
    final selectedProfileAsync = ref.watch(simpleSelectedProfileProvider);
    final isSelected = selectedProfileAsync.maybeWhen(
      data: (selectedProfile) => selectedProfile?.id == profile.id,
      orElse: () => false,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          ref.read(setSelectedProfileProvider).call(profile.id);
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1), // Professional indigo
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${profile.firstName[0]}${profile.lastName[0]}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile.firstName} ${profile.lastName}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                    ),
                    Text(
                      'Age ${DateTime.now().year - profile.dateOfBirth.year}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleQuickVitalsNavigation(BuildContext context) {
    // Simple navigation - go directly to vitals tracking screen
    // The vitals screen should handle profile selection if needed
    context.push(AppRoutes.vitalsTracking);
  }
}

class _QuickAction {
  const _QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}
